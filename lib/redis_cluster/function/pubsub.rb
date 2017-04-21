require 'redis'

class RedisCluster
  module Function
    #
    # PubSub implement redis several pubsub commands including :
    # - psubscribe
    # - publish
    # - subscribe
    #
    # TODO: We may want to port pubsub command for debugging later on.
    #
    # SETTER = [:publish]
    # GETTER = [:psubscribe, :subscribe] (blocking)
    #
    # It seems that publishing & subscribing to namespace/key are
    # being propagated nicely in redis-server so no logic key partition
    # needed in client.
    #
    # @see https://redis.io/topics/cluster-spec
    # @see https://redis.io/topics/pubsub
    # @see https://github.com/redis/redis-rb/blob/master/lib/redis.rb#L2128-L2190
    #
    module PubSub
      #
      # Publish message to channel.
      #
      # @param channel [String, Symbol] the channel to be published
      # @param message [String]         message that want to be sent
      #
      def publish(channel, message)
        call(channel, [:publish, channel])
      end

      #
      # Subscribe to multiple channel based on namespace regex.
      #
      # @param channel [String, Symbol]
      #
      def psubscribe(*channel, &block)
        call(channel, [:psubcribe, channel, block])
      end

      #
      # Subscibe to single channel based on namespace.
      #
      # @param channel [String]
      #
      def subscribe(*channel, &block)
        call(channel, [:subscribe, channel, block])
      end
    end
  end
end
