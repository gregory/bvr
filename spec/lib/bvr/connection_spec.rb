require_relative '../../spec_helper'

describe Bvr::Connection do
  describe '.base_uri' do
    subject{ Bvr::Connection.base_uri }
    let(:base_uri) { 'https://www.voipinfocenter.com' }

    it "returns the base_uri of the api" do
      subject.must_equal base_uri
    end
  end

  describe '.connection(faraday_adapter)' do
    let(:default_faraday_adapter) { Faraday::Adapter::NetHttp }
    subject{ Bvr::Connection.connection}

    it 'returns a Faraday::Connection with the nethttp adapter' do
      subject.must_be_instance_of Faraday::Connection
      subject.builder.handlers.must_include default_faraday_adapter
    end
  end

  describe '.get(params)' do
    let(:params) { {foo: 'bar'} }
    let(:connection) { Minitest::Mock.new }
    let(:username) { 'username' }
    let(:password) { 'password' }

    before do
      Bvr.configure do |config|
        config.username = username
        config.password = password
      end
    end

    subject{ Bvr::Connection.get(params) }

    it 'calls connection.get with the right uri' do
      Bvr::Connection.stub(:connection, connection) do
        response =  Minitest::Mock.new
        connection.expect :get, response, [Bvr::Connection.uri(params)]
        response.expect :body, nil
        subject
        connection.verify
        response.verify
      end
    end

  end

  describe '.uri(queryH)' do
    let(:queryH) { { foo: 'bar', bar: 'foo'} }
    let(:username) { 'username' }
    let(:password) { 'password' }

    before do
      Bvr.configure do |config|
        config.username = username
        config.password = password
      end
    end

    subject{ Bvr::Connection.uri(queryH) }

    it 'match the api path' do
      subject.must_match Regexp.new(Bvr::Connection::API_PATH)
    end

    it 'transform queryH to valid GET params' do
      subject.must_match Regexp.new("foo=#{queryH[:foo]}&bar=#{queryH[:bar]}")
    end

    it 'contain username and password from the config' do #This is pretty bad :(
      subject.must_match Regexp.new("username=#{username}&password=#{password}")
    end

    describe 'when username and password are passed in the H' do
      let(:queryH) { {username: 'foo', password: 'bar'} }

      it 'overwrite username and password params' do
        subject.must_match Regexp.new("username=#{username}&password=#{password}")
      end
    end
  end
end
