#!/usr/bin/env th

require 'torch'

-- Train our network


-- Now handle requests!

require 'nn'
mlp = nn.Sequential()

local f = assert(io.open('ml_fifo', "r"))
local line = f:read()

if arg[1] == 'train' then
  -- test network here

  print('Testing:')

  os.exit()
end

local socket = require 'socket'
local s = assert(socket.bind('localhost', 12345))
local c = assert(s:accept())

while true do
  print('iterating')
  local line = c:receive()
  if line then
    print('got', line)
    from:send("helo!\n")
    print('written')
  else
    print("nil line")
  end
  print('here')
  if line == 'quit' then 
    print('there')
    from:send("You quit!\n")
    break
  end
  print('finished loop')
end

