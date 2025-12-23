local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local PlotService = Knit.CreateService {
	Name = "PlotService",
	Client = {}
}

local storedPlots = ServerStorage:WaitForChild("Plots")
local worldPlots = Workspace:WaitForChild("Map"):WaitForChild("Plots")

local freePlots = {}
local activePlots = {}

for _, plot in ipairs(worldPlots:GetChildren()) do
	table.insert(freePlots, plot.Name)
end

local function getSpawnLocation(folder)
	for _, d in ipairs(folder:GetDescendants()) do
		if d:IsA("SpawnLocation") then
			return d
		end
	end
	return nil
end

local function teleportToSpawn(player, character)
	local data = activePlots[player.UserId]
	if not data or not data.Plot then return end
	local spawnLocation = getSpawnLocation(data.Plot)
	if not spawnLocation then
		
		return
	end
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if hrp then
		player.RespawnLocation = spawnLocation
		character:PivotTo(spawnLocation.CFrame + Vector3.new(0, 3, 0))
	end
end

function PlotService.Client:TeleportSpawn(player)
	teleportToSpawn(player, player.Character)
end

local function assignPlot(player)
	if #freePlots == 0 then
		warn("No free plots available for " .. player.Name)
		return
	end

	local plotNumber = table.remove(freePlots, 1)
	local worldPlot = worldPlots:FindFirstChild(plotNumber)
	if not worldPlot then
		warn("World plot " .. plotNumber .. " missing")
		return
	end

	worldPlot:SetAttribute("Claimed", true)
	worldPlot:SetAttribute("OwnerUserId", player.UserId)

	activePlots[player.UserId] = {
		Number = plotNumber,
		Plot = worldPlot
	}

	if player.Character then
		teleportToSpawn(player, player.Character)
	end

	activePlots[player.UserId].CharConn = player.CharacterAdded:Connect(function(char)
		teleportToSpawn(player, char)
	end)

	worldPlot.Model.PlotInfo.Root.SurfaceGui.PlotName.Text = player.Name
	local ThumbnailType = Enum.ThumbnailType.HeadShot
	local ThumbnailSize = Enum.ThumbnailSize.Size100x100

	-- when setting up the plot:
	local userId = player.UserId
	local thumb, isReady = Players:GetUserThumbnailAsync(userId, ThumbnailType, ThumbnailSize)

	if isReady then
		local imageLabel = worldPlot.Model.PlotInfo.Root.SurfaceGui.Profile
		imageLabel.Image = thumb
	end

	warn("Assigned plot " .. plotNumber .. " to " .. player.Name)
	
	--local EggManager = Knit.GetService("EggService")
	--local HatchingService = Knit.GetService("HatchingService")
	--local DataService = Knit.GetService("DataService")
	---- -------- LOAD SAVED EGGS --------
	--local profile = DataService:GetProfile(player)
	--repeat task.wait() profile = DataService:GetProfile(player) until profile
	--if profile then
	--	warn("Get profile")
	--	EggManager:LoadEggs(player, profile)
		
	--else
	--	warn("Did not get profile")
	--end
end
function PlotService:GetPlayerPlot(player)
	local data = activePlots[player.UserId]
	return data and data.Plot or nil
end
local function releasePlot(player)
	local data = activePlots[player.UserId]
	if not data then
		warn("No active plot to release for " .. player.Name)
		return
	end

	if data.CharConn then
		data.CharConn:Disconnect()
	end

	local plotNumber = data.Number

	-- fully remove the player’s plot
	if data.Plot then
		data.Plot:Destroy()
	end

	-- instantly replace with a clean one
	local template = storedPlots:FindFirstChild(plotNumber)
	if template then
		local newPlot = template:Clone()
		newPlot.Name = plotNumber
		newPlot.Parent = worldPlots
		newPlot:SetAttribute("Claimed", false)
		newPlot:SetAttribute("OwnerUserId", nil)
		warn("Reset plot " .. plotNumber .. " back to default")
	else
		warn("Template plot " .. plotNumber .. " missing in ServerStorage")
	end

	table.insert(freePlots, plotNumber)
	activePlots[player.UserId] = nil
	warn("Released and replaced plot " .. plotNumber .. " for " .. player.Name)
end

function PlotService:KnitStart()
	Players.PlayerAdded:Connect(assignPlot)
	Players.PlayerRemoving:Connect(releasePlot)
	warn("PlotService started. Free plots: " .. #freePlots)
end

return PlotService
