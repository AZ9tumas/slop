-- Egg Evolution Client Variables Initialization
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- UI References
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainUI = playerGui:WaitForChild("MainUI")
local evolveEggsFrame = mainUI:WaitForChild("EvolveEggs")

local currentEggFrame = evolveEggsFrame:WaitForChild("Current")
local successEggFrame = evolveEggsFrame:WaitForChild("Success")
local failEggFrame = evolveEggsFrame:WaitForChild("Fail")
local topBar = evolveEggsFrame:WaitForChild("Top")
local cancelButton = evolveEggsFrame:WaitForChild("Cancel")
local evolveButton = evolveEggsFrame:WaitForChild("Evolve")
local background = evolveEggsFrame:WaitForChild("Background")
local badFrame = evolveEggsFrame:WaitForChild("Bad")
local goodFrame = evolveEggsFrame:WaitForChild("Good")
local badPercentageLabel = evolveEggsFrame:WaitForChild("BadPercentage")
local goodPercentageLabel = evolveEggsFrame:WaitForChild("GoodPercentage")
local timeInfoLabel = evolveEggsFrame:WaitForChild("TimeInfo")
local dgLabel = evolveEggsFrame:WaitForChild("dg")
local upgLabel = evolveEggsFrame:WaitForChild("upg")

-- Knit Service
local EggEvolutionService = Knit.GetService("EggEvolutionService")

-- Other variables for state
local selectedEggUUID = nil
local evolutionStageData = nil

-- Ready for further logic and UI connections


-- init
local a = workspace.TemplateSlot.MainStand.CenterFoot
local players = game:GetService("Players")

a.Touched:Connect(function(hit)
	if hit and hit.Parent and hit.Parent:FindFirstChildWhichIsA("Humanoid") then
        local char = hit.Parent
        local hrp = char:FindFirstChildWhichIsA("HumanoidRootPart")
		local plr = players:GetPlayerFromCharacter(hit.Parent)

        if (hrp.Position - a.Position).Magnitude > 5 then
            plr.PlayerGui.MainUI.Frames.EvolveEggs.Visible = false
            return
        end
		plr.PlayerGui.MainUI.Frames.EvolveEggs.Visible = true
	end
end)