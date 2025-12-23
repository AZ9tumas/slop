local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local RewardsModule = require(game.ReplicatedStorage.Info.DailyRewards)

local DailyRewardsService = Knit.CreateService {
	Name = "DailyRewardsService",
	Client = {}
}

function DailyRewardsService:CanClaim(profile)
	local data = profile.Data.DailyReward
	local now = os.time()
	local elapsed = now - data.LastClaim

	if elapsed >= 24 * 60 * 60 then
		if elapsed >= 48 * 60 * 60 then
			data.Day = 1
			data.ClaimedDays = {}
		end
		return true, data.Day
	end
	return false, data.Day
end

local Icons = {
	["Pigeons"] = "rbxassetid://125126736270718",
	["Eggs"] = "rbxassetid://79192961641227",
	["Beaks"] = "rbxassetid://130900765268666",
}

function DailyRewardsService:ClaimReward(player)
	local DataService = Knit.GetService("DataService")
	local InventoryService = Knit.GetService("InventoryService")
	local profile = DataService:GetProfile(player)
	if not profile then return end

	local canClaim, day = self:CanClaim(profile)
	if not canClaim then return end

	local rewardData = RewardsModule[day]
	if not rewardData then return end
	warn(rewardData)
	if rewardData.Beaks and rewardData.Beaks > 1 then
		profile.Data.Beaks += rewardData.Beaks
		player.leaderstats.Beaks.Value = profile.Data.Beaks
		--game.ReplicatedStorage.Remotes.Notification:FireClient(player,("Awarded "..rewardData.Beaks.." From Daily Reward Day "..day))
        --game.ReplicatedStorage.Remotes.SuperNotification:FireClient(player,Icons.Beaks, "Reward Day "..day, "Awarded "..rewardData.Beaks.." Beaks")
        player.PlayerGui.MainUI.Frames.DailyRewards.Visible = false
        local Effect = script.BeakEffect:Clone()
        Effect.Parent = player.Character
        Effect.Enabled = true
        game.Debris:AddItem(Effect, 10)
	end

	if rewardData.Eggs then
		for _, eggType in ipairs(rewardData.Eggs) do
			InventoryService:AddItem(player, eggType.." Egg", "Egg")
		--	game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Awarded "..eggType.." Egg From Daily Reward Day "..day)
			game.ReplicatedStorage.Remotes.SuperNotification:FireClient(player,Icons.Eggs,  "Reward Day "..day, "Awarded "..eggType.." Egg")
            player.PlayerGui.MainUI.Frames.DailyRewards.Visible = false
		end
		
	end

	if rewardData.Pigeons then
		for _, pigeonType in ipairs(rewardData.Pigeons) do
			InventoryService:AddItem(player, pigeonType, "Pigeon")
			--game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Awarded "..pigeonType.." Egg From Daily Reward Day "..day)
			game.ReplicatedStorage.Remotes.SuperNotification:FireClient(player,Icons.Pigeons,  "Reward Day "..day, "Awarded "..pigeonType.." Pigeon")
            player.PlayerGui.MainUI.Frames.DailyRewards.Visible = false
		end
	end

	profile.Data.DailyReward.LastClaim = os.time()
	table.insert(profile.Data.DailyReward.ClaimedDays, day)

	profile.Data.DailyReward.Day = day + 1
	if profile.Data.DailyReward.Day > 7 then
		profile.Data.DailyReward.Day = 1
		profile.Data.DailyReward.ClaimedDays = {}
	end

	return rewardData, profile.Data.DailyReward.Day, profile.Data.DailyReward.ClaimedDays
end


-- remote for client claim
function DailyRewardsService.Client:ClaimReward(player)
	return self.Server:ClaimReward(player)
end

-- remote for client UI refresh
function DailyRewardsService.Client:GetStatus(player)
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	if not profile then return end

	local canClaim, day = self.Server:CanClaim(profile)
	return {
		Day = day,
		CanClaim = canClaim,
		ClaimedDays = profile.Data.DailyReward.ClaimedDays
	}
end

return DailyRewardsService
