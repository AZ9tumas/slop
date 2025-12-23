local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


game.ReplicatedStorage.Remotes.DeleteItem.OnServerEvent:Connect(function(plr, Tool)
	if plr.Character and Tool and Tool.Parent == plr.Character and Tool:IsA("Tool") then
		Tool:Destroy()
	end
end)

game.ReplicatedStorage.Remotes.RemovePigeonServer.OnServerEvent:Connect(function(Plr, Id, PigeonName)
    local PigeonService = Knit.GetService("PigeonService")
    PigeonService:RemovePlayerPigeon(Plr, Id, PigeonName)
end)