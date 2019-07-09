# frozen_string_literal: true

require_relative 'client'

class RedisCluster

  # Cluster implement redis cluster logic for client.
  class Cluster
    attr_reader :options, :slots, :clients, :replicas, :client_creater

    HASH_SLOTS = 16_384
    CROSSSLOT_ERROR = Redis::CommandError.new("CROSSSLOT Keys in request don't hash to the same slot")

    def initialize(seeds, cluster_opts = {}, &block)
      @options = cluster_opts
      @slots = []
      @clients = {}
      @replicas = nil
      @client_creater = block
      @last_reset = Time.now - reset_interval

      @buffer = []
      init_client(seeds)
    end

    def force_cluster?
      options[:force_cluster] || false
    end

    def read_mode
      options[:read_mode] || :master
    end

    # Reset_interval return interval in second which reset can happen. A reset can only happen once per reset_interval.
    #
    # @return [Fixnum] reset interval
    def reset_interval
      options[:reset_interval].to_f
    end

    def slot_for(keys)
      slot = [keys].flatten.map{ |k| _slot_for(k) }.uniq
      slot.size == 1 ? slot.first : (raise CROSSSLOT_ERROR)
    end

    def client_for(operation, slot)
      mode = operation == :read ? read_mode : :master

      case mode
      when :master
        slots[slot].first
      when :slave
        pick_client(slots[slot], skip: 1) || slots[slot].first
      when :master_slave
        pick_client(slots[slot])
      end
    end

    def close
      clients.values.each(&:close)
    end

    def connected?
      clients.values.all?(&:connected?)
    end

    def random
      clients.values.sample
    end

    # Reset will reload cluster topology. Reset will only be executed once per reset_interval if not forced.
    #
    # @param [Boolean] force: Whether to force reset to happen or not.
    # @return [void]
    def reset(force: false)
      return if !force && @last_reset + reset_interval > Time.now

      try = 3
      # binding.pry
      pool = clients.values.select(&:healthy?)
      begin
        try -= 1
        raise 'No healthy seed' if pool.length.zero?

        i = rand(pool.length)
        client = pool[i]
        slots_and_clients(client)
      rescue StandardError => e
        pool.delete_at(i)
        try.positive? ? retry : (raise e)
      end
      @last_reset = Time.now
    end

    def [](url)
      clients[url] ||= create_client(url)
    end

    def inspect
      "#<RedisCluster cluster v#{RedisCluster::VERSION}>"
    end

    private

    def pick_client(pool, skip: 0)
      begin
        i = rand(skip...pool.length)

        buffer = pool.delete(pool[i])

        return buffer if buffer.healthy?

        return nil if pool.length.zero?
        retry
      end
    end

    def slots_and_clients(client)
      replicas = ::Hash.new{ |h, k| h[k] = [] }

      result = client.call(%i[cluster slots])
      if result.is_a?(StandardError)
        if result.message.eql?('ERR This instance has cluster support disabled') &&
           !force_cluster?
          host, port = client.url.split(':', 2)
          result = [[0, HASH_SLOTS - 1, [host, port, nil], [host, port, nil]]]
        else
          raise result
        end
      end

      result.each do |arr|
        arr[2..-1].each_with_index do |a, i|
          cli = self["#{a[0]}:#{a[1]}"]
          replicas[arr[0]] << cli

          cli.role = i.zero? ? :master : :slave
          cli.refresh = Time.now
        end

        (arr[0]..arr[1]).each do |slot|
          slots[slot] = replicas[arr[0]]
        end
      end

      @buffer = Array.new(clients.length) if clients.length > @buffer.length
      @replicas = replicas
    end

    def init_client(seeds)
      # register seeds into clients
      seeds.each do |s|
        self[s]
      end

      reset(force: true)
    end

    def create_client(url)
      client_creater.call(url)
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
        crc = ((crc << 8) & 0xffff) ^ XMODEM_CRC16_LOOKUP[((crc >> 8) ^ b) & 0xff]
      end
      crc
    end

    # Return Redis::Client for a given key.
    # Modified from https://github.com/antirez/redis-rb-cluster/blob/master/cluster.rb#L104-L117
    def _slot_for(key)
      key = key.to_s
      if (s = key.index('{'))
        if (e = key.index('}', s + 1)) && e != s + 1
          key = key[s + 1..e - 1]
        end
      end
      crc16(key) % HASH_SLOTS
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
    ].freeze
  end
end
