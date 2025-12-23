local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local CustomDisplay = require(Modules:WaitForChild("CustomDisplay"))

local CustomDisplayRemote = Remotes:WaitForChild("SuperNotification") -- RemoteEvent

-- Shared handler
task.wait(5)
local function handleReward(icon, topText, bottomText)
	CustomDisplay.QueueReward(icon, topText, bottomText)
end

-- Listen for server triggers
CustomDisplayRemote.OnClientEvent:Connect(handleReward)
_G.SuperNotification(handleReward)
