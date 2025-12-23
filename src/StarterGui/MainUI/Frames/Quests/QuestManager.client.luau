local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Quests = require(ReplicatedStorage.Modules:WaitForChild("QuestData"))
local Achievements = require(ReplicatedStorage.Modules:WaitForChild("AddAchievment"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClaimEvent = Remotes:WaitForChild("ClaimQuestEvent")
local GetClaimed = Remotes:WaitForChild("GetClaimedQuests")
local GetTrackedQuest = Remotes:WaitForChild("GetTrackedQuest")

local gui = script.Parent
local ScrollingFrame = gui:WaitForChild("ScrollingFrame")
local ParticleBorder = require(ReplicatedStorage:WaitForChild("ParticleBorder"))


local claimedQuests = {}
local autoTracked = {}
_G.CanClaimAny = false
_G.EverythingDone = false

local UPDATE_INTERVAL = 0.3 
local lastUpdate = 0

local function checkEverythingDone()
	for _, q in ipairs(Quests) do
		if not claimedQuests[q.Name] then
			_G.EverythingDone = false
			return false
		end
	end
	_G.EverythingDone = true
	return true
end
-- Get claimed quests
local ok, result = pcall(function() return GetClaimed:InvokeServer() end)
if ok and type(result) == "table" then
	claimedQuests = result
	checkEverythingDone()
end

-- Mark claimed quests visually
local function markClaimed(frame)
	frame.Claim.Rewards.Text = "Claimed"
end

-- add this helper near the top with your other locals



-- Build quest UI
local LayoutOrder = 0
for _, quest in ipairs(Quests) do
	local Template = script.QuestTemplate:Clone()
	Template.Name = quest.Name
	Template.Title.Title.Text = quest.Title
	LayoutOrder += 1
	Template.LayoutOrder = LayoutOrder

	for i2, todo in ipairs(quest.ToDo) do
		local Template2 = script.WhatToDo1:Clone()
		Template2.Name = "WhatToDo" .. i2
		Template2.QuestTitle.Text = todo
		Template2.Parent = Template
	end

	Template.Reward.Text = quest.Rewards
	Template.Parent = ScrollingFrame

	if claimedQuests[quest.Name] then
		markClaimed(Template)
	end

	Template.Claim.MouseButton1Click:Connect(function()
		if claimedQuests[quest.Name] then return end
		ClaimEvent:FireServer(quest.Name)
	end)
end

-- When quest claimed by server
ClaimEvent.OnClientEvent:Connect(function(questName)
	claimedQuests[questName] = true
	local frame = ScrollingFrame:FindFirstChild(questName)
	if frame then
		markClaimed(frame)
		_G.HasTracked = false
		wait(.1)
		checkEverythingDone()
		--_G.AutoTrackQuest()
	end
end)


	

-- Helper to calculate progress ratios
local function getProgress(needed, data)
	local progressData = {}
	for key, requirement in pairs(needed) do
		if type(requirement) == "table" then
			for subKey, subVal in pairs(requirement) do
				local have = (data[key] and data[key][subKey]) or 0
				table.insert(progressData, { progress = have, total = subVal })
			end
		elseif type(requirement) == "number" then
			table.insert(progressData, { progress = data[key] or 0, total = requirement })
		elseif type(requirement) == "boolean" then
			table.insert(progressData, { progress = data[key] and 1 or 0, total = 1 })
		end
	end
	return progressData
end

local ok, trackedQuestName = pcall(function()
	return GetTrackedQuest:InvokeServer()
end)

if ok and trackedQuestName then
	print("Resuming tracked quest:", trackedQuestName)

	-- 1️⃣ Find the quest table
	local quest
	for _, q in ipairs(Quests) do
		if q.Name == trackedQuestName then
			quest = q
			break
		end
	end

	if quest then
		-- 2️⃣ Get player progress
		local Data = Achievements.Get()
		local progressData = getProgress(quest.Needed, Data)

		-- 3️⃣ Build progress ratios
		local ratios = {}
		for _, info in ipairs(progressData) do
			table.insert(ratios, math.min(info.progress, info.total) / math.max(info.total, 1))
		end

		-- 4️⃣ Find quest frame in UI
		local questFrame = ScrollingFrame:FindFirstChild(quest.Name)
		if questFrame then
			-- 5️⃣ Finally, track it!
			_G.Track(quest, ratios, questFrame.Tracker)
		else
			warn("Could not find quest frame for tracked quest:", quest.Name)
		end
	else
		warn("No quest found matching tracked quest name:", trackedQuestName)
	end
else
	if not ok then
		warn("Failed to get tracked quest from server.")
	else
		print("No tracked quest yet.")
	end
end

-- Auto track next quest
local function autoTrackNextQuest()
	for i, quest in ipairs(Quests) do
		if not claimedQuests[quest.Name] then
			local Data = Achievements.Get()
			local progressData = getProgress(quest.Needed, Data)

			local isComplete = true
			for _, info in ipairs(progressData) do
				if info.progress < info.total then
					isComplete = false
					break
				end
			end

			if not isComplete then
				local questFrame = ScrollingFrame:FindFirstChild(quest.Name)
				if questFrame then
					local ratios = {}
					for _, info in ipairs(progressData) do
						table.insert(ratios, math.min(info.progress, info.total) / math.max(info.total, 1))
					end
					_G.Track(quest, ratios, questFrame.Tracker)
				end
				return
			end
		end
	end
	_G.Track(nil, {}, nil)
end

_G.AutoTrackQuest = function()
	autoTrackNextQuest()
end

task.delay(1, function()
	--autoTrackNextQuest()
end)

-- Update quest progress
local function updateQuest(quest, Data)
	local questFrame = ScrollingFrame:FindFirstChild(quest.Name)
	if not questFrame then return false end

	local progressData = getProgress(quest.Needed, Data)
	local ratios = {}

	for _, info in ipairs(progressData) do
		table.insert(ratios, math.min(info.progress, info.total) / math.max(info.total, 1))
	end

	local todoFrames = {}
	for _, child in ipairs(questFrame:GetChildren()) do
		if child:IsA("Frame") and child:FindFirstChild("Progress") and child.Name:match("WhatToDo") then
			table.insert(todoFrames, child)
		end
	end

	table.sort(todoFrames, function(a, b)
		return tonumber(a.Name:match("%d+")) < tonumber(b.Name:match("%d+"))
	end)

	for i = #todoFrames, 1, -1 do
		local todoFrame = todoFrames[i]
		local ratio = ratios[#todoFrames - i + 1] or 0
		todoFrame.Progress.Bar.Size = UDim2.new(ratio, 0, 1, 0)
	end

	local isComplete = true
	for _, info in ipairs(progressData) do
		if info.progress < info.total then
			isComplete = false
			break
		end
	end

	if claimedQuests[quest.Name] then
		questFrame.Title.Title.Text = "<font color='#00FF00'>" .. quest.Title .. " (Claimed!)</font>"
		questFrame.Tracker.Visible = false
		questFrame.Claim.Visible = false
		if questFrame.LayoutOrder > -1 then
			questFrame.LayoutOrder = -questFrame.LayoutOrder
		end
	elseif isComplete then
		questFrame.Title.Title.Text = "<font color='#00FF00'>" .. quest.Title .. " (Complete!)</font>"
		questFrame.Tracker.Visible = false
		questFrame.Claim.Visible = true

		-- ✅ AUTO CLAIM QUEST WHEN COMPLETE
		--[[local ok, trackedQuestName = pcall(function() return GetTrackedQuest:InvokeServer() end)
		if ok and trackedQuestName == quest.Name and not claimedQuests[quest.Name] then
			ClaimEvent:FireServer(quest.Name)
			_G.Notification("Task Complete!")
			claimedQuests[quest.Name] = true
			task.wait(0.2)
		end]]

		if questFrame.LayoutOrder > -1 then
			questFrame.LayoutOrder = -questFrame.LayoutOrder
		end
	else
		questFrame.Title.Title.Text = quest.Title
		questFrame.Tracker.Visible = true
		questFrame.Claim.Visible = false
	end

	if _G.UpdateTrackedQuest then
		_G.UpdateTrackedQuest(quest.Name, ratios, isComplete)
	end

	return isComplete and not claimedQuests[quest.Name]
end

-- ✅ Only auto-claim the tracked quest when interacting with the TaskShop
game.Workspace.TaskShop.ProximityPrompt.Triggered:Connect(function(p)
	if p ~= player then return end

	-- Get which quest is currently being tracked
	local ok, trackedQuestName = pcall(function()
		return GetTrackedQuest:InvokeServer()
	end)
	if not ok or not trackedQuestName then
		warn("No tracked quest found or failed to get tracked quest.")
		return
	end

	local Data = Achievements.Get()
	local questToClaim

	-- Find the tracked quest data
	for _, quest in ipairs(Quests) do
		if quest.Name == trackedQuestName then
			questToClaim = quest
			break
		end
	end

	if not questToClaim then
		warn("Tracked quest not found in quest list:", trackedQuestName)
		return
	end

	-- Skip if already claimed
	if claimedQuests[questToClaim.Name] then
		return
	end

	-- Check if tracked quest is complete
	local progressData = getProgress(questToClaim.Needed, Data)
	local isComplete = true
	for _, info in ipairs(progressData) do
		if info.progress < info.total then
			isComplete = false
			break
		end
	end

	-- ✅ Only claim if tracked quest is complete
	if isComplete then
		ClaimEvent:FireServer(questToClaim.Name)
        _G.Notification("Tracked Task Claimed!")
        local confettiFolder = ReplicatedStorage.Particles.Confetti

        ParticleBorder.createFromTop(
            confettiFolder,
            0.5,    -- seconds of emission
            1.3   -- screen coverage multiplier
        )
		claimedQuests[questToClaim.Name] = true
		checkEverythingDone()

		local frame = ScrollingFrame:FindFirstChild(questToClaim.Name)
		if frame then
			markClaimed(frame)
		end
	end
end)



-- Main loop to update quests
local function trackQuests()
	local now = os.clock()
	if now - lastUpdate < UPDATE_INTERVAL then return end
	lastUpdate = now

	local Data = Achievements.Get()
	local anyCanClaim = false

	for _, quest in ipairs(Quests) do
		if updateQuest(quest, Data) then
			anyCanClaim = true
		end
	end

	_G.CanClaimAny = anyCanClaim
	checkEverythingDone()
end

for _, quest in ipairs(Quests) do
	local questFrame = ScrollingFrame:FindFirstChild(quest.Name)
	if questFrame then
		questFrame.Tracker.MouseButton1Click:Connect(function()
			local Data = Achievements.Get()
			local progressData = getProgress(quest.Needed, Data)
			local ratios = {}
			for _, info in ipairs(progressData) do
				table.insert(ratios, math.min(info.progress, info.total) / math.max(info.total, 1))
			end
			_G.Track(quest, ratios, questFrame.Tracker)
		end)
	end
end

RunService.RenderStepped:Connect(trackQuests)

_G.TrackFirstQuest = function()
	local firstQuest = Quests[1]
	if not firstQuest then return end

	local questFrame = ScrollingFrame:FindFirstChild(firstQuest.Name)
	if not questFrame then return end

	local Data = Achievements.Get()
	local progressData = getProgress(firstQuest.Needed, Data)
	local ratios = {}

	for _, info in ipairs(progressData) do
		local ratio = math.min(info.progress, info.total) / math.max(info.total, 1)
		table.insert(ratios, ratio)
	end

	_G.Track(firstQuest, ratios, questFrame:FindFirstChild("Tracker"))
end
