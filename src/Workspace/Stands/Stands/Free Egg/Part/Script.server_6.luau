local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DB = false

script.Parent.Touched:Connect(function(Part)
	if DB == true then return end
	DB = true
	task.delay(1, function()
		DB = false
	end)
	if Part and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
		local Player = game.Players:GetPlayerFromCharacter(Part.Parent)
		if Player then
			local profile = Knit.GetService("DataService"):GetProfile(Player)
			if profile.Data.GroupReward == false then
				if Player:IsInGroup(590837616) then
					profile.Data.GroupReward = true
					game.ReplicatedStorage.Remotes.Notification:FireClient(Player,"You got a Miner Egg!")
					local InventoryService = Knit.GetService("InventoryService")
					local space = InventoryService:AddItem(Player, "Miner Egg", "Egg", {
						ID = game:GetService("HttpService"):GenerateGUID(false),
					})
				else
					game.ReplicatedStorage.Remotes.Notification:FireClient(Player, "Like the game and join the group to claim the reward!")
				end
			else
				game.ReplicatedStorage.Remotes.Notification:FireClient(Player, "You have already claimed the reward.")
			end
		end
	end
end)