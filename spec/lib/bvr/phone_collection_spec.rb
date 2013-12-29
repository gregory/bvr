require_relative '../../spec_helper'
require_relative "../../helpers/faraday_stub"

describe Bvr::PhoneCollection do
  describe '.add(customer_id, phone, add="add")' do
    include FaradayStub

    let(:customer_id) { 'foo' }
    let(:phone) { "+4412345678" }
    let(:geocallcli_options) { "add" }
    let(:options) do
      {
        command: Bvr::PhoneCollection::API_COMMANDS[:add],
        customer: customer_id,
        geocallcli_options: geocallcli_options,
        geocallcli: phone
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/customerblocked.xml'))
    end

    subject{ Bvr::PhoneCollection.add(customer_id, phone) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    it 'return result' do
      subject['Result'][0].must_be_instance_of String
    end
  end

  describe '#add(phone)' do
    include FaradayStub

    let(:customer) { Bvr::Customer.new('foo') }
    let(:phone) { Bvr::Phone.new("+4412345678") }
    let(:geocallcli_options) { "add" }
    let(:options) do
      {
        command: Bvr::PhoneCollection::API_COMMANDS[:add],
        customer: customer.id,
        geocallcli_options: geocallcli_options,
        geocallcli: phone.number
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/customerblocked.xml'))
    end

    subject{ customer.phones.add(phone) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    it 'adds a phone' do
      customer.phones.collection.wont_include phone
      subject.must_equal true
      customer.phones.collection.must_include phone
    end
  end

  describe '#rm(phone)' do
    include FaradayStub

    let(:phone) { Bvr::Phone.new("+4412345678") }
    let(:customer) { Bvr::Customer.new('foo').tap{ |c| c.phones.collection << phone } }
    let(:geocallcli_options) { "delete" }
    let(:options) do
      {
        command: Bvr::PhoneCollection::API_COMMANDS[:add],
        customer: customer.id,
        geocallcli_options: geocallcli_options,
        geocallcli: phone.number
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/customerblocked.xml'))
    end

    subject{ customer.phones.rm(phone) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    it 'adds a phone' do
      customer.phones.collection.must_include phone
      subject.must_equal true
      customer.phones.collection.wont_include phone
    end
  end
end
