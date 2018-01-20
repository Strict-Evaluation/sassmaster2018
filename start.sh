#!/usr/bin/env bash

if [ "$1" == "init" ]; then
  gem install json
  gem install sinatra
  luarocks install luasocket
fi

./run.lua &

sleep 2

ruby server.rb
