-- Require your modules
local EggModule = require(game.ReplicatedStorage.Info:WaitForChild("EggInfo")) -- adjust path
local PigeonModule = require(game.ReplicatedStorage.Info:WaitForChild("PigeonInfo"))
local ToolModule = require(game.ReplicatedStorage.Info:WaitForChild("ToolInfo"))

-- Create a combined list
local allItems = {}

for eggName, _ in pairs(EggModule) do
	table.insert(allItems, eggName)
end

--[[for pigeonName, _ in pairs(PigeonModule) do
	table.insert(allItems, pigeonName)
end]]

for toolName, _ in pairs(ToolModule) do
	table.insert(allItems, toolName)
end

-- Optional: print all items
for _, name in ipairs(allItems) do
	print(name)
end


return function(registry)
	registry:RegisterType("gameItem",registry.Cmdr.Util.MakeEnumType("gameItem",allItems))
end
