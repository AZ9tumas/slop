local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CustomTweenService = require(ReplicatedStorage.TweenV2.ReplicatedTweening)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local EggService = Knit.CreateService { Name = "EggService", Client = {} }

local eggFolder = ReplicatedStorage.Game:WaitForChild("Eggs")
local EggModule = require(ReplicatedStorage.Info:WaitForChild("EggInfo"))
local MutationsInfo = require(ReplicatedStorage.Info:WaitForChild("MutationsInfo"))

local PlotService
local DataService

local Eggs = {}
EggService.EggHatched = Instance.new("BindableEvent")


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggUpdate = Instance.new("RemoteEvent")
EggUpdate.Name = "EggUpdate"
EggUpdate.Parent = ReplicatedStorage.Remotes

local SyncedTime = require(ReplicatedStorage.Modules:WaitForChild("SyncedTime"))



local function sendFullUpdate(player)
    local eggsForClient = {}
    local userEggs = Eggs[player.UserId] or {}

    for _, egg in ipairs(userEggs) do
        table.insert(eggsForClient, {
            ID = egg.ID,
            Remaining = egg.Remaining,
            HatchTime = egg.HatchTime,
            Rarity = egg.Rarity,
            Mutation = egg.Mutation
        })
    end

    EggUpdate:FireClient(player, {
        Type = "EggUpdate",
        Eggs = eggsForClient
    })
end

local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function rollMutation()
    local rolledMutation
    for mutationName, chance in pairs(MutationsInfo.SpawnChances) do
        if math.random() < chance then
            rolledMutation = mutationName
            break
        end
    end
    return rolledMutation
end

local function createProximityPrompt(egg, player)
    if not egg.Model or not egg.Model.PrimaryPart then return end
    if egg.Model:GetAttribute("Hatched") then return end
    egg.Model:SetAttribute("Hatched", false)

    if egg.Model.PrimaryPart:FindFirstChild("HatchPrompt") then return end
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "HatchPrompt"
    prompt.ActionText = "Hatch Egg"
    prompt.ObjectText = egg.Rarity .. " Egg"
    prompt.HoldDuration = 1
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 12
    prompt.Parent = egg.Model.PrimaryPart
    prompt.Style = "Custom"
    prompt:SetAttribute("Theme", "DefaultGreen")

    prompt.Triggered:Connect(function(triggeringPlayer)
        if triggeringPlayer ~= player then return end
        if egg.Model:GetAttribute("Hatched") then return end
        prompt.Enabled = false
        egg.Model:SetAttribute("Hatched", true)


        local PigeonService = Knit.GetService("PigeonService")
        local pigeonData = {
            Position = egg.RelativeCFrame,
            Pivot = egg.Model:GetPivot(),
            Rarity = egg.Rarity,
            EggName = egg.Name,
            PreMutation = egg.Model:GetAttribute("Mutation") or egg.Mutation,
            LuckBoost = egg.Model:GetAttribute("LuckBoost"),
            SizeBoost = egg.Model:GetAttribute("SizeBoost"),
            ID = egg.ID
        }

        PigeonService:RewardPigeon(player, pigeonData)

        local eggs = Eggs[player.UserId]
        for i, e in ipairs(eggs) do
            if e.ID == egg.ID then
                table.remove(eggs, i)
                break
            end
        end
        if egg.Model then egg.Model:Destroy() end
    end)
end

local function updateEggGui(egg)

    if not egg.Model or not egg.Model:FindFirstChild("BillboardGui") then return end
    local gui = egg.Model.BillboardGui
    local bar = gui:FindFirstChild("ProgressBar")



    if egg.Mutation then
        if egg.Mutation == "Normal" then
            return
        end
        local mutationsImage = gui:FindFirstChild("MutationsLabel")
        if not mutationsImage then
            mutationsImage = ReplicatedStorage.Game.MutationsLabel:Clone()
            mutationsImage.Parent = gui
            local MutationVFX = game.ReplicatedStorage.Game.MutationParticles[egg.Mutation]:Clone()
            MutationVFX.Parent = egg.Model.PrimaryPart
            MutationVFX.Enabled = true
        end
        mutationsImage[egg.Mutation].Visible = true
        local MutationVFX = game.ReplicatedStorage.Game.MutationParticles[egg.Mutation]:Clone()
        MutationVFX.Parent = egg.Model.PrimaryPart
        MutationVFX.Enabled = true
    end
end

local function placeEgg(player, rarity, modelName, relativeCFrame, save, eggId, mutation, boosts)

    -- ✅ FIX #1: Generate eggId BEFORE duplicate checks
    eggId = eggId or HttpService:GenerateGUID(false)

    local plot = PlotService:GetPlayerPlot(player)
    if game:GetService("RunService") then
        warn("Placing Egg in the Server")
    end
    if not plot then return nil end

    local template = eggFolder:FindFirstChild(rarity) and eggFolder[rarity]:FindFirstChild(modelName)
    if not template then
        warn("No template")
        return nil
    end

    local eggsFolder = plot:FindFirstChild("Eggs") or Instance.new("Folder")
    eggsFolder.Name = "Eggs"
    eggsFolder.Parent = plot

    local profile = DataService:GetProfile(player)
    Eggs[player.UserId] = Eggs[player.UserId] or {}

    -------------------------------------------------------
    -- ✅ FIX #2: Do NOT remove eggs while LOADING (save ~= true)
    -------------------------------------------------------
    if save == true then
        local exists = false
        for i, existingEgg in ipairs(Eggs[player.UserId]) do
            if existingEgg.ID == eggId then
                exists = true

                -- Remove from saved profile
                if profile and profile.Data and profile.Data.PlacedEggs then
                    for j, savedEgg in ipairs(profile.Data.PlacedEggs) do
                        if savedEgg.ID == eggId then
                            table.remove(profile.Data.PlacedEggs, j)
                            break
                        end
                    end
                end

                -- Destroy existing model
                if existingEgg.Model and existingEgg.Model.Parent then
                    existingEgg.Model:Destroy()
                end

                -- Remove from memory
                table.remove(Eggs[player.UserId], i)
                break
            end
        end
    end
    -------------------------------------------------------

    local clone = template:Clone()
    clone.Parent = eggsFolder

    local plotRoot = plot.Model:FindFirstChild("Floor").Part
    local worldCFrame = plotRoot.CFrame:ToWorldSpace(relativeCFrame)

    if clone.PrimaryPart then
        clone:SetPrimaryPartCFrame(worldCFrame)
        clone:SetPrimaryPartCFrame(worldCFrame * CFrame.new(0, 4, 0))
        task.delay(0.2, function()
            local sound = script.Place:Clone()
            sound.Parent = clone.PrimaryPart or clone.Handle
            sound:Play()
            game.Debris:AddItem(sound, 5)
        end)
        for _, Part in clone:GetChildren() do
            if Part:IsA("BasePart") then
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = CustomTweenService:GetTweenObject(
                    Part,
                    tweenInfo,
                    {CFrame = Part.CFrame * CFrame.new(0, -4, 0)}
                )
                tween:Play()
            end
        end
    else
        clone:PivotTo(worldCFrame)
        clone:PivotTo(worldCFrame * CFrame.new(0, 4, 0))
        task.delay(0.2, function()
            local sound = script.Place:Clone()
            sound.Parent = clone.PrimaryPart or clone.Handle
            sound:Play()
            game.Debris:AddItem(sound, 5)
        end)
        for _, Part in clone:GetChildren() do
            if Part:IsA("BasePart") then
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = CustomTweenService:GetTweenObject(
                    Part,
                    tweenInfo,
                    {CFrame = Part.CFrame * CFrame.new(0, -4, 0)}
                )
                tween:Play()
            end
        end
    end

    pcall(function() clone.BillboardGui.Price.Text = player.Name .. "'s Egg" end)
    pcall(function() clone:SetAttribute("LuckBoost", boosts.LuckBoost) end)
    pcall(function() clone:SetAttribute("SizeBoost", boosts.SizeBoost) end)

    pcall(function()
        if clone:GetAttribute("LuckBoost") or clone:GetAttribute("SizeBoost") then
            local StatsE
            if clone.PrimaryPart:FindFirstChild("EggStats") then
                StatsE = clone.PrimaryPart:FindFirstChild("EggStats")
            else
                StatsE = game.ReplicatedStorage.Game.EggStats:Clone()
                StatsE.Parent = clone.PrimaryPart
                StatsE.Adornee = clone.PrimaryPart
            end
            if clone:GetAttribute("LuckBoost") then
                StatsE.Luck.Visible = true
                StatsE.Luck.Text = "Luck: " .. clone:GetAttribute("LuckBoost") .. "0%"
            end
            if clone:GetAttribute("SizeBoost") then
                StatsE.Sizee.Visible = true
                StatsE.Sizee.Text = "Size: " .. clone:GetAttribute("SizeBoost") .. "0%"
            end
        end
    end)

    local hatchTime = EggModule[rarity .. " Egg"].HatchTime
    local endTime = game.ReplicatedStorage.CurrentTime.Value + hatchTime

    Knit.GetService("InventoryService"):RemoveItem(player, rarity .. " Egg", "Egg", {ID = eggId})
    ReplicatedStorage.Remotes.RequestSkipEgg:FireClient(player, "Hatching", clone)

    if save == true then
        game.ReplicatedStorage.Remotes.EggSkipRemote:FireClient(player, clone, "Hatching", eggId)
    end

    clone:SetAttribute("EggId", eggId)

    -- ✅ Add to table
    table.insert(Eggs[player.UserId], {
        ID = eggId,
        Rarity = rarity,
        HatchTime = hatchTime,
        EndTime = endTime,
        Mutation = mutation,
        relativeCFrame = relativeCFrame,
        Model = clone
    })

    updateEggGui({
        ID = eggId,
        Rarity = rarity,
        HatchTime = hatchTime,
        EndTime = endTime,
        Mutation = mutation,
        relativeCFrame = relativeCFrame,
        Model = clone
    })

    if save then
        DataService:AddPlacedEgg(player, {
            ID = eggId,
            Rarity = rarity,
            Name = modelName,
            RelativeCFrame = {relativeCFrame:GetComponents()},
            EndTime = endTime,
            Mutation = mutation
        })
    end

    return clone
end



function EggService:KnitStart()
    PlotService = Knit.GetService("PlotService")
    DataService = Knit.GetService("DataService")

    DataService.PlayerProfileLoaded.Event:Connect(function(player)
        local profile
        repeat task.wait() profile = DataService:GetProfile(player) until profile
        if profile then
            self:LoadEggs(player, profile)
        end
    end)
end
function EggService:ReturnEggs(userId)
    return Eggs[userId]
end
function EggService.Client:ReturnEggs(userId)
    return EggService.Server:ReturnEggs(userId)
end
function EggService.Client:PlaceEgg(player, eggFullName, cframeData, mutation,id)
    local split = string.split(eggFullName, " ")
    if #split ~= 2 then return false end

    local rarity, modelName = split[1], split[2]
    local relativeCFrame = CFrame.new(unpack(cframeData))
    
    -- SECURITY FIX: Validate ID and ownership before placement
    local InventoryService = Knit.GetService("InventoryService")
    local inv = InventoryService:GetInventory(player)
    local eggId = id
    local found = false
    local realMutation = "Normal"
    
    if inv and inv.Eggs then
        if eggId then
            -- Verify specific ID exists
            for _, egg in ipairs(inv.Eggs) do
                if egg.ID == eggId and egg.Name == rarity .. " Egg" then
                    found = true
                    realMutation = egg.Mutation or "Normal"
                    break
                end
            end
        else
            -- If no ID provided, find ANY matching egg to use
            for _, egg in ipairs(inv.Eggs) do
                if egg.Name == rarity .. " Egg" then
                    eggId = egg.ID
                    found = true
                    realMutation = egg.Mutation or "Normal"
                    break
                end
            end
        end
    end
    
    if not found then
        warn("[Security] Player " .. player.Name .. " tried to place egg they don't own. ID: " .. tostring(eggId))
        return false
    end

    -- SECURITY FIX: Check if already placed (Anti-Dupe)
    if Eggs[player.UserId] then
        for _, placedEgg in ipairs(Eggs[player.UserId]) do
            if placedEgg.ID == eggId then
                warn("[Security] Player " .. player.Name .. " tried to place already placed egg ID: " .. tostring(eggId))
                return false
            end
        end
    end

    -- Use realMutation instead of client-provided mutation
    local egg = placeEgg(player, rarity, modelName, relativeCFrame, true, eggId, realMutation)
    EggUpdate:FireClient(player, {
        Type = "EggList",
        Eggs = Eggs[player.UserId],
    })
    return egg ~= nil
end

function EggService:AttachModel(player, eggId, model)
    local eggs = Eggs[player.UserId]
    if not eggs then return end
    for _, egg in ipairs(eggs) do
        if egg.ID == eggId then
            egg.Model = model
            return
        end
    end
end

function EggService:SaveEggs(player, profile)
    local eggs = Eggs[player.UserId] or {}
    profile.Data.PlacedEggs = {}

    local seenIDs = {} -- track egg IDs we've already saved

    for _, egg in ipairs(eggs) do
        if not seenIDs[egg.ID] then
            seenIDs[egg.ID] = true

            local remaining = math.max(egg.EndTime - game.ReplicatedStorage.CurrentTime.Value, 0)
            table.insert(profile.Data.PlacedEggs, {
                ID = egg.ID,
                Name = egg.Name,
                Rarity = egg.Rarity,
                RelativeCFrame = {egg.relativeCFrame:GetComponents()},
                EndTime = game.ReplicatedStorage.CurrentTime.Value + remaining,
                HatchTime = egg.HatchTime,
                LuckBoost = egg.LuckBoost,
                SizeBoost = egg.SizeBoost,
                Mutation = egg.Mutation,
            })
        else
            warn(("Duplicate egg ID '%s' found for %s — skipped saving duplicate."):format(tostring(egg.ID), player.Name))
        end
    end

    profile.Data.LastSave = game.ReplicatedStorage.CurrentTime.Value
end


function EggService:AddBoost(player,eggId,boost)
    local eggs = Eggs[player.UserId] or {}
    warn("Adding Boost to "..eggId)
    for _, egg in ipairs(eggs) do
        if egg.ID == eggId then
            warn("Found Egg Boost")
            if egg.Model:GetAttribute("LuckBoost") or egg.Model:GetAttribute("SizeBoost") then
                local StatsE
                if egg.Model.PrimaryPart:FindFirstChild("EggStats") then
                    StatsE = egg.Model.PrimaryPart:FindFirstChild("EggStats")
                else
                    StatsE = game.ReplicatedStorage.Game.EggStats:Clone()
                    StatsE.Parent = egg.Model.PrimaryPart
                    StatsE.Adornee = egg.Model.PrimaryPart
                end
                if egg.Model:GetAttribute("LuckBoost") then
                    StatsE.Luck.Visible = true
                    StatsE.Luck.Text = "Luck: " .. egg.Model:GetAttribute("LuckBoost") .. "0%"

                end
                if egg.Model:GetAttribute("SizeBoost") then
                    StatsE.Sizee.Visible = true
                    StatsE.Sizee.Text = "Size: " .. egg.Model:GetAttribute("SizeBoost") .. "0%"

                end
            end
            if not egg.LuckBoost then
                egg.LuckBoost = boost.LuckBoost
            end
            if not egg.SizeBoost then
                egg.SizeBoost = boost.SizeBoost
            end
            return
        end
    end
end


function EggService:LoadEggs(player, profile)

    Eggs[player.UserId] = {}
    local now = game.ReplicatedStorage.CurrentTime.Value

    for _, eggData in ipairs(profile.Data.PlacedEggs or {}) do
        pcall(function()
            local remaining = math.max((eggData.EndTime or (now + eggData.HatchTime)) - now, 0)
            local relativeCFrame = CFrame.new(unpack(eggData.RelativeCFrame))
            warn("Loaded egg data", eggData)

            local clone = placeEgg(player, eggData.Rarity, "Egg", relativeCFrame, false, eggData.ID, eggData.Mutation, {
                LuckBoost = eggData.LuckBoost,
                SizeBoost = eggData.SizeBoost
            })

            if clone then
                warn("Added egg")
                for _, egg in ipairs(Eggs[player.UserId]) do
                    if egg.ID == eggData.ID then
                        egg.EndTime = now + remaining
                        if remaining > 5 then
                            game.ReplicatedStorage.Remotes.EggSkipRemote:FireClient(player, clone, "Hatching", eggData.ID)
                        end
                        --break
                    end
                end
            end

        end)
    end

    repeat task.wait() until player.Character
    warn("FIRING CLIENT")
    EggUpdate:FireClient(player, {
        Type = "EggList",
        Eggs = Eggs[player.UserId],
    })
    warn("FIRING CLIENT WITH THIS LIST", Eggs[player.UserId])
end

EggUpdate.OnServerEvent:Connect(function(player,id)
    local eggs = Eggs[player.UserId]
    for i, e in ipairs(eggs) do
        if e.ID == id then
            table.remove(eggs, i)
            break
        end
    end
end)

return EggService
