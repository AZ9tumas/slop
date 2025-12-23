local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EggEvolutionInfo = require(ReplicatedStorage.Info.EggEvolutionInfo)

local EggEvolutionService = Knit.CreateService {
	Name = "EggEvolutionService",
	Client = {}
}

-- Runtime state table for active evolutions (session-based, not saved)
-- Format: self.ActiveEvolutions[player] = { ... evolution data ... }
local ActiveEvolutions = {}

----------------------------------------------------------------
-- INTERNAL HELPERS
----------------------------------------------------------------

--[[
	Internal helper to find an egg by UUID in player's inventory.
	Returns the egg data and its name if found, nil otherwise.
]]
local function findEggByUUID(player, eggUUID)
	local InventoryService = Knit.GetService("InventoryService")
	local inventory = InventoryService:GetInventory(player)
	
	if not inventory or not inventory.Eggs then
		return nil, nil
	end
	
	for _, egg in ipairs(inventory.Eggs) do
		if egg.ID == eggUUID then
			return egg, egg.Name
		end
	end
	
	return nil, nil
end

--[[
	Internal helper to remove an egg by UUID from player's inventory.
	This locks the egg during evolution.
]]
local function removeEggByUUID(player, eggUUID, eggName)
	local InventoryService = Knit.GetService("InventoryService")
	InventoryService:RemoveItem(player, eggName, "Egg", { ID = eggUUID })
end

--[[
	Internal helper to add an egg to player's inventory.
]]
local function addEgg(player, eggName)
	local InventoryService = Knit.GetService("InventoryService")
	local HttpService = game:GetService("HttpService")
	return InventoryService:AddItem(player, eggName, "Egg", {
		ID = HttpService:GenerateGUID(false)
	})
end

--[[
	Internal helper that calculates the result of an evolution.
	Called when timer finishes, skip is used, or GetEvolutionStage detects completion.
]]
function EggEvolutionService:_finishEvolution(player)
	local evolution = ActiveEvolutions[player]
	if not evolution then
		return false
	end
	
	if evolution.Status == "Completed" then
		return true -- Already completed
	end
	
	-- Calculate result using EggEvolutionInfo
	local resultEggName, isSuccess = EggEvolutionInfo.Evolve(evolution.SourceEggName)
	
	-- Update state
	evolution.Status = "Completed"
	evolution.FinalResultName = resultEggName
	evolution.IsSuccess = isSuccess
	evolution.CanDevolve = not isSuccess and (evolution.ProtectionProductId ~= nil)
	
	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution Complete!")
	end
	
	return true
end

----------------------------------------------------------------
-- CLIENT METHODS
----------------------------------------------------------------

--[[
	Client:StartEvolution(player, eggUUID)
	
	Initiates an evolution for the specified egg.
	
	Validation:
	- Check if player already has an active evolution (Limit: 1)
	- Verify player owns eggUUID via inventory
	- Get egg data from EggEvolutionInfo.GetEvolutionDetails
	- Check if player has enough currency (Beaks) and deduct it
	
	Returns: true (Success) or false (Fail), optional error message
]]
function EggEvolutionService.Client:StartEvolution(player, eggUUID)
	return self.Server:StartEvolution(player, eggUUID)
end

function EggEvolutionService:StartEvolution(player, eggUUID)
	-- Check if player already has an active evolution
	if ActiveEvolutions[player] then
		return false, "You already have an active evolution"
	end
	
	-- Validate eggUUID
	if not eggUUID or type(eggUUID) ~= "string" then
		return false, "Invalid egg ID"
	end
	
	-- Find the egg in player's inventory
	local eggData, eggName = findEggByUUID(player, eggUUID)
	if not eggData then
		return false, "Egg not found in inventory"
	end
	
	-- Get evolution details from config
	local details = EggEvolutionInfo.GetEvolutionDetails(eggName)
	if not details then
		return false, "This egg cannot be evolved"
	end
	
	-- Check player's currency (Beaks)
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	if not profile then
		return false, "Player data not loaded"
	end
	
	local currentBeaks = profile.Data.Beaks or 0
	if currentBeaks < details.Cost then
		return false, "Not enough Beaks"
	end
	
	-- Deduct currency
	profile.Data.Beaks = currentBeaks - details.Cost
	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Beaks") then
		player.leaderstats.Beaks.Value = profile.Data.Beaks
	end
	
	-- Remove egg from inventory (lock it during evolution)
	removeEggByUUID(player, eggUUID, eggName)
	
	-- Create evolution entry
	local startTime = os.time()
	local duration = details.Time
	local finishTime = startTime + duration
	
	ActiveEvolutions[player] = {
		EggUUID = eggUUID,
		SourceEggName = eggName,
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
		SkipProductId = details.SkipProductId,
		DelayThread = nil -- Reference to the delayed task for cancellation
	}
	
	-- Spawn a delayed task to finish evolution when time is up
	-- Store reference for potential cancellation on player disconnect
	local evolution = ActiveEvolutions[player]
	evolution.DelayThread = task.delay(duration, function()
		-- Check if evolution still exists and belongs to same egg (player might have started a new one)
		if ActiveEvolutions[player] and ActiveEvolutions[player].EggUUID == eggUUID then
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

--[[
	Client:GetEvolutionStage(player)
	
	Retrieves the current evolution status for the player.
	
	Returns:
	- Percentage (number 0-1)
	- TimeLeft (number)
	- IsComplete (boolean)
	- ResultPreview (string, only sent if complete)
	- SourceEggName (string)
	- TargetEggName (string)
	- FailEggName (string)
	- ProtectionProductId (number or nil)
	- SkipProductId (number or nil)
	- IsSuccess (boolean or nil)
]]
function EggEvolutionService.Client:GetEvolutionStage(player)
	return self.Server:GetEvolutionStage(player)
end

function EggEvolutionService:GetEvolutionStage(player)
	local evolution = ActiveEvolutions[player]
	
	if not evolution then
		return nil -- No active evolution
	end
	
	local currentTime = os.time()
	local elapsed = currentTime - evolution.StartTime
	local percentage = math.clamp(elapsed / evolution.Duration, 0, 1)
	local timeLeft = math.max(0, evolution.FinishTime - currentTime)
	
	-- Check if evolution should be completed
	if evolution.Status == "InProgress" and currentTime >= evolution.FinishTime then
		self:_finishEvolution(player)
	end
	
	local isComplete = evolution.Status == "Completed"
	
	return {
		Percentage = percentage,
		TimeLeft = timeLeft,
		IsComplete = isComplete,
		ResultPreview = isComplete and evolution.FinalResultName or nil,
		SourceEggName = evolution.SourceEggName,
		TargetEggName = evolution.TargetEggName,
		FailEggName = evolution.FailEggName,
		ProtectionProductId = evolution.ProtectionProductId,
		SkipProductId = evolution.SkipProductId,
		IsSuccess = evolution.IsSuccess,
		CanDevolve = evolution.CanDevolve
	}
end

--[[
	Client:AcceptEvolution(player)
	
	Claims the evolution result and adds the final egg to inventory.
	
	Validation:
	- Evolution must be in "Completed" status
	
	Returns: true (Success) or false (Fail), optional error message
]]
function EggEvolutionService.Client:AcceptEvolution(player)
	return self.Server:AcceptEvolution(player)
end

function EggEvolutionService:AcceptEvolution(player)
	local evolution = ActiveEvolutions[player]
	
	if not evolution then
		return false, "No active evolution"
	end
	
	if evolution.Status ~= "Completed" then
		return false, "Evolution is not complete yet"
	end
	
	-- Add the final egg to inventory
	local success = addEgg(player, evolution.FinalResultName)
	if not success then
		return false, "Failed to add egg to inventory"
	end
	
	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "You received a " .. evolution.FinalResultName .. "!")
	end
	
	-- Clear evolution data
	ActiveEvolutions[player] = nil
	
	return true
end

--[[
	Client:CancelEvolution(player)
	
	Cancels an in-progress evolution and returns the original egg.
	Only works if evolution is still in progress.
	
	Returns: true (Success) or false (Fail), optional error message
]]
function EggEvolutionService.Client:CancelEvolution(player)
	return self.Server:CancelEvolution(player)
end

function EggEvolutionService:CancelEvolution(player)
	local evolution = ActiveEvolutions[player]
	
	if not evolution then
		return false, "No active evolution"
	end
	
	if evolution.Status == "Completed" then
		return false, "Cannot cancel a completed evolution"
	end
	
	-- Return the original egg
	local success = addEgg(player, evolution.SourceEggName)
	if not success then
		return false, "Failed to return egg to inventory"
	end
	
	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution cancelled. " .. evolution.SourceEggName .. " returned.")
	end
	
	-- Clear evolution data
	ActiveEvolutions[player] = nil
	
	return true
end

----------------------------------------------------------------
-- PRODUCT HANDLERS (for StoreManager integration)
----------------------------------------------------------------

--[[
	ProcessSkip(player)
	
	Called by StoreManager when player purchases the Skip Timer product.
	Immediately completes the evolution.
	
	Returns: true if processed, false if not applicable
]]
function EggEvolutionService:ProcessSkip(player)
	local evolution = ActiveEvolutions[player]
	
	if not evolution then
		return false
	end
	
	if evolution.Status == "Completed" then
		return false -- Already complete
	end
	
	-- Force finish
	evolution.FinishTime = os.time()
	self:_finishEvolution(player)
	
	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution timer skipped!")
	end
	
	return true
end

--[[
	ProcessProtection(player)
	
	Called by StoreManager when player purchases the Protection product.
	Changes the result from failure back to the original egg.
	
	Returns: true if processed, false if not applicable
]]
function EggEvolutionService:ProcessProtection(player)
	local evolution = ActiveEvolutions[player]
	
	if not evolution then
		return false
	end
	
	if evolution.Status ~= "Completed" then
		return false -- Not completed yet
	end
	
	if evolution.IsSuccess then
		return false -- Cannot protect a success
	end
	
	if not evolution.CanDevolve then
		return false -- Protection not available
	end
	
	-- Restore original egg
	evolution.FinalResultName = evolution.SourceEggName
	evolution.CanDevolve = false
	
	-- Notify player
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution Protection Applied! Egg restored.")
	end
	
	return true
end

--[[
	GetSkipProductId(player)
	
	Returns the skip product ID for the player's current evolution.
]]
function EggEvolutionService:GetSkipProductId(player)
	local evolution = ActiveEvolutions[player]
	if evolution then
		return evolution.SkipProductId
	end
	return nil
end

--[[
	GetProtectionProductId(player)
	
	Returns the protection product ID for the player's current evolution.
]]
function EggEvolutionService:GetProtectionProductId(player)
	local evolution = ActiveEvolutions[player]
	if evolution then
		return evolution.ProtectionProductId
	end
	return nil
end

----------------------------------------------------------------
-- LIFECYCLE
----------------------------------------------------------------

function EggEvolutionService:KnitStart()
	-- Cleanup on player leaving
	Players.PlayerRemoving:Connect(function(player)
		local evolution = ActiveEvolutions[player]
		if evolution then
			-- Cancel any pending delayed task to prevent it from running after cleanup
			if evolution.DelayThread then
				task.cancel(evolution.DelayThread)
			end
		end
		-- Evolution data is session-based and intentionally not persisted.
		-- Per the specification: "active evolutions are not saved to DataStores and are lost if the player disconnects"
		ActiveEvolutions[player] = nil
	end)
end

function EggEvolutionService:KnitInit()
	-- Initialization if needed
end

return EggEvolutionService
