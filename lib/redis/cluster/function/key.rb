# frozen_string_literal: true
require 'redis'

class Redis
  class Cluster
    module Function

      # Key implement redis keys commands. There will be some adjustment for cluster.
      # see https://redis.io/commands#generic. Most of the code are copied from
      # https://github.com/redis/redis-rb/blob/master/lib/redis.rb.
      #
      # SETTER = [:del, :expire, :pexpire, :restore]
      # GETTER = [:exists, :ttl, :pttl, :type]
      module Key

        # Delete one key.
        #
        # @param [String] key
        # @return [Boolean] whether the key was deleted or not
        def del(key)
          call(:del, key, transform: Redis::Boolify)
        end

        # Set a key's time to live in seconds.
        #
        # @param [String] key
        # @param [Fixnum] seconds time to live
        # @return [Boolean] whether the timeout was set or not
        def expire(key, seconds)
          call(:expire, key, seconds, transform: Redis::Boolify)
        end

        # Set a key's time to live in milliseconds.
        #
        # @param [String] key
        # @param [Fixnum] milliseconds time to live
        # @return [Boolean] whether the timeout was set or not
        def pexpire(key, milliseconds)
          call(:pexpire, key, milliseconds, transform: Redis::Boolify)
        end

        # Determine if a key exists.
        #
        # @param [String] key
        # @return [Boolean]
        def exists(key)
          call(:exists, key, transform: Redis::Boolify, read: true)
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
          call(:ttl, key, read: true)
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
          call(:pttl, key, read: true)
        end

        # Determine the type stored at key.
        #
        # @param [String] key
        # @return [String] `string`, `list`, `set`, `zset`, `hash` or `none`
        def type(key)
          call(:type, key, read: true)
        end

        # Create a key using the serialized value, previously obtained using DUMP.
        #
        # @param [String] key
        # @param [String] ttl
        # @param [String] serialized_value
        # @param [Hash] options
        #   - `replace: true`: replace existing key
        # @return [String] `"OK"`
        def restore(key, ttl, serialized_value, option = {})
          args = [:restore, key, ttl, serialized_value]
          args << 'REPLACE' if option[:replace]

          call(*args)
        end

        # Return a serialized version of the value stored at a key.
        #
        # @param [String] key
        # @return [String] serialized_value
        def dump(key)
          call(:dump, key, read: true)
        end
      end
    end
  end
end
