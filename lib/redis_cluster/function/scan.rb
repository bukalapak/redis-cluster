# frozen_string_literal: true
require 'redis'

class RedisCluster
  module Function

    # Scan is a collection of redis scan functions
    module Scan
      HSCAN = ->(v){ [v[0], v[1].each_slice(2).to_a] }
      ZSCAN = ->(v){ [v[0], Redis::FloatifyPairs.call(v[1])] }

      # Scan a sorted set
      #
      # @example Retrieve the first batch of key/value pairs in a hash
      #   redis.zscan("zset", 0)
      #
      # @param [String, Integer] cursor the cursor of the iteration
      # @param [Hash] options
      #   - `:match => String`: only return keys matching the pattern
      #   - `:count => Integer`: return count keys at most per iteration
      #
      # @return [String, Array<[String, Float]>] the next cursor and all found
      #   members and scores
      def zscan(key, cursor, options = {})
        args = [:zscan, key, cursor]
        args.push('MATCH', options[:match]) if options[:match]
        args.push('COUNT', options[:count]) if options[:count]

        call(key, args, ZSCAN)
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

      # Convenient method for iterating a hash or sorted_set.
      #
      # @param [String] key
      # @param [Hash] options
      #   - `:match => String`: only return keys matching the pattern
      #   - `:count => Integer`: return count keys at most per iteration
      [:zscan, :hscan].each do |method|
        define_method "#{method}_each" do |key, options = {}, &block|
          return if block.nil?

          cursor = '0'
          loop do
            cursor, values = public_send(method, key, cursor, options)
            values.each(&block)
            break if cursor == '0'
          end
        end
      end
    end
  end
end
