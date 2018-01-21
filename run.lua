#!/usr/bin/env th

require 'torch'
require 'nn'
require 'rnn'

local parse = require("parse")

-- Train our network
hidden_size = 200
n_classes = 2
n_chars = 255

function random_sentence()
  return tbl[math.ceil(math.random() * #tbl)]
end

function wordFreq(str)
  local frequencies = {}
  
  for word in string.gmatch(str, '%S+') do
    local word = string.lower(word)
    local r = frequencies[word]
    if r then
      frequencies[word] = r + 1
    else
      frequencies[word] = 1
    end
  end

  return frequencies
end

function fileFreq(file)
  local f = io.open(file, 'r')
  local slurped = f:read('*all')
  local freqs = wordFreq(slurped)
  f:close()
  return freqs
end

function nUses(bag, word)
  local uses = bag[word]
  if uses then return uses else return 0 end
end

function average(t)
  local sum = 0
  local keys = 0
  for k, v in pairs(t) do
    sum = sum + v
    keys = keys + 1
  end
  return sum / keys
end

function classify(string, wSarc, wNsarc)
  local sarc = {}
  local nsarc = {}
  for word in string.gmatch(string, '%S+') do
    local word = string.lower(word)
    table.insert(sarc, nUses(wSarc, word))
    table.insert(nsarc, nUses(wNsarc, word))
  end
  return {
    sarc = average(sarc),
    nsarc = average(nsarc)
  }
end

-- Now handle requests!
if arg[1] == 'train' then
  -- test network here
  print('Testing:')

  local sarc = fileFreq('sarc2.txt')
  local notsarc = fileFreq('notsarc2.txt')

  local sums = {}
  for k, v in pairs(sarc) do
    sums[k] = v
  end

  for k, v in pairs(notsarc) do
    sums[k] = nUses(sums, k) + v
  end

  local wSarc = {}
  local wNsarc = {}

  for k, v in pairs(sarc) do
    wSarc[k] = v / sums[k]
  end

  for k, v in pairs(notsarc) do
    wNsarc[k] = v / sums[k]
  end

  while true do
    local line = io.read()
    if not line or line == 'quit' then break end
    print(classify(line, wSarc, wNsarc))
  end

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

