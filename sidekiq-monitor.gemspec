# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/monitor/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq-monitor'
  spec.version       = Sidekiq::Monitor::VERSION
  spec.authors       = ['Dimko']
  spec.email         = ['deemox@gmail.com']
  spec.description   = %q{Tracks jobs enqueued, average duration and etc.}
  spec.summary       = %q{Jobs and queue stats for Sidekiq}
  spec.homepage      = 'https://github.com/dimko/sidekiq-monitor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'sidekiq',        '~> 2.6'
  spec.add_dependency 'rails',          '~> 3.2'
  spec.add_dependency 'will_paginate',  '~> 3.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
