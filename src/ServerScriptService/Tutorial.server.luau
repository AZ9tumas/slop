_G.Tutorial = function(player,progress)
	if progress < 5 then
		game.ReplicatedStorage.Remotes.TutorialRemote:FireClient(player,progress)
	end
end
local Knit = require(game.ReplicatedStorage.Packages.Knit)
game.ReplicatedStorage.Remotes.TutorialRemote.OnServerEvent:Connect(function(player,progress)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if profile then
		profile.Data.Tutorial = progress
		_G.Tutorial(player,progress)
	end
end)