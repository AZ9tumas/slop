local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PigeonInfo = require(ReplicatedStorage.Info:WaitForChild("PigeonInfo"))
local EggInfo = require(ReplicatedStorage.Info:WaitForChild("EggInfo"))



task.spawn(function()
game.ReplicatedStorage.Remotes.FuseMachinePutIn.OnServerEvent:Connect(function(Player, PigeonID, PigeonName, Holder)
    if Player and PigeonID and Holder then
        
        local profile = Knit.GetService("DataService"):GetProfile(Player)
        profile.Data.FuseMachine[Holder] = PigeonName
        game.ReplicatedStorage.Remotes.FuseMachine:FireClient(Player, profile.Data.FuseMachine)
            local inventoryService = Knit.GetService("InventoryService")

            -- 1. Check if gifting player has a pigeon table
            local uniques = inventoryService:GetInventory(Player)
            if not uniques then
                warn("No pigeons in inventory")
                return false, "No pigeons in inventory"
            end
            local pigeonData
            for i, pigeon in ipairs(uniques.Pigeons) do
                if pigeon.ID == PigeonID then
                    pigeonData = pigeon
                    break
                end
            end
            task.spawn(function()
                for i, pigeon in ipairs(uniques.Pigeons) do
                    if pigeon.ID == pigeonData.ID then
                        inventoryService:RemoveItem(Player, pigeonData.Name, "Pigeon", {ID = pigeonData.ID})
                        if Player.Character:FindFirstChildWhichIsA("Tool") and Player.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId") and Player.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId") == PigeonID then
                            Player.Character:FindFirstChildWhichIsA("Tool"):Destroy()
                        elseif
                            Player.Backpack:FindFirstChildWhichIsA("Tool") and Player.Backpack:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId") and Player.Backpack:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId") == PigeonID then
                            Player.Backpack:FindFirstChildWhichIsA("Tool"):Destroy()

                        end
                        local DataService = Knit.GetService("DataService")
                        local profile = DataService:GetProfile(Player)
                        if profile then
                            inventoryService:SaveInventory(Player, profile)
                        end
                        break
                    end
                end
            end)
    end
end)
end)

game.ReplicatedStorage.Remotes.FuseMachineFusePrompt.OnServerEvent:Connect(function(Player)
    if not Player then return end
    local profile = Knit.GetService("DataService"):GetProfile(Player)

    if profile.Data.FuseMachine.First == nil or profile.Data.FuseMachine.Second == nil then
        game.ReplicatedStorage.Remotes.Notification:FireClient(Player, "You need 2 pigeons to fuse.", Color3.new(1, 0, 0))
    elseif profile.Data.Beaks < 15000 then
        game.ReplicatedStorage.Remotes.Notification:FireClient(Player, "You need 10,000 Beaks.", Color3.new(1, 0, 0))
    elseif profile.Data.FuseMachine.First ~= nil or profile.Data.FuseMachine.Second ~= nil and profile.Data.FuseMachine.Running == false and profile.Data.Beaks >= 15000 then
        profile.Data.Beaks = profile.Data.Beaks - 15000
        Player.leaderstats.Beaks.Value = profile.Data.Beaks
        profile.Data.FuseMachine.Running = true
        game.ReplicatedStorage.Remotes.Notification:FireClient(Player, "Fuse Started!", Color3.new(0.215686, 1, 0))
        local RandomValue = math.random(1, 2)
        if RandomValue == 1 then
            profile.Data.FuseMachine.FinishTime = game.ReplicatedStorage.CurrentTime.Value + 420
        else
            profile.Data.FuseMachine.FinishTime = game.ReplicatedStorage.CurrentTime.Value + 600
        end
      
    elseif profile.Data.FuseMachine.First ~= nil or profile.Data.FuseMachine.Second ~= nil and profile.Data.FuseMachine.Running == true and profile.Data.FuseMachine.FinishTime ~= nil then
        game.ReplicatedStorage.Remotes.Notification:FireClient(Player, "The pigeons are still fusing.", Color3.new(1, 0, 0))
    
    end
end)

game.Players.PlayerAdded:Connect(function(Player)
    repeat wait(2.5) until Player:FindFirstChild("leaderstats")
    local profile = Knit.GetService("DataService"):GetProfile(Player)
    --[[profile.Data.FuseMachine["First"] = nil
    profile.Data.FuseMachine["Second"] = nil
    profile.Data.FuseMachine["FinishTime"] = nil
    profile.Data.FuseMachine["Running"] = nil]]
    game.ReplicatedStorage.Remotes.FuseMachine:FireClient(Player, profile.Data.FuseMachine)
    while wait(1) do
        if not Player then break end
        if profile.Data.FuseMachine["Running"] == true then
            local TimeLeft = profile.Data.FuseMachine.FinishTime - game.ReplicatedStorage.CurrentTime.Value
            game.ReplicatedStorage.Remotes.FuseMachineUpdateNumber:FireClient(Player, TimeLeft)
        else
            game.ReplicatedStorage.Remotes.FuseMachineUpdateNumber:FireClient(Player, 0)
        end
        if Player and profile and profile.Data.FuseMachine["Running"] ~= nil and profile.Data.FuseMachine["FinishTime"] <= game.ReplicatedStorage.CurrentTime.Value then
            local Value = 0
            
            local FirstPigeonVal = PigeonInfo[profile.Data.FuseMachine["First"]].Multiplier * 3.5
            local SecondPigeonVal = PigeonInfo[profile.Data.FuseMachine["Second"]].Multiplier * 3.5
            
            Value = FirstPigeonVal * SecondPigeonVal
            
            local closestEgg
            local smallestDifference = math.huge

            for eggName, data in pairs(EggInfo) do
                if data.Cost then
                    local difference = math.abs(data.Cost - Value)
                    if difference < smallestDifference then
                        smallestDifference = difference
                        closestEgg = data
                    end
                end
            end

            if closestEgg then
                task.delay(1, function()
                    game.ReplicatedStorage.Remotes.Notification:FireClient(Player,"You got a " .. closestEgg.Rarity ..  " Egg from the fuse machine!", Color3.new(1, 1, 0))
                end)
                local InventoryService = Knit.GetService("InventoryService")
                local space = InventoryService:AddItem(Player, closestEgg.Rarity ..  " Egg", "Egg", {
                    ID = game:GetService("HttpService"):GenerateGUID(false),
                })
                print("Reward:", closestEgg.Rarity)
                print("Cost:", closestEgg.Cost)
            else
                warn("No eggs found!")
            end
            

            profile.Data.FuseMachine["First"] = nil
            profile.Data.FuseMachine["Second"] = nil
            profile.Data.FuseMachine["FinishTime"] = nil
            profile.Data.FuseMachine["Running"] = false
            game.ReplicatedStorage.Remotes.FuseMachine:FireClient(Player, profile.Data.FuseMachine)
            wait(.1)
            profile.Data.FuseMachine["Running"] = nil
        end
    end
end)