# frozen_string_literal: true

require 'redis'

class RedisCluster
  module Function

    # String implement redis strings commands. There will be some adjustment for cluster.
    # see https://redis.io/commands#string. Most of the code are copied from
    # https://github.com/redis/redis-rb/blob/master/lib/redis.rb.
    #
    # SETTER = [:getset, :append, :setbit, :setrange, :set, :setex, :psetex, :setnx, :incr,
    #           :incrby, :incrbyfloat, :decr, :decrby]
    # GETTER = [:strlen, :bitpos, :bitcount, :getbit, :getrange, :get]
    module String

      # Decrement the integer value of a key by one.
      #
      # @example
      #   redis.decr("value")
      #     # => 4
      #
      # @param [String] key
      # @return [Fixnum] value after decrementing it
      def decr(key)
        call(key, [:decr, key])
      end

      # Decrement the integer value of a key by the given number.
      #
      # @example
      #   redis.decrby("value", 5)
      #     # => 0
      #
      # @param [String] key
      # @param [Fixnum] decrement
      # @return [Fixnum] value after decrementing it
      def decrby(key, decrement)
        call(key, [:decrby, key, decrement])
      end

      # Increment the integer value of a key by one.
      #
      # @example
      #   redis.incr("value")
      #     # => 6
      #
      # @param [String] key
      # @return [Fixnum] value after incrementing it
      def incr(key)
        call(key, [:incr, key])
      end

      # Increment the integer value of a key by the given integer number.
      #
      # @example
      #   redis.incrby("value", 5)
      #     # => 10
      #
      # @param [String] key
      # @param [Fixnum] increment
      # @return [Fixnum] value after incrementing it
      def incrby(key, increment)
        call(key, [:incrby, key, increment])
      end

      # Increment the numeric value of a key by the given float number.
      #
      # @example
      #   redis.incrbyfloat("value", 1.23)
      #     # => 1.23
      #
      # @param [String] key
      # @param [Float] increment
      # @return [Float] value after incrementing it
      def incrbyfloat(key, increment)
        call(key, [:incrbyfloat, key, increment], transform: Redis::Floatify)
      end

      # Set the string value of a key.
      #
      # @param [String] key
      # @param [String] value
      # @param [Hash] options
      #   - `:ex => Fixnum`: Set the specified expire time, in seconds.
      #   - `:px => Fixnum`: Set the specified expire time, in milliseconds.
      #   - `:nx => true`: Only set the key if it does not already exist.
      #   - `:xx => true`: Only set the key if it already exist.
      # @return [String, Boolean] `"OK"` or true, false if `:nx => true` or `:xx => true`
      def set(key, value, options = {})
        ex = options[:ex]
        px = options[:px]
        args = [:set, key, value.to_s]

        args.concat(['EX', ex]) if ex
        args.concat(['PX', px]) if px
        args.concat(['NX']) if options[:nx]
        args.concat(['XX']) if options[:xx]

        call(key, args, transform: Redis::BoolifySet)
      end

      # Set the time to live in seconds of a key.
      #
      # @param [String] key
      # @param [Fixnum] ttl
      # @param [String] value
      # @return [String] `"OK"`
      def setex(key, ttl, value)
        call(key, [:setex, key, ttl, value.to_s])
      end

      # Set the time to live in milliseconds of a key.
      #
      # @param [String] key
      # @param [Fixnum] ttl
      # @param [String] value
      # @return [String] `"OK"`
      def psetex(key, ttl, value)
        call(key, [:psetex, key, ttl, value.to_s])
      end

      # Set the value of a key, only if the key does not exist.
      #
      # @param [String] key
      # @param [String] value
      # @return [Boolean] whether the key was set or not
      def setnx(key, value)
        call(key, [:setnx, key, value.to_s], transform: Redis::Boolify)
      end

      # Get the value of a key.
      #
      # @param [String] key
      # @return [String]
      def get(key)
        call(key, [:get, key], read: true)
      end

      # Overwrite part of a string at key starting at the specified offset.
      #
      # @param [String] key
      # @param [Fixnum] offset byte offset
      # @param [String] value
      # @return [Fixnum] length of the string after it was modified
      def setrange(key, offset, value)
        call(key, [:setrange, key, offset, value.to_s])
      end

      # Get a substring of the string stored at a key.
      #
      # @param [String] key
      # @param [Fixnum] start zero-based start offset
      # @param [Fixnum] stop zero-based end offset. Use -1 for representing
      #   the end of the string
      # @return [Fixnum] `0` or `1`
      def getrange(key, start, stop)
        call(key, [:getrange, key, start, stop], read: true)
      end

      # Sets or clears the bit at offset in the string value stored at key.
      #
      # @param [String] key
      # @param [Fixnum] offset bit offset
      # @param [Fixnum] value bit value `0` or `1`
      # @return [Fixnum] the original bit value stored at `offset`
      def setbit(key, offset, value)
        call(key, [:setbit, key, offset, value])
      end

      # Returns the bit value at offset in the string value stored at key.
      #
      # @param [String] key
      # @param [Fixnum] offset bit offset
      # @return [Fixnum] `0` or `1`
      def getbit(key, offset)
        call(key, [:getbit, key, offset], read: true)
      end

      # Append a value to a key.
      #
      # @param [String] key
      # @param [String] value value to append
      # @return [Fixnum] length of the string after appending
      def append(key, value)
        call(key, [:append, key, value])
      end

      # Count the number of set bits in a range of the string value stored at key.
      #
      # @param [String] key
      # @param [Fixnum] start start index
      # @param [Fixnum] stop stop index
      # @return [Fixnum] the number of bits set to 1
      def bitcount(key, start = 0, stop = -1)
        call(key, [:bitcount, key, start, stop], read: true)
      end

      # Return the position of the first bit set to 1 or 0 in a string.
      #
      # @param [String] key
      # @param [Fixnum] bit whether to look for the first 1 or 0 bit
      # @param [Fixnum] start start index
      # @param [Fixnum] stop stop index
      # @return [Fixnum] the position of the first 1/0 bit.
      #                  -1 if looking for 1 and it is not found or start and stop are given.
      def bitpos(key, bit, start = nil, stop = nil)
        command = [:bitpos, key, bit]
        command << start if start
        command << stop if start && stop

        call(key, command, read: true)
      end

      # Set the string value of a key and return its old value.
      #
      # @param [String] key
      # @param [String] value value to replace the current value with
      # @return [String] the old value stored in the key, or `nil` if the key
      #   did not exist
      def getset(key, value)
        call(key, [:getset, key, value.to_s])
      end

      # Get the length of the value stored in a key.
      #
      # @param [String] key
      # @return [Fixnum] the length of the value stored in the key, or 0
      #   if the key does not exist
      def strlen(key)
        call(key, [:strlen, key], read: true)
      end
    end
  end
end
