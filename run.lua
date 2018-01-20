#!/usr/bin/env th

-- Train our network


-- Now handle requests!

require 'nn'
mlp = nn.Sequential()

local f = assert(io.open('ml_fifo', "r"))
local line = f:read()

while line ~= "quit" and line ~= "" do
  print("Woah!" .. line)
  line = f:read("*all")
end

f:close()
