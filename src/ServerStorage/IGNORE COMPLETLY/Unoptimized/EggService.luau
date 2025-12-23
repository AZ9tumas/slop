--local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local HttpService = game:GetService("HttpService")

--local EggService = Knit.CreateService {
--	Name = "EggService",
--	Client = {}
--}

--local eggFolder = ReplicatedStorage.Game:WaitForChild("Eggs")
--local PlotService
--local DataService
--local EggModule = require(ReplicatedStorage.Info:WaitForChild("EggInfo")) -- adjust path



---- Eggs[player.UserId] = { { ID, Name, Rarity, RelativeCFrame, Remaining, HatchTime, Model }, ... }
--local Eggs = {}
--EggService.EggHatched = Instance.new("BindableEvent")

--local function formatTime(seconds)
--	local h = math.floor(seconds / 3600)
--	local m = math.floor((seconds % 3600) / 60)
--	local s = seconds % 60
--	return string.format("%02d:%02d:%02d", h, m, s)
--end
--local function rollMutation()
--	local rolledMutation = nil
--	for mutationName, chance in pairs(require(game.ReplicatedStorage.Info.MutationsInfo).SpawnChances) do
--		if math.random() < chance then
--			rolledMutation = mutationName
--			break
--		end
--	end
--	return rolledMutation
--end
--local function createProximityPrompt(egg, player)
--	if not egg.Model or not egg.Model.PrimaryPart then return end
--	if egg.Model.PrimaryPart:FindFirstChild("HatchPrompt") then return end

--	local prompt = Instance.new("ProximityPrompt")
--	prompt.Name = "HatchPrompt"
--	prompt.ActionText = "Hatch Egg"
--	prompt.ObjectText = egg.Rarity .. " Egg"
--	prompt.HoldDuration = 1
--	prompt.RequiresLineOfSight = false
--	prompt.MaxActivationDistance = 12
--	prompt.Parent = egg.Model.PrimaryPart

--	prompt.Triggered:Connect(function(triggeringPlayer)
--		if triggeringPlayer ~= player then return end
		

--		local PigeonService = Knit.GetService("PigeonService")
--		local tableS = {
--			Position = egg.RelativeCFrame,
--			Pivot = egg.Model:GetPivot(),
--			Rarity = egg.Rarity,
--			EggName = egg.Name,
--			PreMutation = egg.Model:GetAttribute("Mutation") or egg.Mutation,
--			LuckBoost = egg.Model:GetAttribute("LuckBoost"),
--			SizeBoost = egg.Model:GetAttribute("SizeBoost"),
--			ID = egg.ID
--		}
--		PigeonService:RewardPigeon(player, tableS)

--		local eggs = Eggs[player.UserId]
--		for i, e in ipairs(eggs) do
--			if e.ID == egg.ID then
--				table.remove(eggs, i)
--				break
--			end
--		end
		
--		if not egg.Model then return end

--		egg.Model:Destroy()
--	end)
--end
--function EggService:KnitStart()
--	PlotService = Knit.GetService("PlotService")
--	DataService = Knit.GetService("DataService")

--	DataService.PlayerProfileLoaded.Event:Connect(function(player)
--		local profile = DataService:GetProfile(player)
--		repeat task.wait() profile = DataService:GetProfile(player) until profile
--		if profile then
--			self:LoadEggs(player, profile)
--		end
--	end)

--	task.spawn(function()
--		while true do
--			for userId, eggs in pairs(Eggs) do
--				for i = #eggs, 1, -1 do
--					pcall(function()
--						local egg = eggs[i]
--						egg.Remaining = math.max(egg.Remaining - 1, 0)

--						if egg.Remaining <= 0  then
--							egg.Model:SetAttribute("DoneHatching",true)
--							--print("[HATCHED]", egg.Name, egg.Rarity, "for player", userId)
--							local player = game.Players:GetPlayerByUserId(userId)
--							if player then
--								-- remove egg model
--								if egg.Model and egg.Model:FindFirstChild("BillboardGui") then
--									local gui = egg.Model.BillboardGui
--									local bar = gui:FindFirstChild("ProgressBar")
--									if bar then
--										bar.Visible = false
--									end
--									gui.Price.Text = "Ready to hatch!"
--									gui.Price.Visible = true
--								end
--								createProximityPrompt(egg, player)
--								-- reward pigeon at egg position
--								local PigeonService = Knit.GetService("PigeonService")
--								--PigeonService:RewardPigeon(player,tableS )
--								--table.remove(eggs, i)

--							end

--						else
--							if egg.Model and egg.Model:FindFirstChild("BillboardGui") then
--								local gui = egg.Model.BillboardGui
--								local bar = gui:FindFirstChild("ProgressBar")
--								if bar then
--									bar.Visible = true
--									if gui:FindFirstChild("Price") then
--										gui.Price.Visible = false
--									end
--									if bar:FindFirstChild("Progress") then
--										local ratio = egg.Remaining / egg.HatchTime
--										bar.Progress.Size = UDim2.new(ratio, 0, 1, 0)
--										if bar:FindFirstChild("AmountLeft") then
--											bar.AmountLeft.Text = formatTime(egg.Remaining)
--										end
--									end
--								end
--								if egg.Mutation ~= nil then
--									local gui = egg.Model.BillboardGui
--									local mutationsImage = gui:FindFirstChild("MutationsLabel")
--									if mutationsImage then
--										mutationsImage[egg.Mutation].Visible = true
--									else
--										mutationsImage = game.ReplicatedStorage.Game.MutationsLabel:Clone()
--										mutationsImage.Parent = egg.Model.BillboardGui
--										mutationsImage[egg.Mutation].Visible = true
--									end
--								end
--								if egg.Mutation ~= nil and egg.Model:GetAttribute("Mutation") then
--									local gui = egg.Model.BillboardGui
--									local mutationsImage = gui:FindFirstChild("MutationsLabel")
--									if mutationsImage then
--										mutationsImage[egg.Model:GetAttribute("Mutation")].Visible = true
--									else
--										mutationsImage = game.ReplicatedStorage.Game.MutationsLabel:Clone()
--										mutationsImage.Parent = egg.Model.BillboardGui
--										mutationsImage[egg.Model:GetAttribute("Mutation")].Visible = true
--									end
--								end
--							else
--								warn("No model for egg with ID:", egg.ID)
--							end
--						end
--					end)
--				end
--			end
--			task.wait(1)
--		end
--	end)
--end

--function EggService:ReturnEggs(userId)
	
--	return Eggs[userId]
--end

---- Internal: create egg model
--local function placeEgg(player, rarity, modelName, relativeCFrame, save, eggId,mutation)
--	local plot = PlotService:GetPlayerPlot(player)
--	if not plot then return nil end

--	local templateFolder = eggFolder:FindFirstChild(rarity)
--	if not templateFolder then return nil end

--	local template = templateFolder:FindFirstChild(modelName)
--	if not template then return nil end

--	local eggsFolder = plot:FindFirstChild("Eggs") or Instance.new("Folder")
--	eggsFolder.Name = "Eggs"
--	eggsFolder.Parent = plot

--	local clone = template:Clone()
--	clone.Parent = eggsFolder

--	local plotRoot = plot.Model:FindFirstChild("Floor").Part
--	local worldCFrame = plotRoot.CFrame:ToWorldSpace(relativeCFrame)
--	if clone.PrimaryPart then
--		clone:SetPrimaryPartCFrame(worldCFrame)
--	else
--		clone:PivotTo(worldCFrame)
--	end
--	local hatchTime = EggModule[rarity.." Egg"].HatchTime
--	eggId = eggId or HttpService:GenerateGUID(false)
--	if save == true then
--		game.ReplicatedStorage.Remotes.EggSkipRemote:FireClient(player, clone, "Hatching", eggId)
--	end
	
--	Eggs[player.UserId] = Eggs[player.UserId] or {}
--	table.insert(Eggs[player.UserId], {
--		ID = eggId,
--		Name = modelName,
--		Rarity = rarity,
--		RelativeCFrame = {relativeCFrame:GetComponents()},
--		Remaining = hatchTime,
--		HatchTime = hatchTime,
--		Mutation = mutation,
--		Model = clone
--	})

--	if save then
--		DataService:AddPlacedEgg(player, {
--			ID = eggId,
--			Name = modelName,
--			Rarity = rarity,
--			RelativeCFrame = {relativeCFrame:GetComponents()},
--			Remaining = hatchTime,
--			Mutation = mutation,
--			HatchTime = hatchTime
--		})
--	end
--	local InventoryService = Knit.GetService("InventoryService")
--	InventoryService:RemoveItem(player, rarity.." Egg", 1)
--	return clone
--end

--function EggService.Client:PlaceEgg(player, eggFullName, cframeData,mutation)
--	local split = string.split(eggFullName, " ")
--	if #split ~= 2 then return false end

--	local rarity = split[1]
--	local modelName = split[2]

--	local relativeCFrame = CFrame.new(unpack(cframeData))
--	local eggId = HttpService:GenerateGUID(false)
--	local egg = placeEgg(player, rarity, modelName, relativeCFrame, true, eggId,mutation)

--	return egg ~= nil
--end

--function EggService:AttachModel(player, eggId, model)
--	local eggs = Eggs[player.UserId]
--	if not eggs then return end
--	for _, egg in ipairs(eggs) do
--		if egg.ID == eggId then
--			egg.Model = model
--			return
--		end
--	end
--end

--function EggService:SaveEggs(player, profile)
--	local eggs = Eggs[player.UserId] or {}
--	profile.Data.PlacedEggs = {}
--	profile.Data.LastSave = os.time()
--	for _, egg in ipairs(eggs) do
--		table.insert(profile.Data.PlacedEggs, {
--			ID = egg.ID,
--			Name = egg.Name,
--			Rarity = egg.Rarity,
--			RelativeCFrame = egg.RelativeCFrame,
--			Remaining = egg.Remaining,
--			HatchTime = egg.HatchTime,
--			Mutation = egg.Mutation
--		})
--	end
--end

--function EggService:LoadEggs(player, profile)
--	Eggs[player.UserId] = {}
--	local now = os.time()
--	local lastSave = profile.Data.LastSave or now
--	local offlineElapsed = now - lastSave

--	for _, eggData in ipairs(profile.Data.PlacedEggs or {}) do
--		local remaining = (eggData.Remaining or eggData.HatchTime) - offlineElapsed
--		local relativeCFrame = CFrame.new(unpack(eggData.RelativeCFrame))
--		local clone = placeEgg(player, eggData.Rarity, eggData.Name, relativeCFrame, false, eggData.ID,eggData.Mutation)
--		if clone then
--			self:AttachModel(player, eggData.ID, clone)
--		end
--		-- overwrite remaining to keep countdown correct
--		local eggs = Eggs[player.UserId]
--		for _, egg in ipairs(eggs) do
--			if egg.ID == eggData.ID then
--				egg.Remaining = remaining
--				if remaining > 5 then
--					game.ReplicatedStorage.Remotes.EggSkipRemote:FireClient(player, clone, "Hatching", eggData.ID)
--				end
--				break
--			end
--		end
--	end
--end

--return EggService
