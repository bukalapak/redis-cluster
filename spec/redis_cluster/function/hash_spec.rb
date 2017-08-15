# frozen_string_literal: true
require 'redis_cluster/function/hash'

describe RedisCluster::Function::Hash do
  include_examples 'redis function', [
    {
      method:        ->{ :hdel },
      args:          ->{ [key, [:field, :value]] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :hincrby },
      args:          ->{ [key, :field, 1] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :hincrbyfloat },
      args:          ->{ [key, :field, 1.1] },
      redis_result:  ->{ '3.1' },
      transform:     ->{ Redis::Floatify },
      read:          ->{ false }
    }, {
      method:        ->{ :hmset },
      args:          ->{ [key, :field1, 1, :field2, 2] },
      redis_result:  ->{ 'OK' },
      read:          ->{ false }
    }, {
      method:        ->{ :hset },
      args:          ->{ [key, :field, 1] },
      redis_result:  ->{ 0 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :hsetnx },
      args:          ->{ [key, :field, 1] },
      redis_result:  ->{ 0 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :hexists },
      args:          ->{ [key, :field] },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ true }
    }, {
      method:        ->{ :hget },
      args:          ->{ [key, :field] },
      redis_result:  ->{ 'value' },
      read:          ->{ true }
    }, {
      method:        ->{ :hgetall },
      args:          ->{ [key] },
      redis_result:  ->{ ['field1', '2', 'field2', '2'] },
      transform:     ->{ Redis::Hashify },
      read:          ->{ true }
    }, {
      method:        ->{ :hkeys },
      args:          ->{ [key] },
      redis_result:  ->{ ['field1', 'field2'] },
      read:          ->{ true }
    }, {
      method:        ->{ :hvals },
      args:          ->{ [key] },
      redis_result:  ->{ ['2', '2'] },
      read:          ->{ true }
    }, {
      method:        ->{ :hlen },
      args:          ->{ [key] },
      redis_result:  ->{ 2 },
      read:          ->{ true }
    }, {
      method:        ->{ :hmget },
      args:          ->{ [key, :field1, :field2] },
      redis_result:  ->{ ['value1', 'value2'] },
      read:          ->{ true }
    }, {
      method:        ->{ :hstrlen },
      args:          ->{ [key, :field] },
      redis_result:  ->{ 0 },
      read:          ->{ true }
    }
  ]
end
