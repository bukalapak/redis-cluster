# frozen_string_literal: true
require 'redis_cluster/circuit'
require 'pry'

describe RedisCluster::Circuit do
  before(:each) do
  	@circuit = RedisCluster::Circuit.new
  end

  describe 'fail' do
    it 'can up fail' do
      @circuit.failed
      expect(@circuit.fail_count).to eq 1
    end
    it 'can open after 5 fail' do
      expect(@circuit.open?).to eq false
      @circuit.failed
      @circuit.failed
      @circuit.failed
      @circuit.failed
      @circuit.failed
      expect(@circuit.open?).to eq true
    end
  end
  
  describe 'open' do
  	it 'can increase ban time' do
  	  expect(@circuit.open?).to eq false
  	  @circuit.open!
  	  expect(@circuit.ban_until).to be > Time.now
  	  expect(@circuit.open?).to eq true
  	end
  end
end
