# frozen_string_literal: true
require 'redis_cluster/function/string'

describe RedisCluster::Function::String do
  include_examples 'redis function', [
    {
      method:        ->{ :decr },
      args:          ->{ [key] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :decrby },
      args:          ->{ [key, 2] },
      redis_result:  ->{ 0 },
      read:          ->{ false }
    }, {
      method:        ->{ :incr },
      args:          ->{ [key] },
      redis_result:  ->{ 1 },
      read:          ->{ false }
    }, {
      method:        ->{ :incrby },
      args:          ->{ [key, 2] },
      redis_result:  ->{ 3 },
      read:          ->{ false }
    }, {
      method:        ->{ :incrbyfloat },
      args:          ->{ [key, 1.1] },
      redis_result:  ->{ '4.1' },
      transform:     ->{ Redis::Floatify },
      read:          ->{ false }
    }, {
      method:        ->{ :set },
      args:          ->{ [key, 'waw', px: 1000, nx: true] },
      redis_command: ->{ [method, key, 'waw', 'PX', 1000, 'NX'] },
      redis_result:  ->{ 'OK' },
      transform:     ->{ Redis::BoolifySet },
      read:          ->{ false }
    }, {
      method:        ->{ :setex },
      args:          ->{ [key, 10, 'waw'] },
      redis_result:  ->{ 'OK' },
      read:          ->{ false }
    }, {
      method:        ->{ :psetex },
      args:          ->{ [key, 1000, 'waw'] },
      redis_result:  ->{ 'OK' },
      read:          ->{ false }
    }, {
      method:        ->{ :setnx },
      args:          ->{ [key, 'wow'] },
      redis_command: ->{ [method] + args },
      redis_result:  ->{ nil },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :get },
      args:          ->{ [key] },
      redis_result:  ->{ 'wow' },
      read:          ->{ true }
    }, {
      method:        ->{ :setrange },
      args:          ->{ [key, 1, 'wow'] },
      redis_result:  ->{ 4 },
      read:          ->{ false }
    }, {
      method:        ->{ :getrange },
      args:          ->{ [key, 0, -1] },
      redis_result:  ->{ 'wwow' },
      read:          ->{ true }
    }, {
      method:        ->{ :setbit },
      args:          ->{ [key, 0, 1] },
      redis_result:  ->{ "\x01" },
      read:          ->{ false }
    }, {
      method:        ->{ :getbit },
      args:          ->{ [key, 0] },
      redis_result:  ->{ 1 },
      read:          ->{ true }
    }, {
      method:        ->{ :append },
      args:          ->{ [key, 'waw'] },
      redis_result:  ->{ "\x01waw" },
      read:          ->{ false }
    }, {
      method:        ->{ :bitcount },
      args:          ->{ [key, 0, 8] },
      redis_result:  ->{ 1 },
      read:          ->{ true }
    }, {
      method:        ->{ :bitpos },
      args:          ->{ [key, 0, nil, 8] },
      redis_command: ->{ [method, key, 0] },
      redis_result:  ->{ 1 },
      read:          ->{ true }
    }, {
      method:        ->{ :getset },
      args:          ->{ [key, 'waw'] },
      redis_result:  ->{ 'wow' },
      read:          ->{ false }
    }, {
      method:        ->{ :strlen },
      args:          ->{ [key] },
      redis_result:  ->{ 3 },
      read:          ->{ true }
    }
  ]
end
