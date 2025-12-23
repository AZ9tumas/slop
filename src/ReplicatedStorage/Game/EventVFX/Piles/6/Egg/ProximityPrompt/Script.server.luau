local times = 0
local Knit = require(game.ReplicatedStorage.Packages.Knit)


script.Parent.Triggered:Connect(function(plr)
    if times == 19 then
        local InventoryService = Knit.GetService("InventoryService")
        local space = InventoryService:AddItem(plr, "Miner Egg", "Egg", {
            ID = game:GetService("HttpService"):GenerateGUID(false),
        })
        game.ReplicatedStorage.Remotes.Notification:FireAllClients(plr.Name .. " Digged the treasure and got a Miner Egg!")
        script.Parent.Parent.Parent:Destroy()
    else
        local s = script.Sound:Clone()
        s.PlaybackSpeed = math.random(0.85, 1.2)
        s.Parent = script.Parent.Parent.Handle
        s:Play()
        times += 1
        script.Parent.Parent:PivotTo(script.Parent.Parent.PrimaryPart.CFrame * CFrame.new(0, 0.2, 0))
    end
    
end)