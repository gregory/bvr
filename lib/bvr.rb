require 'happymapper'
Dir[File.dirname(__FILE__) + '/bvr/*.rb'].each{ |file| require file }

module Bvr
  extend self

  attr_accessor :config, :connection

  def configure
    @config = Bvr::Configuration.new.tap{ |configuration| yield(configuration) }
  end

  def connection
    @connection ||= Bvr::Connection.new
  end
end
