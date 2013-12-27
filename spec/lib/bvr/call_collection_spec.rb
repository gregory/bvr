require_relative '../../spec_helper'
require_relative "../../helpers/faraday_stub"

describe Bvr::CallCollection do

  describe '.find(customer_id, options={})' do
    let(:customer_id) { 'john' }
    let(:params) { { command: Bvr::CallCollection::API_COMMANDS[:find_by_customer_id], customer: customer_id } }
    let(:connection) { Minitest::Mock.new }

    before { Bvr.connection = connection }

    subject{ Bvr::CallCollection.find_by_customer_id(customer_id) }

    it 'sets the right command and the customer_id' do
      connection.expect :get, {},  [params] #.merge({username: Bvr.config.username, password: Bvr.config.password})]
      subject
      connection.verify
    end

    describe 'when options are provided' do
      let(:options) { { recordcount: 'bar', callid: 'foo' }.merge(params) }

      subject{ Bvr::CallCollection.find_by_customer_id(customer_id, options) }

      it 'merges the CallOverview command and the customer_id with options' do
        connection.expect :get, {},  [options]
        subject
        connection.verify
      end
    end

    describe 'when wrong options are provided' do
      let(:options) { { foo: 'bar', john: 'Doe' }.merge(params) }

      subject{ Bvr::CallCollection.find_by_customer_id(customer_id, options) }

      it 'raise an ArgumentError' do
        proc {subject}.must_raise ArgumentError
      end
    end

    describe 'when there is a response' do
      include FaradayStub

      let(:response) do
        File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/calloverview.xml'))
      end

      subject{ Bvr::CallCollection.find_by_customer_id(customer_id) }

      before do
        faraday_adapter.get(Bvr::Connection.uri_from_h(params)) { [200, {}, response] }
      end

      it 'created a new Bvr::CallCollection from the response' do
        subject.must_be_instance_of Bvr::CallCollection
      end

      it 'sets the total calls' do
        subject.count.must_equal 10
      end

      it 'can tell if there is more data' do
        subject.next?.must_equal false
      end

      it 'sets a collection of Call' do
        subject.collection.must_be_instance_of Array
        subject.collection.size.must_equal 5
      end
    end

    describe 'when there is not response' do
      let(:connection) { Minitest::Mock.new }
      let(:customer_id) { 'foo' }
      let(:params) { { command: Bvr::CallCollection::API_COMMANDS[:find_by_customer_id], customer: customer_id } }

      subject { Bvr::CallCollection.find_by_customer_id(customer_id) }

      before do
        Bvr.connection = connection
      end

      it 'returns empty array' do
        connection.expect(:get, {}, [params])
        subject.must_equal []
        connection.verify
      end
    end
  end

  describe '#count' do
    let(:raw_count) { '20' }
    let(:call_collection) {Bvr::CallCollection.new}

    subject { call_collection.count }

    it 'returns the number of counts' do
      call_collection.stub(:raw_count, raw_count) do
        subject.must_equal Integer(raw_count)
      end
    end
  end

  describe '#next?' do
    let(:raw_more_data) { 'True' }
    let(:call_collection) {Bvr::CallCollection.new}

    subject { call_collection.next? }

    it 'says if there is more data' do
      call_collection.stub(:raw_more_data, raw_more_data) do
        subject.must_equal true
      end
    end
  end
end


