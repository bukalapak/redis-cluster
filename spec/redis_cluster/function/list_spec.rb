# frozen_string_literal: true
require 'redis_cluster/function/list'

describe RedisCluster::Function::List do
  subject{ FakeRedisCluster.new(result).tap{ |o| o.extend described_class } }

  describe '#llen' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :llen }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#lpush' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key, 'value'] }
    let(:method){ :lpush }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#lpushx' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key, 'value'] }
    let(:method){ :lpushx }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#rpush' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key, 'value'] }
    let(:method){ :rpush }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#rpushx' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key, 'value'] }
    let(:method){ :rpushx }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#lpop' do
    let(:result){ '2' }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :lpop }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#rpop' do
    let(:result){ '2' }
    let(:key){ :wow }
    let(:command){ [key] }
    let(:method){ :rpop }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#lindex' do
    let(:result){ '2' }
    let(:key){ :wow }
    let(:command){ [key, 0] }
    let(:method){ :lindex }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#linsert' do
    let(:result){ '2' }
    let(:key){ :wow }
    let(:command){ [key, :AFTER, :wew, 'value'] }
    let(:method){ :linsert }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#lrange' do
    let(:result){ ['2', '3'] }
    let(:key){ :wow }
    let(:command){ [key, 0, -1] }
    let(:method){ :lrange }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#lrem' do
    let(:result){ 2 }
    let(:key){ :wow }
    let(:command){ [key, 0, :wew] }
    let(:method){ :lrem }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#lset' do
    let(:result){ 'OK' }
    let(:key){ :wow }
    let(:command){ [key, 0, :wew] }
    let(:method){ :lset }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end

  describe '#ltrim' do
    let(:result){ 'OK' }
    let(:key){ :wow }
    let(:command){ [key, 1, -3] }
    let(:method){ :ltrim }

    it do
      expect(subject).to receive(:call).with(key, [method] + command).and_return(result)
      subject.public_send(method, *command)
    end
  end
end
