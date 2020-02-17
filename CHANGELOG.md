## 1.1.0 [rc] / 2019-07-03
- [BUGFIX] Better failover algorithm
- [FEATURE] Add parameter for circuit breaker. `circuit_threshold` and circuit_interval.
- [FEATURE] Add parameter for max cluster topology refresh per interval. Cluster topology refresh can only happen once per `reset_interval`.

## 1.0.0 / 2018-06-07
- [FEATURE] Middleware support
- [BUGFIX] Exclue slave instance in LOADING state from client candidate.

## 0.0.9 / 2017-10-02
* [BUGFIX] Fix race condition in pipeline

## 0.0.5 / 2017-04-20
* [BUGFIX] Proper error handling at start-up

## 0.0.4 / 2017-04-18
* [FEATURE] Support dump command

## 0.0.3 / 2017-04-17
* [BUGFIX] Make RedisCluster thread safe.
