#! /bin/bash

cat .circleci/pid | while read a; do kill $a; done
sleep 3
rm *.conf
rm *.rdb
rm .circleci/pid
