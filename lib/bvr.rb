Dir[File.dirname(__FILE__) + '/bvr/*.rb'].each{ |file| require file }

module Bvr
  extend self

  attr_accessor :config

  def configure
    self.config = Bvr::Configuration.new.tap{ |configuration| yield(configuration) }
  end
end
