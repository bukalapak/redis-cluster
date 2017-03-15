#! /bin/bash

redis-server .circleci/7001.conf &
echo $! > .circleci/pid

redis-server .circleci/7002.conf &
echo $! >> .circleci/pid

redis-server .circleci/7003.conf &
echo $! >> .circleci/pid

sleep 3

bundle exec .circleci/redis-trib.rb create 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003
