# frozen_string_literal: true
require 'redis'

require_relative '../transformation'

class RedisCluster
  module Function

    # Hash implement redis hashes commands. There will be some adjustment for cluster.
    # see https://redis.io/commands#hash. Most of the code are copied from
    # https://github.com/redis/redis-rb/blob/master/lib/redis.rb.
    #
    # SETTER = [:hdel, :hincrby, :hincrbyfloat, :hmset, :hset, :hsetnx]
    # GETTER = [:hexists, :hget, :hgetall, :hkeys, :hlen, :hmget, :hstrlen, :hvals, :hscan]
    module Hash

      # Delete one or more hash fields.
      #
      # @param [String] key
      # @param [String, Array<String>] field
      # @return [Fixnum] the number of fields that were removed from the hash
      def hdel(key, field)
        call(key, [:hdel, key, field])
      end

      # Increment the integer value of a hash field by the given integer number.
      #
      # @param [String] key
      # @param [String] field
      # @param [Fixnum] increment
      # @return [Fixnum] value of the field after incrementing it
      def hincrby(key, field, increment)
        call(key, [:hincrby, key, field, increment])
      end

      # Increment the numeric value of a hash field by the given float number.
      #
      # @param [String] key
      # @param [String] field
      # @param [Float] increment
      # @return [Float] value of the field after incrementing it
      def hincrbyfloat(key, field, increment)
        call(key, [:hincrbyfloat, key, field, increment], Redis::Floatify)
      end

      # Set one or more hash values.
      #
      # @example
      #   redis.hmset("hash", "f1", "v1", "f2", "v2")
      #     # => "OK"
      #
      # @param [String] key
      # @param [Array<String>] attrs array of fields and values
      # @return [String] `"OK"`
      def hmset(key, *attrs)
        call(key, [:hmset, key] + attrs)
      end

      # Set the string value of a hash field.
      #
      # @param [String] key
      # @param [String] field
      # @param [String] value
      # @return [Boolean] whether or not the field was **added** to the hash
      def hset(key, field, value)
        call(key, [:hset, key, field, value], Redis::Boolify)
      end

      # Set the value of a hash field, only if the field does not exist.
      #
      # @param [String] key
      # @param [String] field
      # @param [String] value
      # @return [Boolean] whether or not the field was **added** to the hash
      def hsetnx(key, field, value)
        call(key, [:hsetnx, key, field, value], Redis::Boolify)
      end

      # Determine if a hash field exists.
      #
      # @param [String] key
      # @param [String] field
      # @return [Boolean] whether or not the field exists in the hash
      def hexists(key, field)
        call(key, [:hexists, key, field], Redis::Boolify)
      end

      # Get the value of a hash field.
      #
      # @param [String] key
      # @param [String] field
      # @return [String]
      def hget(key, field)
        call(key, [:hget, key, field])
      end

      # Get all the fields and values in a hash.
      #
      # @param [String] key
      # @return [Hash<String, String>]
      def hgetall(key)
        call(key, [:hgetall, key], Redis::Hashify)
      end

      # Get all the fields in a hash.
      #
      # @param [String] key
      # @return [Array<String>]
      def hkeys(key)
        call(key, [:hkeys, key])
      end

      # Get all the values in a hash.
      #
      # @param [String] key
      # @return [Array<String>]
      def hvals(key)
        call(key, [:hvals, key])
      end

      # Get the number of fields in a hash.
      #
      # @param [String] key
      # @return [Fixnum] number of fields in the hash
      def hlen(key)
        call(key, [:hlen, key])
      end

      # Get the values of all the given hash fields.
      #
      # @example
      #   redis.hmget("hash", "f1", "f2")
      #     # => ["v1", "v2"]
      #
      # @param [String] key
      # @param [Array<String>] fields array of fields
      # @return [Array<String>] an array of values for the specified fields
      def hmget(key, *fields)
        call(key, [:hmget, key] + fields)
      end

      # Returns the string length of the value associated with field in the hash stored at key.
      #
      # @param [String] key
      # @param [String] field
      # @return [Fixnum] String lenght
      def hstrlen(key, field)
        call(key, [:hstrlen, key, field])
      end

      # Scan a hash
      #
      # @example Retrieve the first batch of key/value pairs in a hash
      #   redis.hscan("hash", 0)
      #
      # @param [String, Integer] cursor the cursor of the iteration
      # @param [Hash] options
      #   - `:match => String`: only return keys matching the pattern
      #   - `:count => Integer`: return count keys at most per iteration
      #
      # @return [String, Array<[String, String]>] the next cursor and all found keys
      def hscan(key, cursor, options = {})
        args = [:hscan, key, cursor]
        args.push('MATCH', options[:match]) if options[:match]
        args.push('COUNT', options[:count]) if options[:count]

        call(key, args, HSCAN)
      end
    end
  end
end
