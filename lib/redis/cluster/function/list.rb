# frozen_string_literal: true

class Redis
  class Cluster
    module Function

      # List implement redis lists commands. There will be some adjustment for cluster.
      # see https://redis.io/commands#list. Most of the code are copied from
      # https://github.com/redis/redis-rb/blob/master/lib/redis.rb.
      #
      # SETTER = [:linsert, :lpop, :lpush, :lpushx, :lrem, :lset, :ltrim, :rpop, :rpush, :rpushx]
      # GETTER = [:lindex, :llen, :lrange]
      module List

        # Get the length of a list.
        #
        # @param [String] key
        # @return [Fixnum]
        def llen(key)
          call(:llen, key, read: true)
        end

        # Prepend one or more values to a list, creating the list if it doesn't exist
        #
        # @param [String] key
        # @param [String, Array] value string value, or array of string values to push
        # @return [Fixnum] the length of the list after the push operation
        def lpush(key, value)
          call(:lpush, key, value)
        end

        # Prepend a value to a list, only if the list exists.
        #
        # @param [String] key
        # @param [String] value
        # @return [Fixnum] the length of the list after the push operation
        def lpushx(key, value)
          call(:lpushx, key, value)
        end

        # Append one or more values to a list, creating the list if it doesn't exist
        #
        # @param [String] key
        # @param [String] value
        # @return [Fixnum] the length of the list after the push operation
        def rpush(key, value)
          call(:rpush, key, value)
        end

        # Append a value to a list, only if the list exists.
        #
        # @param [String] key
        # @param [String] value
        # @return [Fixnum] the length of the list after the push operation
        def rpushx(key, value)
          call(:rpushx, key, value)
        end

        # Remove and get the first element in a list.
        #
        # @param [String] key
        # @return [String]
        def lpop(key)
          call(:lpop, key)
        end

        # Remove and get the last element in a list.
        #
        # @param [String] key
        # @return [String]
        def rpop(key)
          call(:rpop, key)
        end

        # Get an element from a list by its index.
        #
        # @param [String] key
        # @param [Fixnum] index
        # @return [String]
        def lindex(key, index)
          call(:lindex, key, index, read: true)
        end

        # Insert an element before or after another element in a list.
        #
        # @param [String] key
        # @param [String, Symbol] where `BEFORE` or `AFTER`
        # @param [String] pivot reference element
        # @param [String] value
        # @return [Fixnum] length of the list after the insert operation, or `-1`
        #   when the element `pivot` was not found
        def linsert(key, where, pivot, value)
          call(:linsert, key, where, pivot, value)
        end

        # Get a range of elements from a list.
        #
        # @param [String] key
        # @param [Fixnum] start start index
        # @param [Fixnum] stop stop index
        # @return [Array<String>]
        def lrange(key, start, stop)
          call(:lrange, key, start, stop, read: true)
        end

        # Remove elements from a list.
        #
        # @param [String] key
        # @param [Fixnum] count number of elements to remove. Use a positive
        #   value to remove the first `count` occurrences of `value`. A negative
        #   value to remove the last `count` occurrences of `value`. Or zero, to
        #   remove all occurrences of `value` from the list.
        # @param [String] value
        # @return [Fixnum] the number of removed elements
        def lrem(key, count, value)
          call(:lrem, key, count, value)
        end

        # Set the value of an element in a list by its index.
        #
        # @param [String] key
        # @param [Fixnum] index
        # @param [String] value
        # @return [String] `OK`
        def lset(key, index, value)
          call(:lset, key, index, value)
        end

        # Trim a list to the specified range.
        #
        # @param [String] key
        # @param [Fixnum] start start index
        # @param [Fixnum] stop stop index
        # @return [String] `OK`
        def ltrim(key, start, stop)
          call(:ltrim, key, start, stop)
        end
      end
    end
  end
end
