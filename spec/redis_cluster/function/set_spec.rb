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
      args:          ->{ [key, [:value1, :value2]] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :srem },
      args:          ->{ [key, [:value1, :value2]] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :spop },
      args:          ->{ [key, 2] },
      redis_result:  ->{ ['value1', 'value2'] },
      read:          ->{ false }
    }, {
      method:        ->{ :srandmember },
      args:          ->{ [key] },
      redis_result:  ->{ ['value'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sismember },
      args:          ->{ [key, :value] },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ true }
    }, {
      method:        ->{ :smembers },
      args:          ->{ [key] },
      redis_result:  ->{ ['value1', 'value2'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sdiff },
      multi_keys:    ->{ true },
      args:          ->{ key },
      redis_result:  ->{ ['value'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sdiffstore },
      multi_keys:    ->{ true },
      destination:   ->{ '{key}3' },
      args:          ->{ [destination, key].flatten },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }, {
      method:        ->{ :sinter },
      multi_keys:    ->{ true },
      args:          ->{ key },
      redis_result:  ->{ ['value'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sinterstore },
      multi_keys:    ->{ true },
      destination:   ->{ '{key}3' },
      args:          ->{ [destination, key].flatten },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }, {
      method:        ->{ :smove },
      multi_keys:    ->{ true },
      args:          ->{ [key, 'value'].flatten },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :sunion },
      multi_keys:    ->{ true },
      args:          ->{ key },
      redis_result:  ->{ ['value1', 'value2', 'value3'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sunionstore },
      multi_keys:    ->{ true },
      destination:   ->{ '{key}3' },
      args:          ->{ [destination, key].flatten },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }
  ]
end
