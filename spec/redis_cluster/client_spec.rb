# frozen_string_literal: true
require 'redis_cluster/client'

describe RedisCluster::Client do
  subject do
    described_class.new(host: '127.0.0.1', port: port).tap do |client|
      client.circuit = circuit
      client.role = :master
      client.refresh = refresh
    end
  end

  let(:refresh){ Time.now }

  let(:circuit) do
    Object.new.tap do |circuit|
      allow(circuit).to receive(:open?)
      allow(circuit).to receive(:open!)
      allow(circuit).to receive(:failed)
    end
  end

  let(:port){ 7001 }

  context 'clustered redis' do
    describe '#commit' do
      it 'works' do
        expect(subject.call([:info])).to be_a(String)

        subject.push([:info])
        subject.push([:info])
        expect(subject.commit).to be_a(Array)
      end
    end

    describe '#healthy?' do
      it{ expect(subject.healthy?).to be_truthy }
    end
  end

  context 'standalone redis' do
    let(:port){ 7007 }
    describe '#commit' do
      it 'works' do
        expect(subject.call([:info])).to be_a(String)

        subject.push([:info])
        subject.push([:info])
        expect(subject.commit).to be_a(Array)
      end
    end

    describe '#healthy?' do
      it{ expect(subject.healthy?).to be_truthy }
    end
  end

  describe '#inspect' do
    it{ expect(subject.inspect).to eql "#<RedisCluster client v#{RedisCluster::VERSION} for 127.0.0.1:7001 (master at #{refresh}) status healthy>"}
  end
end
