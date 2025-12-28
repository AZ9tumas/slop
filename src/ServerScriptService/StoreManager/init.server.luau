local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LuckEvent = Instance.new("RemoteEvent")
LuckEvent.Name = "LuckEvent"
LuckEvent.Parent = ReplicatedStorage

local RequestNextLuck = Instance.new("RemoteFunction")
RequestNextLuck.Name = "RequestNextLuck"
RequestNextLuck.Parent = ReplicatedStorage

local PurchaseEvent = Instance.new("RemoteEvent")
PurchaseEvent.Name = "PurchaseEvent"
PurchaseEvent.Parent = ReplicatedStorage

local ServerLuck = {
	Multiplier = 1,
	Duration = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local chatEvent = Instance.new("RemoteEvent")
chatEvent.Name = "GlobalChat"
chatEvent.Parent = ReplicatedStorage

_G.sendGlobalMessage = function(message)
	chatEvent:FireAllClients(message)
end

local productIds = require(game.ReplicatedStorage.Info:WaitForChild("ProductIds"))
local EggEvolutionInfo = require(game.ReplicatedStorage.Info:WaitForChild("EggEvolutionInfo"))

-- Build lookup tables for EggEvolution product IDs
local EggEvolutionSkipProducts = {}
local EggEvolutionProtectionProducts = {}
for eggName, data in pairs(EggEvolutionInfo.Evolutions) do
	if data.SkipProductId then
		EggEvolutionSkipProducts[data.SkipProductId] = eggName
	end
	if data.ProtectionProductId then
		EggEvolutionProtectionProducts[data.ProtectionProductId] = eggName
	end
end

local MAX_MULTIPLIER = 8
local DURATION_INCREMENT = 15 * 60

local PRODUCT_IDS = {
	[2] = 3403897036,
	[4] = 3403897242,
	[8] = 3403897484,
}

local STARTER_PACK_GAMEPASS_ID = productIds.StarterPack -- replace with your StarterPack gamepass id
local X2BEAKD_GAMEPASS_ID = productIds.x2Beaks -- replace with your StarterPack gamepass id
local VOLCANO_PACK_ID = 1565981246
if not workspace:GetAttribute("ServerLuck") then
	workspace:SetAttribute("ServerLuck", 1)
end

local function UpdateClients()
	workspace:SetAttribute("ServerLuck", ServerLuck.Multiplier)
	LuckEvent:FireAllClients(ServerLuck.Multiplier, ServerLuck.Duration)
end

task.spawn(function()
	while true do
		if ServerLuck.Duration > 0 then
			ServerLuck.Duration -= 1
			if ServerLuck.Duration == 0 then
				ServerLuck.Multiplier = 1
			end
			UpdateClients()
		end
		task.wait(1)
	end
end)

local function GetNextMultiplier(current)
	if current == 1 then return 2 end
	if current == 2 then return 4 end
	if current == 4 then return 8 end
	return nil
end

local function GiveStarterPack(player)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if not profile then return end
	profile.Data.Beaks += 5000
	player.leaderstats.Beaks.Value = profile.Data.Beaks
	local InventoryService = Knit.GetService("InventoryService")
	local space = InventoryService:AddItem(player, "Kingdom Egg", "Egg", {
		ID = game:GetService("HttpService"):GenerateGUID(false),
	})
	wait(.3)
	local space2 = InventoryService:AddItem(player, "Beach Egg", "Egg", {
		ID = game:GetService("HttpService"):GenerateGUID(false),
	})
	wait(.3)
	local space3 = InventoryService:AddItem(player, "Beach Egg", "Egg", {
		ID = game:GetService("HttpService"):GenerateGUID(false),
	})
end

local function GiveItem(player, Name)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if not profile then return end
	local InventoryService = Knit.GetService("InventoryService")
	local space = InventoryService:AddItem(player, Name, "Tool", {
		ID = game:GetService("HttpService"):GenerateGUID(false),
	})
end

local function GiveGravityEgg(player)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if not profile then return end
	local InventoryService = Knit.GetService("InventoryService")
	local space = InventoryService:AddItem(player, "Gravity Egg", "Egg", {
		ID = game:GetService("HttpService"):GenerateGUID(false),
	})
end

local function GiveVolcanoPack(player)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if not profile then return end
	profile.Data.Beaks += 20000
	player.leaderstats.Beaks.Value = profile.Data.Beaks
	local InventoryService = Knit.GetService("InventoryService")
	local space = InventoryService:AddItem(player, "Volcano Egg", "Egg", {
		ID = game:GetService("HttpService"):GenerateGUID(false),
	})
	wait(.3)
	GiveItem(player, "Volcanic Spray")
	wait(.3)
	GiveItem(player, "Volcanic Spray")
end

local function GiveFlyingCarpet(player:Player)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if not profile then return end
	GiveItem(player, "Flying Carpet")
end

local function Givex2Beaks(player)
	local profile = Knit.GetService("DataService"):GetProfile(player)
	if not profile then return end
	profile.Data.Gamepasses["x2Beaks"] = true
end

local function ApplyPurchase(multiplier, player)
	if not multiplier then return end
	if multiplier <= ServerLuck.Multiplier then return end
	if ServerLuck.Multiplier == MAX_MULTIPLIER then return end

	ServerLuck.Multiplier = multiplier
	ServerLuck.Duration += DURATION_INCREMENT
	_G.sendGlobalMessage("[PURCHASE]"..player.Name.." Bought Server Luck")
	game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought Server Luck")
	UpdateClients()
	PurchaseEvent:FireClient(player, multiplier, ServerLuck.Duration)
end

RequestNextLuck.OnServerInvoke = function(player)
	local nextMultiplier = GetNextMultiplier(ServerLuck.Multiplier)
	if nextMultiplier then
		return PRODUCT_IDS[nextMultiplier]
	end
	return nil
end

local productFunctions = {
	["SpawnFirst"] = function(player,rarity)

		Knit.GetService("EggSpawnerService"):ExternalSpawn(rarity)
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought "..rarity.." Egg Spawn")
		_G.sendGlobalMessage("[PURCHASE]"..player.Name.." Bought "..rarity.." Egg Spawn")
	end,
	["SpawnSecond"] = function(player,rarity)

		Knit.GetService("EggSpawnerService"):ExternalSpawn(rarity)
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought "..rarity.." Egg Spawn")
		_G.sendGlobalMessage("[PURCHASE]"..player.Name.." Bought "..rarity.." Egg Spawn")
	end,
	["Pack1"] = function(player,earned)
		Knit.GetService("DataService"):GetProfile(player).Data.Beaks += earned
		_G.sendGlobalMessage("[PURCHASE]"..player.Name.." Bought "..earned.." BEAKS")
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought "..earned.." BEAKS")
		player.leaderstats.Beaks.Value = Knit.GetService("DataService"):GetProfile(player).Data.Beaks
	end,
	["Pack2"] = function(player,earned)
		Knit.GetService("DataService"):GetProfile(player).Data.Beaks += earned
		player.leaderstats.Beaks.Value = Knit.GetService("DataService"):GetProfile(player).Data.Beaks
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought "..earned.." BEAKS")
		_G.sendGlobalMessage("[PURCHASE]"..player.Name.." Bought "..earned.." BEAKS")

	end,
	["Pack3"] = function(player,earned)
		Knit.GetService("DataService"):GetProfile(player).Data.Beaks += earned
		player.leaderstats.Beaks.Value = Knit.GetService("DataService"):GetProfile(player).Data.Beaks
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought "..earned.." BEAKS")
		_G.sendGlobalMessage("[PURCHASE]"..player.Name.." Bought "..earned.." BEAKS")

	end,
	["Pack4"] = function(player,earned)
		Knit.GetService("DataService"):GetProfile(player).Data.Beaks += earned
		player.leaderstats.Beaks.Value = Knit.GetService("DataService"):GetProfile(player).Data.Beaks
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought "..earned.." BEAKS")
		_G.sendGlobalMessage("[PURCHASE]"..player.Name.." Bought "..earned.." BEAKS")

	end,
	["Pack5"] = function(player,earned)
		Knit.GetService("DataService"):GetProfile(player).Data.Beaks += earned
		player.leaderstats.Beaks.Value = Knit.GetService("DataService"):GetProfile(player).Data.Beaks
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought "..earned.." BEAKS")
		_G.sendGlobalMessage("[PURCHASE]"..player.Name.." Bought "..earned.." BEAKS")

	end,

}
local function SkipEggHatch(player, eggId)
	local userId = player.UserId
	local eggs = Knit.GetService("EggService"):ReturnEggs(player.UserId)

	if not eggs then return end

	for i, eggData in ipairs(eggs) do
		if eggData.ID == eggId then
			eggData.Remaining = 0
			eggData.EndTime = os.time()
			-- Fire client to update UI / animation
			eggData.Model:SetAttribute("Skipped",true)
			game.ReplicatedStorage.Remotes.EggSkipRemote:FireClient(player, eggData.Model, "Skipped", eggId)
			game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought Hatch Skip")
			-- Call your existing hatch logic
			--Knit.GetService("PigeonService").RewardPigeon(player, eggData)

			-- Remove it from saved eggs if needed
			--DataService:RemovePlacedEgg(player, eggId)

			--table.remove(eggs, i)
			break
		end
	end
end

local function SkipAllTimer(player, eggId)
	local userId = player.UserId
	local eggs = Knit.GetService("EggService"):ReturnEggs(player.UserId)

	if not eggs then return end

	game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Skipped All Egg Timers!")

	for i, eggData in ipairs(eggs) do
		if not eggData.Model:GetAttribute("Skipped") then
			eggData.Remaining = 0
			eggData.EndTime = os.time()
			eggData.Model:SetAttribute("Skipped",true)
			game.ReplicatedStorage.Remotes.EggSkipRemote:FireClient(player, eggData.Model, "Skipped", eggId)
		end
	end
end

local STEAL_PRODUCT_ID = 3405147399 -- replace

local SKIP_PRODUCT_ID = 3405147695
local SKIP_ALL_PRODUCT_ID = 3441132770
local LastEggSkipRequest = {}

game.ReplicatedStorage.Remotes:WaitForChild("RequestSkipEgg").OnServerEvent:Connect(function(player, eggId)
	LastEggSkipRequest[player.UserId] = eggId
end)
game.ReplicatedStorage.Remotes:WaitForChild("StealRemote").OnServerEvent:Connect(function(player, id)
	player:SetAttribute("PendingSteal",id)
end)
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local productId = receiptInfo.ProductId

	local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

	if receiptInfo.ProductId == 3487382299 then--GRAVITY EGG
		GiveGravityEgg(player)
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought Gravity Egg")
		_G.sendGlobalMessage(player.Name.." Bought Gravity Egg for 2000 robux!")
	end
	
	if receiptInfo.ProductId == 3488522294 then
		for i = 1, 10 do 
			GiveGravityEgg(player)
		end
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought x10 Gravity Egg")
		_G.sendGlobalMessage(player.Name.." Bought x10 Gravity Egg for 9999 robux!")
	end
	
	if receiptInfo.ProductId == 3488522171 then
		for i = 1, 4 do 
			GiveGravityEgg(player)
		end
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought x4 Gravity Egg")
		_G.sendGlobalMessage(player.Name.." Bought x4 Gravity Egg for 3999 robux!")
	end

	if receiptInfo.ProductId == SKIP_PRODUCT_ID then
		local eggId = LastEggSkipRequest[player.UserId]
		if eggId then
			SkipEggHatch(player, eggId)
			LastEggSkipRequest[player.UserId] = nil
		end
	end

	if receiptInfo.ProductId == SKIP_ALL_PRODUCT_ID then
		local fade = script.WhiteFade:Clone()
		fade.Parent = player.Character
		fade.Enabled = true
		wait(1.9)
		SkipAllTimer(player)
	end

	if receiptInfo.ProductId == 3436245434 then
		if player then
			print("Boughtssss")
			local profile = Knit.GetService("DataService"):GetProfile(player)
			GiveItem(player, "Volcanic Spray")
		end
	end

	if receiptInfo.ProductId == 3482689984 then--OPEGG
		if player then
			print("Boughtssss")
			local profile = Knit.GetService("DataService"):GetProfile(player)
			local InventoryService = Knit.GetService("InventoryService")
			local space = InventoryService:AddItem(player, "Nature Egg", "Egg", {
				ID = game:GetService("HttpService"):GenerateGUID(false),
			})
			profile.Data.BoughtOPEgg = true
			player.PlayerGui.MainUI.Products.NatureProduct.Visible = false
			ReplicatedStorage.Remotes.Notification:FireClient(player, "You got a nature egg!")
		end
	end

	if receiptInfo.ProductId == 3436245965 then
		if player then
			print("Boughtssss")
			local profile = Knit.GetService("DataService"):GetProfile(player)
			GiveItem(player, "Shock Spray")
		end
	end

	if receiptInfo.ProductId == 3436247816 then
		if player then
			print("Boughtssss")
			local profile = Knit.GetService("DataService"):GetProfile(player)
			GiveItem(player, "Luck Spray")
		end
	end

	if receiptInfo.ProductId == 3436247492 then
		if player then
			print("Boughtssss")
			local profile = Knit.GetService("DataService"):GetProfile(player)
			GiveItem(player, "Size Spray")
		end
	end

	if player then
		for multiplier, id in pairs(PRODUCT_IDS) do
			if id == productId then
				ApplyPurchase(multiplier, player)
			end
		end
		for i,v in pairs(productIds) do
			pcall(function()
				if v.Id == productId then
					-- handle other dev products here if needed
					productFunctions[i](player,v.Arg)
				end
			end)

		end
	end

	if receiptInfo.ProductId == STEAL_PRODUCT_ID then
		local PigeonService = Knit.GetService("PigeonService")
		if player then
			local pigeonId = player:GetAttribute("PendingSteal")
			player:SetAttribute("PendingSteal", nil)
			if pigeonId then
				PigeonService:StealPigeon(player, pigeonId)
			end
			--game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Successfully Stole This Pigeon")
		end
	end

	-- Handle EggEvolution Skip products
	if EggEvolutionSkipProducts[receiptInfo.ProductId] then
		if player then
			local EggEvolutionService = Knit.GetService("EggEvolutionService")
			local success = EggEvolutionService:ProcessSkip(player)
			if not success then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
		end
	end

	-- Handle EggEvolution Protection products
	if EggEvolutionProtectionProducts[receiptInfo.ProductId] then
		if player then
			local EggEvolutionService = Knit.GetService("EggEvolutionService")
			local success = EggEvolutionService:ProcessProtection(player)
			if not success then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
		end
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	print(gamePassId)
	if wasPurchased and gamePassId == STARTER_PACK_GAMEPASS_ID then
		GiveStarterPack(player)
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought Starter Pack")
		_G.sendGlobalMessage(player.Name.." Bought Starter Pack for 29 robux!")
	end
	if wasPurchased and gamePassId == X2BEAKD_GAMEPASS_ID then
		Givex2Beaks(player)
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"2x Beaks Gamepass")
		_G.sendGlobalMessage(player.Name.." Bought 2x Beaks Gamepass for 89 robux!")
	end
	if wasPurchased and gamePassId == VOLCANO_PACK_ID then
		GiveVolcanoPack(player)
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought Volcano Pack")
		_G.sendGlobalMessage(player.Name.." Bought Volcano Pack for 59 robux!")
	end
	if wasPurchased and gamePassId == 1635591128 then--FLYING CARPET
		GiveFlyingCarpet(player)
		game.ReplicatedStorage.Remotes.Notification:FireClient(player,"Bought Flying Carpet")
		_G.sendGlobalMessage(player.Name.." Bought Flying Carpet for 299 robux!")
	end
end)

game.Players.PlayerAdded:Connect(function(player)
	-- Send current luck info to the joining player
	LuckEvent:FireClient(player, ServerLuck.Multiplier, ServerLuck.Duration)
	task.delay(10, function()
		local profile = Knit.GetService("DataService"):GetProfile(player)
		if profile.Data.BoughtOPEgg == true then
			player.PlayerGui.MainUI.Products.NatureProduct.Visible = false
		end
	end)
end)

local MessagesChat = {
	"Already have a good pigeon? make sure to grind mutations on it for more money!",
	"Keep getting unlucky while hatching pigeons? buy luck spray from the gear shop!",
	"If you have bunch of bad pigeons, sell them at the sell stand!",
	"You can steal other people's pigeons with robux!",
	"Join the group and like the game for a free Miner egg!",
	"Join our server for sneak-peaks and notifiers!",
	"Dont forget to expand your plot using the shovel!"
}

while wait(150) do
	local randomMessage = MessagesChat[math.random(1, #MessagesChat)]
	_G.sendGlobalMessage(randomMessage)
end