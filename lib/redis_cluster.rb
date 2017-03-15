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

  def pipeline?
    !@pipeline.nil?
  end

  def call(opts)
    pipeline? ? call_pipeline(opts) : call_immediately(opts)
  end

  def pipelined
    safely do
      begin
        @pipeline = []
        yield

        try = 3
        while !@pipeline.empty? && try.positive?
          try -= 1
          @pipeline = do_pipelined(@pipeline)
        end

        @pipeline.first[1].value unless @pipeline.empty?
      ensure
        @pipeline = nil
      end
    end
  end

  private

  def safely
    synchronize{ yield } if block_given?
  rescue StandardError => e
    logger&.error(e)
    raise e unless silent?
  end

  def call_immediately(key:, command:, transformation: nil)
    safely do
      client = cluster.client_for(key)
      try = 3
      asking = false
      begin
        try -= 1

        client.push([:asking]) if asking
        client.push(command)
        asking = false

        reply = client.commit.last
        raise reply if reply.is_a?(Redis::CommandError)

        transformation ? transformation.call(reply) : reply
      rescue Redis::CommandError => e
        err, _slot, url = e.to_s.split
        raise e if err != 'MOVED' && err != 'ASK'

        client = cluster[url]
        asking = ( err == 'ASK' )
        cluster.reset if err == 'MOVED'

        try.positive? ? retry : ( raise e )
      end
    end
  end

  def call_pipeline(key:, command:, transformation: nil)
    client = cluster.client_for(key)
    future = Redis::Future.new(command, transformation)
    @pipeline << [ key, future, client.url, false ]

    return future
  end

  def do_pipelined(pipe)
    mapping = Hash.new{ |h, k| h[k] = {} }

    idx = 0
    pipe.each_with_index do |arr, i|
      _key, future, url, asking = arr
      client = cluster[url]

      if asking
        client.push([:asking])
        idx += 1
      end

      mapping[client.url][idx] = i
      client.push(future._command)
      idx += 1
    end

    mapping.each do |url, rev_index|
      [ cluster[url].commit ].flatten.each_with_index do |reply, i|
        pipe[rev_index[i]].last._set(reply) if rev_index[i]
      end
    end

    moved = false
    leftover = []
    pipe.each do |arr|
      key, future, _url, _asking = arr
      begin
        future.value
      rescue Redis::CommandError => e
        err, _slot, url = e.to_s.split
        raise e if err != 'MOVED' && err != 'ASK'

        moved ||= err == 'MOVED'
        leftover << [ key, future, url, err == 'ASK' ]
      end
    end
    cluster.reset if moved

    return leftover
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
