# frozen_string_literal: true
require 'redis'

class RedisCluster

  # Client is a decorator object for Redis::Client. It add queue to support pipelining and another
  # useful addition
  class Client
    attr_reader :client, :queue, :url

    def initialize(opts)
      @client = Redis::Client.new(opts)
      @queue = []
      @url = "#{client.host}:#{client.port}"
    end

    def call(command, &block)
      push(command)
      commit(&block)
    end

    def push(command)
      queue << command
    end

    def commit
      return nil if queue.empty?

      result = Array.new(queue.size)
      client.process(queue) do
        queue.size.times do |i|
          result[i] = client.read
        end
      end
      @queue = []

      reply = result.size > 1 ? result : result.first
      block_given? ? yield(reply) : reply
    end
  end
end
