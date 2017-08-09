# frozen_string_literal: true
require 'redis'

require_relative 'version'

class Redis
  class Cluster

    # Client is a decorator object for Redis::Client. It add queue to support pipelining and another
    # useful addition
    class Client
      attr_reader :client, :queue, :url

      def initialize(opts)
        @client = Redis::Client.new(opts)
        @queue = []
        @url = "#{client.host}:#{client.port}"
      end

      def inspect
        "#<Redis::Cluster client v#{Redis::Cluster::VERSION} for #{url}>"
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
        return nil if queue.empty?

        result = Array.new(queue.size)
        client.process(queue) do
          queue.size.times do |i|
            result[i] = client.read
          end
        end
        @queue = []

        return result
      end
    end
  end
end
