local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local player = Players.LocalPlayer
local STEAL_PRODUCT_ID = 3405147399 -- replace

local function attachPrompt(pigeon)
	if pigeon:FindFirstChild("StealPrompt") then return end
	local primary = pigeon.PrimaryPart or pigeon:FindFirstChildWhichIsA("BasePart")
	if not primary then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "StealPrompt"
	prompt.ActionText = "Steal Pigeon"
	prompt.ObjectText = pigeon.Name
	prompt.HoldDuration = 2
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8
	prompt.Parent = primary
	prompt.Style = "Custom"
	prompt:SetAttribute("Theme", "DefaultRed")

	prompt.Triggered:Connect(function()
		local pigeonId = pigeon:GetAttribute("PigeonID")
		if pigeonId then
			-- remember which pigeon we want before purchase
			if pigeon:GetAttribute("Owner") == 8850353662 then _G.Notification("Dont try to steal from the owner..") return end
			if pigeonId == "a93d8cc2-20d5-4e20-93b1-1671aad284d9" then _G.Notification("This Pigeon cant be stolen. dont even try.") return end
		    game.ReplicatedStorage.Remotes:WaitForChild("StealRemote"):FireServer(pigeonId)
			task.wait(.5)
			MarketplaceService:PromptProductPurchase(player, STEAL_PRODUCT_ID)
		end
	end)
end

task.spawn(function()
	while true do
		
		for _, model in ipairs(workspace.Map:GetDescendants()) do
			if model:IsA("Model") and model:GetAttribute("PigeonID") then
				
				if model:GetAttribute("Owner") ~= player.UserId then
					
					attachPrompt(model)
				end
			end
		end
		task.wait(5)
	end
end)
