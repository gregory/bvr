require_relative '../../spec_helper'
require_relative "../../helpers/faraday_stub"

describe Bvr::Credit do
  describe '.add(customer_id, amount)' do
    include FaradayStub
    let(:customer_id) { 'foo' }
    let(:amount)   { 10    }
    let(:options) do
      {
        command: Bvr::Credit::API_COMMANDS[:add],
        customer: customer_id,
        amount: amount
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/settransaction.xml'))
    end

    subject { Bvr::Credit.add(customer_id, amount) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    it 'returns a result' do
      subject['Result'].must_be_instance_of String
    end
  end


  describe '#add(amount)' do
    include FaradayStub
    let(:raw_specific_balance) { 10.12345 }
    let(:raw_balance) { 10.12 }
    let(:amount) { 1 }
    let(:customer) { Bvr::Customer.new }
    let(:credit)   { Bvr::Credit.new(raw_specific_balance, raw_balance, customer) }
    let(:customer_id) { 'foo' }
    let(:options) do
      {
        command: Bvr::Credit::API_COMMANDS[:add],
        customer: customer_id,
        amount: amount
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/settransaction.xml'))
    end

    subject { credit.add(amount) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    it 'increase the amout' do
      customer.stub(:id, customer_id) do
        credit.specific_balance.must_equal raw_specific_balance
        credit.balance.must_equal raw_balance

        subject.must_equal true

        credit.specific_balance.must_equal raw_specific_balance + amount
        credit.balance.must_equal raw_balance + amount
      end
    end

    describe 'when the amount if more than .5f' do
      let(:amount) { 1.000001 }

      it 'round up' do
        customer.id = customer_id

        credit.specific_balance.must_equal raw_specific_balance
        credit.balance.must_equal raw_balance

        subject.must_equal true

        credit.specific_balance.must_equal raw_specific_balance + Float("%.5f" % amount)
        credit.balance.must_equal          raw_balance          + Float("%.2f" % amount)
      end
    end

    describe 'when there is an error' do
      let(:response) do
        File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/settransaction_failed.xml'))
      end

      it 'does not change the amout and return false' do
        customer.stub(:id, customer_id) do
          credit.raw_specific_balance.must_equal raw_specific_balance
          credit.raw_balance.must_equal raw_balance

          subject.must_equal false

          credit.raw_specific_balance.must_equal raw_specific_balance
          credit.raw_balance.must_equal raw_balance
        end
      end
    end
  end

  describe '#rm(amount)' do
    include FaradayStub
    let(:raw_specific_balance) { 10.12345 }
    let(:raw_balance) { 10.12 }
    let(:amount) { 1 }
    let(:customer) { Bvr::Customer.new }
    let(:credit)   { Bvr::Credit.new(raw_specific_balance, raw_balance, customer) }
    let(:customer_id) { 'foo' }
    let(:options) do
      {
        command: Bvr::Credit::API_COMMANDS[:add],
        customer: customer_id,
        amount: - amount
      }
    end
    let(:response) do
      File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/settransaction.xml'))
    end

    subject { credit.rm(amount) }

    before do
      faraday_adapter.get(Bvr::Connection.uri_from_h(options)) { [200, {}, response] }
    end

    it 'decrease the amout' do
      customer.stub(:id, customer_id) do
        credit.specific_balance.must_equal raw_specific_balance
        credit.balance.must_equal raw_balance

        subject.must_equal true

        credit.specific_balance.must_equal raw_specific_balance -  amount
        credit.balance.must_equal raw_balance - amount
      end
    end

  end

  describe '#balance' do
    let(:raw_balance) { "10.12" }
    let(:credit) { Bvr::Credit.new(nil, raw_balance) }

    subject { credit.balance }

    it 'return a float out of the balance' do
      subject.must_be_instance_of Float
      subject.must_equal Float(raw_balance)
    end
  end

  describe '#specific_balance' do
    let(:raw_specific_balance) { "10.12345" }
    let(:credit) { Bvr::Credit.new(raw_specific_balance) }

    subject { credit.specific_balance }

    it 'return a float out of the balance' do
      subject.must_be_instance_of Float
      subject.must_equal Float(raw_specific_balance)
    end
  end
end
