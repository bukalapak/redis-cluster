# frozen_string_literal: true
require 'redis_cluster/circuit'
require 'pry'

describe RedisCluster::Circuit do
  before(:each) do
    subject{ described_class.new }
  end

  describe 'fail' do
    it 'can up fail' do
      subject.failed
      expect(subject.fail_count).to eq 1
    end
    it 'can open after 5 fail' do
      expect(subject.open?).to eq false
      subject.failed
      subject.failed
      subject.failed
      subject.failed
      subject.failed
      expect(subject.open?).to eq true
    end
  end
  
  describe 'open' do
  	it 'can increase ban time' do
  	  expect(subject.open?).to eq false
  	  subject.open!
  	  expect(subject.ban_until).to be > Time.now
  	  expect(subject.open?).to eq true
  	end
  end
end
