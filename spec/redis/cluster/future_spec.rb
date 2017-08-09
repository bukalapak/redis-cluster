# frozen_string_literal: true
require 'redis/cluster/future'

describe Redis::Cluster::Future do
  subject{ described_class.new(slot, command, transformation) }
  let(:slot){ 2300 }
  let(:command){ [:exists, slot] }
  let(:transformation){ Redis::Boolify }

  describe '#slot' do
    it{ expect(subject.slot).to eql slot }
  end

  describe '#command' do
    it{ expect(subject.command).to eql command }
  end

  describe '#asking and asking=' do
    it{ expect{ subject.asking = true }.to change{ subject.asking }.from(false).to(true) }
  end

  describe '#url and url=' do
    it{ expect{ subject.url = 'local' }.to change{ subject.url }.from(nil).to('local') }
  end

  describe '#value and #value=' do
    it do
      expect{ subject.value }.to raise_error(Redis::FutureNotReady)

      subject.value = 1
      expect(subject.value).to be_truthy
    end
  end
end
