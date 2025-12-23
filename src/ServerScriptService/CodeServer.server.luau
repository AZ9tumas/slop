local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local CodeInfo = require(ReplicatedStorage.Info.CodeInfo)
local RedeemServer = ReplicatedStorage.Remotes.RedeemCode


RedeemServer.OnServerEvent:Connect(function(Player, Code)
    if CodeInfo[Code] then
        local profile = Knit.GetService("DataService"):GetProfile(Player)
        if profile.Data.RedeemedCodes[Code] == true then
            ReplicatedStorage.Remotes.Notification:FireClient(Player, "You have already redeemed this code.", Color3.new(1, 0.0666667, 0.0666667))
        else
            if CodeInfo[Code].Type == "Beaks" then
                profile.Data.Beaks = (profile.Data.Beaks or 0) + CodeInfo[Code].Reward
                Player.leaderstats.Beaks.Value = profile.Data.Beaks
                ReplicatedStorage.Remotes.Notification:FireClient(Player, "You got " .. CodeInfo[Code].Reward .. " Beaks!", Color3.new(0, 1, 0))
            elseif CodeInfo[Code].Type == "Egg" then
                local InventoryService = Knit.GetService("InventoryService")
                local space = InventoryService:AddItem(Player, CodeInfo[Code].Reward, "Egg", {
                    ID = game:GetService("HttpService"):GenerateGUID(false),
                })
                ReplicatedStorage.Remotes.Notification:FireClient(Player, "You got a " .. CodeInfo[Code].Reward .. " Egg!", Color3.new(0, 1, 0))
            
            end
            profile.Data.RedeemedCodes[Code] = true
        end
        
    else
        ReplicatedStorage.Remotes.Notification:FireClient(Player, "Code doesnt exist.", Color3.new(1, 0.0666667, 0.0666667))
    end
end)