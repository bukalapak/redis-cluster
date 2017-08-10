# frozen_string_literal: true
require 'redis/cluster/function/scan'

describe Redis::Cluster::Function::Scan do
  describe '#zscan_each' do
    subject{ FakeRedisCluster.new(result).tap{ |o| o.extend described_class } }
    let(:value){ [['wew', 2.2], ['waw', 3.3]] }
    let(:result){ ['0', value.flatten.map(&:to_s)] }

    it do
      idx = 0
      subject.zscan_each(:wow) do |val|
        expect(val).to eql value[idx]
        idx += 1
      end
    end
  end

  include_examples 'redis function', [
    {
      method:        ->{ :hscan },
      args:          ->{ [key, 0, match: '*', count: 1000] },
      redis_command: ->{ [method, key, 0, 'MATCH', '*', 'COUNT', 1000] },
      redis_result:  ->{ ['0', ['wew', 2, 'waw', 2]] },
      transform:     ->{ Redis::Cluster::Function::Scan::HSCAN },
      read:          ->{ true }
    }, {
      method:        ->{ :zscan },
      args:          ->{ [key, 0, match: '*', count: 1000] },
      redis_command: ->{ [method, key, 0, 'MATCH', '*', 'COUNT', 1000] },
      redis_result:  ->{ ['0', ['wew', '2.2', 'waw', '3.3']] },
      transform:     ->{ Redis::Cluster::Function::Scan::ZSCAN },
      read:          ->{ true }
    }, {
      method:        ->{ :sscan },
      args:          ->{ [key, 0] },
      redis_result:  ->{ ['0', ['waw', 'wew']] },
      read:          ->{ true }
    }
  ]
end
