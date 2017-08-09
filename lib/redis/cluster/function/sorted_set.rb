# frozen_string_literal: true
require 'redis'

class Redis
  class Cluster
    module Function

      # SortedSet implement redis sorted set commands. There will be some adjustment for cluster.
      # see https://redis.io/commands#sorted_set. Most of the code are copied from
      # https://github.com/redis/redis-rb/blob/master/lib/redis.rb.
      #
      # SETTER = [:zadd, :zincrby, :zrem, :zremrangebyrank, :zremrangebyscore]
      # GETTER = [:zcard, :zscore, :zrange, :zrevrange, :zrank, :zrevrange, :zrangebylex,
      #           :zrevrangebylex, :zrangebyscore, :zrevrangebyscore, :zcount]
      module SortedSet

        # Get the number of members in a sorted set.
        #
        # @example
        #   redis.zcard("zset")
        #     # => 4
        #
        # @param [String] key
        # @return [Fixnum]
        def zcard(key)
          call(key, [:zcard, key], read: true)
        end

        # Add one or more members to a sorted set, or update the score for members
        # that already exist.
        #
        # @example Add a single `[score, member]` pair to a sorted set
        #   redis.zadd("zset", 32.0, "member")
        # @example Add an array of `[score, member]` pairs to a sorted set
        #   redis.zadd("zset", [[32.0, "a"], [64.0, "b"]])
        #
        # @param [String] key
        # @param [[Float, String], Array<[Float, String]>] args
        #   - a single `[score, member]` pair
        #   - an array of `[score, member]` pairs
        # @param [Hash] options
        #   - `:xx => true`: Only update elements that already exist (never
        #   add elements)
        #   - `:nx => true`: Don't update already existing elements (always
        #   add new elements)
        #   - `:ch => true`: Modify the return value from the number of new
        #   elements added, to the total number of elements changed (CH is an
        #   abbreviation of changed); changed elements are new elements added
        #   and elements already existing for which the score was updated
        #   - `:incr => true`: When this option is specified ZADD acts like
        #   ZINCRBY; only one score-element pair can be specified in this mode
        #
        # @return [Boolean, Fixnum, Float]
        #   - `Boolean` when a single pair is specified, holding whether or not it was
        #   **added** to the sorted set.
        #   - `Fixnum` when an array of pairs is specified, holding the number of
        #   pairs that were **added** to the sorted set.
        #   - `Float` when option :incr is specified, holding the score of the member
        #   after incrementing it.
        def zadd(key, *args)
          zadd_options = [:zadd, key]
          if args.last.is_a?(::Hash)
            options = args.pop
            incr = options[:incr]

            zadd_options << 'NX' if options[:nx]
            zadd_options << 'XX' if options[:xx]
            zadd_options << 'CH' if options[:ch]
            zadd_options << 'INCR' if incr
          end

          if args.size == 1 && args[0].is_a?(Array)
            # Variadic: return float if INCR, integer if !INCR
            call(key, zadd_options + args[0], transform: (incr ? Redis::Floatify : nil))
          elsif args.size == 2
            # Single pair: return float if INCR, boolean if !INCR
            call(key, zadd_options + args, transform: (incr ? Redis::Floatify : Redis::Boolify))
          else
            raise ArgumentError, 'wrong number of arguments'
          end
        end

        # Increment the score of a member in a sorted set.
        #
        # @example
        #   redis.zincrby("zset", 32.0, "a")
        #     # => 64.0
        #
        # @param [String] key
        # @param [Float] increment
        # @param [String] member
        # @return [Float] score of the member after incrementing it
        def zincrby(key, increment, member)
          call(key, [:zincrby, key, increment, member], transform: Redis::Floatify)
        end

        # Remove one or more members from a sorted set.
        #
        # @example Remove a single member from a sorted set
        #   redis.zrem("zset", "a")
        # @example Remove an array of members from a sorted set
        #   redis.zrem("zset", ["a", "b"])
        #
        # @param [String] key
        # @param [String, Array<String>] member
        #   - a single member
        #   - an array of members
        #
        # @return [Fixnum] number of members that were removed to the sorted set
        def zrem(key, member)
          call(key, [:zrem, key, member])
        end

        # Get the score associated with the given member in a sorted set.
        #
        # @example Get the score for member "a"
        #   redis.zscore("zset", "a")
        #     # => 32.0
        #
        # @param [String] key
        # @param [String] member
        # @return [Float] score of the member
        def zscore(key, member)
          call(key, [:zscore, key, member], transform: Redis::Floatify, read: true)
        end

        # Return a range of members in a sorted set, by index.
        #
        # @example Retrieve all members from a sorted set
        #   redis.zrange("zset", 0, -1)
        #     # => ["a", "b"]
        # @example Retrieve all members and their scores from a sorted set
        #   redis.zrange("zset", 0, -1, :withscores => true)
        #     # => [["a", 32.0], ["b", 64.0]]
        #
        # @param [String] key
        # @param [Fixnum] start start index
        # @param [Fixnum] stop stop index
        # @param [Hash] options
        #   - `:withscores => true`: include scores in output
        #
        # @return [Array<String>, Array<[String, Float]>]
        #   - when `:withscores` is not specified, an array of members
        #   - when `:withscores` is specified, an array with `[member, score]` pairs
        def zrange(key, start, stop, options = {})
          args = [:zrange, key, start, stop]

          if options[:withscores]
            args << 'WITHSCORES'
            block = Redis::FloatifyPairs
          end

          call(key, args, transform: block, read: true)
        end

        # Return a range of members in a sorted set, by index, with scores ordered
        # from high to low.
        #
        # @example Retrieve all members from a sorted set
        #   redis.zrevrange("zset", 0, -1)
        #     # => ["b", "a"]
        # @example Retrieve all members and their scores from a sorted set
        #   redis.zrevrange("zset", 0, -1, :withscores => true)
        #     # => [["b", 64.0], ["a", 32.0]]
        #
        # @see #zrange
        def zrevrange(key, start, stop, options = {})
          args = [:zrevrange, key, start, stop]

          if options[:withscores]
            args << 'WITHSCORES'
            block = Redis::FloatifyPairs
          end

          call(key, args, transform: block, read: true)
        end

        # Determine the index of a member in a sorted set.
        #
        # @param [String] key
        # @param [String] member
        # @return [Fixnum]
        def zrank(key, member)
          call(key, [:zrank, key, member], read: true)
        end

        # Determine the index of a member in a sorted set, with scores ordered from
        # high to low.
        #
        # @param [String] key
        # @param [String] member
        # @return [Fixnum]
        def zrevrank(key, member)
          call(key, [:zrevrank, key, member], read: true)
        end

        # Remove all members in a sorted set within the given indexes.
        #
        # @example Remove first 5 members
        #   redis.zremrangebyrank("zset", 0, 4)
        #     # => 5
        # @example Remove last 5 members
        #   redis.zremrangebyrank("zset", -5, -1)
        #     # => 5
        #
        # @param [String] key
        # @param [Fixnum] start start index
        # @param [Fixnum] stop stop index
        # @return [Fixnum] number of members that were removed
        def zremrangebyrank(key, start, stop)
          call(key, [:zremrangebyrank, key, start, stop])
        end

        # Return a range of members with the same score in a sorted set, by lexicographical ordering
        #
        # @example Retrieve members matching a
        #   redis.zrangebylex("zset", "[a", "[a\xff")
        #     # => ["aaren", "aarika", "abagael", "abby"]
        # @example Retrieve the first 2 members matching a
        #   redis.zrangebylex("zset", "[a", "[a\xff", :limit => [0, 2])
        #     # => ["aaren", "aarika"]
        #
        # @param [String] key
        # @param [String] min
        #   - inclusive minimum is specified by prefixing `(`
        #   - exclusive minimum is specified by prefixing `[`
        # @param [String] max
        #   - inclusive maximum is specified by prefixing `(`
        #   - exclusive maximum is specified by prefixing `[`
        # @param [Hash] options
        #   - `:limit => [offset, count]`: skip `offset` members, return a maximum of
        #   `count` members
        #
        # @return [Array<String>, Array<[String, Float]>]
        def zrangebylex(key, min, max, options = {})
          args = [:zrangebylex, key, min, max]

          limit = options[:limit]
          args.concat(['LIMIT'] + limit) if limit

          call(key, args, read: true)
        end

        # Return a range of members with the same score in a sorted set, by reversed lexicographical
        # ordering. Apart from the reversed ordering, #zrevrangebylex is similar to #zrangebylex.
        #
        # @example Retrieve members matching a
        #   redis.zrevrangebylex("zset", "[a", "[a\xff")
        #     # => ["abbygail", "abby", "abagael", "aaren"]
        # @example Retrieve the last 2 members matching a
        #   redis.zrevrangebylex("zset", "[a", "[a\xff", :limit => [0, 2])
        #     # => ["abbygail", "abby"]
        #
        # @see #zrangebylex
        def zrevrangebylex(key, max, min, options = {})
          args = [:zrevrangebylex, key, min, max]

          limit = options[:limit]
          args.concat(['LIMIT'] + limit) if limit

          call(key, args, read: true)
        end

        # Return a range of members in a sorted set, by score.
        #
        # @example Retrieve members with score `>= 5` and `< 100`
        #   redis.zrangebyscore("zset", "5", "(100")
        #     # => ["a", "b"]
        # @example Retrieve the first 2 members with score `>= 0`
        #   redis.zrangebyscore("zset", "0", "+inf", :limit => [0, 2])
        #     # => ["a", "b"]
        # @example Retrieve members and their scores with scores `> 5`
        #   redis.zrangebyscore("zset", "(5", "+inf", :withscores => true)
        #     # => [["a", 32.0], ["b", 64.0]]
        #
        # @param [String] key
        # @param [String] min
        #   - inclusive minimum score is specified verbatim
        #   - exclusive minimum score is specified by prefixing `(`
        # @param [String] max
        #   - inclusive maximum score is specified verbatim
        #   - exclusive maximum score is specified by prefixing `(`
        # @param [Hash] options
        #   - `:withscores => true`: include scores in output
        #   - `:limit => [offset, count]`: skip `offset` members, return a maximum of
        #   `count` members
        #
        # @return [Array<String>, Array<[String, Float]>]
        #   - when `:withscores` is not specified, an array of members
        #   - when `:withscores` is specified, an array with `[member, score]` pairs
        def zrangebyscore(key, min, max, options = {})
          args = [:zrangebyscore, key, min, max]

          if options[:withscores]
            args << 'WITHSCORES'
            block = Redis::FloatifyPairs
          end

          limit = options[:limit]
          args.concat(['LIMIT'] + limit) if limit

          call(key, args, transform: block, read: true)
        end

        # Return a range of members in a sorted set, by score, with scores ordered
        # from high to low.
        #
        # @example Retrieve members with score `< 100` and `>= 5`
        #   redis.zrevrangebyscore("zset", "(100", "5")
        #     # => ["b", "a"]
        # @example Retrieve the first 2 members with score `<= 0`
        #   redis.zrevrangebyscore("zset", "0", "-inf", :limit => [0, 2])
        #     # => ["b", "a"]
        # @example Retrieve members and their scores with scores `> 5`
        #   redis.zrevrangebyscore("zset", "+inf", "(5", :withscores => true)
        #     # => [["b", 64.0], ["a", 32.0]]
        #
        # @see #zrangebyscore
        def zrevrangebyscore(key, max, min, options = {})
          args = [:zrevrangebyscore, key, min, max]

          if options[:withscores]
            args << 'WITHSCORES'
            block = Redis::FloatifyPairs
          end

          limit = options[:limit]
          args.concat(['LIMIT'] + limit) if limit

          call(key, args, transform: block, read: true)
        end

        # Remove all members in a sorted set within the given scores.
        #
        # @example Remove members with score `>= 5` and `< 100`
        #   redis.zremrangebyscore("zset", "5", "(100")
        #     # => 2
        # @example Remove members with scores `> 5`
        #   redis.zremrangebyscore("zset", "(5", "+inf")
        #     # => 2
        #
        # @param [String] key
        # @param [String] min
        #   - inclusive minimum score is specified verbatim
        #   - exclusive minimum score is specified by prefixing `(`
        # @param [String] max
        #   - inclusive maximum score is specified verbatim
        #   - exclusive maximum score is specified by prefixing `(`
        # @return [Fixnum] number of members that were removed
        def zremrangebyscore(key, min, max)
          call(key, [:zremrangebyscore, key, min, max])
        end

        # Count the members in a sorted set with scores within the given values.
        #
        # @example Count members with score `>= 5` and `< 100`
        #   redis.zcount("zset", "5", "(100")
        #     # => 2
        # @example Count members with scores `> 5`
        #   redis.zcount("zset", "(5", "+inf")
        #     # => 2
        #
        # @param [String] key
        # @param [String] min
        #   - inclusive minimum score is specified verbatim
        #   - exclusive minimum score is specified by prefixing `(`
        # @param [String] max
        #   - inclusive maximum score is specified verbatim
        #   - exclusive maximum score is specified by prefixing `(`
        # @return [Fixnum] number of members in within the specified range
        def zcount(key, min, max)
          call(key, [:zcount, key, min, max], read: true)
        end
      end
    end
  end
end
