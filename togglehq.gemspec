# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'togglehq/version'

Gem::Specification.new do |spec|
  spec.name          = "togglehq"
  spec.version       = Togglehq::VERSION
  spec.authors       = ["Toggle"]
  spec.email         = ["hello@togglehq.com"]

  spec.summary       = %q{Ruby gem wrapper for the ToggleHQ API}
  spec.description   = %q{Ruby gem wrapper for the ToggleHQ API}
  spec.homepage      = "https://www.togglehq.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "faraday"
  spec.add_dependency "net-http-persistent"
  spec.add_dependency "json"
end
