# frozen_string_literal: true
require 'redis/cluster/function/sorted_set'

describe Redis::Cluster::Function::SortedSet do
  describe '#zadd' do
    let(:key){ :wow }
    let(:method){ :zadd }

    context 'single data' do
      let(:redis_result){ 1 }
      let(:command){ [key, 32.2, 'member', { ch: true }] }
      let(:redis_command){ [method, key, 'CH', 32.2, 'member'] }

      it do
        expect{ subject.public_send(method, *command) }.not_to raise_error
        expect(subject).to receive(:call).with(*redis_command, transform: Redis::Boolify).and_return(true)
        subject.public_send(method, *command)
      end
    end

    context 'multiple data' do
      let(:redis_result){ 1 }
      let(:command){ [key, [[32.2, 'member'], [1, 'member2']], ch: true ] }
      let(:redis_command){ [method, key, 'CH', [32.2, 'member'], [1, 'member2']] }

      it do
        expect{ subject.public_send(method, *command) }.not_to raise_error
        expect(subject).to receive(:call).with(*redis_command, transform: nil).and_return(1)
        subject.public_send(method, *command)
      end
    end

    context 'invalid argument' do
      let(:redis_result){ nil }
      it do
        expect{ subject.zadd(key, :test) }.to raise_error(ArgumentError)
        expect{ subject.zadd(key, 2.2, :test, 3.3, :wow) }.to raise_error(ArgumentError)
      end
    end
  end

  include_examples 'redis function', [
    {
      method:        ->{ :zcard },
      args:          ->{ [key] },
      redis_result:  ->{ 2 },
      read:          ->{ true }
    }, {
      method:        ->{ :zincrby },
      args:          ->{ [key, 2.2, 'member'] },
      redis_result:  ->{ '2.2' },
      transform:     ->{ Redis::Floatify },
      read:          ->{ false }
    }, {
      method:        ->{ :zrem },
      args:          ->{ [key, ['member', 'member2']] },
      redis_result:  ->{ 2 },
      read:          ->{ false }
    }, {
      method:        ->{ :zscore },
      args:          ->{ [key, 'member'] },
      redis_result:  ->{ '2.2' },
      transform:     ->{ Redis::Floatify },
      read:          ->{ true }
    }, {
      method:        ->{ :zrange },
      args:          ->{ [key, 0, -1, withscores: true] },
      redis_command: ->{ [method, key, 0, -1, 'WITHSCORES'] },
      redis_result:  ->{ [['member', '2.2']] },
      transform:     ->{ Redis::FloatifyPairs },
      read:          ->{ true }
    }, {
      method:        ->{ :zrevrange },
      args:          ->{ [key, 0, -1, withscores: true] },
      redis_command: ->{ [method, key, 0, -1, 'WITHSCORES'] },
      redis_result:  ->{ [['member', '2.2']] },
      transform:     ->{ Redis::FloatifyPairs },
      read:          ->{ true }
    }, {
      method:        ->{ :zrank },
      args:          ->{ [key, 'member'] },
      redis_result:  ->{ 1 },
      read:          ->{ true }
    }, {
      method:        ->{ :zrevrank },
      args:          ->{ [key, 'member'] },
      redis_result:  ->{ 9 },
      read:          ->{ true }
    }, {
      method:        ->{ :zremrangebyrank },
      args:          ->{ [key, 0, -1] },
      redis_result:  ->{ 9 },
      read:          ->{ false }
    }, {
      method:        ->{ :zrangebylex },
      args:          ->{ [key, 'a', 'b'] },
      redis_result:  ->{ ['a member', 'b member'] },
      read:          ->{ true }
    }, {
      method:        ->{ :zrevrangebylex },
      args:          ->{ [key, 'a', 'b'] },
      redis_command: ->{ [method, key, 'b', 'a'] },
      redis_result:  ->{ ['b member', 'a member'] },
      read:          ->{ true }
    }, {
      method:        ->{ :zrangebyscore },
      args:          ->{ [key, '0', '+inf', withscores: true] },
      redis_command: ->{ [method, key, '0', '+inf', 'WITHSCORES'] },
      redis_result:  ->{ ['member1', '2.2', 'member2', '3.2'] },
      transform:     ->{ Redis::FloatifyPairs },
      read:          ->{ true }
    }, {
      method:        ->{ :zrevrangebyscore },
      args:          ->{ [key, '0', '+inf', withscores: true] },
      redis_command: ->{ [method, key, '+inf', '0', 'WITHSCORES'] },
      redis_result:  ->{ ['member2', '3.2', 'member1', '2.2'] },
      transform:     ->{ Redis::FloatifyPairs },
      read:          ->{ true }
    }, {
      method:        ->{ :zremrangebyscore },
      args:          ->{ [key, '0', '+inf'] },
      redis_result:  ->{ 9 },
      read:          ->{ false }
    }, {
      method:        ->{ :zcount },
      args:          ->{ [key, 0, -1] },
      redis_result:  ->{ 9 },
      read:          ->{ true }
    }
  ]
end
