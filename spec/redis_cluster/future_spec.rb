# frozen_string_literal: true
require 'redis_cluster/future'

describe RedisCluster::Future do
  subject{ described_class.new(key, command, url, transformation) }
  let(:key){ 'wow' }
  let(:command){ [:exists, key] }
  let(:url){ '127.0.0.1:7001' }
  let(:transformation){ Redis::Boolify }

  describe '#key' do
    it{ expect(subject.key).to eql key }
  end

  describe '#command' do
    it{ expect(subject.command).to eql command }
  end

  describe '#url' do
    it{ expect(subject.url).to eql url }
  end

  describe '#url=' do
    let(:url2){ '127.0.0.1:7002' }

    it{ expect{ subject.url = url2 }.to change{ subject.url }.from(url).to(url2) }
  end

  describe '#value and #value=' do
    it do
      expect{ subject.value }.to raise_error(Redis::FutureNotReady)

      subject.value = 1
      expect(subject.value).to be_truthy
    end
  end
end
