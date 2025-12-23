local Players = game:GetService("Players")
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local QuestData = require(game.ReplicatedStorage.Modules.QuestData)

-- Create or reuse remotes
local GetTrackedQuest = Remotes:FindFirstChild("GetTrackedQuest") or Instance.new("RemoteFunction")
GetTrackedQuest.Name = "GetTrackedQuest"
GetTrackedQuest.Parent = Remotes

local SetTrackedQuest = Remotes:FindFirstChild("SetTrackedQuest") or Instance.new("RemoteEvent")
SetTrackedQuest.Name = "SetTrackedQuest"
SetTrackedQuest.Parent = Remotes

-- Helper: Check if quest exists in QuestData
local function questExists(name)
	if not name then return false end
	for _, quest in ipairs(QuestData) do
		if quest.Name == name then
			return true
		end
	end
	return false
end

-- When client requests current tracked quest
GetTrackedQuest.OnServerInvoke = function(player)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if profile then
		local currentQuest = profile.Data.CurrentTask

		-- ✅ Validate quest exists before returning
		if not questExists(currentQuest) then
			profile.Data.CurrentTask = nil
			return nil
		end

		return currentQuest
	end
	return nil
end

-- When client sets new tracked quest
SetTrackedQuest.OnServerEvent:Connect(function(player, questName)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if not profile then return end

	-- ✅ Validate before saving
	if questName and questExists(questName) then
		profile.Data.CurrentTask = questName
	else
		profile.Data.CurrentTask = nil
	end
end)
