require_relative '../../spec_helper'

describe Bvr::Configuration do
  describe '.new' do
    subject{ Bvr::Configuration.new(username, password) }

    let(:username) { 'foo' }
    let(:password) { 'bar' }

    it 'has username and password accessor' do
      subject.username.must_equal username
      subject.password.must_equal password
    end
  end
end
