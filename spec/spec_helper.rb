require 'rubygems'
require 'bundler/setup'
Bundler.require(:test)

require_relative '../lib/bvr'

require 'minitest/autorun'
require 'minitest/pride'

Turn.config do |c|
  c.format  = :outline
  c.natural = true
end
