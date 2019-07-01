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

    def failed
      @fail_count = 0 if (@last_fail_time + @interval_time).utc < Time.now
      @fail_count += 1
      @last_fail_time = Time.now
      open! if @fail_count >= @fail_threshold
    end

    def open!
      @ban_until = (Time.now + @interval_time).utc
    end

    def open?
      return false if @ban_until <= Time.now
      true
    end

  end
end
