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

      #it 'parse the response to objects' do
          #subject.must_be_instance_of Bvr::CallOverview
          #subject.calls.size.must_equal 5
          #subject.count.must_equal 10

          #subject.calls[0].tap do |call|
            #start_time = Time.parse("2013-12-24 18:05:26  (UTC)")
            #call.id.must_equal "1234567890"
            #call.calltype.must_equal "PSTNOutSip"
            #call.start_time.must_equal start_time
            #call.dest.must_be_instance_of Bvr::Phone
            #call.dest.number.must_equal "+32123456788"
            #call.duration.must_equal "00:02:21"
            #call.relative_duration.must_equal Time.parse("00:02:21", start_time)
            #call.charge.must_equal "0.0705"
          #end
        #end
      #end
    end
  end
end


