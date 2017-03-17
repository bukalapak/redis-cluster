# frozen_string_literal: true
require 'redis_cluster/function/sorted_set'

describe RedisCluster::Function::SortedSet do
  subject{ FakeRedisCluster.new(result).tap{ |o| o.extend described_class } }

  describe '#zcard' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :zcard }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#zadd' do
    let(:key){ :wow }
    let(:method){ :zadd }

    context 'single data' do
      let(:result){ 1 }
      let(:command){ [key, 32.2, 'member', { ch: true }] }
      let(:redis_command){ [method, key, 'CH', 32.2, 'member'] }

      it do
        expect(subject).to receive(:call).with(key, redis_command, Redis::Boolify).and_return(true)
        subject.public_send(method, *command)
      end
    end

    context 'multiple data' do
      let(:result){ ['32.2', '1'] }
      let(:command){ [key, [[32.2, 'member'], [1, 'member2']], { incr: true, ch: true }] }
      let(:redis_command){ [method, key, 'CH', 'INCR', [32.2, 'member'], [1, 'member2']] }

      it do
        expect(subject).to receive(:call).with(key, redis_command, Redis::Floatify).and_return([ 32.2, 1 ])
        subject.public_send(method, *command)
      end
    end

    context 'invalid argument' do
      let(:result){ nil }
      it do
        expect{ subject.zadd(key, :test) }.to raise_error(ArgumentError)
        expect{ subject.zadd(key, 2.2, :test, 3.3, :wow) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#zincrby' do
    let(:result){ '2.2' }
    let(:key){ :wow }
    let(:command){ [key, 2.2, 'member'] }
    let(:method){ :zincrby }

    it do
      expect(subject).to receive(:call).with(key, [method] + command, Redis::Floatify).and_return(2.2)
      subject.public_send(method, *command)
    end
  end

  describe '#zrem' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key, ['member', 'member2']] }
    let(:method){ :zrem }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#zscore' do
    let(:result){ '2.2' }
    let(:key){ :wow }
    let(:command){ [key, 'member'] }
    let(:method){ :zscore }

    it do
      expect(subject).to receive(:call).with(key, [method] + command, Redis::Floatify).and_return(2.2)
      subject.public_send(method, *command)
    end
  end

  describe '#zrange' do
    let(:result){ [['member', '2.2']] }
    let(:key){ :wow }
    let(:command){ [key, 0, -1, withscores: true] }
    let(:redis_command){ [method, key, 0, -1, 'WITHSCORES'] }
    let(:method){ :zrange }

    it do
      expect(subject).to receive(:call).with(key, redis_command, Redis::FloatifyPairs).and_return([['member', 2.2]])
      subject.public_send(method, *command)
    end
  end

  describe '#zrevrange' do
    let(:result){ [['member', '2.2']] }
    let(:key){ :wow }
    let(:command){ [key, 0, -1, withscores: true] }
    let(:redis_command){ [method, key, 0, -1, 'WITHSCORES'] }
    let(:method){ :zrevrange }

    it do
      expect(subject).to receive(:call).with(key, redis_command, Redis::FloatifyPairs).and_return([['member', 2.2]])
      subject.public_send(method, *command)
    end
  end

  describe '#zrank' do
    let(:result){ 1 }
    let(:key){ :wow }
    let(:command){ [key, 'member'] }
    let(:method){ :zrank }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#zrevrank' do
    let(:result){ 9 }
    let(:key){ :wow }
    let(:command){ [key, 'member'] }
    let(:method){ :zrevrank }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#zremrangebyrank' do
    let(:result){ 9 }
    let(:key){ :wow }
    let(:command){ [key, 0, -1] }
    let(:method){ :zremrangebyrank }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#zrangebylex' do
    let(:result){ ['a member', 'b member'] }
    let(:key){ :wow }
    let(:command){ [key, 'a', 'b'] }
    let(:method){ :zrangebylex }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#zrevrangebylex' do
    let(:result){ ['b member', 'a member'] }
    let(:key){ :wow }
    let(:command){ [key, 'a', 'b'] }
    let(:method){ :zrevrangebylex }

    it do
      expect(subject).to receive(:call).with(key, [method, key, 'b', 'a']).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#zrangebyscore' do
    let(:result){ [['member', '2.2'], ['member', '3.2']] }
    let(:key){ :wow }
    let(:command){ [key, '0', '+inf', withscores: true] }
    let(:redis_command){ [method, key, '0', '+inf', 'WITHSCORES'] }
    let(:method){ :zrangebyscore }

    it do
      expect(subject).to receive(:call).with(key, redis_command, Redis::FloatifyPairs).and_return([['member', 2.2], ['member', 3.2]])
      subject.public_send(method, *command)
    end
  end

  describe '#zrevrangebyscore' do
    let(:result){ [['member', '3.2'], ['member', '2.2']] }
    let(:key){ :wow }
    let(:command){ [key, '0', '+inf', withscores: true] }
    let(:redis_command){ [method, key, '+inf', '0', 'WITHSCORES'] }
    let(:method){ :zrevrangebyscore }

    it do
      expect(subject).to receive(:call).with(key, redis_command, Redis::FloatifyPairs).and_return([['member', 3.2], ['member', 2.2]])
      subject.public_send(method, *command)
    end
  end

  describe '#zremrangebyscore' do
    let(:result){ 9 }
    let(:key){ :wow }
    let(:command){ [key, '0', '+inf'] }
    let(:method){ :zremrangebyscore }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#zcount' do
    let(:result){ 9 }
    let(:key){ :wow }
    let(:command){ [key, 0, -1] }
    let(:method){ :zcount }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end
end
