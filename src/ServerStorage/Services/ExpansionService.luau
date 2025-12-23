local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ExpansionService = Knit.CreateService{
    Name = "ExpansionService",
    Client = {}
}

local PlotService
local DataService
local ExpansionPrices = require(game:GetService("ReplicatedStorage").Info:WaitForChild("ExpansionPrices"))

local function hideExpansion(expansion)
    for _, obj in ipairs(expansion:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            game.TweenService:Create(obj, TweenInfo.new(0.5), {Transparency = 1, Size = obj.Size * 0.001}):Play()
            game.Debris:AddItem(obj,0.5)
        end
    end
end

function ExpansionService:KnitStart()
    PlotService = Knit.GetService("PlotService")
    DataService = Knit.GetService("DataService")
end

-- SERVER function
function ExpansionService:BuyExpansionServer(player, expansionNumber)

    local profile = DataService:GetProfile(player)
    if not profile then return false, "No profile found" end

    -- initialize if missing
    profile.Data.ExpansionsBoughtCount = profile.Data.ExpansionsBoughtCount or 0
    profile.Data.OwnedExpansions = profile.Data.OwnedExpansions or {}

    -- Check if already owns this expansion
    for _, owned in ipairs(profile.Data.OwnedExpansions) do
        if owned == tostring(expansionNumber) then
            warn("You already own this expansion")
        end
    end
    local Val = player:GetAttribute("TotalExpands") or 0
    local nextExpansion = Val + 1

    local price = ExpansionPrices[nextExpansion]
    if not price then
        warn( "No price for expansion #" .. tostring(nextExpansion))
    end
    warn("Price: "..price)
    if profile.Data.Beaks < price then
        player.PlayerGui.MainUI.Frames.Store.Visible = false
        player.PlayerGui.MainUI.Frames.Store.Visible = true
        game.ReplicatedStorage.Remotes.Notification:FireClient(player, "Not enough Beaks to expand", Color3.new(1, 0, 0))
        local errorC = game.ReplicatedStorage.EffectClients.Error:Clone()
        errorC.Parent = player.PlayerGui
        errorC.Enabled = true
        game.Debris:AddItem(errorC, 5)
        warn("you dont have enough beaks")
        return
    end
    -- Deduct and update

    profile.Data.Beaks -= price
    player.leaderstats.Beaks.Value = profile.Data.Beaks
    profile.Data.ExpansionsBoughtCount = nextExpansion
    table.insert(profile.Data.OwnedExpansions, expansionNumber)

    -- Hide the model
    local plot = PlotService:GetPlayerPlot(player)
    if plot and plot.Model and plot.Model:FindFirstChild("Expansions") then
        local expansion = plot.Model.Expansions:FindFirstChild(expansionNumber)
        warn("Hiding expansion name ",expansionNumber)
        if expansion then
            hideExpansion(expansion)
        end
    end

    return true, "Expansion #" .. tostring(expansionNumber) .. " purchased (slot " .. tostring(nextExpansion) .. ")"
end

-- CLIENT callable
function ExpansionService.Client:BuyExpansion(player, expansionNumber)
    return self.Server:BuyExpansionServer(player, expansionNumber)
end


function ExpansionService:GetNextExpansionPrice(player)
    local profile = DataService:GetProfile(player)
    if not profile then return nil end

    --profile.Data.ExpansionsBoughtCount = profile.Data.ExpansionsBoughtCount or 0
    local Val = player:GetAttribute("TotalExpands") or 0
    local nextExpansion = Val + 1

    return ExpansionPrices[nextExpansion] or nil
end

function ExpansionService.Client:GetNextExpansionPrice(player)
    return self.Server:GetNextExpansionPrice(player)
end

-- Called when player joins / plot is assigned
function ExpansionService:LoadExpansions(player, profile)
    if not profile then return end
    profile.Data.ExpansionsBoughtCount = profile.Data.ExpansionsBoughtCount or 0
    profile.Data.OwnedExpansions = profile.Data.OwnedExpansions or {}

    local plot = PlotService:GetPlayerPlot(player)
    if not plot or not plot.Model then return end

    -- Hide all expansions the player owns
    for _, expansionName in ipairs(profile.Data.OwnedExpansions) do
        local expansion = plot.Model.Expansions:FindFirstChild(expansionName)
        if expansion then
            hideExpansion(expansion)
        end
    end
end

return ExpansionService
