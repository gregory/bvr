class Module
  include Minitest::Spec::DSL
end
module FaradayStub
  let(:faraday_adapter) { Faraday::Adapter::Test::Stubs.new }

  before do
    Bvr.connection = Bvr::Connection.new.tap{ |con| con.faraday_connection = Faraday.new{|b| b.adapter :test, faraday_adapter} }
  end
end
