# frozen_string_literal: true
require 'redis-cluster'

describe RedisCluster do
  subject{ described_class.new(seed, cluster_opts: { read_mode: :slave }) }
  let(:seed){ [ '127.0.0.1:7001' ] }

  describe '#silent?' do
    it{ is_expected.not_to be_silent }
  end

  describe '#logger' do
    it{ expect(subject.logger).to be_nil }
  end

  describe '#pipeline?' do
    it do
      is_expected.not_to be_pipeline

      subject.pipelined do
        is_expected.to be_pipeline
      end
    end
  end

  describe '#close' do
    it{  expect{ subject.close }.not_to raise_error }
  end

  describe '#connected?' do
    it{ is_expected.not_to be_connected }
  end

  describe '#safety' do
    subject{ described_class.new(seed, cluster_opts: { read_mode: :slave, silent: true }) }

    it do
      expect{ subject.call('key1', [:del, 'key1', 'key2']) }.not_to raise_error
    end
  end

  describe '#call & #pipelined' do
    context 'stable cluster' do
      it do
        num_keys = 5
        expect do
          num_keys.times do |i|
            subject.call("key#{i}", [:set, "key#{i}", "value#{i}"])
            subject.call("key#{i}", [:get, "key#{i}"], read: true)
          end
        end.not_to raise_error

        futures = Array.new(num_keys)
        expect do
          subject.pipelined do
            num_keys.times do |i|
              futures[i] = subject.call("key#{i}", [:get, "key#{i}"])
            end
          end
        end.not_to raise_error

        num_keys.times do |i|
          expect(futures[i].value).to eql "value#{i}"
        end
      end
    end

    context 'migrating' do
      it do
        expect do
          subject.call('{slot}1', [:set, '{slot}1', '1'])
          subject.call('{slot}2', [:set, '{slot}2', '2'])

          slot = subject.cluster.slot_for('slot')
          cluster = subject.cluster.random.call([:cluster, :slots]).map do |from, to, master|
            # master[0]:master[1] is an url, master[2] is redis node-id
            [(from..to).cover?(slot), "#{master[0]}:#{master[1]}", master[2]]
          end
          from = cluster.select{ |info| info.first }.first
          to = cluster.reject{ |info| info.first }.first
          from_client = subject.cluster[from[1]]
          to_client = subject.cluster[to[1]]

          # set slot to migrating state
          to_client.call([:cluster, :setslot, slot, :importing, from.last])
          from_client.call([:cluster, :setslot, slot, :migrating, to.last])
          from_client.call([:migrate, to_client.url.split(':').first, to_client.url.split(':').last, '{slot}2', 0, 5000])

          # ask redirection should occurs
          subject.call('{slot}2', [:get, '{slot}2'])
          subject.pipelined do
            subject.call('{slot}1', [:get, '{slot}1'])
            subject.call('{slot}2', [:get, '{slot}2'])
          end

          from_client.call([:migrate, to_client.url.split(':').first, to_client.url.split(':').last, '{slot}1', 0, 5000])
          from_client.call([:cluster, :setslot, slot, :node, to.last])
          to_client.call([:cluster, :setslot, slot, :node, to.last])

          # move redirection should occures
          subject.call('{slot}2', [:get, '{slot}2'])
          subject.pipelined do
            subject.call('{slot}1', [:get, '{slot}1'])
            subject.call('{slot}2', [:get, '{slot}2'])
          end
        end.not_to raise_error
      end
    end

    context 'server down' do
      def safely
        yield
      rescue Redis::CannotConnectError
        sleep 1
        retry
      rescue Redis::FutureNotReady
        sleep 1
        retry
      rescue Redis::CommandError => e
        err = e.to_s.split.first.downcase.to_sym
        raise e unless err == :clusterdown
        sleep 1
        retry
      end

      it do
        num_keys = 2
        value = nil
        num_keys.times do |k|
          slot = subject.cluster.slot_for("key#{k}")
          slot_port = subject.cluster.master(slot).url.split(':').last.to_i
          File.new('.circleci/tmp/pid', 'r').each_with_index do |l, i|
            `kill -9 #{l}` if slot_port - 7001 == i
          end

          expect do
            safely do
              if k.even?
                subject.call("key#{k}", [:set, "key#{k}", "value#{k}"])
                value = subject.call("key#{k}", [:get, "key#{k}"], read: true)
              else
                subject.pipelined do
                  subject.call("key#{k}", [:set, "key#{k}", "value#{k}"])
                  value = subject.call("key#{k}", [:get, "key#{k}"], read: true)
                end
              end
            end
          end.not_to raise_error
          tested_value = k.even? ? value : value.value
          expect(tested_value).to eq "value#{k}"
        end
      end
    end
  end

  it 'can handle race condition' do
    subject.call('key', [:set, 'key', 'value'])

    t = Thread.new do
      subject.pipelined do
        sleep 5
        future = subject.call('key', [:get, 'key'], read: true)
      end

      expect(future).to be_a RedisCluster::Future
    end

    sleep 1
    value = subject.call('key', [:get, 'key'], read: true)

    expect(value).to eql 'value'
  end
end
