# redis-cluster
[![CircleCI](https://circleci.com/gh/bukalapak/redis-cluster.svg?style=shield&circle-token=5ebe750ce74100b7bc18768395ec3e4ebd9f1a43)](https://circleci.com/gh/bukalapak/redis-cluster)

## Getting started

Install redis-cluster.
````ruby
gem install 'redis-cluster'
````

This will start a redis from seed servers. Currently it only support master read configuration.
````ruby
seed = ['127.0.0.1:7001', '127.0.0.1:7002']
redis = RedisCluster.new(seed, redis_opts: { timeout: 5, connect_timeout: 1})
````

## Limitation
All multi keys operation, cluster command, multi-exec, and some commands are not supported.

## Pipeline
Can be used with same interface as standalone redis client. See [redis pipeline](https://github.com/redis/redis-rb#pipelining)


## Contributing
[Fork the project](https://github.com/bukalapak/redis-cluster) and send pull requests.
