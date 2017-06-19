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
      key:           ->{ ['{wow}1', '{wow}2'] },
      args:          ->{ key },
      redis_result:  ->{ ['wew'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sdiffstore },
      key:           ->{ ['{wow}1', '{wow}2'] },
      args:          ->{ ['{wow}3', key].flatten },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }, {
      method:        ->{ :sinter },
      key:           ->{ ['{wow}1', '{wow}2'] },
      args:          ->{ key },
      redis_result:  ->{ ['waw'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sinterstore },
      key:           ->{ ['{wow}1', '{wow}2'] },
      args:          ->{ ['{wow}3', key].flatten },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }, {
      method:        ->{ :smove },
      key:           ->{ ['{wow}1', '{wow}2'] },
      args:          ->{ [key, 'waw'].flatten },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :sunion },
      key:           ->{ ['{wow}1', '{wow}2'] },
      args:          ->{ key },
      redis_result:  ->{ ['waw', 'wew', 'wuw'] },
      read:          ->{ true }
    }, {
      method:        ->{ :sunionstore },
      key:           ->{ ['{wow}1', '{wow}2'] },
      args:          ->{ ['{wow}3', key].flatten },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }
  ]
end
