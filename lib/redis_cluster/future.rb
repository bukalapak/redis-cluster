# frozen_string_literal: true
require 'redis'

class RedisCluster

  # Future basically act the same way as Redis::Future with some modification
  class Future
    attr_reader :key, :command
    attr_accessor :url

    NOOP = ->(v){ v }

    def initialize(key, command, url, transformation)
      @key = key
      @command = command
      @url = url
      @transformation = transformation || NOOP
      @value = Redis::Future::FutureNotReady
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
