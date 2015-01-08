# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pargser'

Gem::Specification.new do |spec|
  spec.name          = "pargser"
  spec.version       = Pargser::VERSION
  spec.authors       = ["sergeych"]
  spec.email         = ["sergeych"]
  spec.summary       = %q{Very Ruby-style command line parser}
  spec.description   = %q{Allows to write CLI in ruby without headache of arguments parsing and
usage writing}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rspec", '~> 3.1'
  spec.add_development_dependency "rake", "~> 10.0"
end
