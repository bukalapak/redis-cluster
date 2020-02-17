# frozen_string_literal: true

class RedisCluster

  # Circuit is circuit breaker for RedisCluster.
  class Circuit

    attr_reader :fail_count, :ban_until, :causes, :trigger, :middlewares

    # Create new circuit
    #
    # @param [int] threshold: threshold before the circuit open
    # @param [time] interval: use to increase ban_until when the circuit open
    # @param [RedisCluster::Middlewares] middlewares: Redis cluster middleware
    def initialize(threshold, interval, middlewares)
      @ban_until = Time.at 0
      @fail_count = 0
      @last_fail_time = Time.now
      @fail_threshold = threshold
      @interval_time = interval
      @middlewares = middlewares

      @causes = []
      @trigger = nil
    end

    # Failed is a method to add failed count and compare it to threshold,
    # Will trip circuit if the count goes through threshold.
    #
    # @param [Exception] err: exception that caused circuit failed
    # @return[void]
    def failed(err)
      if @last_fail_time + (@interval_time * 1.5) < Time.now
        @fail_count = 0
        @causes = []
      end
      @fail_count += 1
      @last_fail_time = Time.now
      @causes << err
      open!('failure') if @fail_count >= @fail_threshold
    end

    # Open! is a method to update ban time.
    # will trigger middleware[:circuit] if exist
    #
    # @param [string] trigger: message to indicate why the circuit open
    # @return[void]
    def open!(trigger)
      @trigger = trigger

      unless middlewares
        @ban_until = Time.now + @interval_time
        return
      end

      middlewares.invoke(:circuit, self) do
        @ban_until = Time.now + @interval_time
      end
    end

    # Open? is a method to check if the circuit breaker status.
    #
    # @return[Boolean] Wheter the circuit is open or not
    def open?
      @ban_until > Time.now
    end

  end
end
