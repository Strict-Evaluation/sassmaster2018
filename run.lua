#!/usr/bin/env th

require 'torch'
require 'nn'
require 'rnn'

local parse = require("parse")

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
  local prediction = 'neutral'
  if math.abs(average(sarc) - average(nsarc)) >= 0.05 then
    if average(sarc) > average(nsarc) then
      prediction = 'sarc'
    else
      prediction = 'notsarc'
    end
  end
  return {
    prediction = prediction,
    sarc = average(sarc),
    nsarc = average(nsarc)
  }
end

function runBayesian(str)
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

  local line = str
  if not line or line == 'quit' then return nil end
  return classify(line, wSarc, wNsarc)
end

function unicodeChars(str)
    return string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)")
end

function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

function makeWordInputs(word, n_chars)
  word = trim(word)
  local char_vectors = {}
  for char in unicodeChars(word) do
    if all_chars[char] then
      local char_vector = torch.zeros(n_chars)
      char_vector[all_chars[char]] = 1
      table.insert(char_vectors, char_vector)
    end
  end
  local inputs = torch.zeros(#char_vectors, n_chars)
  for ci = 1, #char_vectors do
      inputs[ci] = char_vectors[ci]
  end
  return inputs
end

function runModel(str)
  local line = str
  if not line or line == 'quit' then return nil end

  model:forget()
  local inputs = makeWordInputs(line, n_chars)
  local outputs = model:forward(inputs)

  -- Get maximum output value and index as score and class
  max_val, max_index = outputs:max(1)
  local score = max_val[1]
  local predicted = max_index[1]
  print(line, classes[predicted] .. '   ', score)

  -- Make list of pairs of all scores and classes
  local predictions = {}
  for pi = 1, outputs:size()[1] do
      predictions[pi] = {
          score=outputs[pi],
          class=classes[pi]
      }
  end

  local prediction = classes[predicted]
  if math.abs(predictions[2].score - predictions[1].score) < 1 then
    prediction = 'neutral'
  end

  return {
    prediction = prediction,
    nsarc = predictions[2].score,
    sarc = predictions[1].score
  }
end

model = torch.load('t7s/model.t7')
classes = torch.load('t7s/classes.t7')
all_chars = torch.load('t7s/all_chars.t7')
n_chars = all_chars.n_chars

sarc = fileFreq('sarc2.txt')
notsarc = fileFreq('notsarc2.txt')

function run_ml(line)
  local result = nil
  if not line then return nil end
  line = string.lower(line)
  local bayes = runBayesian(line)
  local ml = runModel(line)
  if not bayes or not ml then
    return {prediction = 'neutral', data = {}}
  end
  if bayes.prediction ~= ml.prediction and ml.prediction ~= 'neutral' and bayes.prediction ~= 'neutral' then
    if math.random(0, 1) == 0 then
      result = bayes.prediction
    else
      result = ml.prediction
    end
  elseif bayes.prediction == 'neutral' then
    result = ml.prediction
  elseif ml.prediction == 'neutral' then
    result = bayes.prediction
  else
    result = ml.prediction
  end
  return {
    prediction = result,
    data = {bayes = bayes, ml = ml}
  }
end

-- Now handle requests!
if arg[1] == 'train' then
  -- test network here
  print('Testing:')
  while true do
    local line = io.read()
    if not line then break end
    print(run_ml(line))
  end
  os.exit()
end

local JSON = require("JSON")

print('Starting')
local socket = require 'socket'
local s = assert(socket.bind('localhost', 12345))
local c = assert(s:accept())

while true do
  local line = c:receive()
  local res = nil
  if line then
    res = run_ml(line)
    if res then
      c:send(JSON:encode(res) .. "\n")
    else
      c:send('{"error": "no classification"}\n')
      break
    end
  end
  if line == 'quit' then 
    break
  end
end

