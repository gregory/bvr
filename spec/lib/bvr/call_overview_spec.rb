require_relative '../../spec_helper'

describe Bvr::CallOverview do
  describe '.find(customer_id, options)' do
    let(:customer_id) { 'john' }
    let(:connection)      { Minitest::Mock.new }
    let(:body)        { 'response' }

    def stub_connection
      Bvr.stub(:connection, connection) { yield }
    end

    def stub_result(res)
      Bvr::CallOverview.stub(:result, res) { yield }
    end

    def stub_parse(result)
      Bvr::CallOverview.stub(:parse, result) { yield }
    end

    describe 'when options are omitted' do
      subject{ Bvr::CallOverview.find(customer_id) }

      it 'sets the right command and the customer_id' do
        stub_connection do
          stub_parse([]) do
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
          stub_parse([]) do
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
        expected_options = options.merge({command: Bvr::CallOverview::API_COMMAND, customer: customer_id})
        proc {subject}.must_raise ArgumentError
      end
    end


    describe 'when there is a response' do
      let(:response) do
        File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/CallOverview.xml'))
      end

      subject{ Bvr::CallOverview.find(customer_id) }

      it 'parse the response to objects' do
        stub_result(response) do |connection|
          subject.must_be_instance_of Bvr::CallOverview
          subject.calls.size.must_equal 5
          subject.count.must_equal 10

          subject.calls[0].tap do |call|
            start_time = Time.parse("2013-12-24 18:05:26  (UTC)")
            call.id.must_equal "1234567890"
            call.calltype.must_equal "PSTNOutSip"
            call.start_time.must_equal start_time
            call.dest.must_be_instance_of Bvr::Phone
            call.dest.number.must_equal "+32123456788"
            call.duration.must_equal "00:02:21"
            call.relative_duration.must_equal Time.parse("00:02:21", start_time)
            call.charge.must_equal "0.0705"
          end
        end
      end
    end
  end
end


