# frozen_string_literal: true

require_relative 'function/set'
require_relative 'function/key'
require_relative 'function/list'
require_relative 'function/hash'

class RedisCluster

  # Function include necessary redis function.
  module Function
    include Function::Set
    include Function::Key
    include Function::List
    include Function::Hash
  end
end
