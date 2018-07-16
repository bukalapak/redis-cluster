# frozen_string_literal: true

require 'redis'

require_relative 'version'

class RedisCluster

  # Client is a decorator object for Redis::Client. It add queue to support pipelining and another
  # useful addition
  class Client
    attr_reader :client, :queue, :url
    attr_accessor :middlewares

    def initialize(opts)
      @client = Redis::Client.new(opts)
      @queue = []
      @url = "#{client.host}:#{client.port}"

      @loading = false
      @ban_from = nil
    end

    def inspect
      "#<RedisCluster client v#{RedisCluster::VERSION} for #{url}>"
    end

    def connected?
      client.connected?
    end

    def close
      client.disconnect
    end

    def call(command)
      push(command)
      commit.last
    end

    def push(command)
      queue << command
    end

    def commit
      return _commit unless middlewares

      middlewares.invoke(:commit, self) do
        _commit
      end
    end

    def healthy
      return true unless @loading

      # ban for 60 seconds for loading state
      if Time.now - @ban_from > 60
        @loading = false
        @ban_from = nil
      end

      !@loading
    end

    private

    def _commit
      return nil if queue.empty?

      result = Array.new(queue.size)
      client.process(queue) do
        queue.size.times do |i|
          result[i] = client.read
        end
      end
      @queue = []

      if result.last.is_a?(Redis::CommandError) && result.last.message['LOADING']
        @loading = true
        @ban_from = Time.now
      end

      result
    end
  end
end
