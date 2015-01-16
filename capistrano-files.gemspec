# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/files/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-files"
  spec.version       = Capistrano::Files::VERSION
  spec.authors       = ["Martin Fernandez"]
  spec.email         = ["me@bilby91.com"]
  spec.summary       = %q{Capistrano tasks for files handling.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "capistrano", ">= 3.0.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
