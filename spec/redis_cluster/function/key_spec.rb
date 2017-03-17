# frozen_string_literal: true
require 'redis_cluster/function/key'

describe RedisCluster::Function::Key do
  subject{ FakeRedisCluster.new(result).tap{ |o| o.extend described_class } }

  describe '#del' do
    let(:result){ 1 }

    it do
      expect(subject).to receive(:call).with(:wow, [:del, :wow], Redis::Boolify).and_return(true)
      subject.del(:wow)
    end
  end

  describe '#expire' do
    let(:result){ 1 }

    it do
      expect(subject).to receive(:call).with(:wow, [:expire, :wow, 5], Redis::Boolify).and_return(true)
      subject.expire(:wow, 5)
    end
  end

  describe '#pexpire' do
    let(:result){ 1 }

    it do
      expect(subject).to receive(:call).with(:wow, [:pexpire, :wow, 5], Redis::Boolify).and_return(true)
      subject.pexpire(:wow, 5)
    end
  end

  describe '#exists' do
    let(:result){ 1 }

    it do
      expect(subject).to receive(:call).with(:wow, [:exists, :wow], Redis::Boolify).and_return(true)
      subject.exists(:wow)
    end
  end

  describe '#ttl' do
    let(:result){ 1 }

    it do
      expect(subject).to receive(:call).with(:wow, [:ttl, :wow]).and_return(result)
      subject.ttl(:wow)
    end
  end

  describe '#ttl' do
    let(:result){ 1000 }

    it do
      expect(subject).to receive(:call).with(:wow, [:pttl, :wow]).and_return(result)
      subject.pttl(:wow)
    end
  end

  describe '#type' do
    let(:result){ "string" }

    it do
      expect(subject).to receive(:call).with(:wow, [:type, :wow]).and_return(result)
      subject.type(:wow)
    end
  end

  describe '#restore' do
    let(:result){ "OK" }

    it do
      expect(subject).to receive(:call).with(:wow, [:restore, :wow, 1000, 'serialized_value']).and_return(result)
      subject.restore(:wow, 1000, 'serialized_value')
    end
  end
end
