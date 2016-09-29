# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sphericalc/version'

Gem::Specification.new do |spec|
  spec.name          = 'sphericalc'
  spec.version       = Sphericalc::VERSION
  spec.authors       = ['Watch Over Me']
  spec.email         = ['dev@watchovermeapp.com']
  spec.summary        = %q{Spherical calculator}

  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']
end
