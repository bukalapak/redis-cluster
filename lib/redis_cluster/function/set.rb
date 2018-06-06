# frozen_string_literal: true

require 'redis'

class RedisCluster
  module Function

    # Set implement redis sets commands. There will be some adjustment for cluster.
    # see https://redis.io/commands#set. Most of the code are copied from
    # https://github.com/redis/redis-rb/blob/master/lib/redis.rb.
    #
    # SETTER = [:sadd, :spop, :srem, :sdiffstore, :sinterstore, :smove, :sunionstore]
    # GETTER = [:scard, :sismember, :smembers, :srandmember, :sscan, :sdiff, :sinter, :sunion]
    module Set

      # Get the number of members in a set.
      #
      # @param [String] key
      # @return [Fixnum]
      def scard(key)
        call(key, [:scard, key], read: true)
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

        call(key, args, read: true)
      end

      # Determine if a given value is a member of a set.
      #
      # @param [String] key
      # @param [String] member
      # @return [Boolean]
      def sismember(key, member)
        call(key, [:sismember, key, member], transform: Redis::Boolify, read: true)
      end

      # Get all the members in a set.
      #
      # @param [String] key
      # @return [Array<String>]
      def smembers(key)
        call(key, [:smembers, key], read: true)
      end

      # Subtract multiple sets.
      #
      # @param [String, Array<String>] keys keys pointing to sets to subtract
      # @return [Array<String>] members in the difference
      def sdiff(*keys)
        call(keys, [:sdiff] + keys, read: true)
      end

      # Subtract multiple sets and store the resulting set in a key.
      #
      # @param [String] destination destination key
      # @param [String, Array<String>] keys keys pointing to sets to subtract
      # @return [Fixnum] number of elements in the resulting set
      def sdiffstore(destination, *keys)
        call([keys, destination], [:sdiffstore, destination] + keys)
      end

      # Intersect multiple sets.
      #
      # @param [String, Array<String>] keys keys pointing to sets to intersect
      # @return [Array<String>] members in the intersection
      def sinter(*keys)
        call(keys, [:sinter] + keys, read: true)
      end

      # Intersect multiple sets and store the resulting set in a key.
      #
      # @param [String] destination destination key
      # @param [String, Array<String>] keys keys pointing to sets to intersect
      # @return [Fixnum] number of elements in the resulting set
      def sinterstore(destination, *keys)
        call([keys, destination], [:sinterstore, destination] + keys)
      end

      # Move a member from one set to another.
      #
      # @param [String] source source key
      # @param [String] destination destination key
      # @param [String] member member to move from `source` to `destination`
      # @return [Boolean]
      def smove(source, destination, member)
        call([source, destination],
             [:smove, source, destination, member],
             transform: Redis::Boolify)
      end

      # Add multiple sets.
      #
      # @param [String, Array<String>] keys keys pointing to sets to unify
      # @return [Array<String>] members in the union
      def sunion(*keys)
        call(keys, [:sunion] + keys, read: true)
      end

      # Add multiple sets and store the resulting set in a key.
      #
      # @param [String] destination destination key
      # @param [String, Array<String>] keys keys pointing to sets to unify
      # @return [Fixnum] number of elements in the resulting set
      def sunionstore(destination, *keys)
        call([keys, destination], [:sunionstore, destination] + keys)
      end
    end
  end
end
