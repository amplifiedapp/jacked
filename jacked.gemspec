# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jacked/version'

Gem::Specification.new do |spec|
  spec.name          = "jacked"
  spec.version       = Jacked::VERSION
  spec.authors       = ["Sergio Rafael Gianazza", "Leonardo Andrés Garcia Crespo"]
  spec.email         = ["hello@amplifiedapp.com"]
  spec.description   = %q{This gem provide a couple of utility functions to get information from an audio file.}
  spec.summary       = %q{This gem provide a copule of utility functions to get information from an audio file.}
  spec.homepage      = "http://www.amplifiedapp.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fuubar"

  spec.add_dependency "waveformjson"
end
