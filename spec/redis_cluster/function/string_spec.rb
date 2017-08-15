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
      args:          ->{ [key, 'value', px: 1000, nx: true] },
      redis_command: ->{ [method, key, 'value', 'PX', 1000, 'NX'] },
      redis_result:  ->{ 'OK' },
      transform:     ->{ Redis::BoolifySet },
      read:          ->{ false }
    }, {
      method:        ->{ :setex },
      args:          ->{ [key, 10, 'value'] },
      redis_result:  ->{ 'OK' },
      read:          ->{ false }
    }, {
      method:        ->{ :psetex },
      args:          ->{ [key, 1000, 'value'] },
      redis_result:  ->{ 'OK' },
      read:          ->{ false }
    }, {
      method:        ->{ :setnx },
      args:          ->{ [key, 'value'] },
      redis_command: ->{ [method] + args },
      redis_result:  ->{ nil },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :get },
      args:          ->{ [key] },
      redis_result:  ->{ 'value' },
      read:          ->{ true }
    }, {
      method:        ->{ :setrange },
      args:          ->{ [key, 1, 'value'] },
      redis_result:  ->{ 4 },
      read:          ->{ false }
    }, {
      method:        ->{ :getrange },
      args:          ->{ [key, 0, -1] },
      redis_result:  ->{ 'value' },
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
      args:          ->{ [key, 'value'] },
      redis_result:  ->{ "\x01value" },
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
      args:          ->{ [key, 'new_value'] },
      redis_result:  ->{ 'old_value' },
      read:          ->{ false }
    }, {
      method:        ->{ :strlen },
      args:          ->{ [key] },
      redis_result:  ->{ 3 },
      read:          ->{ true }
    }
  ]
end
