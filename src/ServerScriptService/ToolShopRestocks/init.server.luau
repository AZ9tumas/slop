local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopEvent = Remotes:WaitForChild("BuyTool")

local ToolInfo = require(ReplicatedStorage.Info.ToolInfo)

local RestockEvent = Instance.new("RemoteEvent")
RestockEvent.Name = "RestockEvent"
RestockEvent.Parent = Remotes

-- Config
local RESTOCK_TIME = 300 -- 5 minutes
local currentStock = {}
local nextRestock = 0

local stockStore = MemoryStoreService:GetSortedMap("GlobalShopStock_231")
local timeStore = MemoryStoreService:GetSortedMap("GlobalShopTimer_231")

local function generateStock()
	local stock = {}
	for toolName, toolData in pairs(ToolInfo) do
		-- Roll to see if item spawns at all
		if math.random(1, 100) <= toolData.StockChance then
			-- If it spawns, pick a random amount
			local minAmt, maxAmt = toolData.StockAmount[1], toolData.StockAmount[2]
			stock[toolName] = math.random(minAmt, maxAmt)
		else
			stock[toolName] = 0
		end
	end
	return stock
end




local function saveState(stock, nextTime)
	local ok, err = pcall(function()
		stockStore:SetAsync("Stock", stock, RESTOCK_TIME + 30)
		timeStore:SetAsync("Next", nextTime, RESTOCK_TIME + 30)
	end)
	if not ok then
		warn("Save failed:", err)
	end
end

local function loadState()
	local stock, time
	local ok, err = pcall(function()
		stock = stockStore:GetAsync("Stock")
		time = timeStore:GetAsync("Next")
	end)
	if not ok then
		warn("Load failed:", err)
	end
	return stock, time
end

local function publish(stock, nextTime)
	local ok, err = pcall(function()
		MessagingService:PublishAsync("GlobalShopChannel", {
			stock = stock,
			next = nextTime
		})
	end)
	if not ok then
		warn("Publish failed:", err)
	end
end

local function addStock(toolName)
	if not ToolInfo[toolName] then
		warn("Tried to add stock for invalid tool:", toolName)
		return
	end

	currentStock[toolName] = currentStock[toolName] or 0
	currentStock[toolName] += 1

	saveState(currentStock, nextRestock)
	publish(currentStock, nextRestock)
	RestockEvent:FireAllClients(currentStock, nextRestock)
	ReplicatedStorage.Remotes.Notification:FireAllClients(toolName .. " Got restocked in the gear shop.")
	
end


local function restock()
	ReplicatedStorage.Remotes.Notification:FireAllClients("Gear shop has been restocked.")
	currentStock = generateStock()
	nextRestock = os.time() + RESTOCK_TIME
	saveState(currentStock, nextRestock)
	publish(currentStock, nextRestock)
	RestockEvent:FireAllClients(currentStock, nextRestock)
	
end

MessagingService:SubscribeAsync("GlobalShopChannel", function(message)
	local data = message.Data
	if not data then return end
	currentStock = data.stock or {}
	nextRestock = data.next or (os.time() + RESTOCK_TIME)
	RestockEvent:FireAllClients(currentStock, nextRestock)
end)

task.spawn(function()
	local stock, time = loadState()
	if stock and time and os.time() < time then
		currentStock = stock
		nextRestock = time
		RestockEvent:FireAllClients(currentStock, nextRestock)
	else
		restock()
	end

	-- Leader loop
	while true do
		local waitTime = nextRestock - os.time()
		if waitTime > 0 then
			task.wait(waitTime)
		end
		restock()
	end
end)

task.spawn(function()
	while true do
		task.wait(30)
		local stock, time = loadState()
		if stock and time and (time ~= nextRestock) then
			currentStock = stock
			nextRestock = time
			RestockEvent:FireAllClients(currentStock, nextRestock)
		end
	end
end)
ShopEvent.OnServerEvent:Connect(function(plr, toolName)
	if not currentStock[toolName] or currentStock[toolName] <= 0 then game.ReplicatedStorage.Remotes.Notification:FireClient(plr, "Item not in stock.") local errorC = ReplicatedStorage.EffectClients.Error:Clone() errorC.Parent = plr.PlayerGui errorC.Enabled = true game.Debris:AddItem(errorC, 5) return end
	local Knit = require(ReplicatedStorage.Packages.Knit)
	local Data = Knit.GetService("DataService")
	local Profile = Data:GetProfile(plr)

	local price = ToolInfo[toolName].Price
	local InventoryService = Knit.GetService("InventoryService")
	local Inventory = InventoryService:GetInventory(plr)

	local currentCount = InventoryService:GetItemValue(plr,toolName) or 0
	local maxCount = ToolInfo[toolName].MaxTools

	if currentCount >= maxCount then
		game.ReplicatedStorage.Remotes.Notification:FireClient(plr, "You have the maximum amount of "..toolName.." ("..maxCount..")")
	else
		if Profile.Data.Beaks >= price then
			Profile.Data.Beaks -= price
			plr.leaderstats.Beaks.Value = Profile.Data.Beaks
			InventoryService:AddItem(plr, toolName, "Tool", {Amount = 1})
			pcall(function()
				local BuyC = script.Buy:Clone()
				BuyC.Parent = plr.PlayerGui
				BuyC.Enabled = true
				game.Debris:AddItem(BuyC, 5)
			end)
			currentStock[toolName] -= 1
			saveState(currentStock, nextRestock)
			publish(currentStock, nextRestock)
			RestockEvent:FireAllClients(currentStock, nextRestock)
		else
			game.ReplicatedStorage.Remotes.Notification:FireClient(plr, "Not enough Beaks to buy "..toolName)
			pcall(function()
				local errorC = ReplicatedStorage.EffectClients.Error:Clone()
				errorC.Parent = plr.PlayerGui
				errorC.Enabled = true
				game.Debris:AddItem(errorC, 5)
			end)
		end
	end
end)


Players.PlayerAdded:Connect(function(player)
	RestockEvent:FireClient(player, currentStock, nextRestock)
end)

MessagingService:SubscribeAsync("RestockItemGlobal", function(message)
	if message.Data then
		addStock(message.Data)
	end
end)