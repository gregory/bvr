require_relative '../../spec_helper'

describe Bvr::CallOverview do
  describe '.find(customer_id, options)' do
    let(:customer_id) { 'john' }
    let(:connection)      { Minitest::Mock.new }
    let(:body)        { 'response' }

    def stub_connection
      Bvr.stub(:connection, connection) { yield }
    end

    def stub_parse
      Bvr::CallOverview.stub(:parse, []) { yield }
    end

    describe 'when options are omitted' do
      subject{ Bvr::CallOverview.find(customer_id) }

      it 'sets the right command and the customer_id' do
        stub_connection do
          stub_parse do
            connection.expect :get, [],  [{command: Bvr::CallOverview::API_COMMAND, customer: customer_id}]
            subject
            connection.verify
          end
        end
      end
    end

    describe 'when options are provided, it merges the options with the command and customer_id' do
      let(:options) { { recordcount: 'bar', callid: 'foo' } }

      subject{ Bvr::CallOverview.find(customer_id, options) }

      it 'merges the CallOverview command and the customer_id with options' do
        stub_connection do
          stub_parse do
            expected_options = options.merge({command: Bvr::CallOverview::API_COMMAND, customer: customer_id})
            connection.expect :get, [],  [expected_options]
            subject
            connection.verify
          end
        end
      end
    end

    describe 'when wrong options are provided, raise an argument error' do
      let(:options) { { foo: 'bar', john: 'Doe' } }

      subject{ Bvr::CallOverview.find(customer_id, options) }

      it 'merges the CallOverview command and the customer_id with options' do
        stub_connection do
          stub_parse do
            expected_options = options.merge({command: Bvr::CallOverview::API_COMMAND, customer: customer_id})
            proc {subject}.must_raise ArgumentError
          end
        end
      end
    end

  end
end


