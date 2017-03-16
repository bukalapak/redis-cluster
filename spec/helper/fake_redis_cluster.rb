# frozen_string_literal: true

class FakeRedisCluster
  def initialize(result)
    @result = result
  end

  def call(_key, _args, trans = nil)
    trans ? trans.call(@result) : @result
  end
end
