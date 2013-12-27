require_relative '../spec_helper'

describe Bvr do
  subject { Bvr }

  describe '.configure' do
    let(:username) { 'foo' }
    let(:password) { 'bar' }

    before do
      subject.configure do |config|
        config.username = username
        config.password = password
      end
    end

    it 'has a username and password' do
      subject.config.username.must_equal username
      subject.config.password.must_equal password
    end
  end

  describe '.connection' do
    subject { Bvr.connection }

    describe 'when @config is nil' do
      before { Bvr.config = nil }

      it 'raise an exception if @config is nil' do
        proc { subject }.must_raise Exception
      end
    end

    describe 'when @config is set' do
      before { Bvr.config = 'foo' }

      it 'returns a Bvr::Connection' do
        subject.must_be_instance_of Bvr::Connection
      end
    end
  end
end
