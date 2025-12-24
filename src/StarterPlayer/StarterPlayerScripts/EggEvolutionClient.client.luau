local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Player references
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ui references
local mainUI = playerGui:WaitForChild("MainUI")
local mainFrame = mainUI:WaitForChild("Frames")
local evolveEggsFrame = mainFrame:WaitForChild("EvolveEggs")
local currentEggFrame = evolveEggsFrame:WaitForChild("Current")
local successEggFrame = evolveEggsFrame:WaitForChild("Success")
local failEggFrame = evolveEggsFrame:WaitForChild("Fail")
local topBar = evolveEggsFrame:WaitForChild("Top")
local closeButton = topBar:WaitForChild("Close")
local cancelButton = evolveEggsFrame:WaitForChild("Cancel")
local evolveButton = evolveEggsFrame:WaitForChild("Evolve")
local background = evolveEggsFrame:WaitForChild("Background")
local badPercentageLabel = evolveEggsFrame:WaitForChild("BadPercentage")
local goodPercentageLabel = evolveEggsFrame:WaitForChild("GoodPercentage")
local timeInfoLabel = evolveEggsFrame:WaitForChild("TimeInfo")

-- fail evolve
local failEvolveFrame: Frame = mainFrame:WaitForChild("FailEvolve")
local failEvolveCancel: TextButton = failEvolveFrame:WaitForChild("Cancel")
local failEvolveAccept: TextButton = failEvolveFrame:WaitForChild("Evolve")
local info1: TextLabel = failEvolveFrame:WaitForChild("Info1")
local info2: TextLabel = failEvolveFrame:WaitForChild("Info2")

-- Service reference
local EggEvolutionService = nil

-- Local state
local cachedEvolutionData = nil

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

local function startEvolution()
	if not EggEvolutionService then
		return false, "Service not ready"
	end
	local success, result, message = EggEvolutionService:StartEvolution():await()
	if not success then
		return false, "Network Error"
	end
	return result, message
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

local function getEvolutionDetails()
	if not EggEvolutionService then
		return nil
	end
	local success, result = EggEvolutionService:GetEvolutionDetails():await()
	if not success then
		warn("Failed to fetch evolution details:", result)
		return nil
	end
	return result
end

local function getEvolutionStage()
	if not EggEvolutionService then
		return nil
	end

	local success, data = EggEvolutionService:GetEvolutionStage():await()
	if not success then
		return nil
	end

	if data then
		data.TimeLeftFormatted = formatTime(data.TimeLeft or 0)
		cachedEvolutionData = data
	else
		cachedEvolutionData = nil
	end

	return data
end

local function acceptEvolution()
	if not EggEvolutionService then
		return false, "Service not ready"
	end

	local success, result, errorMessage = EggEvolutionService:AcceptEvolution():await()
	if not success then
		return false, "Network Error"
	end

	if result then
		cachedEvolutionData = nil
	end

	return result, errorMessage
end

local function cancelEvolution()
	if not EggEvolutionService then
		return false, "Service not ready"
	end

	local success, result, errorMessage = EggEvolutionService:CancelEvolution():await()
	if not success then
		return false, "Network Error"
	end

	if result then
		cachedEvolutionData = nil
	end

	return result, errorMessage
end

local function hasActiveEvolution()
	local data = getEvolutionStage()
	return data ~= nil
end

local function isEvolutionComplete()
	local data = getEvolutionStage()
	return data ~= nil and data.IsComplete == true
end

local function isEvolutionInProgress()
	local data = getEvolutionStage()
	return data ~= nil and data.IsComplete == false
end

local function getCachedData()
	return cachedEvolutionData
end

local function getSkipProductId()
	local data = getCachedData() or getEvolutionStage()
	if data then
		return data.SkipProductId
	end
	return nil
end

local function getProtectionProductId()
	local data = getCachedData() or getEvolutionStage()
	print("data for protection id:", data)
	if data then
		return data.ProtectionProductId
	end
	return nil
end

local function promptSkipPurchase()
	local productId = getSkipProductId()
	if productId then
		MarketplaceService:PromptProductPurchase(player, productId)
	end
end

local function promptProtectionPurchase()
	local productId = getProtectionProductId()
	if productId then
		MarketplaceService:PromptProductPurchase(player, productId)
	else
		print("Free protection processing...")
		local success, result = EggEvolutionService:ProcessProtection():await()
		print(success, result)
	end
end

_G.EggEvolution = {
	-- Core functions
	StartEvolution = startEvolution,
	GetEvolutionStage = getEvolutionStage,
	GetEvolutionDetails = getEvolutionDetails,
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

Knit.OnStart():andThen(function()
	EggEvolutionService = Knit.GetService("EggEvolutionService")

	local existingEvolution = getEvolutionStage()
	if existingEvolution then
		print("[EggEvolutionClient] Found existing evolution:", existingEvolution.SourceEggName)
	end
end):catch(function(err)
	warn("[EggEvolutionClient] Failed to initialize:", err)
end)

local worldPlots = workspace:WaitForChild("Map"):WaitForChild("Plots")

local function getMyPlot()
	for _, plot in ipairs(worldPlots:GetChildren()) do
		if plot:GetAttribute("OwnerUserId") == player.UserId then
			return plot
		end
	end
	return nil
end

local myPlot = getMyPlot()
if not myPlot then
	repeat task.wait(0.5) myPlot = getMyPlot() until myPlot
end

local evolutionArea = myPlot:WaitForChild("EvolutionArea")
local prompt: ProximityPrompt = evolutionArea:WaitForChild("Display"):WaitForChild("ActionPart"):WaitForChild("ProximityPrompt")

local function makeVisible()
	local details = getEvolutionDetails()
	if not details then
		warn("[EggEvolutionClient] No evolution details found for equipped egg.")
		return
	end

	evolveEggsFrame.Visible = true
	timeInfoLabel.Text = "Evolution Time: " .. formatTime(details.Time)
	goodPercentageLabel.Text = "Success Chance: " .. tostring(math.floor(details.SuccessChance * 100)) .. "%"
	badPercentageLabel.Text = "Fail Chance: " .. tostring(math.floor((1 - details.SuccessChance) * 100)) .. "%"
	successEggFrame.Title.Text = details.NextEgg
	failEggFrame.Title.Text = details.FailEgg
	currentEggFrame.Title.Text = details.CurrentEgg
	evolveButton.Title.Text = "$" .. tostring(details.Cost)
end

closeButton.MouseButton1Click:Connect(function()
	evolveEggsFrame.Visible = false
end)

cancelButton.MouseButton1Click:Connect(function()
	evolveEggsFrame.Visible = false
end)

evolveButton.MouseButton1Click:Connect(function()
	local result, message = startEvolution()
	if not result then
		warn("[EggEvolutionClient] Failed to start evolution:", message)
		_G.Notification(message)
		return
	end
	evolveEggsFrame.Visible = false
end)

failEvolveCancel.MouseButton1Click:Connect(function()
	failEvolveFrame.Visible = false
	local success, msg = acceptEvolution()
	if success then
		_G.Notification("Accepted the devolved egg.")
	else
		_G.Notification(msg or "Failed to accept evolution.")
	end
end)

failEvolveAccept.MouseButton1Click:Connect(function()
	failEvolveFrame.Visible = false
	promptProtectionPurchase()
end)

prompt.Triggered:Connect(function(plr)
	if plr ~= player then return end

	local char = plr.Character
	if not char then return end

	local stage = getEvolutionStage()
	if not stage then
		if char:FindFirstChildWhichIsA("Tool") then
			if not evolveEggsFrame.Visible then
				makeVisible()
			end
		else
			evolveEggsFrame.Visible = false
			_G.Notification("Equip an egg to continue.")
		end
		return
	end

	--[[
		["CanDevolve"] = false,
		["FailEggName"] = "Beach Egg",
		["IsComplete"] = true,
		["IsSuccess"] = true,
		["Percentage"] = 1,
		["ProtectionProductId"] = 200501,
		["ResultPreview"] = "Kingdom Egg",
		["SkipProductId"] = 200502,
		["SourceEggName"] = "Miner Egg",
		["TargetEggName"] = "Kingdom Egg",
		["TimeLeft"] = 0,
		["TimeLeftFormatted"] = "00:00"
	]]

	print("STAGE: ", stage)
	if stage.IsComplete == true then
		-- tap to reveal
		if stage.IsSuccess then
			_G.Notification("Successfully collected " .. stage.ResultPreview .. "!")
			acceptEvolution()
		else
			_G.Notification("Evolution failed. Your egg has devolved into " .. stage.FailEggName .. ".")
			info1.Text = "You downgraded your " .. stage.SourceEggName .. " to a " .. stage.FailEggName .. "!:("
			info2.Text = "Would you like to keep your " .. stage.SourceEggName .. "?"
			failEvolveFrame.Visible = true
		end
	else
		_G.Notification("Your egg is still evolving. Please wait until it is complete.")
		-- Skip...
		promptSkipPurchase()

		return
	end
end)