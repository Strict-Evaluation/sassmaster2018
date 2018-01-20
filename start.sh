#!/usr/bin/env bash

mkfifo ml_fifo

./run.lua &

node server.js

rm ml_fifo
