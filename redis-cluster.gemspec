# frozen_string_literal: true
# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'redis/cluster/version'

Gem::Specification.new do |s|
  s.name              = 'redis-cluster'
  s.version           = Redis::Cluster::VERSION
  s.summary           = 'Redis cluster client. Support pipelining.'
  s.authors           = ['Bukalapak']
  s.email             = ['sre@bukalapak.com']
  s.homepage          = 'https://github.com/bukalapak/redis-cluster'
  s.license           = 'MIT'

  s.files             = %w(README.md) + Dir.glob('{lib/**/*}')
  s.require_paths     = ['lib']

  s.add_runtime_dependency 'redis', '~> 3.0'
end
