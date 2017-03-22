# frozen_string_literal: true

shared_examples 'redis function' do |test_table|
  subject{ FakeRedisCluster.new(redis_result).tap{ |o| o.extend described_class } }
  let(:key){ :wow }
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
