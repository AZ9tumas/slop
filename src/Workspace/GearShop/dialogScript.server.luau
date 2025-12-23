-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--modules
local DialogModule = require(ReplicatedStorage.DialogModule)

--references
local player = game.Players.LocalPlayer
local npc = script.Parent -- Reference to the NPC model
local npcGui = npc:WaitForChild("Head"):WaitForChild("gui")
local prompt = npc:WaitForChild("ProximityPrompt")

local dialogObject = DialogModule.new("Showcase NPC", npc, prompt)
dialogObject:addDialog("What do you want?", {"Show me the gear shop.","Nevermind..."})

local pigeonInfo = require(game.ReplicatedStorage.Info.PigeonInfo)
local eggInfo = require(game.ReplicatedStorage.Info.EggInfo)

--
function GetEquippedToolName(player)
	if not player.Character then return nil end
	for _, tool in ipairs(player.Character:GetChildren()) do
		if tool:IsA("Tool") then
			return tool.Name
		end
	end
	return nil
end


-- what happens when triggered
prompt.Triggered:Connect(function(player)
	dialogObject:triggerDialog(player, 1)
end)

-- logic to go through dialogs
dialogObject.responded:Connect(function(responseNum, dialogNum)
	if dialogNum == 1 then
		if responseNum == 1 then
			dialogObject:hideGui("Here is the gear shop.")
			player.PlayerGui.MainUI.Frames.GearShop.Visible = true
		end
		if responseNum == 2 then
			dialogObject:hideGui("ok bye.")
		end
	end
end)