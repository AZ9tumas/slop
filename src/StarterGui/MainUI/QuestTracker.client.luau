local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuestTracker = script.Parent:WaitForChild("Quest")
local ScrollingFrame = QuestTracker

local currentQuestFrame
local currentTrackedQuest
local currentButton

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local GetTrackedQuest = Remotes:WaitForChild("GetTrackedQuest")
local SetTrackedQuest = Remotes:WaitForChild("SetTrackedQuest")

local CooldownDB = false

_G.HasTracked = false

_G.HasReadyToClaim = false

_G.Track = function(quest, ratios, button)
	-- If already tracking this quest → untrack it
	if currentTrackedQuest == quest.Name then
		if currentQuestFrame then
			currentQuestFrame.Visible = false
		end
		currentTrackedQuest = nil
		if button then
			button.Rewards.Text = "Track"
		end
		currentButton = nil
		_G.HasTracked = false
		_G.HasReadyToClaim = false
		SetTrackedQuest:FireServer(nil)
		return
	end

	-- If tracking a different quest → reset its button first
	if currentTrackedQuest and currentButton and currentButton ~= button then
		currentButton.Rewards.Text = "Track"
	end

	-- Create tracker UI if it doesn't exist yet
	if not currentQuestFrame then
		currentQuestFrame = script.QuestTemplate:Clone()
		currentQuestFrame.Parent = ScrollingFrame
	end

	_G.HasTracked = true

	currentQuestFrame.Visible = true
	currentQuestFrame.Quest1.Title.Text = quest.Title
	currentQuestFrame.Rewards1.Text = quest.Rewards

	-- Clean old ToDo frames
	for _, child in pairs(currentQuestFrame:GetChildren()) do
		if child.Name:match("WhatToDo") then
			child:Destroy()
		end
	end

	-- Add ToDo frames
	for i2, todo in ipairs(quest.ToDo) do
		local Template2 = script.WhatToDo1:Clone()
		Template2.Name = "WhatToDo" .. i2
		Template2.QuestTitle.Text = todo
		Template2.Parent = currentQuestFrame
	end

	currentTrackedQuest = quest.Name
	currentButton = button

	if button then
		button.Rewards.Text = "Untrack"
	end

	SetTrackedQuest:FireServer(quest.Name)

	_G.UpdateTrackedQuest(quest.Name, ratios, false)
end


_G.UpdateTrackedQuest = function(questName, ratios, isComplete)
	if not currentQuestFrame or currentTrackedQuest ~= questName then return end

	-- ❌ Removed auto-hide on completion
	-- ✅ Keep showing the tracker even when quest is complete
	if isComplete then
		_G.HasReadyToClaim = true
		currentQuestFrame.Quest1.Title.Text = "<font color='#00FF00'>Quest Complete! Claim it!</font>"
	else
		_G.HasReadyToClaim = false
	end

	-- Update progress bars
	local todoFrames = {}
	for _, child in pairs(currentQuestFrame:GetChildren()) do
		if child:IsA("Frame") and child:FindFirstChild("Progress") and child.Name:match("WhatToDo") then
			table.insert(todoFrames, child)
		end
	end

	table.sort(todoFrames, function(a, b)
		local numA = tonumber(a.Name:match("%d+")) or 0
		local numB = tonumber(b.Name:match("%d+")) or 0
		return numA < numB
	end)

	for i = #todoFrames, 1, -1 do
		local todoFrame = todoFrames[i]
		local ratio = ratios[#todoFrames - i + 1] or 0
		todoFrame.Progress.Bar.Size = UDim2.new(ratio, 0, 1, 0)
	end
end


-- ✅ Hide tracker only AFTER quest is claimed
Remotes:WaitForChild("ClaimQuestEvent").OnClientEvent:Connect(function(questName)
	if currentTrackedQuest == questName and currentQuestFrame then
		currentQuestFrame.Visible = false
		currentTrackedQuest = nil
		_G.HasTracked = false

		if currentButton then
			currentButton.Rewards.Text = "Track"
			currentButton = nil
		end

		SetTrackedQuest:FireServer(nil)
	end
end)


game:GetService("RunService").Heartbeat:Connect(function()
	script.Parent.LeftSide.Buttons.Quests.Claimable.Visible = _G.CanClaimAny or false
end)
