local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ProfileService = require(game.ServerScriptService.ProfileService)
local RunService = game:GetService("RunService")



local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {}
}

local ProfileStore = ProfileService.GetProfileStore(
    "Player_DataStore_V1",--DataStoreName
    {
        NewPlayer = true,
        Beaks = 0,
        EggsBought = 0,
        PlacedEggs = {},
        LastSave = os.time(),
        ExpansionsBoughtCount = 0,
        OwnedExpansions = {},
        Inventory = {
            Eggs = {},
            Pigeons = {},
            Tools = {
                [0] = {Name = "Shovel",Fav = false, ID = 0 }
            }
        },
        UniquePigeons = {},
        UniqueEggs = {},
        UnlockedItems = {},
        RedeemedCodes = {},
        DailyReward = {
            Day = 1,
            LastClaim = 0,
            ClaimedDays = {}
        },
        BoughtOPEgg = false,
        ClaimedChest = false,
        Tutorial = 1,
        TellMachine = false,
        TellExpand = false,
        PlayTime = 0,
        CurrentTask = nil,
        MusicSetting = true,
        GroupReward = false,
        Gamepasses = {},
        ClaimedQuests = {},
        Achievments = {},
        FuseMachine = {
            First = nil,
            Second = nil,
            Running = nil,
            FinishTime = nil
        },
        ActiveEvolution = nil,
    }
)

local Profiles = {}
local STARTING_BEAKS = 100

DataService.PlayerProfileLoaded = Instance.new("BindableEvent")
DataService.PlayerProfileReleased = Instance.new("BindableEvent")

local function setupLeaderstats(player, profile)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local beaks = Instance.new("IntValue")
    beaks.Name = "Beaks"
    beaks.Parent = leaderstats
    beaks.Value = profile.Data.Beaks
    beaks:GetPropertyChangedSignal("Value"):Connect(function()
        profile.Data.Beaks = beaks.Value
    end)
end

function DataService:GetProfile(player)
    return Profiles[player.UserId]
end

function DataService:AddPlacedEgg(player, eggData)
    local profile = Profiles[player.UserId]
    if profile then
        profile.Data.PlacedEggs = profile.Data.PlacedEggs or {}
        table.insert(profile.Data.PlacedEggs, eggData)
    end
end

local function tryLoadProfile(userId)
    local key = "Player_" .. userId
    local maxRetries = 5
    local attempt = 0
    local profile

    while attempt < maxRetries and not profile do
        attempt += 1
        profile = ProfileStore:LoadProfileAsync(key, "ForceLoad")
        if not profile then
            task.wait(1)
        end
    end

    return profile
end

--function DataService:KnitStart()
    Players.PlayerAdded:Connect(function(player)
        if Profiles[player.UserId] then
            Profiles[player.UserId]:Release()
            Profiles[player.UserId] = nil
        end

        local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
        if profile ~= nil then
            profile:AddUserId(player.UserId)
            profile:Reconcile()
            profile:ListenToRelease(function()
                DataService.PlayerProfileReleased:Fire(player)
                Profiles[player.UserId] = nil
                if player:IsDescendantOf(Players) then
                    player:Kick("Your data was released!")
                end
            end)

            if player:IsDescendantOf(Players) then
                Profiles[player.UserId] = profile
                if profile.Data.NewPlayer == true then
                    profile.Data.Beaks = STARTING_BEAKS
                    profile.Data.NewPlayer = false
                end

                profile.Data.PlacedEggs = profile.Data.PlacedEggs or {}
                setupLeaderstats(player, profile)
                DataService.PlayerProfileLoaded:Fire(player)
                _G.Tutorial(player,profile.Data.Tutorial)
                local PigeonService = Knit.GetService("PigeonService")
                local ExpansionService = Knit.GetService("ExpansionService")
                local InventoryService = Knit.GetService("InventoryService")
                InventoryService:InitPlayerInventory(player, profile)
                PigeonService:LoadPigeons(player, profile)
                ExpansionService:LoadExpansions(player, profile)
            else
                profile:Release()
                Profiles[player.UserId] = nil
            end
        else
            player:Kick("We couldn’t load your data. Please rejoin!")
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        local profile = Profiles[player.UserId]
        if profile then
            profile:Release()
            profile.Data.LastSave = os.time()
            local EggService = Knit.GetService("EggService")
            local PigeonService = Knit.GetService("PigeonService")
            local InventoryService = Knit.GetService("InventoryService")
            EggService:SaveEggs(player, profile)
            PigeonService:SavePigeons(player, profile)
            InventoryService:SaveInventory(player, profile)
            DataService.PlayerProfileReleased:Fire(player)
            --profile:Release()
        end
    end)
--end

return DataService
