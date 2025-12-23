local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local HTTP = game:GetService("HttpService")

local webhook = "https://webhook.lewisakura.moe/api/webhooks/1426535606032269332/0IQ7eRmPyM6-DSk8QF25qRONN3IUVwQDNzMOcAI_6d0ULRpwiA3kGplvgEy2bqzTVnug"


return function(context,rarity)
	
	Knit.GetService("EggSpawnerService"):SpawnEggEverywhere(tostring(rarity))
	if require(ReplicatedStorage.Info.RoleIdInfo)[rarity .. " Egg"] and not game["Run Service"]:IsStudio() then
		local payload = HTTP:JSONEncode({
			content = require(ReplicatedStorage.Info.RoleIdInfo)[rarity .. " Egg"] .. " Has Been Spawned",
			username = "Event Notifier"
		})

		HTTP:PostAsync(webhook, payload)
	end
	
	return "Spawned ",rarity.." Egg Across All Servers"
	
end