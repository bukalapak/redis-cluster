# frozen_string_literal: true

class RedisCluster

  # Middlewares is collection for RedisCluster middleware.
  class Middlewares
    attr_reader :middlewares

    def initialize
      @middlewares = Hash.new{ |h, k| h[k] = [] }
    end

    def register(name, callable = nil, &block)
      return if !callable && !block_given?

      middlewares[name] << callable || block
    end

    def invoke(name, *args, &block)
      callback = middlewares[name].reduce(block) do |acc, obs|
        proc{ obs.call(*args, &acc) }
      end

      callback.call
    end
  end
end
