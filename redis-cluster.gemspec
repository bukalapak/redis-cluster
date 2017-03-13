# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'redis-cluster/version'

Gem::Specification.new do |s|
  s.name              = 'redis-cluster'
  s.version           = RedisCluster::VERSION
  s.summary           = 'Redis cluster client. Support pipelining.'
  s.authors           = ['Roland Rinfandi Utama']
  s.email             = ['roland_hawk@yahoo.com']
  s.homepage          = 'https://github.com/bukalapak/redis-cluster'
  s.license           = 'MIT'

  s.files             = %w(README.md) + Dir.glob('{lib/**/*}')
  s.require_paths     = ['lib']
end
