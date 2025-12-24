local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")

local EggEvolutionController = Knit.CreateController { Name = "EggEvolutionController" }

-- Cached reference to the server service
local EggEvolutionService

-- Local state for tracking evolution UI updates
local currentEvolutionData = nil
local evolutionUpdateCallbacks = {}

-- Helper: Format time as MM:SS or HH:MM:SS
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

--[[
	Start evolution for the currently equipped egg.
	The server auto-detects which egg is equipped - no need to pass egg ID.
	
	@return boolean success, string? errorMessage
]]
function EggEvolutionController:StartEvolution()
	if not EggEvolutionService then
		return false, "Service not ready"
	end
	
	local success, errorMessage = EggEvolutionService:StartEvolution()
	
	if success then
		-- Refresh local state
		self:RefreshEvolutionState()
	end
	
	return success, errorMessage
end

--[[
	Get the current evolution stage/progress.
	
	@return table? evolutionData - Contains:
		- Percentage (number): 0-1 progress
		- TimeLeft (number): Seconds remaining
		- TimeLeftFormatted (string): Formatted time string
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
function EggEvolutionController:GetEvolutionStage()
	if not EggEvolutionService then
		return nil
	end
	
	local data = EggEvolutionService:GetEvolutionStage()
	
	if data then
		-- Add formatted time for convenience
		data.TimeLeftFormatted = formatTime(data.TimeLeft or 0)
		currentEvolutionData = data
	else
		currentEvolutionData = nil
	end
	
	return data
end

--[[
	Accept the completed evolution and receive the resulting egg.
	
	@return boolean success, string? errorMessage
]]
function EggEvolutionController:AcceptEvolution()
	if not EggEvolutionService then
		return false, "Service not ready"
	end
	
	local success, errorMessage = EggEvolutionService:AcceptEvolution()
	
	if success then
		currentEvolutionData = nil
		-- Notify callbacks
		self:_notifyCallbacks(nil)
	end
	
	return success, errorMessage
end

--[[
	Cancel an in-progress evolution and get the original egg back.
	Cannot cancel a completed evolution.
	
	@return boolean success, string? errorMessage
]]
function EggEvolutionController:CancelEvolution()
	if not EggEvolutionService then
		return false, "Service not ready"
	end
	
	local success, errorMessage = EggEvolutionService:CancelEvolution()
	
	if success then
		currentEvolutionData = nil
		-- Notify callbacks
		self:_notifyCallbacks(nil)
	end
	
	return success, errorMessage
end

--[[
	Check if there is an active evolution (in progress or completed).
	Uses cached data to avoid server calls.
	
	@return boolean hasEvolution
]]
function EggEvolutionController:HasActiveEvolution()
	return currentEvolutionData ~= nil
end

--[[
	Check if evolution is complete and waiting to be accepted.
	Uses cached data to avoid server calls.
	
	@return boolean isComplete
]]
function EggEvolutionController:IsEvolutionComplete()
	return currentEvolutionData ~= nil and currentEvolutionData.IsComplete == true
end

--[[
	Check if evolution is still in progress.
	Uses cached data to avoid server calls.
	
	@return boolean isInProgress
]]
function EggEvolutionController:IsEvolutionInProgress()
	return currentEvolutionData ~= nil and currentEvolutionData.IsComplete == false
end

--[[
	Get the Skip DevProduct ID for the current evolution.
	Uses cached data to avoid server calls.
	
	@return number? productId
]]
function EggEvolutionController:GetSkipProductId()
	if currentEvolutionData then
		return currentEvolutionData.SkipProductId
	end
	return nil
end

--[[
	Get the Protection DevProduct ID for the current evolution.
	Uses cached data to avoid server calls.
	
	@return number? productId
]]
function EggEvolutionController:GetProtectionProductId()
	if currentEvolutionData then
		return currentEvolutionData.ProtectionProductId
	end
	return nil
end

--[[
	Get the cached evolution data without making a server call.
	Use this for frequent UI updates. Call RefreshEvolutionState() to update cache.
	
	@return table? evolutionData
]]
function EggEvolutionController:GetCachedEvolutionData()
	return currentEvolutionData
end

--[[
	Refresh evolution state from server.
	Call this after purchases or periodically to update UI.
]]
function EggEvolutionController:RefreshEvolutionState()
	local data = self:GetEvolutionStage()
	self:_notifyCallbacks(data)
	return data
end

--[[
	Register a callback to be notified when evolution state changes.
	
	@param callback function(evolutionData: table?) - Called with evolution data or nil
	@return function disconnect - Call to unregister the callback
]]
function EggEvolutionController:OnEvolutionUpdate(callback)
	table.insert(evolutionUpdateCallbacks, callback)
	
	-- Return disconnect function
	return function()
		for i, cb in ipairs(evolutionUpdateCallbacks) do
			if cb == callback then
				table.remove(evolutionUpdateCallbacks, i)
				break
			end
		end
	end
end

-- Internal: Notify all registered callbacks
function EggEvolutionController:_notifyCallbacks(data)
	for _, callback in ipairs(evolutionUpdateCallbacks) do
		task.spawn(function()
			callback(data)
		end)
	end
end

-- Internal: Poll for evolution updates
-- Only polls actively when evolution is in progress, otherwise checks less frequently
function EggEvolutionController:_startPolling()
	task.spawn(function()
		local idlePollCounter = 0
		local IDLE_POLL_INTERVAL = 5 -- Check every 5 seconds when no active evolution
		
		while true do
			local pollInterval = 1 -- Default: poll every second when evolution active
			
			-- If no active evolution, poll less frequently
			if currentEvolutionData == nil then
				idlePollCounter = idlePollCounter + 1
				if idlePollCounter < IDLE_POLL_INTERVAL then
					task.wait(1)
					continue
				end
				idlePollCounter = 0
			end
			
			local previousData = currentEvolutionData
			local data = self:GetEvolutionStage()
			
			-- Check if state changed
			local stateChanged = false
			if data == nil and previousData ~= nil then
				stateChanged = true
			elseif data ~= nil and previousData == nil then
				stateChanged = true
			elseif data and previousData then
				-- Check for completion transition
				if data.IsComplete ~= previousData.IsComplete then
					stateChanged = true
				end
			end
			
			if stateChanged then
				self:_notifyCallbacks(data)
			end
			
			task.wait(pollInterval)
		end
	end)
end

function EggEvolutionController:KnitStart()
	-- Get reference to server service
	EggEvolutionService = Knit.GetService("EggEvolutionService")
	
	-- Start polling for updates
	self:_startPolling()
	
	-- Initial state check
	self:RefreshEvolutionState()
end

function EggEvolutionController:KnitInit()
	-- Initialization...
end

return EggEvolutionController
