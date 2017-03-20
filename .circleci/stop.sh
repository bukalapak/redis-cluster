#! /bin/bash

cat .circleci/tmp/pid | while read a; do kill $a; done
sleep 3
rm .circleci/tmp/*
