# frozen_string_literal: true

class FakeRedisCluster
  def initialize(result)
    @result = result
  end

  def call(_key, _args, opts = {})
    raise 'need Hash' unless opts.is_a?(::Hash)
    transform = opts[:transform] || ->(v){ v }

    transform.call(@result)
  end
end
