require 'happymapper'
Dir[File.dirname(__FILE__) + '/bvr/*.rb'].each{ |file| require file }

module Bvr
  extend self

  attr_accessor :config, :connection

  def configure
    @config = Bvr::Configuration.new.tap{ |configuration| yield(configuration) }
  end

  def connection
    raise ::Exception.new("Please provide username and password") if @config.nil?

    @connection ||= Bvr::Connection.new
  end
end
