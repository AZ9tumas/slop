local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopEvent = Remotes:WaitForChild("BuyTool")

local ToolInfo = require(ReplicatedStorage.Info.ToolInfo)

local RestockEvent = Instance.new("RemoteEvent")
RestockEvent.Name = "RestockEvent"
RestockEvent.Parent = Remotes

local RESTOCK_TIME = 300
local currentStock = {}
local nextRestock = 0
local currentStockId = HttpService:GenerateGUID(false)

local stockStore = MemoryStoreService:GetSortedMap("GlobalShopStock_231")
local timeStore = MemoryStoreService:GetSortedMap("GlobalShopTimer_231")
local purchasedStore = MemoryStoreService:GetSortedMap("GlobalShopPurchases_231")

local HTTP = game:GetService("HttpService")

local webhook = "https://webhook.lewisakura.moe/api/webhooks/1426535606032269332/0IQ7eRmPyM6-DSk8QF25qRONN3IUVwQDNzMOcAI_6d0ULRpwiA3kGplvgEy2bqzTVnug"



local playerPurchases = {}

local function getPlayerStock(userId)
    local personalStock = {}
    local cache = playerPurchases[userId] and playerPurchases[userId][currentStockId]
    for toolName, amount in pairs(currentStock) do
        local bought = cache and cache[toolName] or 0
        personalStock[toolName] = math.max(amount - bought, 0)
    end
    return personalStock
end

local function loadPlayerPurchases(userId)
    playerPurchases[userId] = playerPurchases[userId] or {}
    playerPurchases[userId][currentStockId] = playerPurchases[userId][currentStockId] or {}
    local cache = playerPurchases[userId][currentStockId]

    for toolName in pairs(currentStock) do
        local key = userId .. "_" .. currentStockId .. "_" .. toolName
        local bought = 0
        pcall(function()
            bought = purchasedStore:GetAsync(key) or 0
        end)
        cache[toolName] = bought
    end
end

local function recordPurchase(userId, toolName, amount)
    playerPurchases[userId] = playerPurchases[userId] or {}
    playerPurchases[userId][currentStockId] = playerPurchases[userId][currentStockId] or {}
    local cache = playerPurchases[userId][currentStockId]
    cache[toolName] = (cache[toolName] or 0) + amount

    local purchaseKey = userId .. "_" .. currentStockId .. "_" .. toolName
    --[[pcall(function()
        purchasedStore:SetAsync(purchaseKey, cache[toolName], RESTOCK_TIME + 30)
    end)]]
end


local function generateStock()
    local stock = {}
    for toolName, toolData in pairs(ToolInfo) do
        if toolData.StockChance and math.random(1, 100) <= toolData.StockChance then
            local minAmt, maxAmt = toolData.StockAmount[1], toolData.StockAmount[2]
            stock[toolName] = math.random(minAmt, maxAmt)
        else
            stock[toolName] = 0
        end
    end
    return stock
end

local function saveState(stock, nextTime, stockId)
    pcall(function()
        stockStore:SetAsync("Stock", stock, RESTOCK_TIME + 30)
        timeStore:SetAsync("Next", nextTime, RESTOCK_TIME + 30)
        timeStore:SetAsync("StockId", stockId, RESTOCK_TIME + 30)
    end)
end

local function loadState()
    local stock, time, stockId
    pcall(function()
        stock = stockStore:GetAsync("Stock")
        time = timeStore:GetAsync("Next")
        stockId = timeStore:GetAsync("StockId")
    end)
    return stock, time, stockId
end

local function publish(stock, nextTime, stockId)
    pcall(function()
        MessagingService:PublishAsync("GlobalShopChannel", {
            stock = stock,
            next = nextTime,
            stockId = stockId
        })
    end)
end

local function getNextAlignedRestock()
    local now = game.ReplicatedStorage.CurrentTime.Value
    return now - (now % RESTOCK_TIME) + RESTOCK_TIME
end

local function restock(DoNotifi)
    currentStock = generateStock()
    nextRestock = getNextAlignedRestock()
    currentStockId = HttpService:GenerateGUID(false)
    saveState(currentStock, nextRestock, currentStockId)
    publish(currentStock, nextRestock, currentStockId)
    for _, Player in game.Players:GetChildren() do
        if Player:IsA("Player") then
            local pStock = getPlayerStock(tostring(Player.UserId))
            RestockEvent:FireClient(Player, pStock, nextRestock, currentStockId)
        end
    end

    if DoNotifi then
        -- Only notify if stock actually changed
        ReplicatedStorage.Remotes.Notification:FireAllClients("Gear shop has been restocked.")
    end
end


MessagingService:SubscribeAsync("GlobalShopChannel", function(message)
    local data = message.Data
    if not data then return end
    currentStock = data.stock or {}
    nextRestock = data.next or getNextAlignedRestock()
    currentStockId = data.stockId or HttpService:GenerateGUID(false)
    for _, Player in game.Players:GetChildren() do
        if Player:IsA("Player") then
            local pStock = getPlayerStock(tostring(Player.UserId))
            RestockEvent:FireClient(Player, pStock, nextRestock, currentStockId)
        end
    end
end)

task.spawn(function()
    local stock, time, stockId = loadState()
    if stock and time and game.ReplicatedStorage.CurrentTime.Value < time then
        currentStock = stock
        nextRestock = time
        currentStockId = stockId or HttpService:GenerateGUID(false)
        for _, Player in game.Players:GetChildren() do
            if Player:IsA("Player") then
                local pStock = getPlayerStock(tostring(Player.UserId))
                RestockEvent:FireClient(Player, pStock, nextRestock, currentStockId)
            end
        end
    else
        restock(false)
    end

    while true do
        local success, err = pcall(function()
            local waitTime = nextRestock - game.ReplicatedStorage.CurrentTime.Value
            if waitTime < 0 then
                waitTime = 0
                nextRestock = getNextAlignedRestock()
            end

            task.wait(waitTime)
            restock(true)
        end)

        if not success then
            warn("[Restock Loop Error]", err)
            task.wait(2) -- avoid runaway loop
        end
    end

end)


--[[task.spawn(function()
    local lastStockId = currentStockId
    while true do
        task.wait(64 * 2)
        local stock, time, stockId = loadState()
        if stockId and stockId ~= lastStockId then
            currentStock = stock
            nextRestock = time
            currentStockId = stockId
            lastStockId = stockId

            for _, player in ipairs(Players:GetPlayers()) do
                local pStock = getPlayerStock(tostring(player.UserId))
                RestockEvent:FireClient(player, pStock, nextRestock, currentStockId)
            end
        end
    end
end)]]


ShopEvent.OnServerEvent:Connect(function(plr, toolName)
    local userId = tostring(plr.UserId)

    -- 🔒 Validate tool
    if not ToolInfo[toolName] then
        return
    end

    -- 🔒 Check GLOBAL stock exists
    if not currentStock[toolName] or currentStock[toolName] <= 0 then
        game.ReplicatedStorage.Remotes.Notification:FireClient(
            plr, "Item not in stock.", Color3.new(1, 0, 0)
        )

        if ToolInfo[toolName].BoughtWithRobux then
            game:GetService("MarketplaceService"):PromptProductPurchase(
                plr, ToolInfo[toolName].ID
            )
        end

        local pStock = getPlayerStock(userId)
        RestockEvent:FireClient(plr, pStock, nextRestock, currentStockId)
        return
    end

    -- 🔒 CHECK PLAYER-LIMITED STOCK (THIS WAS THE BUG)
    local pStock = getPlayerStock(userId)
    if not pStock[toolName] or pStock[toolName] <= 0 then
        game.ReplicatedStorage.Remotes.Notification:FireClient(
            plr, "Item not in stock.", Color3.new(1, 0, 0)
        )

        if ToolInfo[toolName].BoughtWithRobux then
            game:GetService("MarketplaceService"):PromptProductPurchase(
                plr, ToolInfo[toolName].ID
            )
        end

        RestockEvent:FireClient(plr, pStock, nextRestock, currentStockId)
        return
    end

    -- 🏆 Achievement (safe to keep here)
    _G.AddAchiev(plr, {toolName}, 1)

    -- 💰 Currency check
    local Knit = require(ReplicatedStorage.Packages.Knit)
    local Data = Knit.GetService("DataService")
    local Profile = Data:GetProfile(plr)
    local price = ToolInfo[toolName].Price

    if Profile.Data.Beaks < price then
        game.ReplicatedStorage.Remotes.Notification:FireClient(
            plr, "Not enough Beaks to buy " .. toolName, Color3.new(1, 0, 0)
        )
        return
    end

    -- ✅ COMMIT PURCHASE (ORDER MATTERS)
    Profile.Data.Beaks -= price
    plr.leaderstats.Beaks.Value = Profile.Data.Beaks

    recordPurchase(userId, toolName, 1)

    local InventoryService = Knit.GetService("InventoryService")
    InventoryService:AddItem(plr, toolName, "Tool", { Amount = 1 })

    -- 🔁 Send updated stock once
    local newStock = getPlayerStock(userId)
    RestockEvent:FireClient(plr, newStock, nextRestock, currentStockId)
end)


Players.PlayerAdded:Connect(function(player)
    local userId = tostring(player.UserId)
    loadPlayerPurchases(userId)
    task.wait()
    local pStock = getPlayerStock(userId)
    RestockEvent:FireClient(player, pStock, nextRestock, currentStockId)
end)


MessagingService:SubscribeAsync("RestockItemGlobal", function(message)
    if message.Data then
        local toolName = message.Data
        if ToolInfo[toolName] then
            currentStock[toolName] = (currentStock[toolName] or 0) + 1
            saveState(currentStock, nextRestock, currentStockId)
            publish(currentStock, nextRestock, currentStockId)
            for _, Player in game.Players:GetChildren() do
                if Player:IsA("Player") then
                    local pStock = getPlayerStock(tostring(Player.UserId))
                    RestockEvent:FireClient(Player, pStock, nextRestock, currentStockId)
                end
            end
            ReplicatedStorage.Remotes.Notification:FireAllClients(toolName .. " Got restocked in the gear shop.")
        end
    end
end)
