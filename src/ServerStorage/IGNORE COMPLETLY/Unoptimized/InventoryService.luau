--local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--local InventoryService = Knit.CreateService {
--	Name = "InventoryService",
--	Client = {}
--}

--local Inventories = {}
--local UniquePigeons = {} -- [userId] = { [pigeonId] = pigeonData }
--local UniqueEggs = {} -- [userId] = { [eggId] = { Name, Mutation } }

--local Loaded = {}
--local ReplicatedStorage = game:GetService("ReplicatedStorage")

--local EggsModule = require(ReplicatedStorage.Info.EggInfo)
--local PigeonsModule = require(ReplicatedStorage.Info.PigeonInfo)
--local ToolModule = require(ReplicatedStorage.Info.ToolInfo)

--local PlayerUnlocked = {}

--function InventoryService:InitPlayerInventory(player, profile)
--	Loaded[player.UserId] = true
--	Inventories[player.UserId] = {}
--	PlayerUnlocked[player.UserId] = profile.Data.Unlocked or {}

--	local savedInv = profile.Data.Inventory or {}
--	UniquePigeons[player.UserId] = profile.Data.UniquePigeons or {}
--	UniqueEggs[player.UserId] = profile.Data.UniqueEggs or {}

--	-- load normal saved inventory
--	for itemName, data in pairs(savedInv) do
--		local toolData = ToolModule[itemName]
--		if toolData and toolData.Saves == false then
--			continue
--		end

--		if typeof(data) == "table" then
--			Inventories[player.UserId][itemName] = {
--				Count = data.Count or 0,
--				Fav = data.Fav or false,
--				Mutation = data.Mutation or nil
--			}
--		else
--			Inventories[player.UserId][itemName] = {
--				Count = data,
--				Fav = false
--			}
--		end
--	end

--	for _, eggData in pairs(UniqueEggs[player.UserId] or {}) do
--		local name = eggData.Name
--		local inv = Inventories[player.UserId]
--		if not inv[name] then
--			inv[name] = {Count = 1, Fav = false}
--		else
--			inv[name].Count += 1
--		end
--	end

--end



--function InventoryService:SaveInventory(player, profile)
--	profile.Data.Inventory = Inventories[player.UserId] or {}
--	profile.Data.Unlocked = PlayerUnlocked[player.UserId]
--	profile.Data.UniquePigeons = UniquePigeons[player.UserId]
--	profile.Data.UniqueEggs = UniqueEggs[player.UserId]
--end

--function InventoryService:AddItem(player, itemName, amount, pigeonData, mutation, eggData)
--	amount = amount or 1
--	Inventories[player.UserId] = Inventories[player.UserId] or {}
--	UniquePigeons[player.UserId] = UniquePigeons[player.UserId] or {}
--	UniqueEggs[player.UserId] = UniqueEggs[player.UserId] or {}

--	local item = Inventories[player.UserId][itemName]
--	if not item then
--		item = {Count = 0, Fav = false}
--		Inventories[player.UserId][itemName] = item
--	end

--	item.Count += amount 

--	if pigeonData then
--		UniquePigeons[player.UserId][pigeonData.ID] = pigeonData
--	elseif eggData then
--		UniqueEggs[player.UserId][eggData.ID] = eggData 
--	end

--	local DataService = Knit.GetService("DataService")
--	local profile = DataService:GetProfile(player)
--	if profile then
--		self:SaveInventory(player, profile)
--	end

--	game.ReplicatedStorage.Remotes.InventoryUpdate:FireClient(player)
--end


--function InventoryService:RemoveItem(player, itemName, amount, uniqueId)
--	amount = amount or 1
--	Inventories[player.UserId] = Inventories[player.UserId] or {}
--	local inv = Inventories[player.UserId]

--	local item = inv[itemName]
--	if not item or item.Count < amount then
--		return false
--	end

--	if itemName:lower():find("pigeon") then
--		local uniques = UniquePigeons[player.UserId]
--		if uniques and uniqueId and uniques[uniqueId] then
--			uniques[uniqueId] = nil
--		end
--	end

--	if itemName:lower():find("egg") then
--		local uniques = UniqueEggs[player.UserId]
--		if uniques and uniqueId and uniques[uniqueId] then
--			uniques[uniqueId] = nil
--		end
--	end

--	item.Count -= amount
--	if item.Count <= 0 then
--		inv[itemName] = nil
--	end

--	local DataService = Knit.GetService("DataService")
--	local profile = DataService:GetProfile(player)
--	if profile then
--		self:SaveInventory(player, profile)
--	end

--	return true
--end

--function InventoryService:GetUniquePigeons(player)
--	return UniquePigeons[player.UserId]
--end
--function InventoryService.Client:GetUniquePigeons(player)
--	return self.Server:GetUniquePigeons(player)
--end

--function InventoryService:GetAnyPigeon(player, itemName)
--	local uniques = UniquePigeons[player.UserId]
--	if not uniques then return nil end
--	for _, pigeonData in pairs(uniques) do
--		if pigeonData.Name == itemName then
--			return pigeonData.ID, pigeonData
--		end
--	end
--	return nil
--end
--function InventoryService.Client:GetAnyPigeon(player, itemName)
--	return self.Server:GetAnyPigeon(player, itemName)
--end

--function InventoryService:GetUniquePigeon(player, pigeonId)
--	return UniquePigeons[player.UserId] and UniquePigeons[player.UserId][pigeonId]
--end
--function InventoryService.Client:GetUniquePigeon(player, pigeonId)
--	return self.Server:GetUniquePigeon(player, pigeonId)
--end

--function InventoryService:GetUniqueEggs(player)
--	return UniqueEggs[player.UserId]
--end
--function InventoryService.Client:GetUniqueEggs(player)
--	return self.Server:GetUniqueEggs(player)
--end

--function InventoryService:GetUniqueEgg(player, eggId)
--	return UniqueEggs[player.UserId] and UniqueEggs[player.UserId][eggId]
--end
--function InventoryService.Client:GetUniqueEgg(player, eggId)
--	return self.Server:GetUniqueEgg(player, eggId)
--end

--function InventoryService:Favourite(player, itemName, action)
--	local item = Inventories[player.UserId][itemName]
--	if item and item.Count > 0 then
--		item.Fav = action and true or false
--	end
--end
--function InventoryService.Client:Favourite(player, itemName, action)
--	return self.Server:Favourite(player, itemName, action)
--end

--function InventoryService.Client:AddItem(player, itemName)
--	return self.Server:AddItem(player, itemName)
--end

--function InventoryService:GetInventory(player)
--	repeat task.wait() until Loaded[player.UserId]
--	Inventories[player.UserId] = Inventories[player.UserId] or {}
--	return Inventories[player.UserId]
--end
--function InventoryService.Client:GetInventory(player)
--	return self.Server:GetInventory(player)
--end

--function InventoryService:GetUnlocked(player)
--	repeat task.wait() until Loaded[player.UserId]
--	return PlayerUnlocked[player.UserId]
--end
--function InventoryService.Client:GetUnlocked(player)
--	return self.Server:GetUnlocked(player)
--end

--function InventoryService:SellAllNonFavourites(player)
--	local inv = Inventories[player.UserId]
--	if not inv then return 0 end

--	local totalBeaks = 0
--	for itemName, item in pairs(inv) do
--		if item.Count and item.Count > 0 and not item.Fav then
--			local lower = itemName:lower()
--			if lower:find("egg") then
--				local eggData = EggsModule[itemName]
--				if eggData and eggData.Cost then
--					totalBeaks += ((eggData.Cost / 2) * item.Count)
--					inv[itemName] = nil
--					UniqueEggs[player.UserId] = {}
--				end
--			elseif lower:find("pigeon") then
--				local pigeonData = PigeonsModule[itemName]
--				if pigeonData and pigeonData.Price then
--					totalBeaks += ((pigeonData.Price / 2) * item.Count)
--					inv[itemName] = nil
--					UniquePigeons[player.UserId] = {}
--				end
--			end
--		end
--	end

--	local DataService = Knit.GetService("DataService")
--	local profile = DataService:GetProfile(player)
--	if profile then
--		self:SaveInventory(player, profile)
--	end

--	profile.Data.Beaks += totalBeaks
--	print(player.Name .. " sold non-favourite items for " .. totalBeaks .. " beaks")
--	return totalBeaks
--end
--function InventoryService.Client:SellAllNonFavourites(player)
--	return self.Server:SellAllNonFavourites(player)
--end

--function InventoryService:SellTool(player, toolName)
--	local inv = Inventories[player.UserId]
--	if not inv then return 0 end

--	local item = inv[toolName]
--	if not item or item.Count <= 0 then
--		return 0
--	end

--	local totalBeaks = 0
--	local lower = toolName:lower()

--	if lower:find("egg") then
--		local eggData = EggsModule[toolName]
--		if eggData and eggData.Cost then
--			totalBeaks += eggData.Cost
--			item.Count -= 1
--			local uniques = UniqueEggs[player.UserId]
--			for eggId, eggData in pairs(uniques) do
--				if eggData.Name == toolName then
--					uniques[eggId] = nil
--					break
--				end
--			end
--		end
--	elseif lower:find("pigeon") then
--		local pigeonData = PigeonsModule[toolName]
--		if pigeonData and pigeonData.Price then
--			totalBeaks += pigeonData.Price
--			item.Count -= 1
--			local uniques = UniquePigeons[player.UserId]
--			for pigeonId, pigeon in pairs(uniques) do
--				if pigeon.Name == toolName then
--					uniques[pigeonId] = nil
--					break
--				end
--			end
--		end
--	end

--	if item.Count <= 0 then
--		inv[toolName] = nil
--	end

--	local DataService = Knit.GetService("DataService")
--	local profile = DataService:GetProfile(player)
--	if profile then
--		self:SaveInventory(player, profile)
--		profile.Data.Beaks = (profile.Data.Beaks or 0) + totalBeaks
--	end

--	print(player.Name .. " sold 1x " .. toolName .. " for " .. totalBeaks .. " beaks")
--	return totalBeaks
--end
--function InventoryService.Client:SellTool(player, toolName)
--	return self.Server:SellTool(player, toolName)
--end

--function InventoryService:GetItemValue(player, itemName)
--	local inventory = self:GetInventory(player)
--	local item = inventory[itemName]
--	return item and item.Count or 0
--end
--function InventoryService.Client:GetItemValue(player, itemName)
--	return self.Server:GetItemValue(player, itemName)
--end

--return InventoryService
