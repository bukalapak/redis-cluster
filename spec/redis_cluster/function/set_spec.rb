# frozen_string_literal: true
require 'redis_cluster/function/set'

describe RedisCluster::Function::Set do
  include_examples 'redis function', [
    {
      method:        ->{ :scard },
      args:          ->{ [key] },
      redis_result:  ->{ 2 },
      read:          ->{ true }
    }, {
      method:        ->{ :sadd },
      args:          ->{ [key, [:waw, :wew]] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :srem },
      args:          ->{ [key, [:waw, :wew]] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :spop },
      args:          ->{ [key, 2] },
      redis_result:  ->{ ['waw', 'wew'] },
      read:          ->{ false }
    }, {
      method:        ->{ :srandmember },
      args:          ->{ [key] },
      redis_result:  ->{ ['waw'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sismember },
      args:          ->{ [key, :waw] },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ true }
    }, {
      method:        ->{ :smembers },
      args:          ->{ [key] },
      redis_result:  ->{ ['waw', 'wew'] },
      read:          ->{ true }
    }
  ]
end
