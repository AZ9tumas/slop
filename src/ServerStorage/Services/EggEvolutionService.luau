local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local eggsFolder: Folder = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Eggs")

local EggEvolutionInfo = require(ReplicatedStorage.Info.EggEvolutionInfo)

local EggEvolutionService = Knit.CreateService {
	Name = "EggEvolutionService",
	Client = {}
}

-- Runtime delay threads for active evolutions (not saved, restored on login)
local EvolutionDelayThreads = {}

-- Helper: Get ActiveEvolution from profile
local function getActiveEvolution(player)
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	if not profile then return nil end
	return profile.Data.ActiveEvolution
end

-- Helper: Set ActiveEvolution in profile
local function setActiveEvolution(player, data)
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	if not profile then return false end
	profile.Data.ActiveEvolution = data
	return true
end

-- Helper: Get equipped egg from player's character tool (secure server-side)
local function getEquippedEgg(player)
	local character = player.Character
	if not character then return nil end

	local tool = character:FindFirstChildWhichIsA("Tool")
	if not tool then return nil end

	local eggId = tool:GetAttribute("EggId")
	if not eggId then return nil end

	-- Validate egg exists in inventory
	local InventoryService = Knit.GetService("InventoryService")
	local inventory = InventoryService:GetInventory(player)

	if not inventory or not inventory.Eggs then
		return nil
	end

	for _, egg in ipairs(inventory.Eggs) do
		if egg.ID == eggId then
			return egg
		end
	end

	return nil
end

-- Helper: Remove egg by UUID
local function removeEggByUUID(player, eggUUID, eggName)
	local InventoryService = Knit.GetService("InventoryService")
	InventoryService:RemoveItem(player, eggName, "Egg", { ID = eggUUID })
end

-- Helper: Add egg with mutation preservation
local function addEggWithMutation(player, eggName, mutation)
	local InventoryService = Knit.GetService("InventoryService")
	return InventoryService:AddItem(player, eggName, "Egg", {
		ID = HttpService:GenerateGUID(false),
		Mutation = mutation or "Normal"
	})
end

-- Helper: Get source egg name from evolution data (with backward compatibility)
local function getSourceEggName(evolution)
	if evolution.SourceEggData and evolution.SourceEggData.Name then
		return evolution.SourceEggData.Name
	end
	return evolution.SourceEggName
end

-- Helper: Get source egg mutation from evolution data
local function getSourceEggMutation(evolution)
	if evolution.SourceEggData and evolution.SourceEggData.Mutation then
		return evolution.SourceEggData.Mutation
	end
	return "Normal"
end

local function updatePlotDisplayValue(player, evolutionData)
	local PlotService = Knit.GetService("PlotService")
	local plot = PlotService:GetPlayerPlot(player)
	if not plot then return end

	local evolutionArea = plot:FindFirstChild("EvolutionArea")
	if not evolutionArea then return end

	local display = evolutionArea:FindFirstChild("Display")
	if not display then return end

	local displayPart = display:FindFirstChild("DisplayPart")
	if not displayPart then return end

	local numberValue = displayPart:FindFirstChild("Value")
	if not numberValue then return end

	local surfaceUI = displayPart:WaitForChild("SurfaceGui")
	local mainFramePart = surfaceUI:WaitForChild("Main")
	local partTitleInfo = mainFramePart:WaitForChild("TitleInfo")

	local timeLeft = evolutionData and evolutionData.TimeLeft or 0
	local text = "No Active Evolution"

	if evolutionData and evolutionData.Status == "InProgress" then
		text = "Evolving ..."
	elseif evolutionData and evolutionData.Status == "Completed" then
		text = "Evolution Complete!"
	end

	partTitleInfo.Text = text
	numberValue.Value = evolutionData and evolutionData.FinishTime or 0

	local mainstand = display.Parent
	local CenterFoot = mainstand.MainStand.CenterFoot

	--[[
		SourceEggData = sourceEggData,
		SourceEggName = eggName, -- Backward compatibility field
		TargetEggName = details.NextEgg,
		FailEggName = details.FailEgg,
		StartTime = startTime,
		Duration = duration,
		FinishTime = finishTime,
		Status = "InProgress",
		FinalResultName = nil,
		IsSuccess = nil,
		CanDevolve = false,
		ProtectionProductId = details.ProtectionProductId,
		SkipProductId = details.SkipProductId
	]]

	print("EVOLUTION DATA TO DISPLAY EGG:", evolutionData)

	if evolutionData == nil then
		-- if any egg exists under evolutionArea then delete it
		for _, v in pairs(evolutionArea:GetChildren()) do
			if v.Name == "Egg" then
				v:Destroy()
			end
		end
	else
		print("FOUND PROPER EVOLUTION DATA TO DISPLAY EGG")
		local model: Model = eggsFolder:WaitForChild(evolutionData.SourceEggName:gsub(" Egg", "")).Egg:Clone()
		model:PivotTo(CenterFoot.CFrame)
		model.Parent = evolutionArea
	end
end

function EggEvolutionService:_finishEvolution(player)
	if player.Parent ~= Players then return false end

	local evolution = getActiveEvolution(player)
	if not evolution then
		return false
	end

	if evolution.Status == "Completed" then
		return true
	end

	-- Run probability logic using source egg name
	local sourceEggName = getSourceEggName(evolution)
	local resultEggName, isSuccess = EggEvolutionInfo.Evolve(sourceEggName)

	-- Update evolution data
	evolution.Status = "Completed"
	evolution.FinalResultName = resultEggName
	evolution.IsSuccess = isSuccess
	evolution.CanDevolve = not isSuccess and (evolution.ProtectionProductId ~= nil)

	-- Save back to profile
	setActiveEvolution(player, evolution)

	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution Complete!")
	end

	return true
end

function EggEvolutionService.Client:GetEvolutionDetails(player)
	return self.Server:GetEvolutionDetails(player)
end

function EggEvolutionService:GetEvolutionDetails(player)
	local eggData = getEquippedEgg(player)
	if not eggData then
		return nil
	end

	local eggName = eggData.Name
	local eggUUID = eggData.ID
	local details = EggEvolutionInfo.GetEvolutionDetails(eggName)

	return details
end

function EggEvolutionService.Client:StartEvolution(player)
	return self.Server:StartEvolution(player)
end

function EggEvolutionService:StartEvolution(player)
	-- Check if there's already an active evolution in profile
	local existingEvolution = getActiveEvolution(player)
	if existingEvolution then
		game.ReplicatedStorage.Remotes.Notification:FireClient(player, "You already have an active evolution!")
		self:RestoreEvolution(player)
		return false, "You already have an active evolution"
	end

	-- SECURITY: Auto-detect equipped egg from character tool (never trust client)
	local eggData = getEquippedEgg(player)
	if not eggData then
		local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
		if Notification then
			Notification:FireClient(player, "Equip an egg first!")
		end
		return false, "Equip an egg first!"
	end

	local eggName = eggData.Name
	local eggUUID = eggData.ID

	-- Get evolution details
	local details = EggEvolutionInfo.GetEvolutionDetails(eggName)
	if not details then
		return false, "This egg cannot be evolved"
	end

	-- Get player profile
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	if not profile then
		return false, "Player data not loaded"
	end

	-- Check and deduct currency
	local currentBeaks = profile.Data.Beaks or 0
	if currentBeaks < details.Cost then
		return false, "Not enough Beaks"
	end

	profile.Data.Beaks = currentBeaks - details.Cost
	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Beaks") then
		player.leaderstats.Beaks.Value = profile.Data.Beaks
	end

	-- Store full egg data snapshot BEFORE removing from inventory (critical for Mutation preservation)
	local sourceEggData = {
		Name = eggData.Name,
		UUID = eggData.ID,
		Mutation = eggData.Mutation or "Normal",
		Fav = eggData.Fav or false
	}

	-- Remove egg from inventory
	removeEggByUUID(player, eggUUID, eggName)

	-- Destroy the equipped tool
	local character = player.Character
	if character then
		local tool = character:FindFirstChildWhichIsA("Tool")
		if tool and tool:GetAttribute("EggId") == eggUUID then
			tool:Destroy()
		end
	end

	local startTime = os.time()
	local duration = details.Time
	local finishTime = startTime + duration

	-- Construct ActiveEvolution data (persistent)
	local evolutionData = {
		SourceEggData = sourceEggData,
		SourceEggName = eggName, -- Backward compatibility field
		TargetEggName = details.NextEgg,
		FailEggName = details.FailEgg,
		StartTime = startTime,
		Duration = duration,
		FinishTime = finishTime,
		Status = "InProgress",
		FinalResultName = nil,
		IsSuccess = nil,
		CanDevolve = false,
		ProtectionProductId = details.ProtectionProductId,
		SkipProductId = details.SkipProductId
	}

	-- Save to profile (persistent)
	setActiveEvolution(player, evolutionData)

	-- Update plot display value
	updatePlotDisplayValue(player, getActiveEvolution(player))

	-- Start delay thread for auto-completion
	EvolutionDelayThreads[player] = task.delay(duration, function()
		local currentEvolution = getActiveEvolution(player)
		if currentEvolution and currentEvolution.SourceEggData and currentEvolution.SourceEggData.UUID == eggUUID then
			self:_finishEvolution(player)
			updatePlotDisplayValue(player, getActiveEvolution(player))
		end
	end)

	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution started for " .. eggName .. "!")
	end

	return true
end

function EggEvolutionService.Client:GetEvolutionStage(player)
	return self.Server:GetEvolutionStage(player)
end

function EggEvolutionService:GetEvolutionStage(player)
	local evolution = getActiveEvolution(player)

	if not evolution then
		return nil
	end

	local currentTime = os.time()
	local elapsed = currentTime - evolution.StartTime
	local percentage = math.clamp(elapsed / evolution.Duration, 0, 1)
	local timeLeft = math.max(0, evolution.FinishTime - currentTime)

	-- Auto-Complete: If time is up and status is still InProgress
	if evolution.Status == "InProgress" and currentTime >= evolution.FinishTime then
		self:_finishEvolution(player)
		-- Refresh evolution data after completion
		evolution = getActiveEvolution(player)
	end

	local isComplete = evolution.Status == "Completed"
	local sourceEggName = getSourceEggName(evolution)

	return {
		Percentage = percentage,
		TimeLeft = timeLeft,
		IsComplete = isComplete,
		ResultPreview = isComplete and evolution.FinalResultName or nil,
		SourceEggName = sourceEggName,
		TargetEggName = evolution.TargetEggName,
		FailEggName = evolution.FailEggName,
		ProtectionProductId = evolution.ProtectionProductId,
		SkipProductId = evolution.SkipProductId,
		IsSuccess = evolution.IsSuccess,
		CanDevolve = evolution.CanDevolve
	}
end

function EggEvolutionService.Client:AcceptEvolution(player)
	return self.Server:AcceptEvolution(player)
end

function EggEvolutionService:AcceptEvolution(player)
	local evolution = getActiveEvolution(player)

	if not evolution then
		return false, "No active evolution"
	end

	if evolution.Status ~= "Completed" then
		return false, "Evolution is not complete yet"
	end

	-- Get Mutation from SourceEggData to preserve it
	local mutation = getSourceEggMutation(evolution)

	-- Add the final egg to inventory with preserved Mutation
	local success = addEggWithMutation(player, evolution.FinalResultName, mutation)
	if not success then
		return false, "Failed to add egg to inventory"
	end

	-- Clear evolution slot
	setActiveEvolution(player, nil)

	-- Cancel any pending delay thread
	if EvolutionDelayThreads[player] then
		task.cancel(EvolutionDelayThreads[player])
		EvolutionDelayThreads[player] = nil
	end

	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution Accepted!")
	end

	updatePlotDisplayValue(player, nil)

	return true
end

function EggEvolutionService.Client:CancelEvolution(player)
	return self.Server:CancelEvolution(player)
end

function EggEvolutionService:CancelEvolution(player)
	local evolution = getActiveEvolution(player)

	if not evolution then
		return false, "No active evolution"
	end

	if evolution.Status == "Completed" then
		return false, "Cannot cancel a completed evolution"
	end

	-- Get source egg data for Mutation preservation
	local sourceEggName = getSourceEggName(evolution)
	local mutation = getSourceEggMutation(evolution)

	-- Return the original egg with preserved Mutation
	local success = addEggWithMutation(player, sourceEggName, mutation)
	if not success then
		return false, "Failed to return egg to inventory"
	end

	-- Clear evolution slot
	setActiveEvolution(player, nil)

	-- Cancel any pending delay thread
	if EvolutionDelayThreads[player] then
		task.cancel(EvolutionDelayThreads[player])
		EvolutionDelayThreads[player] = nil
	end

	-- Clear plot display
	updatePlotDisplayValue(player, nil)

	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution cancelled. " .. sourceEggName .. " returned.")
	end

	return true
end

function EggEvolutionService:ProcessSkip(player)
	local evolution = getActiveEvolution(player)

	if not evolution then
		return false
	end

	if evolution.Status == "Completed" then
		return false -- Already complete
	end

	-- Set finish time to now (instant finish)
	evolution.FinishTime = os.time()
	setActiveEvolution(player, evolution)

	-- Finish the evolution
	self:_finishEvolution(player)

	-- Cancel any pending delay thread
	if EvolutionDelayThreads[player] then
		task.cancel(EvolutionDelayThreads[player])
		EvolutionDelayThreads[player] = nil
	end

	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution timer skipped!")
	end

	return true
end

function EggEvolutionService.Client:ProcessProtection(player)
	-- if protection id is nil then this happens for free
	local id = self.Server:GetProtectionProductId(player)
	if id == nil then
		return self.Server:ProcessProtection(player)
	end

	return false
end

function EggEvolutionService:ProcessProtection(player)
	print("Processing protection for player:", player.Name)
	local evolution = getActiveEvolution(player)

	if not evolution then
		return false
	end

	if evolution.Status ~= "Completed" then
		return false
	end

	if evolution.IsSuccess then
		return false
	end

	if not evolution.CanDevolve then
		return false
	end

	-- Restore original egg name from SourceEggData
	local sourceEggName = getSourceEggName(evolution)
	evolution.FinalResultName = sourceEggName
	evolution.IsSuccess = true -- Flag as success to prevent re-purchasing protection
	evolution.CanDevolve = false

	-- Save updated evolution data
	setActiveEvolution(player, evolution)

	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution Failed, but Egg was protected! You can now collect it.")
	end

	return true
end

function EggEvolutionService:GetSkipProductId(player)
	local evolution = getActiveEvolution(player)
	if evolution then
		return evolution.SkipProductId
	end
	return nil
end

function EggEvolutionService:GetProtectionProductId(player)
	local evolution = getActiveEvolution(player)
	if evolution then
		return evolution.ProtectionProductId
	end
	return nil
end

-- Restore evolution timer for a player (called on player join)
function EggEvolutionService:RestoreEvolution(player)
	local evolution = getActiveEvolution(player)

	if not evolution then
		return
	end

	local currentTime = os.time()
	local timeLeft = math.max(0, evolution.FinishTime - currentTime)

	updatePlotDisplayValue(player, evolution)

	-- If evolution is still in progress, set up a delay thread
	if evolution.Status == "InProgress" then
		if timeLeft > 0 then
			-- Set up delay thread for remaining time
			EvolutionDelayThreads[player] = task.delay(timeLeft, function()
				local currentEvolution = getActiveEvolution(player)
				if currentEvolution and currentEvolution.Status == "InProgress" then
					self:_finishEvolution(player)
					updatePlotDisplayValue(player, getActiveEvolution(player))
				end
			end)
		else
			-- Time has passed, finish immediately
			print("Evolution time up!!")
			self:_finishEvolution(player)
		end
	end
end

function EggEvolutionService:KnitStart()
	local DataService = Knit.GetService("DataService")

	-- Restore evolution timers for players who have active evolutions on join
	DataService.PlayerProfileLoaded.Event:Connect(function(player)
		task.defer(function()
			self:RestoreEvolution(player)
		end)
	end)

	-- Cleanup on player leaving
	Players.PlayerRemoving:Connect(function(player)
		-- Cancel delay thread if any
		if EvolutionDelayThreads[player] then
			task.cancel(EvolutionDelayThreads[player])
			EvolutionDelayThreads[player] = nil
		end
	end)
end

function EggEvolutionService:KnitInit()
	-- Initialization...
end

return EggEvolutionService
