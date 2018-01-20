#!/usr/bin/env th

require 'torch'
require 'nn'

--[[
  basically, take the first 800 chars of the input, stick it in sequentially, and then 
  infer font / textual data from it
  theoretically, we could just have one output parameter then, (index in list of all fonts + data)
  but it'd be nicer to have two, in case we switch to using just 1 dictionary + generating fonts
  based on it
]]--

function padStrToNums(str, l, p)
  local out = {}
  for c in string.gmatch(str, '.') do
    if #out < l then
      table.insert(out, string.byte(c))
    else break end
  end
  for i=#out, l - 1 do
    table.insert(out, p or 32)
  end
  return out
end

function pad(s, l, c)
  return s .. string.rep(c or ' ', l - #s)
end

function loadSample(file, metaData)
  -- scan the file to the next -:
  -- load the target name, load the target font
  -- read the height from the next line, and load the data
  local out = {}
  local line = file:read()
  while line do
    local text, font = string.match(line, '-:(.*);(.*)>')
    if text then
      out.font = font
      out.text = text
      out.height = tonumber(file:read())
      out.data = ''
      for i=1, out.height do
        out.data = out.data .. pad(file:read(), 80)
      end
      out.data = torch.Tensor(padStrToNums(out.data, 800))

      -- set metadata
      if not metaData.fontToken[out.font] then
        table.insert(metaData.fonts, out.font)
        metaData.fontToken[out.font] = #metaData.fonts
      end
      if not metaData.wordToken[out.text] then
        table.insert(metaData.words, out.text)
        metaData.wordToken[out.text] = #metaData.words
      end
      return out
    end
    line = file:read()
  end
  return nil
end

-- tokenize fonts, tokenize words
-- stick em all in one huge list
function loadSamples(filename)
  local f = io.open(filename, 'r')
  local out = {}
  local metaData = {
    fontToken = {},
    fonts = {},
    wordToken = {},
    words = {}
  }

  while true do
    local sample = loadSample(f, metaData)
    if not sample then break end
    table.insert(out, sample)
  end
  f:close()
  return out, metaData
end

function toContiguousDataset(samples, metaData, start, finish)
  local out = {}
  for i=start or 1, finish or #samples do
    local s = samples[i]
    table.insert(out, {s.data, torch.Tensor({metaData.fontToken[s.font], metaData.wordToken[s.text]})})
  end
  function out:size() return #self end
  return out
end

function extract(dataset, index)
  local out = {}
  for i=1, #dataset do
    table.insert(out, dataset[i][index])
  end
  return out
end

local samples, metaData = loadSamples('smaller-training.txt')
--local samples, metaData = loadSamples('test.txt')

print(samples)

local net = nn.Sequential()

net:add(nn.Linear(800, 30))
net:add(nn.Sigmoid())
--net:add(nn.Linear(70, 30))
--net:add(nn.ReLU())
net:add(nn.Linear(30, 2))

local criterion = nn.MSECriterion() --nn.ClassNLLCriterion()
local trainer = nn.StochasticGradient(net, criterion)
trainer.learningRate = 0.01
trainer.maxIteration = 400

local dataSet = toContiguousDataset(samples, metaData)

print(dataSet)

trainer:train(dataSet)

local testing = toContiguousDataset(samples, metaData, 1, 3)
local ins = extract(testing, 1)
local outs = extract(testing, 2)

print(testing)

print(net:forward(ins[1]))
print(outs[1])

-- while true do
--   local x = tonumber(io.read())
--   if x == "" then
--     break
--   end
--   local y = tonumber(io.read())

--   print(net:forward(torch.Tensor({{x, y}}))[1])
-- end
