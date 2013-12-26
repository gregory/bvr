require 'rubygems'
require 'bundler/setup'
Bundler.require(:test)

require_relative '../lib/bvr'

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/stub_const'

Turn.config do |c|
  c.format  = :outline
  c.natural = true
end

MiniTest::Spec.before :each do
  Bvr.configure do |config|
    config.username = 'default_username'
    config.password = 'default_password'
  end
end
