task.wait(2)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

script.Parent.Top.Close.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
end)

local LuckEvent = ReplicatedStorage:WaitForChild("LuckEvent")
local RequestNextLuck = ReplicatedStorage:WaitForChild("RequestNextLuck")
local PurchaseEvent = ReplicatedStorage:WaitForChild("PurchaseEvent")

local textLabel = script.Parent.ScrollingFrame.ServerLuck.Boost
local timeLabel = script.Parent.ScrollingFrame.ServerLuck.Mins
local button = script.Parent.ScrollingFrame.ServerLuck.Buy

local productIds = require(game.ReplicatedStorage.Info:WaitForChild("ProductIds"))

local function FormatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local sec = seconds % 60
	return string.format("%02d:%02d", minutes, sec)
end

local function updateButtonPrice()
	local nextProductId = RequestNextLuck:InvokeServer()
	if nextProductId then
		local success, info = pcall(function()
			return MarketplaceService:GetProductInfo(nextProductId, Enum.InfoType.Product)
		end)
		if success and info then
			button.Price.Text = info.PriceInRobux
			button.Visible = true
		else
			button.Text = "Buy"
		end
	else
		button.Visible = false
	end
end

LuckEvent.OnClientEvent:Connect(function(multiplier, duration)
	textLabel.Text = "x" .. multiplier

	if duration > 0 then
		timeLabel.Text = FormatTime(duration)
	else
		timeLabel.Text = "00:00"
	end

	if multiplier == 8 then
		button.Visible = false
	elseif multiplier == 1 and duration == 0 then
		updateButtonPrice()
		timeLabel.Text = "+15 Minutes"
	end
end)

local function ownsGamePass(player, gamePassId)
	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
	if success then
		return owns
	else
		warn("Failed to check gamepass ownership for player:", player.Name)
		return false
	end
end

PurchaseEvent.OnClientEvent:Connect(function(multiplier, duration)
	print("Purchase applied: x" .. multiplier .. " for " .. duration .. "s")
	updateButtonPrice()
end)

button.MouseButton1Click:Connect(function()
	local nextProductId = RequestNextLuck:InvokeServer()
	if nextProductId then
		MarketplaceService:PromptProductPurchase(player, nextProductId)
	else
		print("No upgrade available")
	end
end)
local suc,info = pcall(function()
	return MarketplaceService:GetProductInfo(productIds.SpawnFirst.Id, Enum.InfoType.Product)
end)

if suc  and info then
	script.Parent.ScrollingFrame.Passes.SpawnSecret.Buy.TitleS.Text = info.PriceInRobux
end

local suc,info = pcall(function()
	return MarketplaceService:GetProductInfo(productIds.SpawnSecond.Id, Enum.InfoType.Product)
end)

if suc and info then
	script.Parent.ScrollingFrame.Passes.SpawnZombified.Buy.TitleS.Text = info.PriceInRobux
end
script.Parent.ScrollingFrame.Passes.SpawnSecret.Buy.MouseButton1Click:Connect(function()
	
	MarketplaceService:PromptProductPurchase(player, productIds.SpawnFirst.Id)
end)
script.Parent.ScrollingFrame.Passes.SpawnZombified.Buy.MouseButton1Click:Connect(function()
	
	MarketplaceService:PromptProductPurchase(player, productIds.SpawnSecond.Id)
end)

local suc,info = pcall(function()
	return MarketplaceService:GetProductInfo(productIds.StarterPack, Enum.InfoType.GamePass)
end)

if suc  and info then
	script.Parent.ScrollingFrame.StarterPack.Buy.TitleS.Text = info.PriceInRobux
end

local suc,info = pcall(function()
	return MarketplaceService:GetProductInfo(productIds.x2Beaks, Enum.InfoType.GamePass)
end)

if suc  and info then
    script.Parent.ScrollingFrame.x2Beaks.Buy.TitleS.Text = info.PriceInRobux
end



local suc,info = pcall(function()
    return MarketplaceService:GetProductInfo(productIds.FlyingCarpet, Enum.InfoType.GamePass)
end)

if suc  and info then
    script.Parent.ScrollingFrame.FlyingCarpet.Buy.TitleS.Text = info.PriceInRobux
end

if ownsGamePass(game.Players.LocalPlayer,productIds.StarterPack) then
	script.Parent.ScrollingFrame.StarterPack.Buy.TitleS.Text = "Owned"
end
if ownsGamePass(game.Players.LocalPlayer,productIds.x2Beaks) then
	script.Parent.ScrollingFrame.x2Beaks.Buy.TitleS.Text = "Owned"
end
script.Parent.ScrollingFrame.x2Beaks.Buy.MouseButton1Click:Connect(function()
	MarketplaceService:PromptGamePassPurchase(player, productIds.x2Beaks)
end)


if ownsGamePass(game.Players.LocalPlayer,productIds.FlyingCarpet) then
    script.Parent.ScrollingFrame.FlyingCarpet.Buy.TitleS.Text = "Owned"
end
script.Parent.ScrollingFrame.FlyingCarpet.Buy.MouseButton1Click:Connect(function()
    MarketplaceService:PromptGamePassPurchase(player, productIds.FlyingCarpet)
end)

-- StarterPack Game Pass purchase button
script.Parent.ScrollingFrame.StarterPack.Buy.MouseButton1Click:Connect(function()
	MarketplaceService:PromptGamePassPurchase(player, productIds.StarterPack)
end)

script.Parent.ScrollingFrame.GravityEgg.Get.MouseButton1Click:Connect(function()
	print("ye ok")
	MarketplaceService:PromptProductPurchase(player, productIds.GravityEgg.Id)
end)

-- BEAK PACKS

for i = 1,3 do
	local suc,info = pcall(function()
		return MarketplaceService:GetProductInfo(productIds["Pack"..i].Id, Enum.InfoType.Product)
	end)

	if suc  and info then
		script.Parent.ScrollingFrame.Coins1["Pack"..i].Buy.TitleS.Text = info.PriceInRobux
	end

	script.Parent.ScrollingFrame.Coins1["Pack"..i].Buy.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(player, productIds["Pack"..i].Id)

	end)
end
for i = 4,5 do
	local suc,info = pcall(function()
		return MarketplaceService:GetProductInfo(productIds["Pack"..i].Id, Enum.InfoType.Product)
	end)

	if suc  and info then
		script.Parent.ScrollingFrame.Coins2["Pack"..i].Buy.TitleS.Text = info.PriceInRobux
	end

	script.Parent.ScrollingFrame.Coins2["Pack"..i].Buy.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(player, productIds["Pack"..i].Id)

	end)
end