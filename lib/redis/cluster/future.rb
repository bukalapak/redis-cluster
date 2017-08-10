# frozen_string_literal: true
require 'redis'

class Redis
  class Cluster

    # Future basically act the same way as Redis::Future with some modification
    class Future
      attr_reader :command, :slot
      attr_accessor :asking, :url

      def initialize(slot, command, transformation)
        @slot = slot
        @command = command
        @transformation = transformation
        @value = Redis::Future::FutureNotReady
        @asking = false
      end

      def value
        raise @value if @value.is_a?(::RuntimeError)
        @value
      end

      def value=(value)
        @value = @transformation.call(value)
      end
    end
  end
end
