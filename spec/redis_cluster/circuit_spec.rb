# frozen_string_literal: true
require 'redis_cluster/circuit'
require 'pry'

describe RedisCluster::Circuit do
  subject{ described_class.new(5, 5) }

  describe '#failed' do
    it 'can up fail_count' do
      subject.failed
      expect(subject.fail_count).to eq 1
    end
    it 'can ban after 5 failed attempt' do
      subject.failed
      subject.failed
      subject.failed
      subject.failed
      subject.failed
  	  expect(subject.ban_until).to be > Time.now
    end
  end
  
  describe '#open!' do
  	it 'can increase ban time' do
  	  subject.open!
  	  expect(subject.ban_until).to be > Time.now
  	end
  end

  describe '#open?' do
  	it 'can check if its not banned' do
  		expect(subject.open?).to eq false
  	end
  	it 'can check if its banned' do
  		subject.open!
  		expect(subject.open?).to eq true
  	end
  end

end
