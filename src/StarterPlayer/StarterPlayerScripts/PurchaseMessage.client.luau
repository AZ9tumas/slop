local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local chatEvent = ReplicatedStorage:WaitForChild("GlobalChat")

chatEvent.OnClientEvent:Connect(function(message)
	game.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(message)
end)

-- Example usage
function sendMessage(message)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local chatEvent = ReplicatedStorage:WaitForChild("GlobalChat")
	chatEvent:FireServer(message)
end
