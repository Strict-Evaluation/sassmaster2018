#!/usr/bin/env bash

rm -f to_ml
rm -f from_ml

mkfifo to_ml
sleep 10d > to_ml &

mkfifo from_ml

./run.lua &

sleep 2

node server.js

rm -f to_ml
rm -f from_ml
