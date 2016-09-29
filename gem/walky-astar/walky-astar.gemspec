# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'walky-astar/version'

Gem::Specification.new do |spec|
  spec.name          = 'walky-astar'
  spec.version       = Walky::AStar::VERSION
  spec.authors       = ['Watch Over Me']
  spec.email         = ['dev@watchovermeapp.com']
  spec.summary        = %q{A* pathfinding algorithm}

  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']
end
