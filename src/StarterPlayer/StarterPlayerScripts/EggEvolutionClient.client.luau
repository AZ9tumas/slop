--[[
	Egg Evolution Client
	
	This module provides basic client functions to interact with the EggEvolutionService.
	Use these functions to build UI connections and handle evolution state.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Player references
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Service reference (initialized after Knit starts)
local EggEvolutionService = nil

-- Local state
local cachedEvolutionData = nil

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------

-- Format seconds as MM:SS or HH:MM:SS
local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%02d:%02d:%02d", h, m, s)
	else
		return string.format("%02d:%02d", m, s)
	end
end

--------------------------------------------------------------------------------
-- BASIC CLIENT FUNCTIONS (Reusable for UI connections)
--------------------------------------------------------------------------------

--[[
	Start evolution for the currently equipped egg.
	The server auto-detects which egg is equipped.
	
	@return boolean success, string? errorMessage
]]
local function startEvolution()
	if not EggEvolutionService then
		return false, "Service not ready"
	end
	return EggEvolutionService:StartEvolution()
end

--[[
	Get the current evolution stage/progress from server.
	
	@return table? evolutionData - Contains:
		- Percentage (number): 0-1 progress
		- TimeLeft (number): Seconds remaining
		- IsComplete (boolean): Whether evolution has finished
		- ResultPreview (string?): Name of result egg (only when complete)
		- SourceEggName (string): Original egg name
		- TargetEggName (string): Possible success egg
		- FailEggName (string): Possible fail egg
		- IsSuccess (boolean?): Whether evolution succeeded (only when complete)
		- CanDevolve (boolean): Whether protection can be purchased
		- ProtectionProductId (number?): DevProduct ID for protection
		- SkipProductId (number?): DevProduct ID for skip
]]
local function getEvolutionStage()
	if not EggEvolutionService then
		return nil
	end
	
	local data = EggEvolutionService:GetEvolutionStage()
	
	if data then
		-- Add formatted time for convenience
		data.TimeLeftFormatted = formatTime(data.TimeLeft or 0)
		cachedEvolutionData = data
	else
		cachedEvolutionData = nil
	end
	
	return data
end

--[[
	Accept the completed evolution and receive the resulting egg.
	
	@return boolean success, string? errorMessage
]]
local function acceptEvolution()
	if not EggEvolutionService then
		return false, "Service not ready"
	end
	
	local success, errorMessage = EggEvolutionService:AcceptEvolution()
	
	if success then
		cachedEvolutionData = nil
	end
	
	return success, errorMessage
end

--[[
	Cancel an in-progress evolution and get the original egg back.
	Cannot cancel a completed evolution.
	
	@return boolean success, string? errorMessage
]]
local function cancelEvolution()
	if not EggEvolutionService then
		return false, "Service not ready"
	end
	
	local success, errorMessage = EggEvolutionService:CancelEvolution()
	
	if success then
		cachedEvolutionData = nil
	end
	
	return success, errorMessage
end

--[[
	Check if there is an active evolution (in progress or completed).
	
	@return boolean hasEvolution
]]
local function hasActiveEvolution()
	local data = getEvolutionStage()
	return data ~= nil
end

--[[
	Check if evolution is complete and waiting to be accepted.
	
	@return boolean isComplete
]]
local function isEvolutionComplete()
	local data = getEvolutionStage()
	return data ~= nil and data.IsComplete == true
end

--[[
	Check if evolution is still in progress.
	
	@return boolean isInProgress
]]
local function isEvolutionInProgress()
	local data = getEvolutionStage()
	return data ~= nil and data.IsComplete == false
end

--[[
	Get the cached evolution data without making a server call.
	
	@return table? evolutionData
]]
local function getCachedData()
	return cachedEvolutionData
end

--[[
	Get the Skip DevProduct ID for the current evolution.
	
	@return number? productId
]]
local function getSkipProductId()
	local data = getCachedData() or getEvolutionStage()
	if data then
		return data.SkipProductId
	end
	return nil
end

--[[
	Get the Protection DevProduct ID for the current evolution.
	
	@return number? productId
]]
local function getProtectionProductId()
	local data = getCachedData() or getEvolutionStage()
	if data then
		return data.ProtectionProductId
	end
	return nil
end

--[[
	Prompt purchase of skip timer product.
]]
local function promptSkipPurchase()
	local productId = getSkipProductId()
	if productId then
		MarketplaceService:PromptProductPurchase(player, productId)
	end
end

--[[
	Prompt purchase of protection product.
]]
local function promptProtectionPurchase()
	local productId = getProtectionProductId()
	if productId then
		MarketplaceService:PromptProductPurchase(player, productId)
	end
end

--------------------------------------------------------------------------------
-- EXPOSE FUNCTIONS GLOBALLY FOR UI SCRIPTS
--------------------------------------------------------------------------------

-- Create a global table for easy access from other scripts
_G.EggEvolution = {
	-- Core functions
	StartEvolution = startEvolution,
	GetEvolutionStage = getEvolutionStage,
	AcceptEvolution = acceptEvolution,
	CancelEvolution = cancelEvolution,
	
	-- State checks
	HasActiveEvolution = hasActiveEvolution,
	IsEvolutionComplete = isEvolutionComplete,
	IsEvolutionInProgress = isEvolutionInProgress,
	GetCachedData = getCachedData,
	
	-- Product helpers
	GetSkipProductId = getSkipProductId,
	GetProtectionProductId = getProtectionProductId,
	PromptSkipPurchase = promptSkipPurchase,
	PromptProtectionPurchase = promptProtectionPurchase,
	
	-- Utility
	FormatTime = formatTime,
}

--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------

-- Wait for Knit to start, then get the service reference
Knit.OnStart():andThen(function()
	EggEvolutionService = Knit.GetService("EggEvolutionService")
	
	-- Check for any existing evolution on join
	local existingEvolution = getEvolutionStage()
	if existingEvolution then
		print("[EggEvolutionClient] Found existing evolution:", existingEvolution.SourceEggName)
	end
end):catch(function(err)
	warn("[EggEvolutionClient] Failed to initialize:", err)
end)

--------------------------------------------------------------------------------
-- UI TRIGGER (Touch detection for evolution stand)
--------------------------------------------------------------------------------

local touchPart = workspace:FindFirstChild("TemplateSlot") 
	and workspace.TemplateSlot:FindFirstChild("MainStand") 
	and workspace.TemplateSlot.MainStand:FindFirstChild("CenterFoot")

if touchPart then
	touchPart.Touched:Connect(function(hit)
		if hit and hit.Parent and hit.Parent:FindFirstChildWhichIsA("Humanoid") then
			local char = hit.Parent
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local plr = Players:GetPlayerFromCharacter(char)
			
			if plr ~= player then return end
			if not hrp then return end
			
			local evolveFrame = playerGui:FindFirstChild("MainUI") 
				and playerGui.MainUI:FindFirstChild("Frames")
				and playerGui.MainUI.Frames:FindFirstChild("EvolveEggs")
			
			if evolveFrame then
				if (hrp.Position - touchPart.Position).Magnitude > 5 then
					evolveFrame.Visible = false
				else
					evolveFrame.Visible = true
				end
			end
		end
	end)
end