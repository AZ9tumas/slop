local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local DailyRewardsModule = require(game.ReplicatedStorage.Info.DailyRewards)

local suffixes = {"", "K", "M", "B", "T", "Q"}

local function formatNumber(num)
	local i = 1
	while num >= 1000 and i < #suffixes do
		num = num / 1000
		i = i + 1
	end
	return string.format("%.1f%s", num, suffixes[i]):gsub("%.0", "")
end

Knit.OnStart():andThen(function()
	local DailyRewardsService = Knit.GetService("DailyRewardsService")

	local function RefreshUI()
		local status 
		repeat wait()
			warn("WAITING FOR STATUS")
			DailyRewardsService:GetStatus():andThen(function(rewardS)
				status = rewardS
			end)
		until status
		if not status then return end

		for i = 1, 7 do
			local item = script.Parent.Holder["Day"..i]
			local rewardData = DailyRewardsModule[i]

			if rewardData and rewardData.Beaks then
				--item.Main.Title.Text = formatNumber(rewardData.Beaks) .. " Beaks"
			else
				--item.Main.Title.Text = "Reward"
			end

			if table.find(status.ClaimedDays, i) then
				script.Parent.Parent.Parent.LeftSide.Buttons.Daily.Claimable.Visible = false
				item.Claim.Title.Text = "Claimed"
			elseif i == status.Day and status.CanClaim then
				script.Parent.Parent.Parent.LeftSide.Buttons.Daily.Claimable.Visible = true
				item.Claim.Title.Text = "Claim"
				warn("CAN CLAIM")
                item.Claim.MouseButton1Click:Connect(function()
                    script.Parent.Parent.DailyRewards.Visible = false
					local reward
					DailyRewardsService:ClaimReward():andThen(function(rewardS)
						item.Claim.Title.Text = "Claimed"
						reward = rewardS
						script.Parent.Parent.Parent.LeftSide.Buttons.Daily.Claimable.Visible = false
					end)

					if reward then
						--script.Parent.Visible = false
						if reward.Beaks then
							print("You got:", reward.Beaks, "Beaks")
						end
						if reward.Eggs then
							for _, egg in ipairs(reward.Eggs) do
								print("You got an Egg:", egg)
							end
						end
						if reward.Pigeons then
							for _, pigeon in ipairs(reward.Pigeons) do
								print("You got a Pigeon:", pigeon)
							end
						end

						RefreshUI()
					end
				end)
			end
		end
	end

	RefreshUI()

	script.Parent.Top.Close.MouseButton1Click:Connect(function()
		script.Parent.Visible = false
	end)
end)
