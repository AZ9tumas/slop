local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

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

-- Helper: Find egg by UUID in inventory
local function findEggByUUID(player, eggUUID)
	local InventoryService = Knit.GetService("InventoryService")
	local inventory = InventoryService:GetInventory(player)
	
	if not inventory or not inventory.Eggs then
		return nil
	end
	
	for _, egg in ipairs(inventory.Eggs) do
		if egg.ID == eggUUID then
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

function EggEvolutionService:_finishEvolution(player)
	local evolution = getActiveEvolution(player)
	if not evolution then
		return false
	end
	
	if evolution.Status == "Completed" then
		return true
	end
	
	-- Run probability logic using source egg name
	local sourceEggName = evolution.SourceEggData and evolution.SourceEggData.Name or evolution.SourceEggName
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

function EggEvolutionService.Client:StartEvolution(player)
	return self.Server:StartEvolution(player)
end

function EggEvolutionService:StartEvolution(player)
	-- Check if there's already an active evolution in profile
	local existingEvolution = getActiveEvolution(player)
	if existingEvolution then
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
	
	-- Start delay thread for auto-completion
	EvolutionDelayThreads[player] = task.delay(duration, function()
		local currentEvolution = getActiveEvolution(player)
		if currentEvolution and currentEvolution.SourceEggData and currentEvolution.SourceEggData.UUID == eggUUID then
			self:_finishEvolution(player)
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
	local sourceEggName = evolution.SourceEggData and evolution.SourceEggData.Name or evolution.SourceEggName
	
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
	local mutation = evolution.SourceEggData and evolution.SourceEggData.Mutation or "Normal"
	
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
	local sourceEggName = evolution.SourceEggData and evolution.SourceEggData.Name or evolution.SourceEggName
	local mutation = evolution.SourceEggData and evolution.SourceEggData.Mutation or "Normal"
	
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

function EggEvolutionService:ProcessProtection(player)
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
	local sourceEggName = evolution.SourceEggData and evolution.SourceEggData.Name or evolution.SourceEggName
	evolution.FinalResultName = sourceEggName
	evolution.IsSuccess = true -- Flag as success to prevent re-purchasing protection
	evolution.CanDevolve = false
	
	-- Save updated evolution data
	setActiveEvolution(player, evolution)
	
	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution Failed, but Egg was protected!")
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
function EggEvolutionService:RestoreEvolutionTimer(player)
	local evolution = getActiveEvolution(player)
	if not evolution then
		return
	end
	
	-- If evolution is still in progress, set up a delay thread
	if evolution.Status == "InProgress" then
		local currentTime = os.time()
		local timeLeft = math.max(0, evolution.FinishTime - currentTime)
		
		if timeLeft > 0 then
			-- Set up delay thread for remaining time
			local eggUUID = evolution.SourceEggData and evolution.SourceEggData.UUID
			EvolutionDelayThreads[player] = task.delay(timeLeft, function()
				local currentEvolution = getActiveEvolution(player)
				if currentEvolution and currentEvolution.Status == "InProgress" then
					self:_finishEvolution(player)
				end
			end)
		else
			-- Time has passed, finish immediately
			self:_finishEvolution(player)
		end
	end
end

function EggEvolutionService:KnitStart()
	local DataService = Knit.GetService("DataService")
	
	-- Restore evolution timers for players who have active evolutions on join
	DataService.PlayerProfileLoaded.Event:Connect(function(player)
		task.defer(function()
			self:RestoreEvolutionTimer(player)
		end)
	end)
	
	-- Cleanup on player leaving
	Players.PlayerRemoving:Connect(function(player)
		-- Cancel delay thread if any
		if EvolutionDelayThreads[player] then
			task.cancel(EvolutionDelayThreads[player])
			EvolutionDelayThreads[player] = nil
		end
		-- Note: Evolution data is persisted in profile, no need to clear it
	end)
end

function EggEvolutionService:KnitInit()
	-- Initialization...
end

return EggEvolutionService
