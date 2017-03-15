# frozen_string_literal: true

require 'redis'

require_relative 'redis_cluster/cluster'
require_relative 'redis_cluster/client'

# RedisCluster is a client for redis-cluster *huh*
class RedisCluster
  include MonitorMixin

  attr_reader :cluster, :logger

  def initialize(seeds, redis_opts: {}, logger: nil, silent: false)
    @cluster = Cluster.new(seeds, redis_opts)
    @logger = logger
    @silent = silent

    super()
  end

  def silent?
    @silent
  end

  private

  def safely
    yield if block_given?
  rescue StandardError => e
    logger&.error(e)
    raise e unless silent?
  end

  # SETTER = [
  #   :del, :expire,                                                              # Keys
  #   :hdel, :hincrby, :hincrbyfloat, :hmset, :hset, :hsetnx,                     # Hashes
  #   :linsert, :lpop, :lpush, :lpushx, :lrem, :lset, :ltrim, :rpop, :rpush,      # Lists
  #   :rpushx,
  #   :sadd, :spop, :srem,                                                        # Sets
  #   :zadd, :zincrby, :zrem, :zremrangebylex, :zremrangebyrank,                  # Sorted Sets
  #   :zremrangebyscore,
  #   :append, :decr, :decrby, :incr, :incrby, :incrbyfloat, :set, :setex, :setnx # Strings
  # ]

  # GETTER = [
  #   :exists, :ttl,                                                              # Keys
  #   :hexists, :hget, :hgetall, :hkeys, :hlen, :hmget, :hstrlen, :hvals, :hscan, # Hashes
  #   :lindex, :llen, :lrange,                                                    # Lists
  #   :scard, :sismembers, :smembers, :srandmember, :sscan,                       # Sets
  #   :zcard, :zcount, :zlexcount, :zrange, :zrangebylex, :zrevrangebylex,        # Sorted Sets
  #   :zrangebyscore, :zrank, :zrevrange, :zrevrangebyscore, :zrevrank, :zscore,
  #   :zscan,
  #   :get, :strlen                                                               # Strings
  # ]
end
