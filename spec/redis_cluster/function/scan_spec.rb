# frozen_string_literal: true
require 'redis_cluster/function/scan'

describe RedisCluster::Function::Scan do
  subject{ FakeRedisCluster.new(result).tap{ |o| o.extend described_class } }

  describe '#hscan' do
    let(:result){ ["0", ['wew', 2, 'waw', 2]] }

    it do
      expect(subject).to receive(:call).with(:wow, [:hscan, :wow, 0, 'MATCH', '*', 'COUNT', 1000], RedisCluster::HSCAN).and_return(["0", [['wew', 2], ['waw', 2]]])
      subject.hscan(:wow, 0, match: '*', count: 1000)
    end
  end

  describe '#zscan' do
    let(:result){ ["0", ['wew', '2.2', 'waw', '3.3']] }

    it do
      expect(subject).to receive(:call).with(:wow, [:zscan, :wow, 0, 'MATCH', '*', 'COUNT', 1000], RedisCluster::ZSCAN).and_return(["0", [['wew', 2.2], ['waw', 3.3]]])
      subject.zscan(:wow, 0, match: '*', count: 1000)
    end
  end

  describe '#zscan' do
    let(:value){ [['wew', 2.2], ['waw', 3.3]] }
    let(:result){ ["0", value.flatten.map(&:to_s)] }

    it do
      idx = 0
      subject.zscan_each(:wow) do |val|
        expect(val).to eql value[idx]
        idx += 1
      end
    end
  end
end
