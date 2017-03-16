# frozen_string_literal: true
require 'redis'

class RedisCluster

  # Future basically act the same way as Redis::Future with some modification
  class Future
    attr_reader :key, :command
    attr_accessor :asking

    def initialize(key, command, transformation)
      @key = key
      @command = command
      @transformation = transformation
      @value = Redis::Future::FutureNotReady
      @asking = false
    end

    def value(raised: true)
      raise @value if raised && @value.is_a?(::RuntimeError)
      @value
    end

    def value=(value)
      @value = @transformation.call(value)
    end
  end
end
