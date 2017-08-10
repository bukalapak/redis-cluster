# frozen_string_literal: true
require 'redis/cluster/function/key'

describe Redis::Cluster::Function::Key do
  include_examples 'redis function', [
    {
      method:        ->{ :del },
      args:          ->{ [key] },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :expire },
      args:          ->{ [key, 5] },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :pexpire },
      args:          ->{ [key, 5000] },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ false }
    }, {
      method:        ->{ :exists },
      args:          ->{ [key] },
      redis_result:  ->{ 1 },
      transform:     ->{ Redis::Boolify },
      read:          ->{ true }
    }, {
      method:        ->{ :ttl },
      args:          ->{ [key] },
      redis_result:  ->{ 1 },
      read:          ->{ true }
    }, {
      method:        ->{ :pttl },
      args:          ->{ [key] },
      redis_result:  ->{ 1000 },
      read:          ->{ true }
    }, {
      method:        ->{ :type },
      args:          ->{ [key] },
      redis_result:  ->{ 'string' },
      read:          ->{ true }
    }, {
      method:        ->{ :restore },
      args:          ->{ [key, 1000, 'serialized_value'] },
      redis_result:  ->{ 'OK' },
      read:          ->{ false }
    }, {
      method:        ->{ :dump },
      args:          ->{ [key] },
      redis_result:  ->{ 'string' },
      read:          ->{ true }
    }
  ]
end
