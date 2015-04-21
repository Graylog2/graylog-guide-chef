# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chef/handler/graylog/version'

Gem::Specification.new do |spec|
  spec.name          = 'chef-handler-graylog'
  spec.version       = Chef::Handler::Graylog::VERSION
  spec.authors       = ["Bernd Ahlers"]
  spec.email         = ["bernd@graylog.com"]

  spec.summary       = %q{Chef handler for Graylog GELF}
  spec.description   = %q{Chef handler to send GELF events to Graylog}
  spec.homepage      = 'https://www.graylog.org/'
  spec.license       = 'ASL2'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
