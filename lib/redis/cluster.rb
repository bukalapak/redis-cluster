# frozen_string_literal: true
require 'redis'

require_relative 'cluster/client'
require_relative 'cluster/future'
require_relative 'cluster/function'

# Redis::Cluster is a client for redis-cluster *huh*
class Redis
  # Create a new client instance
  #
  # @param [Hash] options
  # @option options [String] :url (value of the environment variable REDIS_URL) a Redis URL, for a TCP connection: `redis://:[password]@[hostname]:[port]/[db]` (password, port and database are optional), for a unix socket connection: `unix://[path to Redis socket]`. This overrides all other options.
  # @option options [String] :host ("127.0.0.1") server hostname
  # @option options [Fixnum] :port (6379) server port
  # @option options [String] :path path to server socket (overrides host and port)
  # @option options [Float] :timeout (5.0) timeout in seconds
  # @option options [Float] :connect_timeout (same as timeout) timeout for initial connect in seconds
  # @option options [String] :password Password to authenticate against server
  # @option options [Fixnum] :db (0) Database to select after initial connect
  # @option options [Symbol] :driver Driver to use, currently supported: `:ruby`, `:hiredis`, `:synchrony`
  # @option options [String] :id ID for the client connection, assigns name to current connection by sending `CLIENT SETNAME`
  # @option options [Hash, Fixnum] :tcp_keepalive Keepalive values, if Fixnum `intvl` and `probe` are calculated based on the value, if Hash `time`, `intvl` and `probes` can be specified as a Fixnum
  # @option options [Fixnum] :reconnect_attempts Number of attempts trying to connect
  # @option options [Boolean] :inherit_socket (false) Whether to use socket in forked process or not
  # @option options [Array] :sentinels List of sentinels to contact
  # @option options [Symbol] :role (:master) Role to fetch via Sentinel, either `:master` or `:slave`
  # @option options [Array] :nodes startup redis cluster nodes.
  # @option options [Hash] :cluster_opts redis cluster options.
  #
  # @return [Redis] a new client instance
  def initialize(options = {})
    @options = options.dup
    nodes = @options.delete :nodes
    cluster_opts = @options.delete :cluster_opts
    @client = (nodes and nodes.is_a? ::Array) ?
                Cluster.new(nodes, redis_opts: @options, cluster_opts: cluster_opts) :
                Client.new(@options)
    @original_client = @client

    @queue = Hash.new { |h, k| h[k] = [] }

    super() # Monitor#initialize
  end
  
  class Cluster
    include MonitorMixin
    include Function

    HASH_SLOTS = 16_384

    attr_reader :options, :slots, :clients, :replicas

    def initialize(nodes, redis_opts: nil, cluster_opts: nil)
      @options = redis_opts || {}
      @cluster_options = cluster_opts || {}
      @slots = []
      @clients = {}
      @replicas = nil

      init_client(nodes)
      super()
    end

    def logger
      @cluster_options[:logger]
    end

    def silent?
      @cluster_options[:silent]
    end

    def read_mode
      @cluster_options[:read_mode] || :master
    end

    def pipeline?
      !@pipeline.nil?
    end

    # Return Redis::Client for a given key.
    # Modified from https://github.com/antirez/redis-rb-cluster/blob/master/cluster.rb#L104-L117
    def slot_for_key(key)
      if key
        key = key.to_s
        if (s = key.index('{'))
          if (e = key.index('}', s + 1)) && e != s+1
            key = key[s+1..e-1]
          end
        end
        crc16(key) % HASH_SLOTS
      end
    end

    def master(slot)
      slot ? slots[slot].first : random
    end

    def slave(slot)
      slot ? (slots[slot][1..-1].sample || slots[slot].first) : random
    end

    def master_slave(slot)
      slot ? slots[slot].sample : random
    end

    def close
      safely{ clients.values.each(&:close) }      
    end

    def connected?
      clients.values.all?(&:connected?)
    end

    def random
      clients.values.sample
    end

    def reset
      try = 3
      begin
        try -= 1
        client = random
        slots_and_clients(client)
      rescue StandardError => e
        clients.delete(client.url)
        try.positive? ? retry : ( raise e )
      end
    end

    def [](url)
      clients[url] ||= create_client(url)
    end

    def call(*command, keys: nil, transform: NOOP, read: false)
      slot = slot_for_keys(keys ||  command[1])

      opts = {
        transform: transform,
        read: read
      }
      
      safely do
        if pipeline?
          call_pipeline(slot, command, opts)
        else
          call_immediately(slot, command, opts)
        end
      end
    end

    def pipelined
      return yield if pipeline?

      safely do
        begin
          @pipeline = []
          yield

          try = 3
          while !@pipeline.empty? && try.positive?
            try -= 1
            moved = false
            mapped_future = map_pipeline(@pipeline)

            @pipeline = []
            mapped_future.each do |url, futures|
              leftover, move = do_pipelined(url, futures)
              moved ||= move

              @pipeline.concat(leftover)
            end

            reset if moved
          end

          @pipeline.first.value unless @pipeline.empty?
        ensure
          @pipeline = nil
        end
      end
    end

    private

    NOOP = ->(v){ v }
    CROSSSLOT_ERROR = Redis::CommandError.new("CROSSSLOT Keys in request don't hash to the same slot")

    def safely
      synchronize{ yield } if block_given?
    rescue StandardError => e
      logger&.error(e)
      raise e unless silent?
    end

    def slot_for_keys(keys)
      if keys
        keys = [keys] unless keys.is_a? ::Array
        slot = keys.map{ |k| slot_for_key(k) }.uniq
        slot.size == 1 ? slot.first : ( raise CROSSSLOT_ERROR )
      end      
    end

    def call_immediately(slot, command, opts = {})
      try = 3
      asking = false
      reply = nil
      mode = opts[:read] ? read_mode : :master
      client = send(mode, slot)

      while try.positive?
        begin
          try -= 1

          client.push([:asking]) if asking
          reply = client.call(command)

          err, url = scan_reply(reply)
          return opts[:transform].call(reply) unless err

          reset if err == :moved
          asking = err == :ask
          client = self[url]
        rescue Redis::CannotConnectError => e
          asking = false
          reset
          client = send(mode, slot)
          reply = e
        end
      end

      raise reply
    end

    def call_pipeline(slot, command, opts = {})
      Future.new(slot, command, opts[:transform]).tap do |future|
        @pipeline << future
      end
    end

    def map_pipeline(pipe)
      futures = ::Hash.new{ |h, k| h[k] = [] }
      pipe.each do |future|
        url = future.url || master(future.slot).url
        futures[url] << future
      end

      return futures
    end

    def do_pipelined(url, futures)
      moved = false
      leftover = []

      rev_index = {}
      idx = 0
      client = self[url]

      futures.each_with_index do |future, i|
        if future.asking
          client.push([:asking])
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
        future.asking = err == :ask
        future.url = url
        leftover << future
      end

      return [leftover, moved]
    rescue Redis::CannotConnectError
      # reset url and asking when connection refused
      futures.each{ |f| f.url = nil; f.asking = false }

      return [futures, true]
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

    def slots_and_clients(client)
      replicas = ::Hash.new{ |h, k| h[k] = [] }

      client.call([:cluster, :slots]).tap do |result|
        result.each do |arr|
          arr[2..-1].each_with_index do |a, i|
            cli = self["#{client.scheme}://#{a[0]}:#{a[1]}"]
            replicas[arr[0]] << cli
            cli.call([:readonly]) if i.nonzero?
          end

          (arr[0]..arr[1]).each do |slot|
            slots[slot] = replicas[arr[0]]
          end
        end
      end

      @replicas = replicas
    end

    def init_client(nodes)
      try = nodes.count
      err = nil

      while try.positive?
        try -= 1
        begin
          client = create_client(nodes[try])
          slots_and_clients(client)
          return
        rescue StandardError => e
          err = e
        end
      end

      raise err
    end

    def create_client(node)
      if node.is_a? ::String
        Client.new(options.merge(url: node))
      else
        Client.new(options.merge(node))
      end      
    end

    def method_missing(name, *args, &block)
      # super unless DELEGATE.include? name
      client = master(slot_for_keys([ args[1] ].flatten))      
      client.send name, *args, &block
    end

    # -----------------------------------------------------------------------------
    #
    # This is the CRC16 algorithm used by Redis Cluster to hash keys.
    # Implementation according to CCITT standards.
    # Copied from https://github.com/antirez/redis-rb-cluster/blob/master/crc16.rb
    #
    # This is actually the XMODEM CRC 16 algorithm, using the
    # following parameters:
    #
    # Name                       : "XMODEM", also known as "ZMODEM", "CRC-16/ACORN"
    # Width                      : 16 bit
    # Poly                       : 1021 (That is actually x^16 + x^12 + x^5 + 1)
    # Initialization             : 0000
    # Reflect Input byte         : False
    # Reflect Output CRC         : False
    # Xor constant to output CRC : 0000
    # Output for "123456789"     : 31C3

    def crc16(bytes)
      crc = 0
      bytes.each_byte do |b|
        crc = ((crc<<8) & 0xffff) ^ XMODEM_CRC16_LOOKUP[((crc>>8)^b) & 0xff]
      end
      crc
    end

    XMODEM_CRC16_LOOKUP = [
      0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
      0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
      0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
      0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de,
      0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485,
      0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
      0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4,
      0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc,
      0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
      0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b,
      0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12,
      0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
      0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41,
      0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
      0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
      0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78,
      0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f,
      0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
      0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e,
      0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256,
      0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
      0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
      0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c,
      0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
      0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab,
      0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
      0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
      0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
      0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9,
      0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
      0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8,
      0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
    ]
    
  end
end
