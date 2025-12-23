--local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
--local ReplicatedStorage = game:GetService("ReplicatedStorage")

--local PigeonService = Knit.CreateService {
--	Name = "PigeonService",
--	Client = {
--	}
--}
--local OfflineCollection = require(ReplicatedStorage.Info:WaitForChild("NewOfflineCollection"))
--local Beaks = require(ReplicatedStorage.Info:WaitForChild("NewBeaksInfo"))
--local EggModule = require(ReplicatedStorage.Info:WaitForChild("EggInfo"))
--local PigeonInfo = require(ReplicatedStorage.Info:WaitForChild("PigeonInfo"))
--local MutationInfo = require(ReplicatedStorage.Info:WaitForChild("MutationsInfo"))
--local FriendBoostInfo = require(ReplicatedStorage.Info:WaitForChild("FriendBoostInfo"))

--local pigeonFolder = ReplicatedStorage.Game:WaitForChild("Pigeons")
--local PlotService
--local DataService

--local Pigeons = {}
--local Remote = Instance.new("RemoteEvent")
--Remote.Name = "PigeonCollected"
--Remote.Parent = ReplicatedStorage.Remotes

---- Helper to play idle animation on a rigged pigeon
--local function playIdleAnimation(pigeonModel)
--	if not pigeonModel.PrimaryPart then return end

--	-- find Humanoid or AnimationController
--	local humanoid = pigeonModel:FindFirstChildOfClass("Humanoid")
--	local controller = pigeonModel:FindFirstChildOfClass("AnimationController")

--	if not humanoid and not controller then
--		controller = Instance.new("AnimationController")
--		controller.Name = "PigeonAnimController"
--		controller.Parent = pigeonModel
--	end

--	local animator = (humanoid and humanoid:FindFirstChildOfClass("Animator"))
--		or (controller and controller:FindFirstChildOfClass("Animator"))

--	if not animator then
--		animator = Instance.new("Animator")
--		animator.Parent = humanoid or controller
--	end

--	-- load the idle animation
--	local anim = Instance.new("Animation")
--	anim.AnimationId = "rbxassetid://106018986813285"

--	local track = animator:LoadAnimation(anim)
--	track.Looped = true
--	track:Play()
--end


--local function pickPigeonFromEgg(eggName, boost)
--	local eggInfo = EggModule[eggName]
--	if not eggInfo or not eggInfo.Pigeons then
--		return nil, nil, nil
--	end

--	local serverLuck = workspace:GetAttribute("ServerLuck") or 1
--	local boostMultiplier = 1 + ((boost or 0) * 0.1)
--	if boost then
--		warn("Luck Boost Applied of "..(10 * boost).."%")
--	end
--	local effectiveLuck = serverLuck * boostMultiplier

--	local totalChance = 0
--	local chances = {}
--	for _, entry in ipairs(eggInfo.Pigeons) do
--		local adjustedChance = math.max(1, math.floor(entry.Chance * effectiveLuck))
--		table.insert(chances, adjustedChance)
--		totalChance += adjustedChance
--	end

--	local rand = math.random(1, totalChance)
--	local cumulative = 0
--	local pickedEntry = nil
--	for i, entry in ipairs(eggInfo.Pigeons) do
--		cumulative += chances[i]
--		if rand <= cumulative then
--			pickedEntry = entry
--			break
--		end
--	end

--	if not pickedEntry then
--		return nil, nil, nil
--	end

--	local pigeonName = pickedEntry.Name
--	local baseWeight = pickedEntry.Weight
--	local baseChance = pickedEntry.Chance



--	return pigeonName, baseWeight, baseChance
--end







--local function rollMutation()
--	local totalChance = 0
--	for _, info in pairs(MutationInfo) do
--		totalChance += info.Chance
--	end
--	local roll = math.random() * totalChance
--	local cumulative = 0
--	for name, info in pairs(MutationInfo) do
--		cumulative += info.Chance
--		if roll <= cumulative then
--			return name
--		end
--	end
--	return nil
--end

--local function getModelCenter(model)
--	if not model then return nil end
--	local cf, _ = model:GetBoundingBox()
--	return cf.Position
--end

--local function isNear(player, pigeonModel, range)
--	local character = player.Character
--	if not character or not character.PrimaryPart then return false end

--	local center = getModelCenter(pigeonModel)
--	if not center then return false end

--	local distance = (character.PrimaryPart.Position - center).Magnitude
--	return distance <= (range or 10)
--end

--function PigeonService:TryCollectNearby(player, range)
--	local pigeons = Pigeons[player.UserId]
--	if not pigeons then return end

--	for _, pigeon in ipairs(pigeons) do
--		if (pigeon.EarnedBeaks or 0) > 0 and pigeon.Model and isNear(player, pigeon.Model, range or 2) then
--			local earned = pigeon.EarnedBeaks
--			local profile = DataService:GetProfile(player)
--			if profile then
--				profile.Data.Beaks += earned
--				if profile.Data.Gamepasses.x2Beaks == true then
--					profile.Data.Beaks += earned
--				end
--				pigeon.EarnedBeaks = 0

--				if pigeon.Model:FindFirstChild("PigeonBillboard") then
--					pigeon.Model.PigeonBillboard.SavedMoney.Amount.Text = "0"
--				end

--				Remote:FireClient(player, earned, getModelCenter(pigeon.Model))
--			end
--		end
--	end
--end
--local Players = game:GetService("Players")

--local function IsFriendInGame(player)
--	if not player or not player:IsA("Player") then
--		return false
--	end

--	for _, otherPlayer in ipairs(Players:GetPlayers()) do
--		if otherPlayer ~= player then
--			if player:IsFriendsWith(otherPlayer.UserId) then
--				return true, otherPlayer
--			end
--		end
--	end

--	return false, nil
--end
--function PigeonService:KnitStart()
--	PlotService = Knit.GetService("PlotService")
--	DataService = Knit.GetService("DataService")

--	task.spawn(function()
--		while true do
--			for userId, pigeonList in pairs(Pigeons) do
--				local player = game.Players:GetPlayerByUserId(userId)
--				if player then
--					local profile = DataService:GetProfile(player)
--					if profile then
--						player.leaderstats.Beaks.Value = profile.Data.Beaks
--						local totalGain = 0
--						for _, pigeon in ipairs(pigeonList) do
--							local info = PigeonInfo[pigeon.Name]
--							if info then
--								local rate = Beaks:GetBeaksPerSecond(pigeon.Weight, info)
--								if pigeon.Mutation then
--									rate *= MutationInfo.Multipliers[pigeon.Mutation]
--								end
--								if IsFriendInGame(player) then
--									rate *= FriendBoostInfo.MoneyMultiplier
--								end
--								pigeon.EarnedBeaks = (pigeon.EarnedBeaks or 0) + rate
--								totalGain += rate
--								if pigeon.Model and pigeon.Model:FindFirstChild("PigeonBillboard") then
--									local board = pigeon.Model.PigeonBillboard
--									board.SavedMoney.Amount.Text = tostring(math.floor(pigeon.EarnedBeaks))
--									board.AmountPerSecond.Text = string.format("%.1f $/s", rate)
--								end
--							end
--						end
--						if totalGain > 0 then
--							--warn("[ONLINE FARMING]", player.Name, "earned", math.floor(totalGain), "Beaks this tick")
--						end
--					end
--				end
--			end
--			task.wait(1)
--		end
--	end)

--	task.spawn(function()
--		while true do
--			for _, player in ipairs(game.Players:GetPlayers()) do
--				self:TryCollectNearby(player, 5)
--			end
--			task.wait(0.5)
--		end
--	end)
--end

--local function addMutationVisual(pigeonModel, mutationName)
--	if not pigeonModel or not mutationName then return end

--	-- find largest BasePart in model
--	local largestPart
--	local largestSize = 0
--	for _, descendant in ipairs(pigeonModel:GetDescendants()) do
--		if descendant:IsA("BasePart") then
--			local size = descendant.Size.X * descendant.Size.Y * descendant.Size.Z
--			if size > largestSize then
--				largestSize = size
--				largestPart = descendant
--			end
--		end
--	end

--	if not largestPart then return end

--	-- clone the particle emitter from ReplicatedStorage
--	local emitterTemplate = ReplicatedStorage.Game.MutationParticles:FindFirstChild(mutationName)
--	if not emitterTemplate then
--		warn("No particle emitter found for mutation:", mutationName)
--		return
--	end

--	-- prevent duplicates
--	if largestPart:FindFirstChild("MutationEmitter") then
--		largestPart.MutationEmitter:Destroy()
--	end

--	local emitter = emitterTemplate:Clone()
--	emitter.Name = "MutationEmitter"
--	emitter.Parent = largestPart
	
--	emitter.Enabled = true
--end
--local function getModelSize(model)
--	local size = Vector3.new(0,0,0)
--	for _, part in ipairs(model:GetDescendants()) do
--		if part:IsA("BasePart") then
--			size = Vector3.new(
--				math.max(size.X, part.Size.X),
--				math.max(size.Y, part.Size.Y),
--				math.max(size.Z, part.Size.Z)
--			)
--		end
--	end
--	return size
--end
--local function getScale(weight)
--	local minWeight, maxWeight = 20, 200
--	local minScale, maxScale = 0.15, 0.252

--	if weight < minWeight then
--		weight = minWeight
--	elseif weight > maxWeight then
--		weight = maxWeight
--	end

--	return minScale + ((weight - minWeight) / (maxWeight - minWeight)) * (maxScale - minScale)
--end
--function PigeonService:RewardPigeon(player, egg)
--	local plot = PlotService:GetPlayerPlot(player)
--	if not plot then return end

--	local pigeonName, baseWeight,chance = pickPigeonFromEgg(egg.Rarity.." Egg",egg.LuckBoost)
--	local rolledMutation = egg.PreMutation
--	if not pigeonName then return end

--	local template = pigeonFolder:FindFirstChild(pigeonName)
--	if not template then return end

--	local info = PigeonInfo[pigeonName]
--	local rolledWeight = baseWeight
--	if info and info.Weight then
--		local factor = math.random() * (info.Weight.Max - info.Weight.Min) + info.Weight.Min
--		rolledWeight = math.floor(baseWeight * factor * 100) / 100
--	end

--	if egg.SizeBoost then
--		warn("Luck Boost Applied of "..10*egg.SizeBoost.."%")
--		rolledWeight = math.floor(rolledWeight * (1 + egg.SizeBoost * 0.1) * 100) / 100
--	end
--	local mutation
--	if egg.PreMutation then
--		mutation =  egg.PreMutation
--	else
--		mutation = rolledMutation
--	end
	
	
	
	
--	local clone = template:Clone()
--	clone.Parent = plot:FindFirstChild("Pigeons") or Instance.new("Folder", plot)
--	local scale = getScale(rolledWeight)
--	if clone.Name ~= "Pigeon" then
--		clone:ScaleTo(scale)
--	end
--	local relativeCFrame = CFrame.new(unpack(egg.Position))
--	local plotRoot = plot.Model:FindFirstChild("Floor").Part
--	local worldCFrame = plotRoot.CFrame:ToWorldSpace(relativeCFrame)
--	local function getPivotOffset(model)
--		local primary = model.PrimaryPart
--		local size = model:GetExtentsSize()
--		local cf = model:GetBoundingBox()
--		local bottomY = (cf.Position - Vector3.new(0, size.Y/2, 0)).Y
--		local pivotY = primary.Position.Y
--		return pivotY - bottomY
--	end
--	-- Cast a short ray downward from the model pivot to detect the floor
--	local rayOrigin = worldCFrame.Position + Vector3.new(0, 5, 0) -- slightly above
--	local rayDirection = Vector3.new(0, -10, 0) -- short downward ray
--	local rayParams = RaycastParams.new()
--	rayParams.FilterType = Enum.RaycastFilterType.Include
--	rayParams.FilterDescendantsInstances = {plotRoot}
--	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
--	local offsetY = getPivotOffset(clone)

--	if result then
--		worldCFrame = CFrame.new(Vector3.new(worldCFrame.Position.X, result.Position.Y + offsetY, worldCFrame.Position.Z)) * CFrame.Angles(worldCFrame:ToEulerAnglesXYZ())
--	end

--	if clone.PrimaryPart then
--		clone:SetPrimaryPartCFrame(worldCFrame)
--	else
--		clone:PivotTo(worldCFrame)
--	end

	
--	--createDebugPart(previewCFrame.Position, Color3.fromRGB(0, 0, 255))
	

--	--local relativeCFrame = CFrame.new(unpack(egg.Position))
--	--local plotRoot = plot.Model:FindFirstChild("Floor").Part
--	--local worldCFrame = plotRoot.CFrame:ToWorldSpace(relativeCFrame)
--	--if clone.PrimaryPart then
--	--	clone:SetPrimaryPartCFrame(previewCFrame)
--	--end
	
--	if mutation then
--		addMutationVisual(clone, mutation)
--	end
--	local board = ReplicatedStorage.Game.PigeonBillboard:Clone()
--	board.Parent = clone
--	board.Adornee = clone:WaitForChild("Head")
--	local mutationText = mutation and (" ("..mutation..")") or ""
--	board.PigeonName.Text = pigeonName.." ["..rolledWeight.."Kg]"..mutationText
--	board.AmountPerSecond.Text = info.Multiplier.." $/s"
--	board.SavedMoney.Amount.Text = "0"
--	if mutation then
--		if board.Mutations[mutation] then
--			board.Mutations[mutation].Visible = true
--		end
--	end
	
--	playIdleAnimation(clone)
--	clone:SetAttribute("Owner",player.UserId)
--	clone:SetAttribute("PigeonID",egg.ID)

--	Pigeons[player.UserId] = Pigeons[player.UserId] or {}
--	table.insert(Pigeons[player.UserId], {
--		ID = egg.ID,
--		Name = pigeonName,
--		Rarity = egg.Rarity,
--		RelativeCFrame = egg.Position,
--		Weight = rolledWeight,
--		EarnedBeaks = 0,
--		Model = clone,
--		Mutation = mutation
--	})

--	local profile = DataService:GetProfile(player)
--	if profile then
--		profile.Data.PlacedPigeons = profile.Data.PlacedPigeons or {}
--		table.insert(profile.Data.PlacedPigeons, {
--			ID = egg.ID,
--			Name = pigeonName,
--			Rarity = egg.Rarity,
--			RelativeCFrame = egg.Position,
--			Weight = rolledWeight,
--			EarnedBeaks = 0,
--			Mutation = mutation
--		})
--		profile.Data.Unlocked = profile.Data.Unlocked or {}
--		profile.Data.Unlocked[pigeonName] = true
--	end
--end
--function PigeonService:StorePigeon(player, pigeonId)
--	local pigeons = Pigeons[player.UserId]
--	if not pigeons then return false, "No pigeons found" end

--	-- find pigeon by ID
--	local indexToRemove
--	local pigeonData
	
--	for i, pigeon in ipairs(pigeons) do
--		if pigeon.ID == pigeonId then
--			indexToRemove = i
--			pigeonData = pigeon
--			break
--		end
--	end
	
--	if not indexToRemove then
--		return false, "Pigeon not found"
--	end

--	-- delete model if exists
--	if pigeonData.Model and pigeonData.Model.Parent then
		
--		pigeonData.Model:Destroy()
--	end
--	pigeonData.Model = nil
--	-- remove from in-memory list
--	table.remove(pigeons, indexToRemove)
--	local inventoryService = Knit.GetService("InventoryService")
--	inventoryService:AddItem(player,pigeonData.Name,1,pigeonData)
--	-- update profile save data
--	local profile = DataService:GetProfile(player)
--	if profile then
--		if profile.Data.PlacedPigeons then
--			for i, saved in ipairs(profile.Data.PlacedPigeons) do
--				if saved.ID == pigeonId then
--					table.remove(profile.Data.PlacedPigeons, i)
--					break
--				end
--			end
--		end
--		self:SavePigeons(player, profile)
--	end

--	print("[PIGEON STORED]", player.Name, "stored pigeon:", pigeonData.Name, pigeonData.ID)
--	return true, pigeonData
--end
--local function serializeCFrame(cf)
--	return {cf:GetComponents()}
--end
--function PigeonService:PlacePigeon(player, pigeonData, position)
	
--	local plot = PlotService:GetPlayerPlot(player)
--	if not plot then
--		return false, "No plot"
--	end

--	local template = pigeonFolder:FindFirstChild(pigeonData.Name)
--	if not template then
--		return false, "No pigeon template for ".. tostring(pigeonData.Name)
--	end
	
--	local clone = template:Clone()
--	clone.Parent = plot:FindFirstChild("Pigeons") or Instance.new("Folder", plot)
--	local scale = getScale(pigeonData.Weight)
--	if pigeonData.Name ~= "Pigeon" then
--		clone:ScaleTo(scale)
--	end
--	-- world position from plot + given relative/absolute position
--	clone:SetPrimaryPartCFrame(position)
--	-- attributes for tracking
--	clone:SetAttribute("Owner", player.UserId)
--	clone:SetAttribute("PigeonID", pigeonData.ID)

--	-- billboard
--	local info = PigeonInfo[pigeonData.Name]
--	local board = ReplicatedStorage.Game.PigeonBillboard:Clone()
--	board.Adornee = clone:WaitForChild("Head")
--	board.Parent = clone
--	board.PigeonName.Text = pigeonData.Name.." ["..(pigeonData.Weight or "?").."Kg]"
--	board.AmountPerSecond.Text = (info and info.Multiplier or "?").." $/s"
--	board.SavedMoney.Amount.Text = tostring(math.floor(pigeonData.EarnedBeaks or 0))
--	if pigeonData.Mutation then
--		if board.Mutations[pigeonData.Mutation] then
--			board.Mutations[pigeonData.Mutation].Visible = true
--		end
--	end
--	-- visuals
--	if pigeonData.Mutation then
--		addMutationVisual(clone, pigeonData.Mutation)
--	end
--	playIdleAnimation(clone)
--	local plotRoot = plot.Model:FindFirstChild("Floor").Part
--	local relativeCFrame = plotRoot.CFrame:ToObjectSpace(position)
--	-- register in memory
--	Pigeons[player.UserId] = Pigeons[player.UserId] or {}
--	table.insert(Pigeons[player.UserId], {
--		ID = pigeonData.ID,
--		Name = pigeonData.Name,
--		Rarity = pigeonData.Rarity,
--		RelativeCFrame = {relativeCFrame:GetComponents()},
--		Weight = pigeonData.Weight,
--		EarnedBeaks = pigeonData.EarnedBeaks or 0,
--		Model = clone,
--		Mutation = pigeonData.Mutation
--	})

--	-- save into profile
--	local profile = DataService:GetProfile(player)
--	if profile then
--		profile.Data.PlacedPigeons = profile.Data.PlacedPigeons or {}
--		table.insert(profile.Data.PlacedPigeons, {
--			ID = pigeonData.ID,
--			Name = pigeonData.Name,
--			Rarity = pigeonData.Rarity,
--			RelativeCFrame = {relativeCFrame:GetComponents()},
--			Weight = pigeonData.Weight,
--			EarnedBeaks = pigeonData.EarnedBeaks or 0,
--			Mutation = pigeonData.Mutation
--		})
--	end

--	return true, clone
--end

--function PigeonService:PlaceFromInventory(player, pigeonId, position)
	
--	local inv = Knit.GetService("InventoryService")
--	local uniques = inv:GetUniquePigeons(player)
--	if not uniques then
		
--		return false, "No pigeons in inventory"
--	end

	
--	local pigeonData

--	-- find the pigeon by ID
	
--	local pigeonData = uniques[pigeonId]
--	local pigeonIndex = table.find(uniques,pigeonId)
--	if not pigeonData then
--		return false, "Pigeon not found"
--	end

--	local success, clone = PigeonService:PlacePigeon(player, pigeonData, position)
--	if success then
--		warn("inventory placing pigeon with model? ",pigeonData)
--		table.remove(uniques, pigeonIndex) -- remove it from inventory
--		local InventoryService = Knit.GetService("InventoryService")
--		InventoryService:RemoveItem(player,pigeonData.Name,1,pigeonData.ID)
--		local profile = DataService:GetProfile(player)
--		if profile then
--			inv:SaveInventory(player, profile)
--		end
--	end
--	return success, clone
--end
--local HttpService = game:GetService("HttpService")
--local function newId()
--	return HttpService:GenerateGUID(false)
--end

--function PigeonService:StealPigeon(thief, pigeonId)
--	local ownerUserId
--	local pigeonData
--	local pigeonIndex
--	for uid, list in pairs(Pigeons) do
--		for i, pd in ipairs(list) do
--			if pd.ID == pigeonId then
--				ownerUserId = uid
--				pigeonData = pd
--				pigeonIndex = i
--				break
--			end
--		end
--		if ownerUserId then break end
--	end
--	if not pigeonData then return false, "Pigeon not found" end
--	if ownerUserId == thief.UserId then return false, "Cannot steal your own pigeon" end
--	if pigeonData.Model and pigeonData.Model.Parent then
--		pigeonData.Model:Destroy()
--	end
--	local cloneData = table.clone(pigeonData)
--	cloneData.ID = newId()
--	cloneData.Model = nil
--	cloneData.EarnedBeaks = 0

--	local inv = Knit.GetService("InventoryService")
--	inv:AddItem(thief, cloneData.Name, 1, cloneData)

--	local thiefProfile = DataService:GetProfile(thief)
--	if thiefProfile then
--		inv:SaveInventory(thief, thiefProfile)
--	end

--	-- remove from owner
--	local ownerPlayer = Players:GetPlayerByUserId(ownerUserId)
--	if Pigeons[ownerUserId] and pigeonIndex then
--		table.remove(Pigeons[ownerUserId], pigeonIndex)
--	end
--	if ownerPlayer then
--		local profile = DataService:GetProfile(ownerPlayer)
--		if profile and profile.Data.PlacedPigeons then
--			for i, saved in ipairs(profile.Data.PlacedPigeons) do
--				if saved.ID == pigeonId then
--					table.remove(profile.Data.PlacedPigeons, i)
--					break
--				end
--			end
--			self:SavePigeons(ownerPlayer, profile)
--		end
--	end
--	return true, cloneData
--end

--function PigeonService.Client:PlaceFromInventory(player, pigeonId, position)
--	return self.Server:PlaceFromInventory(player, pigeonId, position)
--end

--function PigeonService.Client:Store(player,id)
--	return self.Server:StorePigeon(player,id)
--end
--function PigeonService:SavePigeons(player, profile)
--	local pigeons = Pigeons[player.UserId] or {}
--	profile.Data.PlacedPigeons = {}
--	for _, pigeon in ipairs(pigeons) do
--		table.insert(profile.Data.PlacedPigeons, {
--			ID = pigeon.ID,
--			Name = pigeon.Name,
--			Rarity = pigeon.Rarity,
--			RelativeCFrame = pigeon.RelativeCFrame,
--			Weight = pigeon.Weight,
--			EarnedBeaks = pigeon.EarnedBeaks or 0,
--			Mutation = pigeon.Mutation
--		})
--	end
--	profile.Data.LastSave = os.time()
--end

--function PigeonService:LoadPigeons(player, profile)
--	Pigeons[player.UserId] = {}
--	local plot = PlotService:GetPlayerPlot(player)
--	if not plot then return end

--	local now = os.time()
--	local lastSave = profile.Data.LastSave or now
--	local cycles = OfflineCollection:GetOfflineCycles(lastSave)

--	for _, pigeonData in ipairs(profile.Data.PlacedPigeons or {}) do
--		local template = pigeonFolder:FindFirstChild(pigeonData.Name)
--		if not template then
--			warn("No pigeon template for:", pigeonData.Name)
--			continue
--		end

--		local clone = template:Clone()
--		clone.Parent = plot:FindFirstChild("Pigeons") or Instance.new("Folder", plot)
--		local scale = getScale(pigeonData.Weight)
--		if pigeonData.Name ~= "Pigeon" then
--			clone:ScaleTo(scale)
--		end
		
--		local relativeCFrame = CFrame.new(unpack(pigeonData.RelativeCFrame))
--		local plotRoot = plot.Model:FindFirstChild("Floor").Part
--		local worldCFrame = plotRoot.CFrame:ToWorldSpace(relativeCFrame)
--		local function getPivotOffset(model)
--			local primary = model.PrimaryPart
--			local size = model:GetExtentsSize()
--			local cf = model:GetBoundingBox()
--			local bottomY = (cf.Position - Vector3.new(0, size.Y/2, 0)).Y
--			local pivotY = primary.Position.Y
--			return pivotY - bottomY
--		end
--		-- Cast a short ray downward from the model pivot to detect the floor
--		local rayOrigin = worldCFrame.Position + Vector3.new(0, 5, 0) -- slightly above
--		local rayDirection = Vector3.new(0, -10, 0) -- short downward ray
--		local rayParams = RaycastParams.new()
--		rayParams.FilterType = Enum.RaycastFilterType.Include
--		rayParams.FilterDescendantsInstances = {plotRoot}
--		local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
--		local offsetY = getPivotOffset(clone)

--		if result then
--			worldCFrame = CFrame.new(Vector3.new(worldCFrame.Position.X, result.Position.Y + offsetY, worldCFrame.Position.Z)) * CFrame.Angles(worldCFrame:ToEulerAnglesXYZ())
--		end

--		if clone.PrimaryPart then
--			clone:SetPrimaryPartCFrame(worldCFrame)
--		else
--			clone:PivotTo(worldCFrame)
--		end
--		clone:SetAttribute("Owner",player.UserId)
--		clone:SetAttribute("PigeonID",pigeonData.ID)
		
--		local info = PigeonInfo[pigeonData.Name]
--		local earned = pigeonData.EarnedBeaks or 0

--		if cycles > 0 and info then
--			local rate = Beaks:GetBeaksPerSecond(pigeonData.Weight, info)
--			if pigeonData.Mutation then
--				rate *= MutationInfo.Multipliers[pigeonData.Mutation]
--			end
--			local perCycle = rate * OfflineCollection.Cycle * OfflineCollection.Scaling
--			local totalGain = perCycle * cycles
--			earned = (earned or 0) + totalGain
--			--warn("[OFFLINE FARMING]", player.Name, pigeonData.Name, "earned", math.floor(totalGain), "Beaks from", cycles, "cycles")
--		end

--		local board = ReplicatedStorage.Game.PigeonBillboard:Clone()
--		board.Parent = clone
--		board.Adornee = clone:WaitForChild("Head")
--		local mutationText = pigeonData.Mutation and (" ("..pigeonData.Mutation..")") or ""
--		board.PigeonName.Text = pigeonData.Name.." ["..(pigeonData.Weight or "?").."Kg]"..mutationText
--		board.AmountPerSecond.Text = (info and info.Multiplier or "?").." $/s"
--		board.SavedMoney.Amount.Text = tostring(math.floor(earned))
--		if pigeonData.Mutation then
--			if board.Mutations[pigeonData.Mutation] then
--				board.Mutations[pigeonData.Mutation].Visible = true
--			end
--		end
--		if pigeonData.Mutation then
--			addMutationVisual(clone, pigeonData.Mutation)
--		end
--		playIdleAnimation(clone)

--		table.insert(Pigeons[player.UserId], {
--			ID = pigeonData.ID,
--			Name = pigeonData.Name,
--			Rarity = pigeonData.Rarity,
--			RelativeCFrame = pigeonData.RelativeCFrame,
--			Weight = pigeonData.Weight,
--			EarnedBeaks = earned,
--			Model = clone,
--			Mutation = pigeonData.Mutation
--		})
--	end
--end


--function PigeonService:SetMutation(pigeonid, mutation)
--	for userId, list in pairs(Pigeons) do
--		for i, pd in ipairs(list) do
--			if pd.ID == pigeonid theni wa
--				if pd.Mutation then 
--					break
--				end
--				pd.Mutation = mutation
--				if pd.Model then
--					if mutation then
--						addMutationVisual(pd.Model, mutation)
--					else
--						for _, desc in ipairs(pd.Model:GetDescendants()) do
--							if desc.Name == "MutationEmitter" then
--								desc:Destroy()
--							end
--						end
--					end
--					pd.Model:SetAttribute("Mutation", mutation)
--					local board = pd.Model:FindFirstChild("PigeonBillboard")
--					local info = PigeonInfo[pd.Name]
--					local baseRate = info and info.Multiplier or 0
--					local displayRate = baseRate
--					if mutation and MutationInfo and MutationInfo.Multipliers and MutationInfo.Multipliers[mutation] then
--						displayRate = baseRate * MutationInfo.Multipliers[mutation]
--					end
--					if board then
--						local mtext = mutation and (" ("..mutation..")") or ""
--						board.PigeonName.Text = pd.Name.." ["..(pd.Weight or "?").."Kg]"..mtext
--						board.AmountPerSecond.Text = tostring(displayRate).." $/s"
--					end
--				end
--				local player = Players:GetPlayerByUserId(userId)
--				if player then
--					local profile = DataService:GetProfile(player)
--					if profile and profile.Data.PlacedPigeons then
--						for _, saved in ipairs(profile.Data.PlacedPigeons) do
--							if saved.ID == pigeonid then
--								saved.Mutation = mutation
--								break
--							end
--						end
--						self:SavePigeons(player, profile)
--					end
--				end
--				return true, pd
--			end
--		end
--	end
--	return false, "Pigeon not found"
--end

--return PigeonService
