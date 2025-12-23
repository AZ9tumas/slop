local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WealthInfo = require(ReplicatedStorage.Info.WealthInfo)
local PigeonInfo = require(ReplicatedStorage.Info.PigeonInfo)
local MutationInfo = require(ReplicatedStorage.Info.MutationsInfo)

local PendingTrades = {}

local function GetBeaksPerSecond(pigeonWeight, pigeonInfo)
    if not pigeonInfo or not pigeonInfo.Weight then
        return 1
    end
    local weight = math.clamp(pigeonWeight, pigeonInfo.Weight.Min, pigeonInfo.Weight.Max)
    local weightRange = pigeonInfo.Weight.Max - pigeonInfo.Weight.Min
    local normalisedWeight = (weight - pigeonInfo.Weight.Min) / (weightRange > 0 and weightRange or 1)
    local beaksPerSecond = 0.79 * (pigeonInfo.Multiplier or 1) * (1 + normalisedWeight * 1.1)
    return beaksPerSecond
end

local function computeMutationMultiplier(mutations)
    if not mutations then return 1 end
    local mult = 1
    for _, m in ipairs(mutations) do
        if m and m ~= "Normal" and MutationInfo and MutationInfo.Multipliers and MutationInfo.Multipliers[m] then
            mult = mult * MutationInfo.Multipliers[m]
        end
    end
    return mult
end

game.Players.PlayerRemoving:Connect(function(Player)
    PendingTrades[Player] = nil
end)

game.ReplicatedStorage.Remotes.WealthReward.OnServerEvent:Connect(function(Player, ItemName, Type, Amount)
    if not Player then return end
    local profile = Knit.GetService("DataService"):GetProfile(Player)
    
    if Type == "InitiateTrade" then
        local PigeonID = ItemName
        local InventoryService = Knit.GetService("InventoryService")
        
        -- 1. Verify Ownership
        local inv = InventoryService:GetInventory(Player)
        local pigeonData = nil
        if inv and inv.Pigeons then
            for _, p in ipairs(inv.Pigeons) do
                if p.ID == PigeonID then
                    pigeonData = p
                    break
                end
            end
        end
        
        if not pigeonData then
            warn("Player tried to trade pigeon they don't own")
            return
        end
        
        -- 2. Calculate Value
        local info = PigeonInfo[pigeonData.Name]
        if not info then return end
        
        local mutations = pigeonData.Mutation
        if type(mutations) ~= "table" then mutations = {mutations} end
        
        local val = GetBeaksPerSecond(pigeonData.Weight, info) * 20 * computeMutationMultiplier(mutations)
        local AmountF = math.floor(val)
        
        if AmountF <= 3000 then return warn("noob player") end
        
        -- 3. Find Reward Tier
        local closestEgg
        local smallestDifference = math.huge
        for eggName, data in pairs(WealthInfo) do
            if data.Cost then
                local difference = math.abs(data.Cost - AmountF)
                if difference < smallestDifference then
                    smallestDifference = difference
                    closestEgg = data
                end
            end
        end
        
        if not closestEgg then return end
        
        -- 4. Remove Pigeon (BEFORE Options)
        InventoryService:RemoveItem(Player, pigeonData.Name, "Pigeon", {ID = PigeonID})
        
        local char = Player.Character
        if char then
            local tool = char:FindFirstChildWhichIsA("Tool")
            if tool and tool:GetAttribute("PigeonId") == PigeonID then
                tool:Destroy()
            end
        end
        
        -- 5. Store Pending Trade and Notify Client
        PendingTrades[Player] = closestEgg
        game.ReplicatedStorage.Remotes.WealthReward:FireClient(Player, "ShowOptions", closestEgg)

    elseif Type == "TradePigeon" then
        -- Amount is RewardIndex (1, 2, 3)
        local RewardIndex = Amount
        local closestEgg = PendingTrades[Player]
        
        if not closestEgg then return end
        
        -- Select Reward
        local rewardItem
        if RewardIndex == 1 then rewardItem = closestEgg.Reward1
        elseif RewardIndex == 2 then rewardItem = closestEgg.Reward2
        elseif RewardIndex == 3 then rewardItem = closestEgg.Reward3
        end
        
        if not rewardItem then return end
        
        -- Clear Pending
        PendingTrades[Player] = nil
        
        -- Give Reward
        local InventoryService = Knit.GetService("InventoryService")
        if rewardItem.Type == "Beaks" then
            profile.Data.Beaks = (profile.Data.Beaks or 0) + rewardItem.Amount
            Player.leaderstats.Beaks.Value = profile.Data.Beaks
            game.ReplicatedStorage.Remotes.Notification:FireClient(Player, "You Claimed " .. rewardItem.Amount .. " Beaks!")
            
            local Effect = script.BeakEffect:Clone()
            Effect.Parent = Player.Character
            Effect.Enabled = true
            game.Debris:AddItem(Effect, 10)

        elseif rewardItem.Type == "Tool" or rewardItem.Type == "Egg" then
            for i = 1, rewardItem.Amount do
                InventoryService:AddItem(Player, rewardItem.Item, rewardItem.Type, {
                    ID = game:GetService("HttpService"):GenerateGUID(false),
                })
            end
            game.ReplicatedStorage.Remotes.Notification:FireClient(Player, "You Got " .. rewardItem.Amount .. " " .. rewardItem.Item .. "!")
        end
    else
        warn("Invalid type sent.")
    end
end)