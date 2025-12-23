local ReplicatedStorage = game:GetService("ReplicatedStorage")


local HTTP = game:GetService("HttpService")

local webhook = "https://webhook.lewisakura.moe/api/webhooks/1426535606032269332/0IQ7eRmPyM6-DSk8QF25qRONN3IUVwQDNzMOcAI_6d0ULRpwiA3kGplvgEy2bqzTVnug"


local Knit = require(ReplicatedStorage.Packages.Knit)


return function(context,event:string)
	
	local MessagingService = game:GetService("MessagingService")

	MessagingService:PublishAsync("GlobalEventTrigger", tostring(event))
	
	if require(ReplicatedStorage.Info.RoleIdInfo)[tostring(event)] and not game["Run Service"]:IsStudio() then
	local payload = HTTP:JSONEncode({
		content = require(ReplicatedStorage.Info.RoleIdInfo)[tostring(event)] .. " Event has started!",
		username = "Event Notifier"
	})

	HTTP:PostAsync(webhook, payload)
	end
	return "Spawned ",event.." Event Across All Servers"
	
end