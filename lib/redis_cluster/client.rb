# frozen_string_literal: true

require 'redis'

require_relative 'version'

class RedisCluster

  # LoadingStateError is an error when try to read redis that in loading state.
  class LoadingStateError < StandardError; end

  # CircuitOpenError is an error that fired when circuit in client is trip.
  class CircuitOpenError < StandardError; end

  # Client is a decorator object for Redis::Client. It add queue to support pipelining and another
  # useful addition
  class Client
    attr_reader :client, :queue, :url
    attr_accessor :middlewares, :circuit

    def initialize(opts)
      @client = Redis::Client.new(opts)
      @queue = []
      @url = "#{client.host}:#{client.port}"
      @ready = false
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

    # Healthy? will retrun true if circuit breaker is not open and Redis Client is ready.
    # Redis Client will be ready if it already sent with `readonly` command.
    #
    # return [Boolean] Whether client is healthy or not.
    def healthy?
      return false if @circuit.open?
      prepare unless @ready

      true
    rescue StandardError
      false
    end

    private

    def _commit
      raise CircuitOpenError, "Circuit open in client #{url} until #{@circuit.ban_until}" if @circuit.open?
      return nil if queue.empty?

      result = Array.new(queue.size)
      client.process(queue) do
        queue.size.times do |i|
          result[i] = client.read

          if result[i].is_a?(Redis::CommandError) && result[i].message['LOADING']
            @circuit.open!
            raise LoadingStateError, "Client #{url} is in Loading State"
          end
        end
      end

      result
    rescue LoadingStateError, CircuitOpenError, Redis::BaseConnectionError => e
      @circuit.failed
      @ready = false if @circuit.open?

      [e] # return this
    ensure
      @queue = []
    end

    def prepare
      call([:readonly])
      @ready = true
    end
  end
end
