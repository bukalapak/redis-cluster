#! /bin/bash

for port in 7001 7002 7003 7004 7005 7006
do
  sed "s/{{port}}/${port}/g" .circleci/redis.conf > .circleci/tmp/${port}.conf
  redis-server .circleci/tmp/${port}.conf &
  echo $! >> .circleci/tmp/pid
done
sleep 3

bundle exec .circleci/redis-trib.rb create --replicas 1 127.0.0.1:7001 127.0.0.1:7002\
                           127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 127.0.0.1:7006
sleep 3
