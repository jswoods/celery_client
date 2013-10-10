# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'celery_client/version'

Gem::Specification.new do |spec|
  spec.name          = "celery_client"
  spec.version       = CeleryClient::VERSION
  spec.authors       = ["Jestin Woods"]
  spec.email         = ["jestin.woods@jivesoftware.com"]
  spec.description   = %q{Execute celery tasks}
  spec.summary       = %q{Execute celery tasks}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
	spec.add_development_dependency "rspec", "~> 2.6"
end
