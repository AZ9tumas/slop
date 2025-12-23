local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local MessagingService = game:GetService("MessagingService")

local EggSpawnerService = Knit.CreateService {
	Name = "EggSpawnerService",
	Client = {}
}

local start = Workspace.Map.Points:WaitForChild("Start")
local eggFolder = ReplicatedStorage.Game:WaitForChild("Eggs")
local EggSpawnInfo = require(ReplicatedStorage.Info.EggSpawnInfo)
local EggInfo = require(ReplicatedStorage.Info.EggInfo)
local MutationsInfo = require(ReplicatedStorage.Info.MutationsInfo)
local http = game:GetService("HttpService")
local spawnCooldown = EggSpawnInfo.SpawnCooldown
local EggRarities = EggSpawnInfo.RarityRates
local pityTimes = EggSpawnInfo.PityTimes

local pityCounters = {}
for rarity, timeS in pairs(pityTimes) do
	pityCounters[rarity] = timeS
end
local function getTimerBoard(rarity)
	local board = Workspace.Map.Unsorted.EggTimerBoard.SurfaceGui.Holder:FindFirstChild(rarity)
	if board and board:FindFirstChild("Timer") then
		return board.Timer
	end
	return nil
end

function FormatWithCommas(number)
	if type(number) ~= "number" then
		warn("FormatWithCommas expects a number, got", type(number))
		return tostring(number)
	end

	local formatted = tostring(math.floor(number))
	local k

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end

	return formatted
end

local function formatTime(seconds)
	local hrs = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d:%02d", hrs, mins, secs)
end
local DataService
task.spawn(function()
	while true do
		task.wait(1)
		for rarity, counter in pairs(pityCounters) do
			if pityTimes[rarity] then
				if counter > 0 then
					pityCounters[rarity] = counter - 1
				end
				local board = getTimerBoard(rarity)
				if board then
					board.Text = formatTime(pityCounters[rarity])
				end
			end
		end
	end
end)
local mutationTable = {}
do
	local cumulative = 0
	for name, chance in pairs(MutationsInfo.SpawnChances) do
		cumulative += chance
		table.insert(mutationTable, {Name = name, Threshold = cumulative})
	end
end

local function rollMutation()
	local roll = math.random() * 100
	for _, entry in ipairs(mutationTable) do
		if roll < entry.Threshold then
			return entry.Name
		end
	end
	return nil
end

local function forceEgg(rarity)
	local rarityFolder = eggFolder:FindFirstChild(rarity)
	if rarityFolder then
		local eggs = rarityFolder:GetChildren()
		if #eggs > 0 then
			local chosenEgg = eggs[math.random(1, #eggs)]
			return chosenEgg:Clone(), rarity
		end
	end
	return nil, nil
end

local function getAdjustedRarityRates(multiplier)
	local adjusted = {}
	local base = EggRarities
	for rarity, weight in pairs(base) do
		if rarity == "Common" then
			adjusted[rarity] = math.max(1, math.floor(weight / multiplier))
		elseif rarity == "Uncommon" then
			adjusted[rarity] = math.floor(weight * (1 + 0.05 * (multiplier - 1)))
		elseif rarity == "Rare" or rarity == "Epic" or rarity == "Beach" or rarity == "Kingdom" then
			adjusted[rarity] = math.floor(weight * multiplier)
		else
			adjusted[rarity] = math.floor(weight * multiplier * 2)
		end
	end
	return adjusted
end

local function getRandomEgg()
	for rarity, counter in pairs(pityCounters) do
		if pityTimes[rarity] and counter <= 0 then
			pityCounters[rarity] = pityTimes[rarity]
			return forceEgg(rarity)
		end
	end

	local mutation = rollMutation()
	local serverLuck = workspace:GetAttribute("ServerLuck") or 1 * require(game.ReplicatedStorage.Info.ServerLuck).Boost
	local adjustedRates = getAdjustedRarityRates(serverLuck)

	local totalWeight = 0
	for _, weight in pairs(adjustedRates) do
		totalWeight += weight
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	local chosenRarity
	for rarity, weight in pairs(adjustedRates) do
		cumulative += weight
		if roll <= cumulative then
			chosenRarity = rarity
			break
		end
	end

	if chosenRarity then
		if game.ReplicatedStorage.SpawnsCount:FindFirstChild(chosenRarity) then
			game.ReplicatedStorage.SpawnsCount[chosenRarity].Value += 1
		end
		local rarityFolder = eggFolder:FindFirstChild(chosenRarity)
		if rarityFolder then
			local eggs = rarityFolder:GetChildren()
			if #eggs > 0 then
				local chosenEgg = eggs[math.random(1, #eggs)]
				return chosenEgg:Clone(), chosenRarity, mutation, adjustedRates
			end
		end
	end
	return nil, nil, adjustedRates
end

local function setupEgg(egg, rarity, mutation)
    local EggStats = EggInfo[rarity .. " " .. egg.Name]
	egg.Parent = Workspace

	egg:SetPrimaryPartCFrame(start.CFrame)
	egg:SetAttribute("Rarity", rarity)
	egg:SetAttribute("Mutation", mutation)
	egg:SetAttribute("SpawnTime", os.clock())
	egg:SetAttribute("Duration", EggSpawnInfo.Duration)
	egg:SetAttribute("SpawnId",http:GenerateGUID(false))
	game.Debris:AddItem(egg,EggSpawnInfo.Duration)
	local eggPrice = EggInfo[rarity .. " " .. egg.Name] and EggInfo[rarity .. " " .. egg.Name].Cost or 150
	egg:SetAttribute("Price", eggPrice)
	egg:FindFirstChild("BillboardGui").Price.Text = "$"..FormatWithCommas(egg:GetAttribute("Price")) 

	local purchasePrompt = script.PurchasePrompt:Clone()
	purchasePrompt.Parent = egg.PrimaryPart
	purchasePrompt.ObjectText = rarity .. " " .. egg.Name -- .. " EG$"
    purchasePrompt.HoldDuration = EggInfo[rarity .. " " .. egg.Name].HoldDuration or 0.6
    
    if EggStats.SpawnSound then
        local sound = Instance.new("Sound", egg.PrimaryPart or egg.Handle)
        sound.SoundId = EggStats.SpawnSound
        sound.Volume = 2.5
        sound.RollOffMaxDistance = 10000
        sound:Play()
    end
    
	if mutation then
		local gui = egg.BillboardGui
		local mutationsImage = gui:FindFirstChild("MutationsLabel")
		if not mutationsImage then
			mutationsImage = ReplicatedStorage.Game.MutationsLabel:Clone()
			mutationsImage.Parent = gui
		end
		mutationsImage[mutation].Visible = true
		local MutationVFX = ReplicatedStorage.Game.MutationParticles[mutation]:Clone()
		MutationVFX.Parent = egg.PrimaryPart
		MutationVFX.Enabled = true
	end

	local prompt = purchasePrompt
	local prompted = false
	--prompt.Triggered:Connect(function(player)
	--	if prompted then return end
	--	local InventoryService = Knit.GetService("InventoryService")
	--	local profile = DataService:GetProfile(player)
	--	if not profile then return end
	--	if profile.Data.Beaks < eggPrice then return end

	--	local space = InventoryService:AddItem(player, rarity .. " " .. egg.Name, "Egg", {
	--		ID = game:GetService("HttpService"):GenerateGUID(false),
	--		Mutation = mutation
	--	})
	--	if space == true then
	--		prompted = true
	--		profile.Data.Beaks -= eggPrice
	--		player.leaderstats.Beaks.Value = profile.Data.Beaks
	--		egg:Destroy()
	--	else
	--		ReplicatedStorage.Remotes.Notification:FireClient(player, "Egg Inventory is Full")
	--	end
	--end)
end
game.ReplicatedStorage.Remotes:WaitForChild("BuyEgg").OnServerEvent:Connect(function(player, egg)
	local Fegg 
	for i,v in pairs(workspace:GetChildren()) do
		if v:GetAttribute("SpawnId") == egg then
			Fegg = v
		end
	end
	egg = Fegg
	if not egg or not egg.Parent then return end
	local profile = DataService:GetProfile(player)
	if not profile then return end
	local eggPrice = egg:GetAttribute("Price") or 150
	if profile.Data.Beaks < eggPrice then
        ReplicatedStorage.Remotes.Notification:FireClient(player, "Not enough Beaks", Color3.new(1, 0, 0))
		player.PlayerGui.MainUI.Frames.Store.Visible = false
		player.PlayerGui.MainUI.Frames.Store.Visible = true
		local errorC = ReplicatedStorage.EffectClients.Error:Clone()
		errorC.Parent = player.PlayerGui
		errorC.Enabled = true
		game.Debris:AddItem(errorC, 5)
		return
    end
    
    
    
	_G.AddAchiev(player,{"Buy",egg:GetAttribute("Rarity")},1)

	if egg:GetAttribute("Mutation") == "Golden" then
		_G.AddAchiev(player,{"GoldenMutation"},1)
	end
	
	if egg:GetAttribute("Mutation") == "Rainbow" then
		_G.AddAchiev(player,{"RainbowMutation"},1)
	end
	


	local InventoryService = Knit.GetService("InventoryService")
	local mutation = egg:GetAttribute("Mutation")
	local space = InventoryService:AddItem(player, egg:GetAttribute("Rarity").." "..egg.Name, "Egg", {
		ID = game:GetService("HttpService"):GenerateGUID(false),
		Mutation = mutation
	})
	if space then
		profile.Data.Beaks -= eggPrice
        player.leaderstats.Beaks.Value = profile.Data.Beaks
        profile.Data.EggsBought = (profile.Data.EggsBought or 0) + 1
        local TS = game:GetService("TweenService")
        task.spawn(function()
        for _,d in ipairs(egg:GetDescendants()) do
            if d:IsA("BasePart") then
                d.CanCollide = false
                TS:Create(d, TweenInfo.new(0.2), {
                    Size = d.Size * 1.65,
                    Transparency = 1
                }):Play()
            elseif d:IsA("ProximityPrompt") then
                d.Enabled = false
            elseif d:IsA("BillboardGui") then
                d.Enabled = false
            
            
            end
        end
        wait(0.2)
        egg:Destroy()
        end)
		--game.ReplicatedStorage.Remotes.SuperNotification:FireClient(player,"rbxassetid://79192961641227","Purchase", "Bought a "..egg:GetAttribute("Rarity").." Egg")
		local sound = game.ReplicatedStorage.Game.BoughtEgg:Clone()
		sound.Parent = player.Character.PrimaryPart
		sound:Play()
	else
		local errorC = ReplicatedStorage.EffectClients.Error:Clone()
		errorC.Parent = player.PlayerGui
		errorC.Enabled = true
		game.Debris:AddItem(errorC, 5)
        ReplicatedStorage.Remotes.Notification:FireClient(player, "Egg Inventory is Full", Color3.new(1, 0, 0))
	end
end)
function EggSpawnerService:KnitStart()
	DataService = Knit.GetService("DataService")

	MessagingService:SubscribeAsync("SpawnEggGlobal", function(message)
		local rarity = message.Data.Rarity
		local egg, r, m = forceEgg(rarity)
		if egg then
            ReplicatedStorage.Remotes:WaitForChild("Notification"):FireAllClients(rarity .. " Egg Was spawned by an admin!", Color3.new(0.403922, 0.0980392, 0.776471))
			setupEgg(egg, r, m)
		end
	end)

	MessagingService:SubscribeAsync("GlobalMessage", function(message)
		ReplicatedStorage.Remotes:WaitForChild("Notification"):FireAllClients(message.Data)
	end)

	task.spawn(function()
		while true do
			local egg, rarity, m = getRandomEgg()
			if egg then
				setupEgg(egg, rarity, m)
			end
			task.wait(spawnCooldown)
		end
	end)
end

function EggSpawnerService:SpawnEggEverywhere(rarity)
	MessagingService:PublishAsync("SpawnEggGlobal", {Rarity = rarity})
end

function EggSpawnerService:ExternalSpawn(rarity)
	local egg, r = forceEgg(rarity)
	if egg then
		setupEgg(egg, r, nil)
	end
end

return EggSpawnerService
