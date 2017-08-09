# frozen_string_literal: true
require 'redis/cluster/function/list'

describe Redis::Cluster::Function::List do
  include_examples 'redis function', [
    {
      method:        ->{ :llen },
      args:          ->{ [key] },
      redis_result:  ->{ 2 },
      read:          ->{ true }
    }, {
      method:        ->{ :lpush },
      args:          ->{ [key, 'value'] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :lpushx },
      args:          ->{ [key, 'value'] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :rpush },
      args:          ->{ [key, 'value'] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :rpushx },
      args:          ->{ [key, 'value'] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :lpop },
      args:          ->{ [key] },
      redis_result:  ->{ '2' },
      read:          ->{ false }
    }, {
      method:        ->{ :rpop },
      args:          ->{ [key] },
      redis_result:  ->{ '2' },
      read:          ->{ false }
    }, {
      method:        ->{ :lindex },
      args:          ->{ [key, 0] },
      redis_result:  ->{ '2' },
      read:          ->{ true }
    }, {
      method:        ->{ :linsert },
      args:          ->{ [key, :AFTER, :wew, 'value'] },
      redis_result:  ->{ '2' },
      read:          ->{ false }
    }, {
      method:        ->{ :lrange },
      args:          ->{ [key, 0, -1] },
      redis_result:  ->{ ['2', '3'] },
      read:          ->{ true }
    }, {
      method:        ->{ :lrem },
      args:          ->{ [key, 0, :wew] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :lset },
      args:          ->{ [key, 0, :wew] },
      redis_result:  ->{ 'OK' },
      read:          ->{ false }
    }, {
      method:        ->{ :ltrim },
      args:          ->{ [key, 1, -3] },
      redis_result:  ->{ 'OK' },
      read:          ->{ false }
    }
  ]
end
