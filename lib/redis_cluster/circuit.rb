# frozen_string_literal: true

class RedisCluster

  # Circuit is circuit breaker for RedisCluster.
  class Circuit

    attr_reader :fail_count, :ban_until

    DEFAULT_FAIL_THRESHOLD  = 5
    DEFAULT_INTERVAL_SECOND = 5

    def initialize
      @ban_until = Time.now
      @fail_count = 0
      @fail_threshold = DEFAULT_FAIL_THRESHOLD
      @last_fail_time = Time.now
      @interval_time = DEFAULT_INTERVAL_SECOND
    end

    def failed
      @fail_count = 0 if (@last_fail_time + @interval_time).utc < Time.now
      @fail_count += 1
      open! if @fail_count >= @fail_threshold
    end

    def open!
      @ban_until = (Time.now + @interval_time).utc
    end

    def open?
      return false if @ban_until < Time.now
      true
    end

  end
end
