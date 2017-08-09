# redis-cluster
[![CircleCI](https://circleci.com/gh/bukalapak/redis-cluster.svg?style=shield&circle-token=5ebe750ce74100b7bc18768395ec3e4ebd9f1a43)](https://circleci.com/gh/bukalapak/redis-cluster)
[![Coverage](https://codecov.io/gh/bukalapak/redis-cluster/branch/master/graph/badge.svg?token=cPZvgDYAft)](https://codecov.io/gh/bukalapak/redis-cluster)

## Description

redis-cluster is redis cluster client for ruby that support pipelining.

## Owner

SRE Bukalapak

## Contact

[Contributors](https://github.com/bukalapak/redis-cluster/graphs/contributors)

## Onboarding and Development Guide

### Getting started

1. Install redis-cluster

   ````ruby
   gem install 'redis-cluster'
   ````

2. Start `irb`. This command will start a redis-cluster client from seed servers.

   ````ruby
   seed = ['127.0.0.1:7001', '127.0.0.1:7002']
   redis = Redis::Cluster.new(
                             seed,
                             redis_opts: { timeout: 5, connect_timeout: 1 },
                             cluster_opts: { read_mode: :master_slave, silent: true, logger: Logger.new }
                           )
   ````

### Development Guide

1. You need [rvm](https://rvm.io) and [bundler](http://bundler.io/) to test.
   See [here](https://rvm.io/rvm/install) to install `rvm`.
   And run these commands to install `bundler` and other dependencies

   ````
   gem install bundler
   bundle install
   ````

2. You also need redis binary.
   See [here](https://redis.io/download) to install `redis`

3. Fork this repo

4. Make your change and it's test.

   ````
   vim lib/**.rb
   vim spec/**_spec.rb
   ````

5. Optionally, run the test in your local

   ````
   rake # run all test and lint
   ````

6. Commit and push your change to upstream

   ````
   git commit -m "message"
   git push # add "--set-upstream branch_name" after "git push" if you haven't set the upstream
   ````

7. Open pull request in `Github`

8. If test in CI is success, ask someone to review your code.

9. If review is passed, your pull request can be merged.

### Configuration

#### redis_opts

Option for Redis::Client instance. Set timeout, ssl, etc here.

#### cluster_opts

Option for RedisCluster.
- `read_mode`: for read command, Redis::Client can try to read from slave if specified. Supported option is `:master`(default), `:slave`, and `:master_slave`.
- `silent`: whether or not Redis::Cluster will raise error.
- `logger`: if specified. Redis::Cluster will log all of RedisCluster errors here.

### Limitation

All multi keys operation, cluster command, multi-exec, and some commands are not supported.

### Pipeline

Can be used with same interface as standalone redis client. See [redis pipeline](https://github.com/redis/redis-rb#pipelining)

## FAQ
