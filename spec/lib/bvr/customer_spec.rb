require_relative "../../spec_helper"
require_relative "../../helpers/faraday_stub"

describe Bvr::Customer do

  describe '.authenticate(id, password)' do
    include FaradayStub

    let(:customer_id) { 'foo' }
    let(:password)    { 'bar' }
    let(:options) do
      {
        command: Bvr::Customer::API_COMMANDS[:authenticate],
        customer: customer_id,
        customerpassword: password
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/validateuser.xml'))
    end

    subject{ Bvr::Customer.authenticate(customer_id, password) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    it 'returns a boolean' do
      subject.must_equal true
    end
  end

  describe '.block(id, block=true)' do
    include FaradayStub

    let(:customer_id) { 'foo' }
    let(:block) { true }
    let(:options) do
      {
        command: Bvr::Customer::API_COMMANDS[:changeuserinfo],
        customer: customer_id,
        customerblocked: block
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/customerblocked.xml'))
    end

    subject{ Bvr::Customer.block(customer_id, block) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    it 'return a response' do
      subject['Result'][0].must_be_instance_of String
      subject['Customer'].must_equal "#{customer_id}*provider"
    end

    describe 'when block is not a boolean' do
      let(:block) { 'foo' }

      subject{ Bvr::Customer.block(customer_id, block) }

      it 'raise an ArgumentError' do
        proc { subject }.must_raise ArgumentError
      end
    end
  end

  describe '.change_password(id, old_pass, new_pass)' do
    include FaradayStub

    let(:customer_id) { 'foo' }
    let(:old_password) { 'bar' }
    let(:new_password) { 'barbar' }
    let(:options) do
      {
        command: Bvr::Customer::API_COMMANDS[:changepassword],
        customer: customer_id,
        oldcustomerpassword: old_password,
        newcustomerpassword: new_password
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/changepassword.xml'))
    end

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    subject { Bvr::Customer.change_password(customer_id, old_password, new_password) }

    it 'return response' do
      subject['Result'].must_be_instance_of String
    end
  end

  describe '.create(options)' do
    include FaradayStub

    let(:options) { { customer: 'foo', customerpassword: 'bar' } }
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/createcustomer_response.xml'))
    end

    subject{ Bvr::Customer.create(options) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    it 'returns the response' do
      subject['Result'].must_be_instance_of String
    end

    describe 'when options are invalid' do
      let(:options) { { foo: 'bar' } }

      it 'raise an ArgumentError' do
        proc { subject }.must_raise ArgumentError
      end
    end
  end

  describe '.find(id)' do
    include FaradayStub

    let(:connection) { Minitest::Mock.new }
    let(:id) { 'foo' }
    let(:params) { { command: Bvr::Customer::API_COMMANDS[:find], customer: id } }

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
      ::XmlSimple.xml_in File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/getuserinfo.xml')), {ForceArray: false}
    end

    subject { Bvr::Customer.new_from_response(h) }

    it 'returns a new Bvr::Customer with the right params' do
      subject.must_be_instance_of Bvr::Customer
      subject.id.must_equal 'foo*provider'
      subject.email.must_equal 'JohnDoe@gmail.com'
      subject.raw_blocked.must_equal 'False'

      subject.credit.must_be_instance_of Bvr::Credit
      subject.credit.raw_balance.must_equal '1.86'
      subject.credit.raw_specific_balance.must_equal '1.86828'

      subject.phones.must_be_instance_of Array
      subject.phones.must_include Bvr::Phone.new('+4412345678')
      subject.phones.must_include Bvr::Phone.new('+4412345679')
    end
  end

  describe '#blocked?' do
    subject { customer.blocked? }

    describe 'when raw_blocked is false' do
      let(:customer) { Bvr::Customer.new('foo').tap{ |c| c.raw_blocked = 'False' } }
      it 'returns true' do
        subject.must_equal false
      end
    end

    describe 'when raw_blocked is true' do
      let(:customer) { Bvr::Customer.new('foo').tap{ |c| c.raw_blocked = 'True' } }
      it 'returns true' do
        subject.must_equal true
      end
    end
  end

  describe '#block!' do
    include FaradayStub

    let(:customer_id) { 'foo' }
    let(:raw_blocked) { 'bar' }
    let(:customer) { Bvr::Customer.new(customer_id).tap{ |c| c.raw_blocked = raw_blocked } }
    let(:block) { true }
    let(:options) do
      {
        command: Bvr::Customer::API_COMMANDS[:changeuserinfo],
        customer: customer_id,
        customerblocked: block
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/customerblocked.xml'))
    end

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    subject { customer.block! }

    it 'updates the attribute of the customer' do
      customer.raw_blocked.must_equal raw_blocked
      subject
      customer.raw_blocked.must_equal Bvr::Customer::BLOCKED_VALUES[true]
    end
  end

  describe '#change_password(new_password)' do
    include FaradayStub

    let(:customer_id) { 'foo' }
    let(:old_password) { 'bar' }
    let(:new_password) { 'barbar' }
    let(:customer) { Bvr::Customer.new(customer_id).tap{ |c| c.password = old_password } }
    let(:options) do
      {
        command: Bvr::Customer::API_COMMANDS[:changepassword],
        customer: customer_id,
        oldcustomerpassword: old_password,
        newcustomerpassword: new_password
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/changepassword.xml'))
    end

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    subject { customer.change_password(new_password) }

    it 'changes the password of the user' do
      customer.password.must_equal old_password
      subject
      customer.password.must_equal new_password
    end

  end

  describe '#unblock!' do
    include FaradayStub

    let(:customer_id) { 'foo' }
    let(:raw_blocked) { 'bar' }
    let(:customer) { Bvr::Customer.new(customer_id).tap{ |c| c.raw_blocked = raw_blocked } }
    let(:block) { false }
    let(:options) do
      {
        command: Bvr::Customer::API_COMMANDS[:changeuserinfo],
        customer: customer_id,
        customerblocked: block
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/customerblocked.xml'))
    end

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    subject { customer.unblock! }

    it 'updates the attribute of the customer' do
      customer.raw_blocked.must_equal raw_blocked
      subject
      customer.raw_blocked.must_equal Bvr::Customer::BLOCKED_VALUES[false]
    end
  end

  describe '#calls(options={})' do
    include FaradayStub

    let(:h) do
      ::XmlSimple.xml_in File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/getuserinfo.xml')), {ForceArray: false}
    end
    let(:calls_response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/calloverview.xml'))
    end
    let(:customer) { Bvr::Customer.new_from_response(h) }
    let(:options) { {} }
    let(:params) { { command: Bvr::CallCollection::API_COMMANDS[:find_by_customer_id], customer: customer.id } }

    subject { customer.calls(options) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(params)) { [200, {}, calls_response] }
    end

    it 'returns an instance of Bvr::CallCollection' do
      subject.must_be_instance_of Bvr::CallCollection
    end

    describe 'when options are the same' do
      let(:call_collection_id) { customer.calls(options).__id__ }

      it 'returns the same object' do
        subject.__id__.must_equal call_collection_id
      end
    end

    describe 'wen options are not the same' do
      let(:call_collection_id) { customer.calls({date: 'bar'}).__id__ }

      it 'returns the same object' do
        subject.__id__.wont_equal call_collection_id
      end
    end
  end
end
