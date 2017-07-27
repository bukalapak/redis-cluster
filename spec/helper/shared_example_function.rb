# frozen_string_literal: true

shared_examples 'redis function' do |test_table|
  subject{ FakeRedisCluster.new(redis_result).tap{ |o| o.extend described_class } }
  let(:multi_keys){ false }
  let(:key) { multi_keys ? ['{key}1', '{key}2'] : :key }
  let(:result){ transform&.call(redis_result) || redis_result }
  let(:redis_command){ [method] + args }
  let(:transform){ nil }
  let(:destination){ nil }
  let(:call_args) do
    if destination.nil?
      [key, redis_command].tap{ |arg| arg << opts unless opts.empty? }
    else
      [[key, destination], redis_command].tap{ |arg| arg << opts unless opts.empty? }
    end
  end
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
