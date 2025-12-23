local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EggModule = require(game.ReplicatedStorage.Info:WaitForChild("EggInfo")) -- adjust path


local Knit = require(ReplicatedStorage.Packages.Knit)


local Egg = {
}

for eggName, _ in pairs(EggModule) do
	table.insert(Egg, eggName)
end

local Pigeons = {
	"Pigeon",
	"Baker Pigeon",
	"Messenger Pigeon",
	"Fisher Pigeon",
	"Pirate Pigeon",
	"Skater Pigeon",
	"Gardener Pigeon",
	"Pharaoh Pigeon",
	"Astronaut Pigeon",
	"Samurai Pigeon",
	"Gladiator Pigeon",
	"Shadow Pigeon",
	"Cyberpunk Pigeon",
	"Surfer Pigeon",
	"Lifeguard Pigeon",
	"Seashell Pigeon",
	"Crown Pigeon",
	"Knight Pigeon",
	"Priest Pigeon",
	"Zombie Pigeon",
	"Skeleton Pigeon",
	"Cyborg Pigeon",
	"Alien Pigeon",
}

local Tools = {
	"Bat",
	"Luck Spray",
	"Shock Spray",
	"Size Spray",
	"Slap",
	"Speed Coil",
	"Trap",
	"Volcanic Spray",
	"Body Swap"
}

local function getItemType(itemName)
	if table.find(Egg, itemName) then
		return "Egg"
	elseif table.find(Pigeons, itemName) then
		return "Pigeon"
	elseif table.find(Tools, itemName) then
		return "Tool"
	else
		return "Unknown"
	end
end


return function(context,player,itemName,amount)
	for i = 1,amount or 1 do
		Knit.GetService("InventoryService"):AddItem(game.Players[tostring(player)],itemName,getItemType(tostring(itemName)))

	end
	
	return 
	
end