# frozen_string_literal: true
require 'redis_cluster/function/string'

describe RedisCluster::Function::String do
  subject{ FakeRedisCluster.new(result).tap{ |o| o.extend described_class } }

  describe '#decr' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :decr }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#decrby' do
    let(:result){ 0 }
    let(:key){ :wow }
    let(:command){ [key, 2] }
    let(:method){ :decrby }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#incr' do
    let(:result){ 1 }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :incr }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#incrby' do
    let(:result){ 3 }
    let(:key){ :wow }
    let(:command){ [key, 2] }
    let(:method){ :incrby }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#incrbyfloat' do
    let(:result){ '4.1' }
    let(:key){ :wow }
    let(:command){ [key, 1.1] }
    let(:method){ :incrbyfloat }

    it do
      expect(subject).to receive(:call).with(key, [method] + command, Redis::Floatify).and_return(4.1)
      subject.public_send(method, *command)
    end
  end

  describe '#set' do
    let(:result){ 'OK' }
    let(:key){ :wow }
    let(:command){ [key, 'waw', { px: 1000, nx: true }] }
    let(:redis_command){ [method, key, 'waw', 'PX', 1000, 'NX'] }
    let(:method){ :set }

    it do
      expect(subject).to receive(:call).with(key, redis_command, Redis::BoolifySet).and_return(true)
      subject.public_send(method, *command)
    end
  end

  describe '#setex' do
    let(:result){ 'OK' }
    let(:key){ :wow }
    let(:command){ [key, 10, 'waw'] }
    let(:method){ :setex }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#psetex' do
    let(:result){ 'OK' }
    let(:key){ :wow }
    let(:command){ [key, 1000, 'waw'] }
    let(:method){ :psetex }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#setnx' do
    let(:result){ nil }
    let(:key){ :wow }
    let(:command){ [key, 'wow'] }
    let(:method){ :setnx }

    it do
      expect(subject).to receive(:call).with(key, [method] + command, Redis::Boolify).and_return(false)
      subject.public_send(method, *command)
    end
  end

  describe '#get' do
    let(:result){ 'wow' }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :get }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#setrange' do
    let(:result){ 4 }
    let(:key){ :wow }
    let(:command){ [key, 1, 'wow'] }
    let(:method){ :setrange }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#getrange' do
    let(:result){ 'wwow' }
    let(:key){ :wow }
    let(:command){ [key, 0, -1] }
    let(:method){ :getrange }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#setbit' do
    let(:result){ '\x01' }
    let(:key){ :wow }
    let(:command){ [key, 0, 1] }
    let(:method){ :setbit }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#getbit' do
    let(:result){ 1 }
    let(:key){ :wow }
    let(:command){ [key, 0] }
    let(:method){ :getbit }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#append' do
    let(:result){ '\x01waw' }
    let(:key){ :wow }
    let(:command){ [key, 'waw'] }
    let(:method){ :append }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#bitcount' do
    let(:result){ 1 }
    let(:key){ :wow }
    let(:command){ [key, 0, 8] }
    let(:method){ :bitcount }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#bitpos' do
    let(:result){ 1 }
    let(:key){ :wow }
    let(:command){ [key, 0, nil, 8] }
    let(:method){ :bitpos }

    it do
      expect(subject).to receive(:call).with(key, [method, key, 0]).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#getset' do
    let(:result){ 'wow' }
    let(:key){ :wow }
    let(:command){ [key, 'waw'] }
    let(:method){ :getset }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#strlen' do
    let(:result){ 3 }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :strlen }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end
end
