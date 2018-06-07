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
   redis = RedisCluster.new(
                             seed,
                             redis_opts: { timeout: 5, connect_timeout: 1 },
                             cluster_opts: { force_cluster: false, read_mode: :master_slave, silent: true, logger: Logger.new }
                           )
   redis.middlewares.register(:commit) do |*args, &block|
     puts "this is RedisCluster middlewares"
     block.call
   end
   ````

### Development Guide

1. You need [rvm](https://rvm.io) and [bundler](http://bundler.io/) to test.
   See [here](https://rvm.io/rvm/install) to install `rvm`.
   And run these commands to install `bundler` and other dependencies

   ````sh
   gem install bundler
   bundle install
   ````

2. You also need redis binary.
   See [here](https://redis.io/download) to install `redis`

3. Fork this repo

4. Make your change and it's test.

   ````sh
   vim lib/**.rb
   vim spec/**_spec.rb
   ````

5. Optionally, run the test in your local

   ````sh
   rake # run all test and lint
   ````

6. Commit and push your change to upstream

   ````sh
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
- `force_cluster`: if true, RedisCluster will only work on clustered Redis or otherwise can also work on standalone Redis. The default value is `false`.
- `read_mode`: for read command, RedisClient can try to read from slave if specified. Supported option is `:master`(default), `:slave`, and `:master_slave`.
- `silent`: whether or not RedisCluster will raise error.
- `logger`: if specified. RedisCluster will log all of RedisCluster errors here.

#### Middlewares

Middlewares are hooks that RedisCluster provide to observe RedisCluster events. To register a middlewares, provide callable object (object that respond to call)
or give block in register method. Middlewares must give block result as return value.
````ruby
class Callable
  call
    start = Time.now
    yield
  rescue StandardError => e
    raise e
  ensure
    Metrics.publish(elapsed_time: Time.now - start)
  end
end
redis.middlewares.register(:commit, Callable.new)

redis.middlewares.register(:commit) do |*args, &block|
  begin
    res = block.call
  rescue StandardError => e
    Log.warn('failed')
    raise e
  end
  Log.info('success')
  res
end
````

Currently there are 3 events that RedisCluster publish.
- `:commit`
  RedisCluster will fire `:commit` events when RedisCluster::Client call redis server. It give queue of command as arguments.
  ````ruby
  redis.middlewares.register(:commit) do |queues, &block|
    puts 'this is :commit events'
    puts "first command: #{queues.first.first}
    puts "last command: #{queues.last.first}
    block.call
  end
  ````
- `:call`
  This events is fired when command is issued in RedisCluster client before any load balancing is done. It give call arguments as arguments
  ````ruby
  redis.middlewares.register(:call) do |keys, command, opts = {}, &block|
    puts "keys to load balance: #{keys}"
    puts "redis command: #{command.first}"
    block.call
  end
  redis.get('something')
  # Output:
  #   keys to load balance: something
  #   redis command: get
  ````
- `:pipelined`
  This events is fired when pipelined method is called from redis client. It does not give any arguments
  ````ruby
  redis.middlewares.register(:pipelined) do |&block|
    puts 'pipelined is called'
    block.call
  end
  ````

### Limitation

All multi keys operation, cluster command, multi-exec, and some commands are not supported.

### Pipeline

Can be used with same interface as standalone redis client. See [redis pipeline](https://github.com/redis/redis-rb#pipelining)

## FAQ
