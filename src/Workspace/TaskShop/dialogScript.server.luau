-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- modules
local DialogModule = require(ReplicatedStorage.DialogModule)

-- references
local player = game.Players.LocalPlayer
local npc = script.Parent -- Reference to the NPC model
local npcGui = npc:WaitForChild("Head"):WaitForChild("gui")
local prompt = npc:WaitForChild("ProximityPrompt")

local dialogObject = DialogModule.new("Showcase NPC", npc, prompt)
dialogObject:addDialog("What's Up?", {"Give me a task.", "Nevermind..."})

-- helper function
function GetEquippedToolName(player)
	if not player.Character then return nil end
	for _, tool in ipairs(player.Character:GetChildren()) do
		if tool:IsA("Tool") then
			return tool.Name
		end
	end
	return nil
end

-- when triggered
prompt.Triggered:Connect(function(player)
	if _G.EverythingDone and _G.EverythingDone == true then
		dialogObject:hideGui("You already completed all my tasks.")
		return
	end
	-- ✅ If player has a quest ready to claim, say "Good job!"
	if _G.HasReadyToClaim then
		_G.HasReadyToClaim = false
		dialogObject:hideGui("Good job, Here is your reward!")
		_G.HasReadyToClaim = false
		return
	end

	-- otherwise start normal dialog
	dialogObject:triggerDialog(player, 1)
end)

-- dialog responses
dialogObject.responded:Connect(function(responseNum, dialogNum)
	if dialogNum == 1 then
		if responseNum == 1 then
			if _G.HasTracked == false then
				pcall(function()
				_G.AutoTrackQuest()
				end)
				dialogObject:hideGui("Here you go, good luck!")
				
			else
				local Speeches = {
					"I already gave you one?",
					"Finish the one I gave you first.",
					"You already have a task."
				}
				local randomIndex = math.random(1, #Speeches)
				local randomMessage = Speeches[randomIndex]
				dialogObject:hideGui(randomMessage)
			end
		elseif responseNum == 2 then
			dialogObject:hideGui("then dont waste my time.")
		end
	end
end)
