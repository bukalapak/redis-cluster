# frozen_string_literal: true
require 'pry'
require 'securerandom'

shared_examples 'redis pubsub function' do |test_table|
  subject{ FakeRedisCluster.new(redis_result).tap { |o| o.extend described_class }}
  let(:channel) { 'mothership:test' }
  let(:message) { SecureRandom.uuid }
  let(:redis_command){ [method] + args }
  let(:call_args){ [key, redis_command].tap{ |arg| arg << opts unless opts.empty? }}

  test_table.each do |test|
    it do
      expect{ subject.public_send(method, *args) }.not_to raise_error
    end
  end
end

shared_examples 'redis function' do |test_table|
  subject{ FakeRedisCluster.new(redis_result).tap{ |o| o.extend described_class } }
  let(:key){ :wow }
  let(:channel) { 'mothership:test' }
  let(:message) { SecureRandom.uuid }
  let(:result){ transform&.call(redis_result) || redis_result }
  let(:redis_command){ [method] + args }
  let(:transform){ nil }
  let(:call_args){ [key, redis_command].tap{ |arg| arg << opts unless opts.empty? }}
  let(:opts) do
    {}.tap do |h|
      h[:transform] = transform if transform
      h[:read] = read if read
    end
  end

  test_table.each do |test|
    describe "##{test[:method].call}" do
      test.each{ |k, v| let(k, &v) }

      it do
        expect{ subject.public_send(method, *args) }.not_to raise_error
        expect(subject).to receive(:call).with(*call_args).and_return(result)
        subject.public_send(method, *args)
      end
    end
  end
end
