# frozen_string_literal: true
require 'redis_cluster/client'

describe RedisCluster::Client do
  subject{ described_class.new(host: '127.0.0.1', port: 7001) }

  it 'works' do
    expect(subject.call([:info])).to be_a(String)

    subject.push([:info])
    subject.push([:info])
    expect(subject.commit).to be_a(Array)
  end

  describe '#inspect' do
    it{ expect(subject.inspect).to eql "#<RedisCluster client v#{RedisCluster::VERSION} for 127.0.0.1:7001>"}
  end
end
