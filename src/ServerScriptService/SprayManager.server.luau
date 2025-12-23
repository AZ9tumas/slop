local remote = game.ReplicatedStorage.Remotes.SprayEvent
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local CustomTweenService = require(game.ReplicatedStorage.TweenV2.ReplicatedTweening)



local function getClosestEntity(player, radius, folder, nameKeyword)
	local character = player.Character
	if not character or not character.PrimaryPart then return end
	local closest, dist = nil, radius
	for _, entity in ipairs(folder:GetDescendants()) do
		if entity:IsA("Model") and string.find(entity.Name, nameKeyword) and entity.PrimaryPart then
			local d = (entity.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
			if d < dist then
				closest, dist = entity, d
			end
		end
	end
	return closest
end

remote.OnServerEvent:Connect(function(player, sprayType,name,id)
	local folder = Knit.GetService("PlotService"):GetPlayerPlot(player) -- folder containing eggs and pigeons
	warn("Spraying")
	Knit.GetService("InventoryService"):RemoveItem(player,name, "Tool", {ID = id})
	_G.AddAchiev(player,{"Spray"},1)
	if sprayType == "Luck" or sprayType == "Size" then
		local egg = getClosestEntity(player, 15, folder, "Egg")
		
		if not egg then 			
			game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Didnt spray anything")
			return end
		if sprayType == "Luck" then
			local current = egg:GetAttribute("LuckBoost") or 0
			if current < 3 then
				_G.AddAchiev(player,{"Spray"},1)
				game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Successfully applied Luck Spray of 10% to the "..egg.Name.." Total of "..((current + 1)*10).."%")
				egg:SetAttribute("LuckBoost", current + 1)
				Knit.GetService("EggService"):AddBoost(player,egg:GetAttribute("EggId"),{LuckBoost = egg:GetAttribute("LuckBoost")})

			else
				game.ReplicatedStorage.Remotes.Notification:FireClient(player,egg.Name.."Has already been sprayed 3 times")

			end
			remote:FireClient(player,"Luck", id)
			local quickHighlight = Instance.new("Highlight",egg)
			quickHighlight.FillColor = Color3.new(0, 1, 0)
			quickHighlight.FillTransparency = 0
			quickHighlight.OutlineTransparency = 1
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween = CustomTweenService:GetTweenObject(quickHighlight, tweenInfo, {FillTransparency = 1})
			tween:Play()
			
			game.Debris:AddItem(quickHighlight,1)
			
		elseif sprayType == "Size" then
			local current = egg:GetAttribute("SizeBoost") or 0
			if current < 3 then
				_G.AddAchiev(player,{"Spray"},1)
				game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Successfully applied Size Spray of 10% to the "..egg.Name.." Total of "..((current + 1)*10).."%")

				egg:SetAttribute("SizeBoost", current + 1)
				Knit.GetService("EggService"):AddBoost(player,egg:GetAttribute("EggId"),{SizeBoost = egg:GetAttribute("SizeBoost")})
			else
				game.ReplicatedStorage.Remotes.Notification:FireClient(player,egg.Name.."Has already been sprayed 3 times")

			end
			remote:FireClient(player,"Size", id)
			local quickHighlight = Instance.new("Highlight",egg)
			quickHighlight.FillColor = Color3.new(0, 0, 1)
			quickHighlight.FillTransparency = 0
			quickHighlight.OutlineTransparency = 1
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween = CustomTweenService:GetTweenObject(quickHighlight, tweenInfo, {FillTransparency = 1})
			tween:Play()
			game.Debris:AddItem(quickHighlight,1)
		end
	elseif sprayType == "Shock" or sprayType == "Volcano" or sprayType == "Gold" or sprayType == "Wealth" then
		local pigeon = getClosestEntity(player, 15, folder, "Pigeon")
		if not pigeon then 	game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Did not spray a pigeon")
			return end
		if sprayType == "Shock" then
			_G.AddAchiev(player,{"Spray"},1)
			local quickHighlight = Instance.new("Highlight",pigeon)
			quickHighlight.FillColor = Color3.new(0, 1, 1)
			quickHighlight.FillTransparency = 0
			quickHighlight.OutlineTransparency = 1
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween = CustomTweenService:GetTweenObject(quickHighlight, tweenInfo, {FillTransparency = 1})
			tween:Play()
			game.Debris:AddItem(quickHighlight,1)
			--game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Successfully applied Shock Spray to "..pigeon.Name)
			remote:FireClient(player,"Shock", id)
			Knit.GetService("PigeonService"):SetMutation(pigeon:GetAttribute("PigeonID"),"Shocked")
		elseif sprayType == "Volcano" then
			_G.AddAchiev(player,{"Spray"},1)
			local quickHighlight = Instance.new("Highlight",pigeon)
			quickHighlight.FillColor = Color3.new(1, 0.4, 0)
			quickHighlight.FillTransparency = 0
			quickHighlight.OutlineTransparency = 1
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween = CustomTweenService:GetTweenObject(quickHighlight, tweenInfo, {FillTransparency = 1})
			tween:Play()
			game.Debris:AddItem(quickHighlight,1)
			--game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Successfully applied Volcano Spray to "..pigeon.Name)
			remote:FireClient(player,"Volcanic", id)
            Knit.GetService("PigeonService"):SetMutation(pigeon:GetAttribute("PigeonID"),"Volcanic")
        elseif sprayType == "Gold" then
            _G.AddAchiev(player,{"Spray"},1)
            local quickHighlight = Instance.new("Highlight",pigeon)
            quickHighlight.FillColor = Color3.new(1, 0.933333, 0)
            quickHighlight.FillTransparency = 0
            quickHighlight.OutlineTransparency = 1
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local tween = CustomTweenService:GetTweenObject(quickHighlight, tweenInfo, {FillTransparency = 1})
            tween:Play()
            game.Debris:AddItem(quickHighlight,1)
            --game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Successfully applied Volcano Spray to "..pigeon.Name)
            remote:FireClient(player,"Gold", id)
            Knit.GetService("PigeonService"):SetMutation(pigeon:GetAttribute("PigeonID"),"Golden")
        elseif sprayType == "Wealth" then
            _G.AddAchiev(player,{"Spray"},1)
            local quickHighlight = Instance.new("Highlight",pigeon)
            quickHighlight.FillColor = Color3.new(1, 0.933333, 0)
            quickHighlight.FillTransparency = 0
            quickHighlight.OutlineTransparency = 1
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local tween = CustomTweenService:GetTweenObject(quickHighlight, tweenInfo, {FillTransparency = 1})
            tween:Play()
            game.Debris:AddItem(quickHighlight,1)
            --game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Successfully applied Volcano Spray to "..pigeon.Name)
            remote:FireClient(player,"Wealth", id)
            Knit.GetService("PigeonService"):SetMutation(pigeon:GetAttribute("PigeonID"),"Wealth")
        
		end
	end
end)




