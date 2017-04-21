require 'redis_cluster/function/pubsub'

describe RedisCluster::Function::PubSub do
  include_examples 'redis function', [
                     {
                       method: -> { :publish },
                       args:   -> { [channel, message] },
                       redis_result: -> { 0 },
                       read:   -> { false },
                       key:    -> { channel }
                     }
                   ]

  #
  # TODO: think about redis subscribe (blocking test)
  # include_examples 'redis pubsub function', [
  #                    {
  #                      method: -> { :subcribe },
  #                      args:   -> { [channel, message] }
  #                    }

  #                  ]

end
