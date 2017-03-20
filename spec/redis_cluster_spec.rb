# frozen_string_literal: true
require 'redis-cluster'

describe RedisCluster do
  subject{ described_class.new(seed, cluster_opts: { read_mode: :slave }) }
  let(:seed){ [ '127.0.0.1:7001' ] }

  describe '#silent?' do
    it{ is_expected.not_to be_silent }
  end

  describe '#logger' do
    it{ expect(subject.logger).to be_nil }
  end

  describe '#pipeline?' do
    it do
      is_expected.not_to be_pipeline

      subject.pipelined do
        is_expected.to be_pipeline
      end
    end
  end

  describe '#close' do
    it{  expect{ subject.close }.not_to raise_error }
  end

  describe '#connected?' do
    it{ is_expected.not_to be_connected }
  end

  describe '#call & #pipelined' do
    it do
      expect do
        subject.call('waw', [:set, 'waw', 'waw'])
        subject.call('wew', [:set, 'wew', 'wew'])
        subject.call('wiw', [:set, 'wiw', 'wiw'])
        subject.call('wow', [:set, 'wow', 'wow'])
        subject.call('wuw', [:set, 'wuw', 'wuw'])

        subject.call('waw', [:get, 'waw'], read: true)
        subject.call('wew', [:get, 'wew'], read: true)
        subject.call('wiw', [:get, 'wiw'], read: true)
        subject.call('wow', [:get, 'wow'], read: true)
        subject.call('wuw', [:get, 'wuw'], read: true)
      end.not_to raise_error

      a, e, i, o, u = nil
      expect do
        subject.pipelined do
          a = subject.call('waw', [:get, 'waw'])
          e = subject.call('wew', [:get, 'wew'])
          i = subject.call('wiw', [:get, 'wiw'])
          o = subject.call('wow', [:get, 'wow'])
          u = subject.call('wuw', [:get, 'wuw'])
        end
      end.not_to raise_error

      expect(a.value).to eql 'waw'
      expect(e.value).to eql 'wew'
      expect(i.value).to eql 'wiw'
      expect(o.value).to eql 'wow'
      expect(u.value).to eql 'wuw'
    end
  end
end
