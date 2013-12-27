require_relative '../../spec_helper'

describe Bvr::Call do
  let(:h) do
    customer_h = ::XmlSimple.xml_in File.read(File.join(File.dirname(__FILE__), '/..', '/..', '/fixtures/calloverview.xml'))
    customer_h['Calls'][0]['Call'][0]
  end

  describe '.new_from_response(h)' do
    subject { Bvr::Call.new_from_response(h) }

    it 'Creates a new Call with the right params' do
      start_time = "2013-12-24 18:05:26  (UTC)"
      subject.must_be_instance_of Bvr::Call
      subject.id.must_equal "1234567890"
      subject.calltype.must_equal "PSTNOutSip"
      subject.raw_start_time.must_equal start_time
      subject.raw_dest.must_equal "+32123456788"
      subject.raw_duration.must_equal "00:02:21"
      subject.charge.must_equal "0.0705"
    end
  end

  describe '#duration' do
    let(:raw_duration) { '00:02:21' }
    let(:raw_start_time)   { "2013-12-24 18:05:26  (UTC)" }
    let(:call) { Bvr::Call.new.tap{ |call| call.raw_duration = raw_duration; call.raw_start_time = raw_start_time } }

    subject { call.duration }

    it 'returns the relative time duration' do
      subject.must_be_instance_of Time
      subject.must_equal Time.parse(raw_duration, call.start_time)
    end
  end

  describe '#start_time' do
    let(:raw_start_time)   { "2013-12-24 18:05:26  (UTC)" }
    let(:call) { Bvr::Call.new.tap{ |call| call.raw_start_time = raw_start_time } }

    subject { call.start_time }

    it 'return the time' do
      subject.must_be_instance_of Time
      subject.must_equal Time.parse(raw_start_time)
    end
  end

  describe '#dest' do
    let(:raw_dest) { "+32123456788" }
    let(:call) { Bvr::Call.new.tap{ |call| call.raw_dest = raw_dest } }

    subject { call.dest }

    it 'returns a phone' do
      subject.must_be_instance_of Bvr::Phone
      subject.number.must_equal raw_dest
    end
  end
end
