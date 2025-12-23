local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Quests = require(ReplicatedStorage.Modules:WaitForChild("QuestData"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClaimEvent = Remotes:WaitForChild("ClaimQuestEvent")
local GetClaimed = Remotes:WaitForChild("GetClaimedQuests")
local AnalyticsService = game:GetService("AnalyticsService")
local SE = require(ReplicatedStorage.Modules["3DCollect"])



local profiles = {} -- cache: player -> profile

local function getQuestByName(name)
	for _, q in ipairs(Quests) do
		if q.Name == name then
			return q
		end
	end
end

local function GetQuestNumber(name)
	local Num = 0
	for _, q in ipairs(Quests) do
		Num += 1
		if q.Name == name then
			return Num
		end
	end
end

local function getQuestLookup()
	local lookup = {}
	for _, quest in ipairs(Quests) do
		lookup[quest.Name] = true
	end
	return lookup
end

Players.PlayerAdded:Connect(function(player)
	local profile
	repeat
		profile = Knit.GetService("DataService"):GetProfile(player)
		task.wait()
	until profile

	profile.Data.ClaimedQuests = profile.Data.ClaimedQuests or {}

	-- ✅ REMOVE quests that no longer exist
	local questLookup = getQuestLookup()
	for questName in pairs(profile.Data.ClaimedQuests) do
		if not questLookup[questName] then
			profile.Data.ClaimedQuests[questName] = nil
		end
	end

	-- ✅ ADD missing quests so all players have a full quest list
	for _, quest in ipairs(Quests) do
		if profile.Data.ClaimedQuests[quest.Name] == nil then
			profile.Data.ClaimedQuests[quest.Name] = false
		end
	end

	profiles[player] = profile
end)


Players.PlayerRemoving:Connect(function(player)
	profiles[player] = nil
end)

GetClaimed.OnServerInvoke = function(player)
	local profile = profiles[player]
	if not profile then
		repeat
			profile = Knit.GetService("DataService"):GetProfile(player)
			if profile then break end
			task.wait()
		until false
		profile.Data.ClaimedQuests = profile.Data.ClaimedQuests or {}
		profiles[player] = profile
	end

	-- ✅ Same cleanup here to keep it consistent
	local questLookup = getQuestLookup()

	for questName in pairs(profile.Data.ClaimedQuests) do
		if not questLookup[questName] then
			profile.Data.ClaimedQuests[questName] = nil
		end
	end

	for _, quest in ipairs(Quests) do
		if profile.Data.ClaimedQuests[quest.Name] == nil then
			profile.Data.ClaimedQuests[quest.Name] = false
		end
	end

	return profile.Data.ClaimedQuests or {}
end

local Icons = {
	["Pigeons"] = "rbxassetid://125126736270718",
	["Eggs"] = "rbxassetid://79192961641227",
	["Beaks"] = "rbxassetid://130900765268666",
	["Tool"] = "rbxassetid://95439986234721",
}

ClaimEvent.OnServerEvent:Connect(function(player, questName)
	local quest = getQuestByName(questName)
	if not quest then return end

	local profile = profiles[player] or Knit.GetService("DataService"):GetProfile(player)
	if not profile then return end

	profile.Data.ClaimedQuests = profile.Data.ClaimedQuests or {}
	local claimed = profile.Data.ClaimedQuests
	if claimed[questName] then return end

	local Achievements = require(ReplicatedStorage.Modules:WaitForChild("AddAchievment"))
	local Data = Achievements.Get(player)

	local function isComplete(needed)
		for key, requirement in pairs(needed) do
			local have = Data[key]
			if type(requirement) == "table" then
				for subKey, subVal in pairs(requirement) do
					if not have or (have[subKey] or 0) < subVal then
						return false
					end
				end
			elseif type(requirement) == "number" then
				if (have or 0) < requirement then
					return false
				end
			elseif type(requirement) == "boolean" then
				if not have then
					return false
				end
			end
		end
		return true
	end

	if not isComplete(quest.Needed) then return end


	-- mark as claimed and ensure saved by ProfileService
	profile.Data.Achievements = {}
	local AchievementsReset = require(ReplicatedStorage.Modules:WaitForChild("AddAchievment"))
	for key, value in pairs(profile.Data) do
		if typeof(value) == "number" and key ~= "Beaks" then
			profile.Data[key] = 0
		end
	end
	claimed[questName] = true
	--[[pcall(function()
	AnalyticsService:LogOnboardingFunnelStepEvent(
		player,
		GetQuestNumber(questName), -- Step number
		questName -- Step name
	)
	end)]]


	-- optional immediate save (ProfileService will save automatically on release/leave):
	if profile.Save then
		pcall(function() profile:Save() end)
	end

	local InventoryService = Knit.GetService("InventoryService")
	local reward = quest.Reward
	if reward and type(reward) == "table" then

		if reward["Beaks"] then
			profile.Data.Beaks = (profile.Data.Beaks or 0) + reward["Beaks"]
			if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Beaks") then
				player.leaderstats.Beaks.Value = profile.Data.Beaks
			end
			local BeakE = script.BeakEffect:Clone()
			BeakE.Parent = player.Character
			BeakE.Enabled = true
			game.Debris:AddItem(BeakE, 8)
			game.ReplicatedStorage.Remotes.Notification:FireClient(player, "You got " ..reward["Beaks"] .. "$ from your quest" )
		end

		if reward["Eggs"] then
			for eggName, amount in pairs(reward["Eggs"]) do
				for _ = 1, amount do
					task.spawn(function()
					local E = script.StarEffect:Clone()
					E.Parent = player.Character
					E.Enabled = true
					game.Debris:AddItem(E, 8)
					wait(1)
					ReplicatedStorage.Remotes.Notification:FireClient(player, "You got a " .. eggName .. " Egg" .. " from your quest!")
					InventoryService:AddItem(player, eggName.." Egg", "Egg")
					end)
					wait(0.8)
				end
			end
		end

		if reward["Tool"] then
			for toolName, amount in pairs(reward["Tool"]) do
				for _ = 1, amount do
					task.spawn(function()
						local E = script.StarEffect:Clone()
						E.Parent = player.Character
						E.Enabled = true
						game.Debris:AddItem(E, 8)
						wait(1)
						InventoryService:AddItem(player, toolName, "Tool")
						ReplicatedStorage.Remotes.Notification:FireClient(player, "You got a " .. toolName .. " from your quest!")
					end)
					wait(0.8)
				end
			end
		end
	end

	ClaimEvent:FireClient(player, questName)
end)
