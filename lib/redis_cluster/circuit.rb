# frozen_string_literal: true

class RedisCluster

  # Circuit is circuit breaker for RedisCluster.
  class Circuit

    attr_reader :fail_count, :ban_until

    def initialize(threshold, interval)
      @ban_until = Time.now
      @fail_count = 0
      @last_fail_time = Time.now
      @fail_threshold = threshold
      @interval_time = interval
    end

    # Failed is a method to add failed count and compare it to threshold,
    # Will trip circuit if the count goes through threshold.
    #
    # @return[void]
    def failed
      @fail_count = 0 if @last_fail_time + (@interval_time * 1.5) < Time.now
      @fail_count += 1
      @last_fail_time = Time.now
      open! if @fail_count >= @fail_threshold
    end

    # Open! is a method to update ban time.
    #
    # @return[void]
    def open!
      @ban_until = Time.now + @interval_time
    end

    # Open? is a method to check if the circuit breaker status.
    #
    # @return[Boolean] Wheter the circuit is open or not
    def open?
      @ban_until > Time.now
    end

  end
end
