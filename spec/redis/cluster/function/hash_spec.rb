# frozen_string_literal: true
require 'redis/cluster/function/hash'

describe Redis::Cluster::Function::Hash do
  include_examples 'redis function', [
    {
      method:        ->{ :hdel },
      args:          ->{ [key, [:aw, :ew]] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :hincrby },
      args:          ->{ [key, :aw, 1] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :hincrbyfloat },
      args:          ->{ [key, :aw, 1.1] },
      redis_result:  ->{ '3.1' },
      transform:     ->{ Redis::Floatify },
      read:          ->{ false }
    }, {
      method:        ->{ :hmset },
      args:          ->{ [key, :aw, 1, :ew, 2] },
      redis_result:  ->{ 'OK' },
      read:          ->{ false }
    }, {
      method:        ->{ :hset },
      args:          ->{ [key, :aw, 1] },
      redis_result:  ->{ 0 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :hsetnx },
      args:          ->{ [key, :aw, 1] },
      redis_result:  ->{ 0 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :hexists },
      args:          ->{ [key, :aw] },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ true }
    }, {
      method:        ->{ :hget },
      args:          ->{ [key, :aw] },
      redis_result:  ->{ 'waw' },
      read:          ->{ true }
    }, {
      method:        ->{ :hgetall },
      args:          ->{ [key] },
      redis_result:  ->{ ['waw', '2', 'wew', '2'] },
      transform:     ->{ Redis::Hashify },
      read:          ->{ true }
    }, {
      method:        ->{ :hkeys },
      args:          ->{ [key] },
      redis_result:  ->{ ['waw', 'wew'] },
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
      args:          ->{ [key, :waw, :wew] },
      redis_result:  ->{ ['waw', 'wew'] },
      read:          ->{ true }
    }, {
      method:        ->{ :hstrlen },
      args:          ->{ [key, :aw] },
      redis_result:  ->{ 0 },
      read:          ->{ true }
    }
  ]
end
