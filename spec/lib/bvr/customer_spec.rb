require_relative "../../spec_helper"
require_relative "../../helpers/faraday_stub"

describe Bvr::Customer do
  include FaradayStub

  describe '.find(id)' do
    let(:connection) { Minitest::Mock.new }
    let(:id) { 'foo' }
    let(:params) { { command: Bvr::Customer::API_COMMANDS[:find_by_id], customer: id } }

    subject { Bvr::Customer.find(id) }

    it 'calls the api with the right params' do
      Bvr.connection = connection
      Bvr::Customer.stub(:new_from_response, nil) do
        connection.expect :get, {}, [params]
        subject
        connection.verify
      end
    end

    describe 'when there is a response' do
      let(:response) do
        File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/getuserinfo.xml'))
      end

      before do
        faraday_adapter.get(Bvr::Connection.uri_from_h(params)) { [200, {}, response] }
      end

      it 'creates a new Bvr::Customer from the response' do
        subject.must_be_instance_of Bvr::Customer
      end
    end
  end

  describe '.new_from_response(h)' do
    let(:h) do
      ::XmlSimple.xml_in File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/getuserinfo.xml'))
    end

    subject { Bvr::Customer.new_from_response(h) }

    it 'returns a new Bvr::Customer with the right params' do
      subject.must_be_instance_of Bvr::Customer
      subject.id.must_equal 'John*Doe'
      subject.email.must_equal 'JohnDoe@gmail.com'
      subject.raw_blocked.must_equal 'False'

      subject.credit.must_be_instance_of Bvr::Credit
      subject.credit.raw_balance.must_equal '1.86'
      subject.credit.raw_specific_balance.must_equal '1.86828'
    end
  end

  describe '#blocked?' do

    subject { customer.blocked? }

    describe 'when raw_blocked is false' do
      let(:customer) { Bvr::Customer.new.tap{ |c| c.raw_blocked = 'False' } }
      it 'returns true' do
        subject.must_equal false
      end
    end

    describe 'when raw_blocked is true' do
      let(:customer) { Bvr::Customer.new.tap{ |c| c.raw_blocked = 'True' } }
      it 'returns true' do
        subject.must_equal true
      end
    end
  end
end
