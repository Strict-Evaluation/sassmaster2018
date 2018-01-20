#!/usr/bin/env th
require('torch')
require('nn')

local net = nn.Sequential()
-- net:add(nn.TemporalConvolution(3, 3, 1))
-- net:add(nn.ReLU())
-- net:add(nn.TemporalConvolution(3, 1, 1))

net:add(nn.Linear(2, 30))
net:add(nn.Tanh())
net:add(nn.Linear(30, 5))

local criterion = nn.MSECriterion() --nn.ClassNLLCriterion()
local trainer = nn.StochasticGradient(net, criterion)
trainer.learningRate = 0.1
trainer.maxIteration = 400

local dataset = {
   {torch.Tensor({0, 0}), torch.Tensor({1, 0, 0, 0, 0})},
   {torch.Tensor({0, 1}), torch.Tensor({0, 1, 0, 0, 1})},
   {torch.Tensor({1, 0}), torch.Tensor({0, 0, 1, 0, 1})},
   {torch.Tensor({1, 1}), torch.Tensor({0, 0, 0, 1, 0})}
}
function dataset:size() return #dataset end

trainer:train(dataset)

print(net:forward(torch.Tensor({{0, 0}, {0, 1}, {1, 0}, {1, 1}})))

while true do
   local x = tonumber(io.read())
   if x == "" then
      break
   end
   local y = tonumber(io.read())

   print(net:forward(torch.Tensor({{x, y}}))[1])
end
