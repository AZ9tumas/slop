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

local function removeEggByUUID(player, eggUUID, eggName)
	local InventoryService = Knit.GetService("InventoryService")
	InventoryService:RemoveItem(player, eggName, "Egg", { ID = eggUUID })
end

local function addEgg(player, eggName)
	local InventoryService = Knit.GetService("InventoryService")
	local HttpService = game:GetService("HttpService")
	return InventoryService:AddItem(player, eggName, "Egg", {
		ID = HttpService:GenerateGUID(false)
	})
end

function EggEvolutionService:_finishEvolution(player)
	local evolution = ActiveEvolutions[player]
	if not evolution then
		return false
	end
	
	if evolution.Status == "Completed" then
		return true
	end
	
	
	local resultEggName, isSuccess = EggEvolutionInfo.Evolve(evolution.SourceEggName)
	
	
	evolution.Status = "Completed"
	evolution.FinalResultName = resultEggName
	evolution.IsSuccess = isSuccess
	evolution.CanDevolve = not isSuccess and (evolution.ProtectionProductId ~= nil)
	
	
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution Complete!")
	end
	
	return true
end

function EggEvolutionService.Client:StartEvolution(player, eggUUID)
	return self.Server:StartEvolution(player, eggUUID)
end

function EggEvolutionService:StartEvolution(player, eggUUID)
	if ActiveEvolutions[player] then
		return false, "You already have an active evolution"
	end
	
	if not eggUUID or type(eggUUID) ~= "string" then
		return false, "Invalid egg ID"
	end
	
	local eggData, eggName = findEggByUUID(player, eggUUID)
	if not eggData then
		return false, "Egg not found in inventory"
	end
	
	local details = EggEvolutionInfo.GetEvolutionDetails(eggName)
	if not details then
		return false, "This egg cannot be evolved"
	end
	
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	if not profile then
		return false, "Player data not loaded"
	end
	
	local currentBeaks = profile.Data.Beaks or 0
	if currentBeaks < details.Cost then
		return false, "Not enough Beaks"
	end
	
	profile.Data.Beaks = currentBeaks - details.Cost
	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Beaks") then
		player.leaderstats.Beaks.Value = profile.Data.Beaks
	end
	
	removeEggByUUID(player, eggUUID, eggName)

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
		DelayThread = nil
	}
	
	local evolution = ActiveEvolutions[player]
	evolution.DelayThread = task.delay(duration, function()
		if ActiveEvolutions[player] and ActiveEvolutions[player].EggUUID == eggUUID then
			self:_finishEvolution(player)
		end
	end)
	
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
	local evolution = ActiveEvolutions[player]
	
	if not evolution then
		return nil
	end
	
	local currentTime = os.time()
	local elapsed = currentTime - evolution.StartTime
	local percentage = math.clamp(elapsed / evolution.Duration, 0, 1)
	local timeLeft = math.max(0, evolution.FinishTime - currentTime)
	
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
	
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "You received a " .. evolution.FinalResultName .. "!")
	end
	
	ActiveEvolutions[player] = nil
	
	return true
end

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
	
	local Notification = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Notification")
	if Notification then
		Notification:FireClient(player, "Evolution cancelled. " .. evolution.SourceEggName .. " returned.")
	end
	
	ActiveEvolutions[player] = nil
	
	return true
end

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

function EggEvolutionService:ProcessProtection(player)
	local evolution = ActiveEvolutions[player]
	
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

function EggEvolutionService:GetSkipProductId(player)
	local evolution = ActiveEvolutions[player]
	if evolution then
		return evolution.SkipProductId
	end
	return nil
end

function EggEvolutionService:GetProtectionProductId(player)
	local evolution = ActiveEvolutions[player]
	if evolution then
		return evolution.ProtectionProductId
	end
	return nil
end

function EggEvolutionService:KnitStart()
	-- Cleanup on player leaving
	Players.PlayerRemoving:Connect(function(player)
		local evolution = ActiveEvolutions[player]
		if evolution then
			if evolution.DelayThread then
				task.cancel(evolution.DelayThread)
			end
		end

		-- lost when left
		ActiveEvolutions[player] = nil
	end)
end

function EggEvolutionService:KnitInit()
	-- Initialization...
end

return EggEvolutionService
