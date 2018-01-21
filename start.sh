#!/usr/bin/env bash

if [ "$1" == "init" ]; then
  gem install json
  gem install sinatra
  gem install sinatra-cross_origin
  luarocks install luasocket
  luarocks install json-lua
fi

pkill luajit

sleep 1

./run.lua &

sleep 10

ruby server.rb
