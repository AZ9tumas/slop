local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryService = Knit.CreateService {
	Name = "InventoryService",
	Client = {}
}

local Inventories = {}
local Loaded = {}
local PlayerUnlocked = {}

local EggsModule = require(ReplicatedStorage.Info.EggInfo)
local PigeonsModule = require(ReplicatedStorage.Info.PigeonInfo)
local ToolModule = require(ReplicatedStorage.Info.ToolInfo)

local BeakINFO = require(ReplicatedStorage.Info.NewBeaksInfo)
local MutationInfo = require(game.ReplicatedStorage.Info.MutationsInfo)

local CategoryLimits = require(ReplicatedStorage.Info.InventoryInfo)

local function GetBeaksPerSecond(pigeonWeight, pigeonInfo)
	if not pigeonInfo or not pigeonInfo.Weight then
		return 1
	end

	-- Clamp weight within its defined range
	local weight = math.clamp(pigeonWeight, pigeonInfo.Weight.Min, pigeonInfo.Weight.Max)

	local weightRange = pigeonInfo.Weight.Max - pigeonInfo.Weight.Min
	local normalisedWeight = (weight - pigeonInfo.Weight.Min) / (weightRange > 0 and weightRange or 1)

	-- Formula: base * multiplier * (1 + normalisedWeight)
	local beaksPerSecond = 0.79 * (pigeonInfo.Multiplier or 1) * (1 + normalisedWeight * 1.1)
	return beaksPerSecond
end

function InventoryService:InitPlayerInventory(player, profile)
	Inventories[player.UserId] = {Eggs = {}, Pigeons = {}, Tools = {}}
	PlayerUnlocked[player.UserId] = profile.Data.Unlocked or {}
	Loaded[player.UserId] = true
	warn("This is player unlocked ",PlayerUnlocked)
	local savedInv = profile.Data.Inventory or {}

	for itemType, items in pairs(savedInv) do

		if itemType == "Eggs" then
			for _, data in ipairs(items) do
				table.insert(Inventories[player.UserId].Eggs, data)
			end
		elseif itemType == "Pigeons" then
			for _, data in ipairs(items) do
				-- Ensure Weight has a default value to prevent nil issues
				if data.Weight == nil then
					data.Weight = 5
				end
				-- Ensure ID exists
				if data.ID == nil then
					data.ID = HttpService:GenerateGUID(false)
				end
				table.insert(Inventories[player.UserId].Pigeons, data)
			end
		elseif itemType == "Tools" then
			for toolName, count in pairs(items) do
				local toolData = ToolModule[count.Name]
				if toolData and toolData.Saves == false then
					continue
				end
				Inventories[player.UserId].Tools[toolName] = count
			end
		end
	end
end

function InventoryService:SaveInventory(player, profile)
	profile.Data.Inventory = Inventories[player.UserId] or {Eggs = {}, Pigeons = {}, Tools = {}}
	profile.Data.Unlocked = PlayerUnlocked[player.UserId] 
end

local function computeMutationMultiplier(mutations)
	if not mutations then return 1 end
	print("Mult")
	local mult = 1
	for _, m in ipairs(mutations) do
		if m and m ~= "Normal" and MutationInfo and MutationInfo.Multipliers and MutationInfo.Multipliers[m] then
			mult = mult * MutationInfo.Multipliers[m]
		end
	end
	print(mult)
	return mult
end

--[[
    SECURITY NOTE: This function was vulnerable to client-side manipulation.
    Replaced by GetEquippedMutationMultiplier which uses server-side data.

local function TableMutations(Tool: Tool)
	local Mutations = {}
	if Tool and Tool:IsA("Tool") and Tool:FindFirstChild("ExampleHandle") then
		local root = Tool.ExampleHandle:FindFirstChild("Torso")
		if root then
			for _, Mutation in ipairs(root:GetChildren()) do
				local name = Mutation.Name
				local suffix = string.match(name, "_([^_]+)$")
				if suffix then
					-- Check both SpawnChances and Multipliers
					if MutationInfo.SpawnChances[suffix] or MutationInfo.Multipliers[suffix] then
						table.insert(Mutations, suffix)
					end
				end
			end
		end
	end

	print(Mutations)
	return Mutations
end]]

local function GetEquippedMutationMultiplier(player)
	local character = player.Character
	if not character then return 1 end

	local tool = character:FindFirstChildWhichIsA("Tool")
	if not tool then return 1 end

	local pigeonId = tool:GetAttribute("PigeonId")
	if not pigeonId then return 1 end

	local inv = Inventories[player.UserId]
	if not inv or not inv.Pigeons then return 1 end

	for _, p in ipairs(inv.Pigeons) do
		if p.ID == pigeonId then
			-- Found the equipped pigeon in inventory
			-- Calculate multiplier based on its mutation
			if p.Mutation then
				local mutations = p.Mutation
				-- Handle both single string and table of strings
				if type(mutations) ~= "table" then
					mutations = {mutations}
				end
				return computeMutationMultiplier(mutations)
			end
			break
		end
	end

	return 1
end

function InventoryService:AddItem(player, itemName, itemType, options)
	Inventories[player.UserId] = Inventories[player.UserId] or {Eggs = {}, Pigeons = {}, Tools = {}}
	local inv = Inventories[player.UserId]
	options = options or {}
	warn("This is player unlocked ",PlayerUnlocked)
	if itemType == "Egg" then
		if itemName == "Secret Egg" or itemName == "Wealth Egg" or itemName == "Space Egg" or itemName == "Zombie Egg" or itemName == "Glitched Egg" then

		end
		if #inv.Eggs >= CategoryLimits.Eggs then
			return false, "Egg limit reached"
		end
		PlayerUnlocked[player.UserId][itemName] = true
		table.insert(inv.Eggs, {
			Name = itemName,
			Mutation = options.Mutation or "Normal",
			Fav = options.Fav or false,
			ID = options.ID or HttpService:GenerateGUID(false)
		})

	elseif itemType == "Pigeon" then
		-- ✅ Check pigeon limit before adding
		if #inv.Pigeons >= CategoryLimits.Pigeons then
			warn("[InventoryService] Pigeon limit reached — skipping hotbar auto-equip")
			return false, "Pigeon limit reached"
		end

		-- ✅ If pigeon already exists with same ID, skip to avoid duplication
		-- FIXED: Removed name+mutation check which prevented having multiple pigeons of the same type
		if options.ID then
			for _, p in ipairs(inv.Pigeons) do
				if p.ID == options.ID then
					warn("[InventoryService] Duplicate pigeon ID prevented: "..options.ID)
					return false, "Already have this pigeon"
				end
			end
		end
		local OldVal = PlayerUnlocked[player.UserId][itemName]
		PlayerUnlocked[player.UserId][itemName] = true
		if OldVal == false then
			ReplicatedStorage.Remotes.NewPigeon:FireClient(player, itemName)
		end
		print("Unlocked " .. itemName)
		table.insert(inv.Pigeons, {
			Name = itemName,
			Mutation = options.Mutation or "Normal",
			Fav = options.Fav or false,
			ID = options.ID or HttpService:GenerateGUID(false),
			Weight = options.Weight or 5
		})


	elseif itemType == "Tool" then
		if #inv.Tools >= CategoryLimits.Tools then
			return false, "Tool limit reached"
		end
		PlayerUnlocked[player.UserId][itemName] = true
		table.insert(inv.Tools, {
			Name = itemName,
			Fav = options.Fav or false,
			ID = options.ID or HttpService:GenerateGUID(false)
		})
	end

	local profile = Knit.GetService("DataService"):GetProfile(player)
	if profile then
		self:SaveInventory(player, profile)
	end

	game.ReplicatedStorage.Remotes.InventoryUpdate:FireClient(player,PlayerUnlocked[player.UserId])
	return true
end


function InventoryService.Client:SellAllNonFavourites(player)
	return self.Server:SellAllNonFavourites(player)
end

function InventoryService:SellAllNonFavourites(player)
	local inv = Inventories[player.UserId]
	if not inv then return 0 end

	local totalBeaks = 0
	local Achivement = game.ReplicatedStorage.Remotes:WaitForChild("AddAchievement")

	local function checkAchievements(itemName)
		local checks = {
			{"Pigeon", "Pigeon"},
			{"Minecart", "Minecart"},
			{"Miner", "Miner"},
			{"Epic", "Epic"},
		}

		for _, check in ipairs(checks) do
			if string.find(itemName, check[1]) then
				_G.AddAchiev(player,{"Sell", check[2]}, 1)
			end
		end
		_G.AddAchiev(player,{"Sell", itemName}, 1)
	end

	-- Calculate multiplier once based on server data
	local mutationMult = GetEquippedMutationMultiplier(player)

	for i = #inv.Eggs, 1, -1 do
		local egg = inv.Eggs[i]
		if not egg.Fav and egg.Name ~= "Speed Coil" and egg.Name ~= "Shovel" then
			local eggData = EggsModule[egg.Name]
			if eggData and eggData.Cost then
				totalBeaks += eggData.Cost / 2
			end
			checkAchievements(egg.Name)
			table.remove(inv.Eggs, i)
		end
	end

	for i = #inv.Pigeons, 1, -1 do
		local pigeon = inv.Pigeons[i]
		if not pigeon.Fav and pigeon.Name ~= "Speed Coil" and pigeon.Name ~= "Shovel" then
			local pigeonData = PigeonsModule[pigeon.Name]
			if pigeonData and pigeonData.Price then
				-- Use the secure multiplier
				totalBeaks += GetBeaksPerSecond(pigeon.Weight, pigeonData) * 20 * mutationMult
			end
			checkAchievements(pigeon.Name)
			table.remove(inv.Pigeons, i)
		end
	end

	--[[for i = #inv.Tools, 1, -1 do
		local tool = inv.Tools[i]
		if not tool.Fav then
			local toolData = ToolModule[tool.Name]
			if toolData and toolData.Price then
				totalBeaks += toolData.Price / 2
			end
			checkAchievements(tool.Name)
			table.remove(inv.Tools, i)
		end
	end]]

	local profile = Knit.GetService("DataService"):GetProfile(player)
	if profile then
		self:SaveInventory(player, profile)
		profile.Data.Beaks = (profile.Data.Beaks or 0) + totalBeaks
		player.leaderstats.Beaks.Value = profile.Data.Beaks
	end
	if player.Character:FindFirstChildWhichIsA("Tool") then
		if player.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId") or player.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("EggId") then
			player.Character:FindFirstChildWhichIsA("Tool"):Destroy()
		end
	end
	game.ReplicatedStorage.Remotes.InventoryUpdate:FireClient(player, PlayerUnlocked[player.UserId])

	return totalBeaks
end

function InventoryService:SellTool(player, itemId, MakeNone)
	local inv = Inventories[player.UserId]
	if not inv then return 0 end

	local totalBeaks = 0
	local found = false

	local mutationMult = GetEquippedMutationMultiplier(player)

	-- Check Eggs
	for i = #inv.Eggs, 1, -1 do
		local egg = inv.Eggs[i]
		if egg.ID == itemId then
			local eggData = EggsModule[egg.Name]
			if eggData and eggData.Cost then
				totalBeaks = eggData.Cost / 2
			end
			table.remove(inv.Eggs, i)
			found = true
			break
		end
	end

	-- Check Pigeons
	if not found then
		for i = #inv.Pigeons, 1, -1 do
			local pigeon = inv.Pigeons[i]
			if pigeon.ID == itemId then
				local pigeonData = PigeonsModule[pigeon.Name]
				if pigeonData and pigeonData.Price then
					print(pigeon.Weight)
					totalBeaks = GetBeaksPerSecond(pigeon.Weight, pigeonData) * 20 * mutationMult
				end
				table.remove(inv.Pigeons, i)
				found = true
				break
			end
		end
	end

	-- Check Tools
	--[[if not found then
		for i = #inv.Tools, 1, -1 do
			local tool = inv.Tools[i]
			if tool.ID == itemId then
				local toolData = ToolModule[tool.Name]
				if toolData and toolData.Price then
					totalBeaks = toolData.Price / 2
				end
				table.remove(inv.Tools, i)
				found = true
				break
			end
		end
	end]]

	if totalBeaks > 1000000000 then
		player:Kick("Error: 1")
		return
	end

	if found then
		local profile = Knit.GetService("DataService"):GetProfile(player)
		if profile then
			self:SaveInventory(player, profile)
			if not MakeNone then
				profile.Data.Beaks = (profile.Data.Beaks or 0) + totalBeaks
				player.leaderstats.Beaks.Value = profile.Data.Beaks
			end
		end

	end
	game.ReplicatedStorage.Remotes.InventoryUpdate:FireClient(player, PlayerUnlocked[player.UserId])
	return totalBeaks
end

function InventoryService.Client:SellTool(player, itemId)
	return self.Server:SellTool(player, itemId)
end

--[[ 
    CRITICAL SECURITY FIX: 
    AddItem was exposed to the client, allowing exploiters to generate infinite items.
    This function has been removed from the Client table.
]]
-- function InventoryService.Client:AddItem(player, itemName, itemType, options)
-- 	return self.Server:AddItem(player, itemName, itemType, options)
-- end

function InventoryService:RemoveItem(player, itemName, itemType, options)
	local userId = player.UserId
	Inventories[userId] = Inventories[userId] or {Eggs = {}, Pigeons = {}, Tools = {}}
	local inv = Inventories[userId]
	options = options or {}

	if not options.ID then
		warn("[InventoryService] RemoveItem called without ID for", itemType, itemName)
		return
	end

	if itemType == "Egg" then
		for i = #inv.Eggs, 1, -1 do
			local egg = inv.Eggs[i]
			if egg.ID == options.ID then
				table.remove(inv.Eggs, i)
				break
			end
		end
	elseif itemType == "Pigeon" then
		for i = #inv.Pigeons, 1, -1 do
			local pigeon = inv.Pigeons[i]
			if pigeon.ID == options.ID then
				table.remove(inv.Pigeons, i)
				break
			end
		end
	elseif itemType == "Tool" then
		for i = #inv.Tools, 1, -1 do
			local tool = inv.Tools[i]
			if tool.ID == options.ID then
				table.remove(inv.Tools, i)
				break
			end
		end
	end

	local profile = Knit.GetService("DataService"):GetProfile(player)
	if profile then
		self:SaveInventory(player, profile)
	end

	game.ReplicatedStorage.Remotes.InventoryUpdate:FireClient(player, PlayerUnlocked[userId])
end




function InventoryService.Client:RemoveItem(player, itemName, itemType, options)
	return self.Server:RemoveItem(player, itemName, itemType, options)
end

function InventoryService:Favourite(player, itemId, action)
	local inv = Inventories[player.UserId]
	if not inv then return end
	for _, egg in pairs(inv.Eggs) do
		if egg.ID == itemId then 
			egg.Fav = action and true or false 
			break
		end
	end
	for _, pigeon in pairs(inv.Pigeons) do
		if pigeon.ID == itemId then 
			pigeon.Fav = action and true or false 
			break
		end
	end
end

function InventoryService.Client:Favourite(player, itemId, action)
	return self.Server:Favourite(player, itemId, action)
end


function InventoryService:GetInventory(player)
	repeat task.wait() until Loaded[player.UserId]
	Inventories[player.UserId] = Inventories[player.UserId] or {Eggs = {}, Pigeons = {}, Tools = {}}
	return Inventories[player.UserId]
end

function InventoryService.Client:GetInventory(player)
	return self.Server:GetInventory(player)
end

function InventoryService:GetUnlocked(player)
	repeat task.wait() until Loaded[player.UserId]
	return PlayerUnlocked[player.UserId]
end

function InventoryService.Client:GetUnlocked(player)
	return self.Server:GetUnlocked(player)
end

function InventoryService:GetItemValue(player, itemName)
	local inv = self:GetInventory(player)
	local count = 0
	for _, egg in ipairs(inv.Eggs) do
		if egg.Name == itemName then count += 1 end
	end
	for _, pigeon in ipairs(inv.Pigeons) do
		if pigeon.Name == itemName then count += 1 end
	end
	for _, tool in ipairs(inv.Tools) do
		if tool.Name == itemName then count += 1 end
	end
	return count
end

function InventoryService.Client:GetItemValue(player, itemName)
	return self.Server:GetItemValue(player, itemName)
end

function InventoryService:GetAnyPigeon(player, pigeonId)
	local userId = player.UserId
	local inv = Inventories[userId]
	if not inv then return nil, nil end

	if not pigeonId then
		warn("[InventoryService] GetAnyPigeon called without ID")
		return nil, nil
	end

	for i, pigeon in ipairs(inv.Pigeons) do
		if pigeon.ID == pigeonId then
			table.remove(inv.Pigeons, i)
			local profile = Knit.GetService("DataService"):GetProfile(player)
			if profile then
				self:SaveInventory(player, profile)
			end
			return pigeon.ID, pigeon
		end
	end

	return nil, nil
end


function InventoryService.Client:GetAnyPigeon(player, pigeonName)
	return self.Server:GetAnyPigeon(player, pigeonName)
end

return InventoryService
