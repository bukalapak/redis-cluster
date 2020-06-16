# frozen_string_literal: true

class RedisCluster
  # Error is a base class for all of RedisCluster error.
  class Error < StandardError; end

  # LoadingStateError is an error when try to read redis that in loading state.
  class LoadingStateError < Error; end

  # CircuitOpenError is an error that fired when circuit in client is trip.
  class CircuitOpenError < Error; end

  # NoHealthySeedError is an error when no more pool / healthy seeds in redis cluster.
  class NoHealthySeedError < Error; end

end
