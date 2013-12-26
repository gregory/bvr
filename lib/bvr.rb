require 'happymapper'
Dir[File.dirname(__FILE__) + '/bvr/*.rb'].each{ |file| require file }

module Bvr
  extend self

  attr_accessor :config

  def configure
    self.config = Bvr::Configuration.new.tap{ |configuration| yield(configuration) }
  end

  def connection
    self.connection = Bvr::Connection.new
  end
end
