local Knit = require(game.ReplicatedStorage.Packages.Knit)

local function pickReward()
    local chances = {
        { Name = "Candy", Chance = 40 },
        { Name = "Volcano", Chance = 30 },
        { Name = "Winter", Chance = 20 },
        { Name = "Zombie", Chance = 10}
    }

    local randomNumber = math.random(1, 100)
    local cumulative = 0

    for _, item in ipairs(chances) do
        cumulative += item.Chance
        if randomNumber <= cumulative then
            return item.Name
        end
    end
end


game.Players.PlayerAdded:Connect(function(Player)
	repeat wait(2.5) until Player:FindFirstChild("leaderstats")
	local profile = Knit.GetService("DataService"):GetProfile(Player)
	if profile.Data.ClaimedChest == true then
		Player:SetAttribute("ClaimedChest", true)
    end
    
	Player:SetAttribute("PlayTime", profile.Data.PlayTime or 0)
	Player:SetAttribute("TotalExpands", #profile.Data.OwnedExpansions or 0)
   -- Player:SetAttribute("TotalEggsBought", profile.Data.EggsBought or 0)
    print(profile.Data)
	while wait(1) do
		if not Player then break end
		pcall(function()
			Player:SetAttribute("PlayTime", profile.Data.PlayTime or 0)
			Player:SetAttribute("TotalExpands", #profile.Data.OwnedExpansions or 0)
            --Player:SetAttribute("TotalEggsBought", profile.Data.EggsBought or 0)
        end)
        if Player:GetAttribute("BasePerSecond") and Player:GetAttribute("BasePerSecond") > 210000000 then
            Player:Kick("Contact a dev please, Error: 1")
        end
        if Player:GetAttribute("BasePerSecond") and Player:GetAttribute("BasePerSecond") > 1500000 and profile.Data.PlayTime < 1800 then
            Player:Kick("Contact a dev please, Error: 1")
        end 
	end
end)

game.ReplicatedStorage.Remotes.GiveChestReward.OnServerEvent:Connect(function(Player, Reward)
	if not Player or not Reward then return end
	local profile = Knit.GetService("DataService"):GetProfile(Player)
	profile.Data.ClaimedChest = true
	Player:SetAttribute("ClaimedChest", true)
	local InventoryService = Knit.GetService("InventoryService")
	local space = InventoryService:AddItem(Player, Reward .. " Egg", "Egg", {
		ID = game:GetService("HttpService"):GenerateGUID(false),
	})
end)

game.ReplicatedStorage.Remotes.GenerateEggRarity.OnServerInvoke = function(Player)
    if not Player then return nil end

    local profile = Knit.GetService("DataService"):GetProfile(Player)
    if profile.Data.ClaimedChest == true then
        return nil
    end

    local Rarity = pickReward()
    return Rarity
end


