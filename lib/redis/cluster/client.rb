# frozen_string_literal: true
require 'redis'

require_relative 'version'

class Redis
  class Cluster

    # Client is a decorator object for Redis::Client. It add queue to support pipelining and another
    # useful addition
    class Client < Client      
      attr_reader :queue, :url
      alias :close :disconnect

      def initialize(opts)
        super(opts)
        @queue = []
        @url = "#{scheme}://#{host}:#{port}"
      end

      def inspect
        "#<Redis::Cluster::Client v#{Redis::Cluster::VERSION} for #{url}>"
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
        process(queue) do
          queue.size.times do |i|
            result[i] = read
          end
        end
        @queue = []

        return result
      end
    end
  end
end
