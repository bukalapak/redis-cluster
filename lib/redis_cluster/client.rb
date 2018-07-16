# frozen_string_literal: true

require 'redis'

require_relative 'version'

class RedisCluster

  class LoadingStateError < StandardError; end

  # Client is a decorator object for Redis::Client. It add queue to support pipelining and another
  # useful addition
  class Client
    attr_reader :client, :queue, :url
    attr_accessor :middlewares

    def initialize(opts)
      @client = Redis::Client.new(opts)
      @queue = []
      @url = "#{client.host}:#{client.port}"

      @healthy = true
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
      return true if @healthy

      # ban for 60 seconds for unhealthy state
      if Time.now - @ban_from > 60
        @healthy = true
        @ban_from = nil
      end

      @healthy
    end

    private

    def _commit
      return nil if queue.empty?

      result = Array.new(queue.size)
      client.process(queue) do
        queue.size.times do |i|
          result[i] = client.read

          unhealthy! if result[i].is_a?(Redis::CommandError) && result[i].message['LOADING']
        end
      end

      result
    ensure
      @queue = []
    end

    def unhealthy!
      @healthy = false
      @ban_from = Time.now
      raise LoadingStateError
    end
  end
end
