# frozen_string_literal: true
require 'redis'

require_relative 'redis_cluster/cluster'
require_relative 'redis_cluster/client'
require_relative 'redis_cluster/future'
require_relative 'redis_cluster/transformation'

require_relative 'redis_cluster/keys'
require_relative 'redis_cluster/hashes'
require_relative 'redis_cluster/lists'

# RedisCluster is a client for redis-cluster *huh*
class RedisCluster
  include MonitorMixin

  include Keys
  include Hashes

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

  def call(key, command, transformation = nil)
    transformation ||= NOOP
    if pipeline?
      call_pipeline(key, command, transformation)
    else
      call_immediately(key, command, transformation)
    end
  end

  def pipelined
    return yield if pipeline?

    safely do
      begin
        @pipeline = Hash.new{ |h, k| h[k] = [] }
        yield

        try = 3
        while !@pipeline.empty? && try.positive?
          try -= 1
          @pipeline = do_pipelined(@pipeline)
        end

        @pipeline.values[0][0].value unless @pipeline.empty?
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

  def call_immediately(key, command, transformation)
    safely do
      client = cluster.client_for(key)
      try = 3
      asking = false
      reply = nil

      while try.positive?
        try -= 1

        client.push([:asking]) if asking
        reply = client.call(command)

        err, url = scan_reply(reply)
        return transformation.call(reply) unless err

        cluster.reset if err == :moved
        asking = err == :asking
        client = cluster[url]
      end

      raise reply
    end
  end

  def call_pipeline(key, command, transformation)
    Future.new(key, command, transformation).tap do |future|
      @pipeline[cluster.client_for(key).url] << future
    end
  end

  def do_pipelined(pipe)
    moved = false
    leftover = Hash.new{ |h, k| h[k] = [] }

    pipe.each do |url, futures|
      rev_index = {}
      idx = 0
      client = cluster[url]

      futures.each_with_index do |future, i|
        if future.asking
          client.push[:asking]
          idx += 1
        end

        rev_index[idx] = i
        client.push(future.command)
        idx += 1
      end

      client.commit.each_with_index do |reply, i|
        next unless rev_index[i]

        future = futures[rev_index[i]]
        future.value = reply

        err, url = scan_reply(reply)
        next unless err

        moved ||= err == :moved
        future.asking = err == :asking
        leftover[url] << future
      end
    end

    cluster.reset if moved
    return leftover
  end

  def scan_reply(reply)
    if reply.is_a?(Redis::CommandError)
      err, _slot, url = reply.to_s.split
      raise reply if err != 'MOVED' && err != 'ASK'

      [err.downcase.to_sym, url]
    elsif reply.is_a?(::RuntimeError)
      raise reply
    end
  end

  # SETTER = [
  #   :sadd, :spop, :srem,                                                        # Sets
  #   :zadd, :zincrby, :zrem, :zremrangebylex, :zremrangebyrank,                  # Sorted Sets
  #   :zremrangebyscore,
  #   :append, :decr, :decrby, :incr, :incrby, :incrbyfloat, :set, :setex, :setnx # Strings
  # ]

  # GETTER = [
  #   :scard, :sismembers, :smembers, :srandmember, :sscan,                       # Sets
  #   :zcard, :zcount, :zlexcount, :zrange, :zrangebylex, :zrevrangebylex,        # Sorted Sets
  #   :zrangebyscore, :zrank, :zrevrange, :zrevrangebyscore, :zrevrank, :zscore,
  #   :zscan,
  #   :get, :strlen                                                               # Strings
  # ]
end
