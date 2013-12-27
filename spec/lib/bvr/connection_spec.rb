require_relative '../../spec_helper'
require_relative "../../helpers/faraday_stub"

describe Bvr::Connection do
  describe '.new(faraday_adapter)' do
    let(:default_faraday_adapter) { Faraday::Adapter::NetHttp }
    subject{ Bvr::Connection.new }

    it 'returns a Faraday::Connection with the nethttp adapter' do
      subject.faraday_connection.must_be_instance_of Faraday::Connection
      subject.faraday_connection.builder.handlers.must_include default_faraday_adapter
    end
  end

  describe 'base_uri' do
    subject{ Bvr::Connection.new.base_uri }
    let(:base_uri) { 'https://www.voipinfocenter.com' }

    it "returns the base_uri of the api" do
      subject.must_equal base_uri
    end
  end


  describe 'get(params)' do
    let(:params) { {foo: 'bar'} }
    let(:faraday_connection) { Minitest::Mock.new }
    let(:username) { 'username' }
    let(:password) { 'password' }
    let(:connection) do
      Bvr::Connection.new.tap do |connection|
        connection.faraday_connection = faraday_connection
      end
    end

    subject { connection.get(params) }

    it 'calls connection.get with the right uri' do
        response =  Minitest::Mock.new
        faraday_connection.expect :get, response, [Bvr::Connection.uri_from_h(params)]
        response.expect :body, ::XmlSimple.xml_out({})
        subject
        faraday_connection.verify
        response.verify
    end
  end

  describe 'self.uri_from_h(queryH)' do
    let(:queryH) { { foo: 'bar', bar: 'foo'} }
    let(:username) { 'username' }
    let(:password) { 'password' }

    before do
      Bvr.configure do |config|
        config.username = username
        config.password = password
      end
    end

    subject { Bvr::Connection.uri_from_h(queryH) }

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
