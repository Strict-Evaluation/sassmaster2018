#!/usr/bin/env th

require 'torch'
require 'nn'

local parse = require("parse")

-- Train our network


-- Now handle requests!
if arg[1] == 'train' then
  -- test network here
  print('Testing:')

  local rnn = nn.Sequential()
  local tbl = parse.read_file("sarcasm_v2.csv")
  print(tbl)

  os.exit()
end

function run_ml(line)
  return 'placeholder'
end

print('Starting')
local socket = require 'socket'
local s = assert(socket.bind('localhost', 12345))
local c = assert(s:accept())

while true do
  local line = c:receive()
  if line then
    c:send(run_ml(line))
  end
  if line == 'quit' then 
    break
  end
end

