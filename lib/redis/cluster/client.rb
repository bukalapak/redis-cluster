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
        return [] if queue.empty?

        result = Array.new(queue.size)       
        reconnect = @reconnect

        begin
          exception = nil

          process(queue) do
            result[0] = read

            @reconnect = false
          
            (queue.size - 1).times do |i|
              reply = read
              result[i + 1] = reply
              exception = reply if exception.nil? && reply.is_a?(CommandError)
            end
          end

          raise exception if exception
        ensure
          @reconnect = reconnect
        end

        result.pop if result.last == "OK"
        result
      end
    end
  end
end
