# frozen_string_literal: true

class RedisCluster
  NOOP  = ->(v){ v }
  HSCAN = ->(v){ [v[0], v[1].each_slice(2).to_a] }
end
