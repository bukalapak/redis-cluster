# frozen_string_literal: true
require 'redis_cluster/cluster'
require 'pry'

describe RedisCluster::Cluster do
  subject do
    described_class.new(seeds, read_mode: read_mode, force_cluster: force_cluster) do |url|
      host, port = url.split(':', 2)
      RedisCluster::Client.new(host: host, port: port).tap do |cl|
        cl.circuit = circuit
      end
    end
  end
  let(:circuit) do
    Object.new.tap do |circuit|
      allow(circuit).to receive(:open?)
      allow(circuit).to receive(:open!)
      allow(circuit).to receive(:failed)
    end
  end
  let(:seeds){ [url] }
  let(:url){ '127.0.0.1:7001' }
  let(:read_mode){ :master }
  let(:force_cluster){ true }

  context 'clustered redis' do
    let(:all_redis) do
      all = []
      mapping = subject.random.call([:cluster, :slots])
      mapping.map do |arr|
        all.concat(arr[2..-1].map{ |h, p| "#{h}:#{p}" })
      end

      return all
    end

    describe '#random' do
      it{ expect(all_redis).to be_include(subject.random.url) }
    end

    describe '#reset' do
      it 'work' do
        expect{ subject.reset }.not_to raise_error
      end

      it 'can retry 3 times' do
        old_count = subject.clients.count
        allow(subject).to receive(:slots_and_clients).and_raise(StandardError)

        expect{ subject.reset }.to raise_error(StandardError)
        expect(subject.clients.count).to eql (old_count)
      end

      it 'set appropriate client role' do
        start = Time.now
        subject.reset
        expect(subject['127.0.0.1:7001'].role).to eq :master
        expect(subject['127.0.0.1:7002'].role).to eq :master
        expect(subject['127.0.0.1:7003'].role).to eq :master
        expect(subject['127.0.0.1:7004'].role).to eq :slave
        expect(subject['127.0.0.1:7005'].role).to eq :slave
        expect(subject['127.0.0.1:7006'].role).to eq :slave
        expect(subject['127.0.0.1:7001'].refresh).to be >= start
        expect(subject['127.0.0.1:7002'].refresh).to be >= start
        expect(subject['127.0.0.1:7003'].refresh).to be >= start
        expect(subject['127.0.0.1:7004'].refresh).to be >= start
        expect(subject['127.0.0.1:7005'].refresh).to be >= start
        expect(subject['127.0.0.1:7006'].refresh).to be >= start
      end
    end

    describe '#[]' do
      let(:url){ '127.0.0.1:7003' }
      it do
        client = subject[url]
        expect(client).not_to be_nil
        expect(client).to eql subject.clients[url]
      end
    end

    describe '#slot_for' do
      it do
        expect(subject.slot_for('key')).to eql 12539
        expect(subject.slot_for('key')).to eql subject.slot_for('this{key}is{used}')
        expect(subject.slot_for(['{key}1', '{key}2'])).to eql 12539
        expect{ subject.slot_for(['key1', 'key2']) }.to raise_error(described_class::CROSSSLOT_ERROR)
      end
    end

    describe '#client_for' do
      let(:expected_url) do
        mapping = subject.random.call([:cluster, :slots])
        mapping.each do |arr|
          return arr[2..-1].map{ |h, p| "#{h}:#{p}" } if (arr[0]..arr[1]).cover?(2300)
        end
      end

      context 'write' do
        let(:read_mode){ :master }

        it{ expect(subject.client_for(:write, 2300).url).to eql expected_url.first }
      end

      context 'read with read_mode master' do
        let(:read_mode){ :master }

        it{ expect(subject.client_for(:read, 2300).url).to eql expected_url.first }
      end

      context 'read with read_mode slave' do
        let(:read_mode){ :slave }

        it{ expect(expected_url[1..-1].include? subject.client_for(:read, 2300).url).to be_truthy }
      end

      context 'read with read_mode master_slave' do
        let(:read_mode){ :master_slave }

        it{ expect(expected_url.include? subject.client_for(:read, 2300).url).to be_truthy }
      end
    end
  end

  context 'standalone redis' do
    let(:url){ '127.0.0.1:7007' }
    let(:force_cluster){ false }

    describe '#[]' do
      it do
        client = subject[url]
        expect(client).not_to be_nil
        expect(client).to eql subject.clients[url]
      end
    end

    describe '@clients' do
      it do
        expect(subject.clients.size).to eql 1
        expect(subject.clients).to have_key(url)
      end
    end

    describe '@slots' do
      it do
        subject.slots.each do |slot|
          expect(slot[0]).to eql subject.clients[url]
          expect(slot[1]).to eql subject.clients[url]
        end
      end
    end

    describe '@replicas' do
      it do
        expect(subject.replicas.size).to eql 1
        expect(subject.replicas[0][0]).to eql subject.clients[url]
        expect(subject.replicas[0][1]).to eql subject.clients[url]
      end
    end
  end

  context 'standalone redis with force_cluster option' do
    let(:url){ '127.0.0.1:7007' }
    let(:force_cluster){ true }

    describe '#initialize' do
      it do
        expect{ subject }.to raise_error('No healthy seed')
      end
    end
  end

  context 'empty seeds' do
    let(:seeds){ [] }

    it do
      expect{ subject }.to raise_error(RedisCluster::NoHealthySeedError)
    end
  end
end
