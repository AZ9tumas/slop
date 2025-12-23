--local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Workspace = game:GetService("Workspace")
--local RunService = game:GetService("RunService")

--local MessagingService = game:GetService("MessagingService")


--local EggSpawnerService = Knit.CreateService {
--	Name = "EggSpawnerService",
--	Client = {}
--}

--local start = Workspace.Map.Points:WaitForChild("Start")
--local End = Workspace.Map.Points:WaitForChild("End")
--local eggFolder = ReplicatedStorage.Game:WaitForChild("Eggs")
--local EggSpawnInfo = require(ReplicatedStorage.Info.EggSpawnInfo)
--local EggInfo = require(ReplicatedStorage.Info.EggInfo)
--local spawnCooldown = EggSpawnInfo.SpawnCooldown

--local EggRarities = EggSpawnInfo.RarityRates

--local pityTimes = EggSpawnInfo.PityTimes
--local pityCounters = {}
--for rarity, timeS in pairs(pityTimes) do
--	pityCounters[rarity] = timeS
--end
--local function rollMutation()
--	local mutations = require(game.ReplicatedStorage.Info.MutationsInfo).SpawnChances
--	local roll = math.random() * 100
--	local cumulative = 0

--	for mutationName, chance in pairs(mutations) do
--		cumulative = cumulative + chance
--		if roll < cumulative then
--			return mutationName
--		end
--	end

--	return nil
--end
--local function getTimerBoard(rarity)
--	local board = Workspace.Map.Unsorted.EggTimerBoard.SurfaceGui.Holder:FindFirstChild(rarity)
--	if board and board:FindFirstChild("Timer") then
--		return board.Timer
--	end
--	return nil
--end

--local function formatTime(seconds)
--	local hrs = math.floor(seconds / 3600)
--	local mins = math.floor((seconds % 3600) / 60)
--	local secs = seconds % 60
--	return string.format("%02d:%02d:%02d", hrs, mins, secs)
--end

--task.spawn(function()
--	while true do
--		task.wait(1)
--		for rarity, counter in pairs(pityCounters) do
--			if pityTimes[rarity] then
--				if counter > 0 then
--					pityCounters[rarity] = counter - 1
--				end
--				local board = getTimerBoard(rarity)
--				if board then
--					board.Text = formatTime(pityCounters[rarity])
--				end
--			end
--		end
--	end
--end)

--local function forceEgg(rarity)
--	local rarityFolder = eggFolder:FindFirstChild(rarity)
--	if rarityFolder and #rarityFolder:GetChildren() > 0 then
--		local eggs = rarityFolder:GetChildren()
--		local chosenEgg = eggs[math.random(1, #eggs)]
--		return chosenEgg:Clone(), rarity
--	end
--	return nil, nil
--end

--local function getRandomEgg()
--	for rarity, counter in pairs(pityCounters) do
--		if pityTimes[rarity] and counter <= 0 then
--			pityCounters[rarity] = pityTimes[rarity]
--			return forceEgg(rarity)
--		end
--	end
--	local mutation = rollMutation()
--	local totalWeight = 0
--	for _, weight in pairs(EggRarities) do
--		totalWeight += weight
--	end

--	local roll = math.random(1, totalWeight)
--	local cumulative = 0
--	local chosenRarity

--	for rarity, weight in pairs(EggRarities) do
--		cumulative += weight
--		if roll <= cumulative then
--			chosenRarity = rarity
--			break
--		end
--	end

--	if chosenRarity then
--		local rarityFolder = eggFolder:FindFirstChild(chosenRarity)
--		if rarityFolder and #rarityFolder:GetChildren() > 0 then
--			local eggs = rarityFolder:GetChildren()
--			local chosenEgg = eggs[math.random(1, #eggs)]
--			return chosenEgg:Clone(), chosenRarity , mutation
--		else
--			warn("No eggs found for rarity: " .. chosenRarity)
--		end
--	end
--	return nil, nil
--end
--local DataService 
--local function moveEgg(egg, eggName, duration,rarity)
--	local function getPivotOffset(model)
--		local primary = model.PrimaryPart
--		local size = model:GetExtentsSize()
--		local cf = model:GetBoundingBox()
--		local bottomY = (cf.Position - Vector3.new(0, size.Y/2, 0)).Y
--		local pivotY = primary.Position.Y
--		return pivotY - bottomY
--	end

--	local startPos = egg.PrimaryPart.Position
--	local endPos = End.Position
--	local totalDistance = (endPos - startPos).Magnitude
--	local moveSpeed = totalDistance / duration
--	local offsetY = getPivotOffset(egg)
--	local eggPrice = EggInfo[eggName].Cost or 150
--	egg.BillboardGui.Price.Text = "$"..eggPrice

--	local hb
--	hb = RunService.Heartbeat:Connect(function(dt)
--		if not egg.Parent then
--			hb:Disconnect()
--			return
--		end

--		local direction = (endPos - egg.PrimaryPart.Position).Unit
--		local distance = moveSpeed * dt
--		local nextPos = egg.PrimaryPart.Position + direction * distance

--		local rayOrigin = nextPos + Vector3.new(0, 50, 0)
--		local rayDirection = Vector3.new(0, -200, 0)
--		local rayParams = RaycastParams.new()
--		rayParams.FilterType = Enum.RaycastFilterType.Include
--		rayParams.FilterDescendantsInstances = {workspace.Map.Unsorted.ConveyorBelt}
--		local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)

--		if result then
--			local groundedPos = Vector3.new(nextPos.X, result.Position.Y + offsetY, nextPos.Z)
--			egg:SetPrimaryPartCFrame(CFrame.new(groundedPos, groundedPos + direction))
--		end

--		if (egg.PrimaryPart.Position - endPos).Magnitude < 4 then
--			hb:Disconnect()
--			egg:Destroy()
--		end
--	end)

--	local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
--	if prompt then
--		prompt.Triggered:Connect(function(player)
--			local profile = DataService:GetProfile(player)
--			if not profile then
--				warn("No profile for player:", player.Name)
--				return
--			end

--			-- check egg price from your EggSpawnInfo (make sure you set prices there)
--			local eggPrice = EggInfo[eggName].Cost or 150
--			if profile.Data.Beaks < eggPrice then
--				warn(player.Name .. " does not have enough Beaks for " .. rarity .. " egg")
--				return
--			end

--			-- deduct cost
--			profile.Data.Beaks -= eggPrice

--			-- give egg tool
--			hb:Disconnect()
--			local InventoryService = Knit.GetService("InventoryService") -- unified service
--			InventoryService:AddItem(player,eggName,1,nil,egg:GetAttribute("Mutation"))
			
--			egg:Destroy()

--			print(player.Name .. " purchased an egg for " .. eggPrice .. " Beaks")
--		end)
--	end
--end

--function EggSpawnerService:KnitStart()
--	DataService = Knit.GetService("DataService")

--	MessagingService:SubscribeAsync("SpawnEggGlobal", function(message)
--		local rarity = message.Data.Rarity
--		local egg, r,m = forceEgg(rarity)
--		if egg then
--			egg.Parent = Workspace
--			egg:SetPrimaryPartCFrame(start.CFrame)
--			egg:SetAttribute("Mutation",m)
--			local purchasePrompt = script.PurchasePrompt:Clone()
--			purchasePrompt.Parent = egg.PrimaryPart
--			purchasePrompt.ObjectText = r.." "..egg.Name.." EG$"
--			if m then
--				local gui = egg.BillboardGui
--				local mutationsImage = gui:FindFirstChild("MutationsLabel")
--				if mutationsImage then
--					mutationsImage[m].Visible = true
--				else
--					mutationsImage = game.ReplicatedStorage.Game.MutationsLabel:Clone()
--					mutationsImage.Parent = egg.BillboardGui
--					mutationsImage[m].Visible = true
--				end
--			end
--			moveEgg(egg, r.." "..egg.Name, EggSpawnInfo.Duration, r)
--			warn("Global spawn: " .. egg.Name .. " (" .. r .. ")")
--		end
--	end)
--	MessagingService:SubscribeAsync("GlobalMessage", function(message)
--		warn("Global Message is ",message)
--		game.ReplicatedStorage.Remotes:WaitForChild("Notification"):FireAllClients(message.Data)
--	end)
--	spawn(function()
--		while true do
--			local egg, rarity,m = getRandomEgg()
--			if egg then
--				egg.Parent = Workspace
--				egg:SetPrimaryPartCFrame(start.CFrame)
--				egg:SetAttribute("Mutation",m)
--				--warn("Spawned " .. egg.Name .. " (" .. rarity .. ")")
--				local purchasePrompt = script.PurchasePrompt:Clone()
--				purchasePrompt.Parent = egg.PrimaryPart
--				purchasePrompt.ObjectText = rarity.." "..egg.Name.." EG$"
--				if m then
--					local gui = egg.BillboardGui
--					local mutationsImage = gui:FindFirstChild("MutationsLabel")
--					if mutationsImage then
--						mutationsImage[m].Visible = true
--					else
--						mutationsImage = game.ReplicatedStorage.Game.MutationsLabel:Clone()
--						mutationsImage.Parent = egg.BillboardGui
--						mutationsImage[m].Visible = true
--					end
--				end
--				moveEgg(egg, rarity.." "..egg.Name, EggSpawnInfo.Duration,rarity)
--			end
--			task.wait(spawnCooldown)
--		end
--	end)
--end

--function EggSpawnerService:SpawnEggEverywhere(rarity)
--	MessagingService:PublishAsync("SpawnEggGlobal", {Rarity = rarity})
--end

--function EggSpawnerService:ExternalSpawn(rarity)
--	local egg, r = forceEgg(rarity)
--	if egg then
--		egg.Parent = Workspace
--		egg:SetPrimaryPartCFrame(start.CFrame)
--		local purchasePrompt = script.PurchasePrompt:Clone()
--		purchasePrompt.Parent = egg.PrimaryPart
--		purchasePrompt.ObjectText = r.." "..egg.Name.." EG$"
--		moveEgg(egg, r.." "..egg.Name, EggSpawnInfo.Duration, r)
--		warn("Gamepass spawn: " .. egg.Name .. " (" .. r .. ")")
--	end
--end
--return EggSpawnerService
