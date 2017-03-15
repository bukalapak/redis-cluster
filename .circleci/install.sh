#! /bin/bash

wget http://download.redis.io/releases/redis-3.2.8.tar.gz
tar xvzf redis-3.2.8.tar.gz
cd redis-3.2.8 && make
cp src/redis-server /bin
