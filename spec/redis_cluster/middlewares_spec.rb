# frozen_string_literal: true
require 'redis_cluster/middlewares'
require 'pry'

describe RedisCluster::Middlewares do
  subject{ described_class.new }

  describe '#register' do
    it 'can register callable' do
      subject.register(:commit, 'callable')
      expect(subject.middlewares[:commit].first).to eq 'callable'
    end

    it 'can register block' do
      subject.register(:commit){ 'block' }
      expect(subject.middlewares[:commit].first).to be_a Proc
    end
  end

  describe '#invoke' do
    context 'callable' do
      let(:callable){ Object.new }

      it do
        expect(callable).to receive(:call) do |*args, &block|
          block.call
        end

        subject.register(:commit, callable)
        expect(subject.invoke(:commit){'hai'}).to eq 'hai'
      end
    end

    context 'proc' do
      it do
        called = false
        subject.register(:commit) do |*args, &block|
          called = true
          block.call
        end

        expect(subject.invoke(:commit){'hai'}).to eq 'hai'
        expect(called).to be_truthy
      end
    end
  end
end
