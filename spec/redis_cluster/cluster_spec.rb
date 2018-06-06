# frozen_string_literal: true
require 'redis_cluster/cluster'
require 'pry'

describe RedisCluster::Cluster do
  context 'clustered redis' do
    subject{ described_class.new(['127.0.0.1:7001']) }
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
        expect(subject.clients.count).to eql (old_count - 3)
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
        expect{ subject.slot_for(['key1', 'key2']) }.to raise_error
      end
    end

    describe '#master/master_slave/slave_for' do
      let(:expected_url) do
        mapping = subject.random.call([:cluster, :slots])
        mapping.each do |arr|
          return arr[2..-1].map{ |h, p| "#{h}:#{p}" } if (arr[0]..arr[1]).cover?(2300)
        end
      end

      it do
        expect(subject.master(2300).url).to eql expected_url.first
        expect(expected_url[1..-1].include? subject.slave(2300).url).to be_truthy
        expect(expected_url.include? subject.master_slave(2300).url).to be_truthy
      end
    end
  end

  context 'standalone redis' do
    let(:url){ '127.0.0.1:7007' }
    subject{ described_class.new([url]) }

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

    describe '#initialize' do
      it do
        expect{ described_class.new([url], { force_cluster: true } ) }.to raise_error('ERR This instance has cluster support disabled')
      end
    end
  end
end
