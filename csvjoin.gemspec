# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csvjoin/version'

Gem::Specification.new do |spec|
  spec.name          = 'csvjoin'
  spec.version       = CSVJoin::VERSION
  spec.authors       = ['Sergey Evstegneiev']
  spec.email         = ['serg123e+github@gmail.com']

  spec.summary       = 'Join 2 CSV tables by specified columns'
  spec.description   = 'tool to align and merge two tables containing different parts of the same data'
  spec.homepage      = 'https://www.github.com/serg123e/csvjoin'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']

  spec.bindir        = 'bin'
  spec.executables   = ['csvjoin2']

  spec.require_paths = ['lib']
  spec.platform      = Gem::Platform::RUBY

  spec.required_ruby_version = '~> 2.4'

  spec.add_dependency 'diff-lcs', '~> 1.3'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0.0'

  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rspec-simplecov', '~> 0.2.2'
  spec.add_development_dependency 'rubocop', '~> 1.1.0'
  spec.add_development_dependency 'simplecov', '~> 0.18.5'
end
