#!/usr/bin/env bash

if [ "$1" == "init" ]; then
  gem install json
  gem install sinatra
  luarocks install luasocket
  luarocks install json-lua
fi

./run.lua &

sleep 10

ruby server.rb
