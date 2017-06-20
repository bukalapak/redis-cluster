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
    }, {
      method:        ->{ :sdiff },
      multi_keys:    ->{ true },
      args:          ->{ key },
      redis_result:  ->{ ['wew'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sdiffstore },
      multi_keys:    ->{ true },
      destination:   ->{ '{wow}3' },
      args:          ->{ [destination, key].flatten },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }, {
      method:        ->{ :sinter },
      multi_keys:    ->{ true },
      args:          ->{ key },
      redis_result:  ->{ ['waw'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sinterstore },
      multi_keys:    ->{ true },
      destination:   ->{ '{wow}3' },
      args:          ->{ [destination, key].flatten },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }, {
      method:        ->{ :smove },
      multi_keys:    ->{ true },
      args:          ->{ [key, 'waw'].flatten },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :sunion },
      multi_keys:    ->{ true },
      args:          ->{ key },
      redis_result:  ->{ ['waw', 'wew', 'wuw'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sunionstore },
      multi_keys:    ->{ true },
      destination:   ->{ '{wow}3' },
      args:          ->{ [destination, key].flatten },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }
  ]
end
