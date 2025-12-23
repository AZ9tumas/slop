local Players = game:GetService("Players")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local GOAL_TIME = 1200

Players.PlayerAdded:Connect(function(player)
	local profile
	repeat
		profile = Knit.GetService("DataService"):GetProfile(player)
		if not profile or not profile.Data or not profile.Data.PlayTime then
			print("Not Found")
			task.wait(2)
		end
	until profile

	-- Load saved time once
	local playTime = profile.Data.PlayTime or 0

	-- Count time while player is in game
	while player.Parent and profile and profile.Data do
		task.wait(1)
		playTime += 1

		_G.SetAchiev(player, {"Time"}, playTime)
		profile.Data.PlayTime = playTime
	end
end)
