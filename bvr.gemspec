# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bvr/version'

Gem::Specification.new do |spec|
  spec.name          = "bvr"
  spec.version       = Bvr::VERSION
  spec.authors       = ["Gregory Horion"]
  spec.email         = ["greg2502@gmail.com"]
  spec.description   = %q{A ruby interface to Bestvoipreselling API}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/gregory/bvr"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rack'
  spec.add_development_dependency "faraday"
  spec.add_development_dependency "happymapper"
end
