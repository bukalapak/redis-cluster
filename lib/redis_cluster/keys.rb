# frozen_string_literal: true
require 'redis'

class RedisCluster

  # Keys implement redis keys commands. There will be some adjustment for cluster.
  # see https://redis.io/commands#generic. Most of the code are copied from
  # https://github.com/redis/redis-rb/blob/master/lib/redis.rb.
  #
  # SETTER = [:del, :expire, :pexpire]
  # GETTER = [:exists, :ttl, :pttl]
  module Keys

    # Delete one key.
    #
    # @param [String] key
    # @return [Boolean] whether the key was deleted or not
    def del(key)
      call(key, [:del, key], Redis::Boolify)
    end

    # Set a key's time to live in seconds.
    #
    # @param [String] key
    # @param [Fixnum] seconds time to live
    # @return [Boolean] whether the timeout was set or not
    def expire(key, seconds)
      call(key, [:expire, key, seconds], Redis::Boolify)
    end

    # Set a key's time to live in milliseconds.
    #
    # @param [String] key
    # @param [Fixnum] milliseconds time to live
    # @return [Boolean] whether the timeout was set or not
    def pexpire(key, milliseconds)
      call(key, [:pexpire, key, milliseconds], Redis::Boolify)
    end

    # Determine if a key exists.
    #
    # @param [String] key
    # @return [Boolean]
    def exists(key)
      call(key, [:exists, key], Redis::Boolify)
    end

    # Get the time to live (in seconds) for a key.
    #
    # @param [String] key
    # @return [Fixnum] remaining time to live in seconds.
    #
    # Starting with Redis 2.8 the return value in case of error changed:
    #
    #     - The command returns -2 if the key does not exist.
    #     - The command returns -1 if the key exists but has no associated expire.
    def ttl(key)
      call(key, [:ttl, key])
    end

    # Get the time to live (in milliseconds) for a key.
    #
    # @param [String] key
    # @return [Fixnum] remaining time to live in milliseconds
    #
    # Starting with Redis 2.8 the return value in case of error changed:
    #
    #     - The command returns -2 if the key does not exist.
    #     - The command returns -1 if the key exists but has no associated expire.
    def pttl(key)
      call(key, [:pttl, key])
    end
  end
end
