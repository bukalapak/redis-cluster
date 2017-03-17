# frozen_string_literal: true
require 'redis_cluster/function/hash'

describe RedisCluster::Function::Hash do
  subject{ FakeRedisCluster.new(result).tap{ |o| o.extend described_class } }

  describe '#hdel' do
    let(:result){ 2 }

    it do
      expect(subject).to receive(:call).with(:wow, [:hdel, :wow, [:aw, :ew]]).and_return(result)
      subject.hdel(:wow, [:aw, :ew])
    end
  end

  describe '#hincrby' do
    let(:result){ 2 }

    it do
      expect(subject).to receive(:call).with(:wow, [:hincrby, :wow, :aw, 1]).and_return(result)
      subject.hincrby(:wow, :aw, 1)
    end
  end

  describe '#hincrbyfloat' do
    let(:result){ "2.2" }

    it do
      expect(subject).to receive(:call).with(:wow, [:hincrbyfloat, :wow, :aw, 1], Redis::Floatify).and_return(2.2)
      subject.hincrbyfloat(:wow, :aw, 1)
    end
  end

  describe '#hmset' do
    let(:result){ "OK" }

    it do
      expect(subject).to receive(:call).with(:wow, [:hmset, :wow, :aw, 1, :ew, 2]).and_return(result)
      subject.hmset(:wow, :aw, 1, :ew, 2)
    end
  end

  describe '#hset' do
    let(:result){ 0 }

    it do
      expect(subject).to receive(:call).with(:wow, [:hset, :wow, :aw, 1], Redis::Boolify).and_return(false)
      subject.hset(:wow, :aw, 1)
    end
  end

  describe '#hsetnx' do
    let(:result){ 0 }

    it do
      expect(subject).to receive(:call).with(:wow, [:hsetnx, :wow, :aw, 1], Redis::Boolify).and_return(false)
      subject.hsetnx(:wow, :aw, 1)
    end
  end

  describe '#hexists' do
    let(:result){ 1 }

    it do
      expect(subject).to receive(:call).with(:wow, [:hexists, :wow, :aw], Redis::Boolify).and_return(true)
      subject.hexists(:wow, :aw)
    end
  end

  describe '#hget' do
    let(:result){ "waw" }

    it do
      expect(subject).to receive(:call).with(:wow, [:hget, :wow, :aw]).and_return(result)
      subject.hget(:wow, :aw)
    end
  end

  describe '#hgetall' do
    let(:result){ [:waw, 2, :wew, 2] }

    it do
      expect(subject).to receive(:call).with(:wow, [:hgetall, :wow], Redis::Hashify).and_return({ waw: 2, wew: 2 })
      subject.hgetall(:wow)
    end
  end

  describe '#hkeys' do
    let(:result){ [:waw, :wew] }

    it do
      expect(subject).to receive(:call).with(:wow, [:hkeys, :wow]).and_return(result)
      subject.hkeys(:wow)
    end
  end

  describe '#hvals' do
    let(:result){ [:waw, :wew] }

    it do
      expect(subject).to receive(:call).with(:wow, [:hvals, :wow]).and_return(result)
      subject.hvals(:wow)
    end
  end

  describe '#hlen' do
    let(:result){ 2 }

    it do
      expect(subject).to receive(:call).with(:wow, [:hlen, :wow]).and_return(result)
      subject.hlen(:wow)
    end
  end

  describe '#hmget' do
    let(:result){ [:waw, :wew] }

    it do
      expect(subject).to receive(:call).with(:wow, [:hmget, :wow, :waw, :wew]).and_return(result)
      subject.hmget(:wow, :waw, :wew)
    end
  end

  describe '#hstrlen' do
    let(:result){ 0 }

    it do
      expect(subject).to receive(:call).with(:wow, [:hstrlen, :wow, :aw]).and_return(result)
      subject.hstrlen(:wow, :aw)
    end
  end
end
