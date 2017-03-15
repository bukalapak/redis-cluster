# frozen_string_literal: true
require 'redis_cluster/cluster'
require 'pry'

describe RedisCluster::Cluster do
  subject{ described_class.new(['127.0.0.1:7001']) }
  let(:all_redis){ ['127.0.0.1:7001', '127.0.0.1:7002', '127.0.0.1:7003'] }

  describe '#random' do
    it{ expect(all_redis).to be_include(subject.random.url) }
  end

  describe '#reset' do
    it 'work' do
      expect{ subject.reset }.not_to raise_error
    end

    it 'can retry 3 times' do
      allow(subject).to receive(:slots_and_clients).and_raise(StandardError)

      expect{ subject.reset }.to raise_error(StandardError)
      expect(subject.clients.count).to eql 0
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
      expect(subject.slot_for('wow')).to eql 2300
      expect(subject.slot_for('wow')).to eql subject.slot_for('coba{wow}aja{hahah}')
    end
  end

  describe '#client_for' do
    let(:expected_url) do
      mapping = subject.random.call([:cluster, :slots])
      mapping.each do |from, to, server|
        return "#{server[0]}:#{server[1]}" if (from..to).cover?(2300)
      end
    end

    it{ expect(subject.client_for('coba{wow}aja').url).to eql expected_url }
  end
end
