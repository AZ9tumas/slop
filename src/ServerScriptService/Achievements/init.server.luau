local Knit = require(game.ReplicatedStorage.Packages.Knit)


game.Players.PlayerAdded:Connect(function(player)
	repeat wait(1) until player and player:FindFirstChild("leaderstats") and player:GetAttribute("TotalExpands")
	local leaderstats = player:WaitForChild("leaderstats")

    local beaks = leaderstats:WaitForChild("Beaks")
    
    local profile = Knit.GetService("DataService"):GetProfile(player)
    
    if profile.Data.PlayTime > 500 then
        profile.Data.TellMachine = true
    end
    
    if player:GetAttribute("TotalExpands") >= 1 then
        profile.Data.TellExpand = true
    end
    
    if profile.Data.Beaks > 10000000000000 then
        player:Kick("Contact a dev please, Error: 1")
    end

    beaks.Changed:Connect(function(newValue)
        if profile.Data.Beaks > 10000000000000 then
            player:Kick("Contact a dev please, Error: 1")
        end
        _G.SetAchiev(player,{"Beaks"},beaks.Value)
        task.spawn(function()
            if beaks.Value > 1000 then
                print("Start")
                if profile.Data.TellExpand == false then
                    print("give")
                    profile.Data.TellExpand = true
                    local E = script.ExpandPlot:Clone()
                    E.Parent = player.Character
                    E.Enabled = true
                    game.Debris:AddItem(E, 1000)
                end
            end
        end)
        if beaks.Value > 15000 then
            if profile.Data.TellMachine == false then
                profile.Data.TellMachine = true
                local Cam = script.FuseMachine:Clone()
                Cam.Parent = player.Character
                Cam.Enabled = true
                game.Debris:AddItem(Cam, 20)
            end
        end
	end)
end)
