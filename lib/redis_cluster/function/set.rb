# frozen_string_literal: true
require 'redis'

class RedisCluster
  module Function

    # Set implement redis sets commands. There will be some adjustment for cluster.
    # see https://redis.io/commands#set. Most of the code are copied from
    # https://github.com/redis/redis-rb/blob/master/lib/redis.rb.
    #
    # SETTER = [:sadd, :spop, :srem]
    # GETTER = [:scard, :sismembers, :smembers, :srandmember, :sscan]
    module Set

      # Get the number of members in a set.
      #
      # @param [String] key
      # @return [Fixnum]
      def scard(key)
        call(key, [:scard, key])
      end

      # Add one or more members to a set.
      #
      # @param [String] key
      # @param [String, Array<String>] member one member, or array of members
      # @return [Fixnum] number of members that were successfully added
      def sadd(key, member)
        call(key, [:sadd, key, member])
      end

      # Remove one or more members from a set.
      #
      # @param [String] key
      # @param [String, Array<String>] member one member, or array of members
      # @return [Boolean, Fixnum] number of members that were successfully removed
      def srem(key, member)
        call(key, [:srem, key, member])
      end

      # Remove and return one or more random member from a set.
      #
      # @param [String] key
      # @return [String]
      # @param [Fixnum] count
      def spop(key, count = nil)
        args = [:spop, key]
        args << count if count

        call(key, args)
      end

      # Get one or more random members from a set.
      #
      # @param [String] key
      # @param [Fixnum] count
      # @return [String]
      def srandmember(key, count = nil)
        args = [:srandmember, key]
        args << count if count

        call(key, args)
      end

      # Determine if a given value is a member of a set.
      #
      # @param [String] key
      # @param [String] member
      # @return [Boolean]
      def sismember(key, member)
        call(key, [:sismember, key, member], Redis::Boolify)
      end

      # Get all the members in a set.
      #
      # @param [String] key
      # @return [Array<String>]
      def smembers(key)
        call(key, [:smembers, key])
      end

      # Scan a set
      #
      # @example Retrieve the first batch of keys in a set
      #   redis.sscan("set", 0)
      #
      # @param [String, Integer] cursor the cursor of the iteration
      # @param [Hash] options
      #   - `:match => String`: only return keys matching the pattern
      #   - `:count => Integer`: return count keys at most per iteration
      #
      # @return [String, Array<String>] the next cursor and all found members
      def sscan(key, cursor, options = {})
        args = [:sscan, key, cursor]
        args.push('MATCH', options[:match]) if options[:match]
        args.push('COUNT', options[:count]) if options[:count]

        call(key, args)
      end
    end
  end
end
