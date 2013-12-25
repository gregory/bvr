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
end
