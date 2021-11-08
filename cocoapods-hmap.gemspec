# frozen_string_literal: true

require File.expand_path('../lib/hmap/version', __FILE__)

# require "#{File.dirname(__FILE__)}/lib/hmap"

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-mapfile'
  spec.version       = HMap::VERSION
  spec.authors       = ['Cat1237']
  spec.email         = ['wangson1237@outlook.com']

  spec.summary       = 'Read or write header map file.'
  spec.description   = %(
    header_reader lets your read Xcode header map file.
    header-writer lets your analyze the project pod dependencies and gen header map file for all pods.
  ).strip.gsub(/\s+/, ' ')
  spec.homepage      = 'https://github.com/Cat1237/cocoapods-hmap.git'
  spec.license       = 'MIT'
  spec.files         = %w[README.md LICENSE] + Dir['lib/**/*.rb']
  spec.executables   = %w[hmapfile]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.1'
  spec.add_development_dependency 'coveralls', '>= 0'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'rspec', '>= 3.0'

  spec.add_runtime_dependency 'claide', '>= 1.0.2', '< 2.0'
  spec.add_runtime_dependency 'xcodeproj', '>= 1.19.0', '< 2.0'
  spec.add_runtime_dependency 'yaml-vfs', '>= 0.0.4'

  spec.required_ruby_version = '>= 2.5'
end
