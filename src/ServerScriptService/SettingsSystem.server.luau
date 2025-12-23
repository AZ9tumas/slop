local Knit = require(game.ReplicatedStorage.Packages.Knit)

game.Players.PlayerAdded:Connect(function(player)
	task.wait(5)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	repeat wait() until profile and player.Character
	game.ReplicatedStorage.Remotes.UpdateSettings:FireClient(player, profile.Data.MusicSetting)
end)

game.ReplicatedStorage.Remotes.ToggleSetting.OnServerEvent:Connect(function(player,Setting)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if profile then
		if profile.Data[Setting] == false then
			profile.Data[Setting] = true
			game.ReplicatedStorage.Remotes.UpdateSettings:FireClient(player, profile.Data.MusicSetting)
		else
			profile.Data[Setting] = false
			game.ReplicatedStorage.Remotes.UpdateSettings:FireClient(player, profile.Data.MusicSetting)
		end
	end
end)