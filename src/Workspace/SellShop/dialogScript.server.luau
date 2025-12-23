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
dialogObject:addDialog("What do you want?", {"I'd Like to sell my Pigeons and Eggs","I'd like to sell this","How much is this worth?","Nevermind..."})

local pigeonInfo = require(game.ReplicatedStorage.Info.PigeonInfo)
local eggInfo = require(game.ReplicatedStorage.Info.EggInfo)
local toolInfo = require(game.ReplicatedStorage.Info.ToolInfo)
local MutationInfo = require(game.ReplicatedStorage.Info.MutationsInfo)
local CameraEffect = require(game.ReplicatedStorage.Modules.Camera)

--
local function GetBeaksPerSecond(pigeonWeight, pigeonInfo)
	if not pigeonInfo or not pigeonInfo.Weight then
		return 1
	end

	-- Clamp weight within its defined range
	local weight = math.clamp(pigeonWeight, pigeonInfo.Weight.Min, pigeonInfo.Weight.Max)

	local weightRange = pigeonInfo.Weight.Max - pigeonInfo.Weight.Min
	local normalisedWeight = (weight - pigeonInfo.Weight.Min) / (weightRange > 0 and weightRange or 1)

	-- Formula: base * multiplier * (1 + normalisedWeight)
	local beaksPerSecond = 0.79 * (pigeonInfo.Multiplier or 1) * (1 + normalisedWeight * 1.1)
	return beaksPerSecond
end


local function TableMutations(Tool: Tool)
	local Mutations = {}
	if Tool:IsA("Tool") and Tool:FindFirstChild("ExampleHandle") then
		local root = Tool.ExampleHandle:FindFirstChild("Torso")
		if root then
			for _, Mutation in ipairs(root:GetChildren()) do
				local name = Mutation.Name
				local suffix = string.match(name, "_([^_]+)$")
				if suffix then
					-- Check both SpawnChances and Multipliers
					if MutationInfo.SpawnChances[suffix] or MutationInfo.Multipliers[suffix] then
						table.insert(Mutations, suffix)
					end
				end
			end
		end
	end

	print(Mutations)
	return Mutations
end




local function computeMutationMultiplier(mutations)
	if not mutations then return 1 end
	print("Mult")
	local mult = 1
	for _, m in ipairs(mutations) do
		if m and m ~= "Normal" and MutationInfo and MutationInfo.Multipliers and MutationInfo.Multipliers[m] then
			mult = mult * MutationInfo.Multipliers[m]
		end
	end
	print(mult)
	return mult
end

function GetEquippedToolName(player)
	if not player.Character then return nil end
	for _, tool in ipairs(player.Character:GetChildren()) do
		if tool:IsA("Tool") then
			return tool.Name
		end
	end
	return nil
end
function GetEquippedId(player)
	if not player.Character then return nil end
	for _, tool in ipairs(player.Character:GetChildren()) do
		if tool:IsA("Tool") then
			return tool:GetAttribute("EggId") or tool:GetAttribute("PigeonId") or tool:GetAttribute("Id")
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
			local InventoryService = Knit.GetService("InventoryService")
			InventoryService:SellAllNonFavourites():andThen(function(beaks)
				_G.ClearInventory()
				dialogObject:hideGui("Here is "..math.round(beaks).." $")
				local CoinEffect = game.ReplicatedStorage.Game.VFX.Beaks:Clone()
				CoinEffect.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
				CoinEffect:Emit(16)
				game.Debris:AddItem(CoinEffect, 5)
				script.Sound2:Play()
				CameraEffect.shake({shake = "Heavy_Bump"})
			end)
			
		end
		if responseNum == 2 then
			local toolName = GetEquippedToolName(player)
			local InventoryService = Knit.GetService("InventoryService")
			if not toolName then
				dialogObject:hideGui("Nothing equipped")
				return
			end
			if string.find(toolName,"Egg") or string.find(toolName,"Pigeon") then
				InventoryService:SellTool(GetEquippedId(player)):andThen(function(beaks)
					_G.SellToolId(GetEquippedId(player))
					player.Character.Humanoid:UnequipTools()
					dialogObject:hideGui("Sold "..toolName.." worth for "..math.round(beaks).." $")
					local CoinEffect = game.ReplicatedStorage.Game.VFX.Beaks:Clone()
					CoinEffect.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
					CoinEffect:Emit(7)
					game.Debris:AddItem(CoinEffect, 5)
					script.Sound:Play()

					CameraEffect.shake({shake = "Bump"})
					
					if string.find(toolName,"Pigeon") then
						local Achivement = game.ReplicatedStorage.Remotes:WaitForChild("AddAchievement")
						Achivement:FireServer({"Sell","Pigeon"},1)
					end
					if string.find(toolName,"Minecart") then
						local Achivement = game.ReplicatedStorage.Remotes:WaitForChild("AddAchievement")
						Achivement:FireServer({"Sell","Minecart"},1)
					end
					if string.find(toolName,"Miner") then
						local Achivement = game.ReplicatedStorage.Remotes:WaitForChild("AddAchievement")
						Achivement:FireServer({"Sell","Miner"},1)
					end
					if string.find(toolName,"Epic") then
						local Achivement = game.ReplicatedStorage.Remotes:WaitForChild("AddAchievement")
						Achivement:FireServer({"Sell","Epic"},1)
					end
					local Achivement = game.ReplicatedStorage.Remotes:WaitForChild("AddAchievement")
					Achivement:FireServer({"Sell",toolName},1)
				end)
			else
				dialogObject:hideGui("Can't sell a gear")
			end
			
		end
		if responseNum == 3 then
			warn("Trying to get the price")
			local toolName = GetEquippedToolName(player)
			if not toolName then
				dialogObject:hideGui("Nothing equipped")
				return
			end
			if string.find(toolName,"Pigeon") then
				local currentPigeon = pigeonInfo[toolName]
				if currentPigeon then
					local AmountF = math.floor(GetBeaksPerSecond(game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("Weight"), currentPigeon) * 20 * computeMutationMultiplier(TableMutations(game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool"))))
					dialogObject:hideGui("Your pigeon is worth "..AmountF .. "$")
				end
			elseif string.find(toolName,"Egg") then
				local currentEgg = eggInfo[toolName]
				if currentEgg then
					dialogObject:hideGui("Your Egg is worth "..(currentEgg.Cost/2).."$")
				end
			else
				dialogObject:hideGui("Can't sell a gear")
			end
			
		end
		if responseNum == 4 then
			dialogObject:hideGui("Alright.")
		end
	end
end)