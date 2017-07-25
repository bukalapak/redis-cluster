#! /bin/bash

for port in 7001 7002 7003 7004 7005 7006
do
  sed "s/{{port}}/${port}/g" .circleci/redis-cluster.conf > .circleci/tmp/${port}.conf
  redis-server .circleci/tmp/${port}.conf > /dev/null 2>&1 &
  echo $! >> .circleci/tmp/pid
done

sed "s/{{port}}/7007/g" .circleci/redis.conf > .circleci/tmp/7007.conf
redis-server .circleci/tmp/7007.conf > /dev/null 2>&1 &
echo $! >> .circleci/tmp/pid

sleep 3

bundle exec .circleci/redis-trib.rb create --replicas 1 127.0.0.1:7001 127.0.0.1:7002\
                           127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 127.0.0.1:7006
sleep 3
