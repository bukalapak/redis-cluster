# frozen_string_literal: true

class FakeRedisCluster
  def initialize(result)
    @result = result
  end

  def call(*_args, keys: nil, transform: nil, read: false)
    transform ||= ->(v){ v }
    transform.call(@result)
  end
end
