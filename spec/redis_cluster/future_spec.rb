# frozen_string_literal: true
require 'redis_cluster/future'

describe RedisCluster::Future do
  subject{ described_class.new(key, command, transformation) }
  let(:key){ 'wow' }
  let(:command){ [:exists, key] }
  let(:transformation){ Redis::Boolify }

  describe '#key' do
    it{ expect(subject.key).to eql key }
  end

  describe '#command' do
    it{ expect(subject.command).to eql command }
  end

  describe '#asking and asking=' do
    it{ expect{ subject.asking = true }.to change{ subject.asking }.from(false).to(true) }
  end

  describe '#value and #value=' do
    it do
      expect{ subject.value }.to raise_error(Redis::FutureNotReady)

      subject.value = 1
      expect(subject.value).to be_truthy
    end
  end
end
