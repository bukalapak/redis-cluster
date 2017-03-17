# frozen_string_literal: true
require 'redis_cluster/function/set'

describe RedisCluster::Function::Set do
  subject{ FakeRedisCluster.new(result).tap{ |o| o.extend described_class } }

  describe '#scard' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :scard }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#sadd' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key, [:waw, :wew]] }
    let(:method){ :sadd }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#srem' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key, [:waw, :wew]] }
    let(:method){ :srem }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#spop' do
    let(:result){ ["waw", "wew"] }
    let(:key){ :wow }
    let(:command){ [key, 2] }
    let(:method){ :spop }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#srandmember' do
    let(:result){ "waw" }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :srandmember }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#sismember' do
    let(:result){ 1 }
    let(:key){ :wow }
    let(:command){ [key, :waw] }
    let(:method){ :sismember }

    it do
      expect(subject).to receive(:call).with(key, [method] + command, Redis::Boolify).and_return(true)
      subject.public_send(method, *command)
    end
  end

  describe '#smembers' do
    let(:result){ ["waw", "wew"] }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :smembers }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#sscan' do
    let(:result){ ["0", ["waw", "wew"]] }
    let(:key){ :wow }
    let(:command){ [key, 0] }
    let(:method){ :sscan }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end
end
