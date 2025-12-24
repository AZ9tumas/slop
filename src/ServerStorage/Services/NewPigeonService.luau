local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CustomTweenService = require(game.ReplicatedStorage.TweenV2.ReplicatedTweening)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Remote = Instance.new("RemoteEvent")
Remote.Name = "PigeonCollected"
Remote.Parent = ReplicatedStorage.Remotes

local PigeonUpdate = Instance.new("RemoteEvent")
PigeonUpdate.Name = "PigeonUpdate"
PigeonUpdate.Parent = ReplicatedStorage.Remotes

local PigeonService = Knit.CreateService {
	Name = "PigeonService",
	Client = {},
}

local OfflineCollection = require(ReplicatedStorage.Info:WaitForChild("NewOfflineCollection"))
local Beaks = require(ReplicatedStorage.Info:WaitForChild("NewBeaksInfo"))
local EggModule = require(ReplicatedStorage.Info:WaitForChild("EggInfo"))
local PigeonInfo = require(ReplicatedStorage.Info:WaitForChild("PigeonInfo"))
local MutationInfo = require(ReplicatedStorage.Info:WaitForChild("MutationsInfo"))
local FriendBoostInfo = require(ReplicatedStorage.Info:WaitForChild("FriendBoostInfo"))

local pigeonFolder = ReplicatedStorage.Game:WaitForChild("Pigeons")
local PlotService
local DataService

local Pigeons = {}
local HasFriendInGame = {}
local MutationEmitters = {}

local SyncedTime = require(ReplicatedStorage.Modules:WaitForChild("SyncedTime"))


for _, v in ipairs(ReplicatedStorage.Game.MutationParticles:GetChildren()) do
	MutationEmitters[v.Name] = v
end

local function recomputeFriendCache()
	local allPlayers = Players:GetPlayers()
	for _, p in ipairs(allPlayers) do
		HasFriendInGame[p.UserId] = false
	end
	for i = 1, #allPlayers do
		local a = allPlayers[i]
		for j = i + 1, #allPlayers do
			local b = allPlayers[j]
			if a:IsFriendsWith(b.UserId) then
				HasFriendInGame[a.UserId] = true
				HasFriendInGame[b.UserId] = true
			end
		end
	end
end

Players.PlayerAdded:Connect(recomputeFriendCache)
Players.PlayerRemoving:Connect(recomputeFriendCache)

local PreloadedAnimation = Instance.new("Animation")
PreloadedAnimation.AnimationId = "rbxassetid://77470685199251"

local function ensureMutationList(m)
	if not m then return {} end
	if type(m) == "string" then
		return {m}
	end
	return m
end

local function CheckDupedEggs(player)
	
end

local function computeMutationMultiplier(mutations)
	if not mutations then return 1 end
	local mult = 1
	for _, m in ipairs(mutations) do
		if m and m ~= "Normal" and MutationInfo and MutationInfo.Multipliers and MutationInfo.Multipliers[m] then
			mult = mult * MutationInfo.Multipliers[m]
		end
	end
	return mult
end

local function GetHighestBaseRate(userId)
    local userPigeons = Pigeons[userId]
    if not userPigeons then return 0 end

    local maxRate = 0
    
    for _, pigeon in pairs(userPigeons) do
        local info = PigeonInfo[pigeon.Name]
        -- Only check "Standard" pigeons (those without RelativeMultiplier)
        if info and not info.RelativeMultiplier then
            local rate = Beaks:GetBeaksPerSecond(pigeon.Weight, info)
            -- Apply mutations if necessary
            local mutationMult = computeMutationMultiplier(ensureMutationList(pigeon.Mutation))
            rate = rate * mutationMult
            
            if rate > maxRate then
                maxRate = rate
            end
        end
    end

	print("Highest rate right now: ", maxRate)
    
    return maxRate
end

local function playIdleAnimation(pigeonModel)
	if not pigeonModel.PrimaryPart then return end
	local humanoid = pigeonModel:FindFirstChildOfClass("Humanoid")
	local controller = pigeonModel:FindFirstChildOfClass("AnimationController")
	if not humanoid and not controller then
		controller = Instance.new("AnimationController")
		controller.Name = "PigeonAnimController"
		controller.Parent = pigeonModel
	end
	local animator = (humanoid and humanoid:FindFirstChildOfClass("Animator")) or (controller and controller:FindFirstChildOfClass("Animator"))
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid or controller
	end
	local anim = PreloadedAnimation:Clone()
	local track = animator:LoadAnimation(anim)
	track.Looped = true
	track:Play()
	return track
end

--local function pickPigeonFromEgg(eggName, boost) local eggInfo = EggModule[eggName] if not eggInfo or not eggInfo.Pigeons then return nil, nil, nil end local serverLuck = workspace:GetAttribute("ServerLuck") or 1 local boostMultiplier = 1 + ((boost or 0) * 0.1) local effectiveLuck = serverLuck * boostMultiplier local totalChance = 0 local chances = {} for _, entry in ipairs(eggInfo.Pigeons) do local adjustedChance = math.max(1, math.floor(entry.Chance * effectiveLuck)) chances[#chances + 1] = adjustedChance totalChance = totalChance + adjustedChance end local rand = math.random(1, totalChance) local cumulative = 0 local pickedEntry = nil for i, entry in ipairs(eggInfo.Pigeons) do cumulative = cumulative + chances[i] if rand <= cumulative then pickedEntry = entry break end end if not pickedEntry then return nil, nil, nil end return pickedEntry.Name, pickedEntry.Weight, pickedEntry.Chance end


local function pickPigeonFromEgg(eggName, boost)
	local eggInfo = EggModule[eggName]
	if not eggInfo or not eggInfo.Pigeons then
		return nil, nil, nil
	end

	local boostMultiplier = 1 + ((boost or 0) * 1)  
	local totalChance = 0
	local chances = {}
	for _, entry in ipairs(eggInfo.Pigeons) do
		local adjustedChance = math.max(1, math.floor(entry.Chance * boostMultiplier))
		chances[#chances + 1] = adjustedChance
		totalChance = totalChance + adjustedChance
	end

	local rand = math.random(1, totalChance)
	local cumulative = 0
	local pickedEntry = nil
	for i, entry in ipairs(eggInfo.Pigeons) do
		cumulative = cumulative + chances[i]
		if rand <= cumulative then
			pickedEntry = entry
			break
		end
	end

	if not pickedEntry then
		return nil, nil, nil
	end

	return pickedEntry.Name, pickedEntry.Weight, pickedEntry.Chance
end

function FormatWithCommas(number)
	if type(number) ~= "number" then
		warn("FormatWithCommas expects a number, got", type(number))
		return tostring(number)
	end

	local integerPart, decimalPart = math.modf(number)
	local formatted = tostring(math.floor(math.abs(integerPart)))
	local k

	-- Add commas
	repeat
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0

	-- Add negative sign back if needed
	if number < 0 then
		formatted = "-" .. formatted
	end

	-- Add decimal if not zero
	if decimalPart ~= 0 then
		local decimalStr = string.format("%.1f", decimalPart)
		decimalStr = string.sub(decimalStr, 3) -- remove "0."
		formatted = formatted .. "." .. decimalStr
	end

	-- Add "/s" if not already there
	if not string.match(formatted, "/s$") then
		formatted = formatted .. "/s"
	end

	return formatted
end


local function rollMutation()
	local totalChance = 0
	for _, info in pairs(MutationInfo) do
		totalChance = totalChance + (info.Chance or 0)
	end
	if totalChance <= 0 then return nil end
	local roll = math.random() * totalChance
	local cumulative = 0
	for name, info in pairs(MutationInfo) do
		cumulative = cumulative + (info.Chance or 0)
		if roll <= cumulative then
			return name
		end
	end
	return nil
end

local function getModelCenter(model)
	if not model then return nil end
	local cf, _ = model:GetBoundingBox()
	return cf.Position
end

local function isNear(player, pigeonModel, range)
	local character = player.Character
	if not character or not character.PrimaryPart then return false end
	local center = getModelCenter(pigeonModel)
	if not center then return false end
	local distance = (character.PrimaryPart.Position - center).Magnitude
	return distance <= (range or 10)
end

local function updateBillboard(board, beaks, rate)
	local newBeaks = FormatWithCommas(rate or 0) or 0  --tostring(math.floor(beaks or 0))
	if board.SavedMoney.Amount.Text ~= newBeaks then
		board.SavedMoney.Amount.Text = newBeaks
	end
	local newRate = FormatWithCommas(rate or 0) or 0 --string.format("%.1f $/s", rate or 0)
	if board.AmountPerSecond.Text ~= newRate then
		board.AmountPerSecond.Text = newRate
	end
end




local function getModelLargestPart(model)
	local largestPart = nil
	local largestSize = 0
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local size = descendant.Size.X * descendant.Size.Y * descendant.Size.Z
			if size > largestSize then
				largestSize = size
				largestPart = descendant
			end
		end
	end
	return largestPart
end

local function addMutationVisual(pigeonModel, mutations)
	if not pigeonModel or not mutations then return end
	local largestPart = getModelLargestPart(pigeonModel)
	if not largestPart then return end
	for _, child in ipairs(largestPart:GetChildren()) do
		if child.Name:match("^MutationEmitter_") then
			child:Destroy()
		end
	end
	for _, mutationName in ipairs(mutations) do
		local emitterTemplate = MutationEmitters[mutationName]
		if emitterTemplate then
			local emitter = emitterTemplate:Clone()
			emitter.Name = "MutationEmitter_"..mutationName
			emitter.Parent = largestPart
			emitter.Enabled = true
		end
	end
end

_G.addmutationvisualGlobal = function(pigeonModel, mutations)
	if not pigeonModel or not mutations then return end
	local largestPart = getModelLargestPart(pigeonModel)
	if not largestPart then return end

	if typeof(mutations) == "string" then
		mutations = { mutations }
	end

	for _, child in ipairs(largestPart:GetChildren()) do
		if child.Name:match("^MutationEmitter_") then
			child:Destroy()
		end
	end

	for _, mutationName in ipairs(mutations) do
		local emitterTemplate = MutationEmitters[mutationName]
		if emitterTemplate then
			local emitter = emitterTemplate:Clone()
			emitter.Name = "MutationEmitter_" .. mutationName
			emitter.Parent = largestPart
			emitter.Enabled = true
		end
	end
end


local function getScale(weight)
    weight = weight or 5
    local minWeight, maxWeight = 2.5, 20.8
    local minScale, maxScale = 0.1955, 0.4455

    if weight > 400 then
        minScale = 1.0555 
        maxScale = 1.5955

    elseif weight > 310 then
        minScale = 0.9955 
        maxScale = 1.1955

    elseif weight > 230 then
        minScale = 0.8755 
        maxScale = 0.9955

    elseif weight > 160 then
        minScale = 0.7255 
        maxScale = 0.8755

    elseif weight > 105 then
        minScale = 0.6655 
        maxScale = 0.7955

    elseif weight > 70 then
        minScale = 0.5155 
        maxScale = 0.6455

        -- 🆕 added more mid-small brackets
    elseif weight > 55 then
        minScale = 0.4555
        maxScale = 0.5955

    elseif weight > 40 then
        minScale = 0.4155
        maxScale = 0.5455

    elseif weight > 35 then
        minScale = 0.3655
        maxScale = 0.5155

    elseif weight > 25 then
        minScale = 0.3355
        maxScale = 0.4955

    elseif weight > 20 then
        minScale = 0.3155
        maxScale = 0.4855

    elseif weight > 15 then
        minScale = 0.2955
        maxScale = 0.4755

    elseif weight > 10 then
        minScale = 0.2655
        maxScale = 0.4555

    elseif weight > 7.5 then
        minScale = 0.2355
        maxScale = 0.4455

    elseif weight > 4.8 then
        minScale = 0.2055
        maxScale = 0.4355

    else
        minScale = 0.1955
        maxScale = 0.3655
    end

    if weight < minWeight then
        weight = minWeight
    elseif weight > maxWeight then
        weight = maxWeight
    end

    return minScale + ((weight - minWeight) / (maxWeight - minWeight)) * (maxScale - minScale)
end


local function newId()
	return HttpService:GenerateGUID(false)
end
local function sendFullUpdate(player)
	local pigeonsForClient = {}
    local userPigeons = Pigeons[player.UserId] or {}
    local AllPerSecond = 0

	for _, pigeon in pairs(userPigeons) do
		local info = PigeonInfo[pigeon.Name]
		if info then
			local refrate = info.RelativeMultiplier and GetHighestBaseRate(player.UserId) or 0
			local rate = Beaks:GetBeaksPerSecond(pigeon.Weight, info, refrate)
			rate = rate * computeMutationMultiplier(ensureMutationList(pigeon.Mutation))
			print("L411 Base Rate:", rate)

			table.insert(pigeonsForClient, {
				ID = pigeon.ID,
				EarnedBeaks = pigeon.EarnedBeaks or 0,
				Rate = rate,
            })
            AllPerSecond = AllPerSecond + rate
            
		end
    end
    
    player:SetAttribute("BasePerSecond", AllPerSecond)

	local profile = DataService:GetProfile(player)
	if profile then
		PigeonUpdate:FireClient(player, {
			Type = "BeakUpdate",
			Beaks = profile.Data.Beaks,
			Pigeons = pigeonsForClient
		})
	end
end




function PigeonService:RewardPigeon(player, egg)
	local plot = PlotService:GetPlayerPlot(player)
	if not plot then return end
	local pigeonName, baseWeight, chance = pickPigeonFromEgg(egg.Rarity.." Egg", egg.LuckBoost)
	local rolledMutation = egg.PreMutation
	if not pigeonName then return end
	local template = pigeonFolder:FindFirstChild(pigeonName)
	if not template then return end
	local info = PigeonInfo[pigeonName]
	local rolledWeight = baseWeight
	if info and info.Weight then
		local factor = math.random() * (info.Weight.Max - info.Weight.Min) + info.Weight.Min
		rolledWeight = math.floor(baseWeight * factor * 100) / 100
	end
	
	if egg.SizeBoost then
		rolledWeight = math.floor(rolledWeight * (1 + egg.SizeBoost * 0.1) * 100) / 100
	end
	local mutation = {egg.Mutation or rolledMutation}
	
	local clone = template:Clone()
	local pigeonsFolder = plot:FindFirstChild("Pigeons") or Instance.new("Folder", plot)
	pigeonsFolder.Name = "Pigeons"
	pigeonsFolder.Parent = plot

	local scale = getScale(rolledWeight)
	if clone.Name ~= "Pigeon" then
		clone:ScaleTo(scale)
	end
	
	local ThePigeon = string.match(pigeonName, "^(%S+)")
	warn(ThePigeon)
	_G.AddAchiev(player,{"Pigeon",ThePigeon},1)
	local relativeCFrame = CFrame.new(unpack(egg.Position))
	local plotRoot = plot.Model:FindFirstChild("Floor").Part
	local worldCFrame = plotRoot.CFrame:ToWorldSpace(relativeCFrame)
	local function getPivotOffset(model)
		local primary = model.PrimaryPart
		local size = model:GetExtentsSize()
		local cf = model:GetBoundingBox()
		local bottomY = (cf.Position - Vector3.new(0, size.Y/2, 0)).Y
		local pivotY = primary.Position.Y
		return pivotY - bottomY
	end
	local rayOrigin = worldCFrame.Position + Vector3.new(0, 5, 0)
	local rayDirection = Vector3.new(0, -10, 0)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = {plotRoot}
	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	local offsetY = getPivotOffset(clone)
	if result then
		
		local scaleDiff = scale/template:GetAttribute("Scale")
		local groundOffset = clone:GetAttribute("GroundOffset") or 0
		groundOffset *= scaleDiff
		worldCFrame = CFrame.new(Vector3.new(
			worldCFrame.Position.X,
			result.Position.Y + offsetY - groundOffset,
			worldCFrame.Position.Z
			)) * CFrame.Angles(worldCFrame:ToEulerAnglesXYZ())

		--[[
				worldCFrame = CFrame.new(Vector3.new(worldCFrame.Position.X, result.Position.Y + offsetY, worldCFrame.Position.Z)) * CFrame.Angles(worldCFrame:ToEulerAnglesXYZ())

		--]]
	end
	if clone.PrimaryPart then
		clone:SetPrimaryPartCFrame(worldCFrame)
	else
		clone:PivotTo(worldCFrame)
	end
	if mutation then
		addMutationVisual(clone, ensureMutationList(mutation))
	end
	local board = ReplicatedStorage.Game.PigeonBillboard:Clone()
	board.Parent = clone
	board.Adornee = clone:WaitForChild("Head")
	local mutationText = ""
	local list = ensureMutationList(mutation)
	local filtered = {}
	for _, m in ipairs(list) do
		if m ~= "Normal" then
			_G.AddAchiev(player,{"Mutation"},1)
			
			local current = _G.GetAchievValue(player, {"TotalMutations"})

			if (current) or 0  < 1 then
				_G.SetAchiev(player, {"TotalMutations"}, 1)
			end
			
			table.insert(filtered, m)
		end
	end
	if next(filtered) then
		mutationText = " ("..table.concat(filtered, ", ")..")"
	end
	board.PigeonName.Text = pigeonName.." ["..rolledWeight.."Kg]"..mutationText
	
	board.SavedMoney.Amount.Text = player.Name .. "'s Pigeon" --"Not your pigeon"
	if mutation then
		
		for _, m in ipairs(list) do
			if board.Mutations[m] then
				board.Mutations[m].Visible = true
			end
		end
	end
	playIdleAnimation(clone)
	clone:SetAttribute("Owner", player.UserId)
	clone:SetAttribute("PigeonID", egg.ID)
	Pigeons[player.UserId] = Pigeons[player.UserId] or {}
	Pigeons[player.UserId][egg.ID] = {
		ID = egg.ID,
		Name = pigeonName,
		Rarity = egg.Rarity,
		RelativeCFrame = egg.Position,
		Weight = rolledWeight,
		EarnedBeaks = 0,
		Model = clone,
		Mutation = mutation,
		Board = board
	}
	
    local refRate = info.RelativeMultiplier and GetHighestBaseRate(player.UserId) or 0
	local rate = Beaks:GetBeaksPerSecond(Pigeons[player.UserId][egg.ID].Weight, info, refRate)
	rate = rate * computeMutationMultiplier(ensureMutationList(Pigeons[player.UserId][egg.ID].Mutation))
	print("L565", rate, pigeonName)

	local CalculatedRate = rate
	board.AmountPerSecond.Text = FormatWithCommas(CalculatedRate or 0) or 0 --string.format("%.1f $/s", CalculatedRate or 0)
	local profile = DataService:GetProfile(player)
	if profile then
		profile.Data.PlacedPigeons = profile.Data.PlacedPigeons or {}
		table.insert(profile.Data.PlacedPigeons, {
			ID = egg.ID,
			Name = pigeonName,
			Rarity = egg.Rarity,
			RelativeCFrame = egg.Position,
			Weight = rolledWeight,
			EarnedBeaks = 0,
			Mutation = mutation
		})
        profile.Data.Unlocked = profile.Data.Unlocked or {}
        local OldVal = profile.Data.Unlocked[pigeonName]
        profile.Data.Unlocked[pigeonName] = true
        task.delay(4, function()
            if OldVal == true then return end
            ReplicatedStorage.Remotes.NewPigeon:FireClient(player, pigeonName)
        print("Unlocked " .. pigeonName)
        end)
	end
	game.ReplicatedStorage.Remotes.InventoryUpdate:FireClient(player)
	if egg.Model then
		--local Hatchsfx = script.HatchSFX:Clone()
		--Hatchsfx.Parent = egg.Model.PrimaryPart or egg.Model.Handle
		--Hatchsfx:Play()
		--task.delay(0.75, function()
		--	if not egg.Model then return end
		--	egg.Model:Destroy()
		--end)
		--for _, Parts in egg.Model:GetChildren() do
		--	if Parts:IsA("Part") then
		--		local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		--		local tween = CustomTweenService:GetTweenObject(Parts, tweenInfo, {CFrame = Parts.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 360, 0), Transparency = 1})
		--		tween:Play()
		--	end
		--end
		game.ReplicatedStorage.Remotes.Shake:InvokeClient(player,egg.Model, egg.Rarity)
		egg.Model:Destroy()
		clone.Parent = pigeonsFolder
		local TweenService = game:GetService("TweenService")

		local model = clone
		local pivot = model:GetPivot()

		-- store original size of each part
		local partData = {}
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				partData[part] = part.Size
				part.Size = part.Size * 0.1
				if part.Transparency == 0 then
				part.Transparency = 1
				end
			end
		end

		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for part, originalSize in pairs(partData) do
			local sizeTween = TweenService:Create(part, tweenInfo, {Size = originalSize})
			local transTween = TweenService:Create(part, tweenInfo, {Transparency = 0})
			sizeTween:Play()
			if part.Transparency == 1 then
			transTween:Play()
			end
		end
		playIdleAnimation(model)
		--model:PivotTo(pivot)

		sendFullUpdate(player)
		--ShakeAndExplodeEgg(egg.Model)
		--egg.Model:Destroy()
	end
end
function PigeonService.Client:RewardPigeon(player, egg)
	return self.Server:RewardPigeon(player,egg)
end

function PigeonService:RemovePlayerPigeon(Player, PigeonId)
    local inventoryService = Knit.GetService("InventoryService")

    -- 1. Check if gifting player has a pigeon table
    local uniques = inventoryService:GetInventory(Player)
    if not uniques then
        warn("No pigeons in inventory")
        return false, "No pigeons in inventory"
    end


    local pigeonData
    for i, pigeon in ipairs(uniques.Pigeons) do
        if pigeon.ID == PigeonId then
            pigeonData = pigeon
            break
        end
    end
    if not pigeonData then return end
    task.spawn(function()
        for i, pigeon in ipairs(uniques.Pigeons) do
            if pigeon.ID == pigeonData.ID then
                inventoryService:RemoveItem(Player, pigeonData.Name, "Pigeon", {ID = pigeonData.ID})
                if Player.Character:FindFirstChildWhichIsA("Tool")
                    and Player.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId")
                    and Player.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId") == PigeonId then

                    Player.Character:FindFirstChildWhichIsA("Tool"):Destroy()

                elseif Player.Backpack then
                    for _, tool in ipairs(Player.Backpack:GetChildren()) do
                        if tool:IsA("Tool")
                            and tool:GetAttribute("PigeonId")
                            and tool:GetAttribute("PigeonId") == PigeonId then

                            tool:Destroy()
                        end
                    end
                end


                local profile = DataService:GetProfile(Player)
                if profile then
                    inventoryService:SaveInventory(Player, profile)
                end
                break
            end
        end
    end)
end

function PigeonService:GiftFunction(GiftingPlayer:Player, GiftedPlayer:Player, PigeonId)
    warn("----- GIFT FUNCTION START -----")
    if not GiftingPlayer then
        ReplicatedStorage.Remotes.Notification:FireClient(GiftedPlayer, "The gift went missing.")
        return
    end
    if not GiftedPlayer then
        ReplicatedStorage.Remotes.Notification:FireClient(GiftingPlayer, "Gift couldn't be sent.")
        return
    end
    if not PigeonId then
        ReplicatedStorage.Remotes.Notification:FireClient(GiftingPlayer, "The gift went missing.")
        ReplicatedStorage.Remotes.Notification:FireClient(GiftedPlayer, "The gift went missing.")
        return
    end
    warn("Gifting:", GiftingPlayer.Name, "->", GiftedPlayer.Name, "ID:", PigeonId)

    local inventoryService = Knit.GetService("InventoryService")

    -- 1. Check if gifting player has a pigeon table
    local uniques = inventoryService:GetInventory(GiftingPlayer)
    if not uniques then
        warn("No pigeons in inventory")
        return false, "No pigeons in inventory"
    end


    local pigeonData
    for i, pigeon in ipairs(uniques.Pigeons) do
        if pigeon.ID == PigeonId then
            pigeonData = pigeon
            break
        end
    end
    
    if not pigeonData then
        
        ReplicatedStorage.Remotes.Notification:FireClient(GiftingPlayer, "The gift went missing.")
        ReplicatedStorage.Remotes.Notification:FireClient(GiftedPlayer, "The gift went missing.")
        return false, "No pigeons found for gifting player"
    end



    warn(pigeonData)
    
    local Removed = false
    
    pcall(function()
        for i, pigeon in ipairs(uniques.Pigeons) do
            if pigeon.ID == pigeonData.ID then
                inventoryService:RemoveItem(GiftingPlayer, pigeonData.Name, "Pigeon", {ID = pigeonData.ID})
                if GiftingPlayer.Character:FindFirstChildWhichIsA("Tool")
                    and GiftingPlayer.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId")
                    and GiftingPlayer.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId") == PigeonId then

                    GiftingPlayer.Character:FindFirstChildWhichIsA("Tool"):Destroy()

                elseif GiftingPlayer.Backpack then
                    for _, tool in ipairs(GiftingPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool")
                            and tool:GetAttribute("PigeonId")
                            and tool:GetAttribute("PigeonId") == PigeonId then

                            tool:Destroy()
                        end
                    end
                end

                
                Removed = true
                local profile = DataService:GetProfile(GiftingPlayer)
                if profile then
                    inventoryService:SaveInventory(GiftingPlayer, profile)
                end
                
                break
            end
        end
    end)
    
    if Removed == false then
        ReplicatedStorage.Remotes.Notification:FireClient(GiftingPlayer, "The gift went missing.")
        ReplicatedStorage.Remotes.Notification:FireClient(GiftedPlayer, "The gift went missing.")
        return false, "Gift went missing."
    end
    -- 4. Add to gifted player's inventory
    local success, message = inventoryService:AddItem(GiftedPlayer, pigeonData.Name, "Pigeon", {
        ID = newId(),
      --  Name = pigeonData.Name,
        Weight = pigeonData.Weight,       -- from PigeonService:RewardPigeon
        Mutation = pigeonData.Mutation    -- "none" or mutation type
    })
    
    local GettingProfile = DataService:GetProfile(GiftedPlayer)
    if GettingProfile then
        inventoryService:SaveInventory(GiftedPlayer, GettingProfile)
    end


    -- 5. Transfer pigeon ownership
    warn("✔ Transferring pigeon ownership...")

    Pigeons[GiftingPlayer.UserId][PigeonId] = nil
    Pigeons[GiftedPlayer.UserId] = Pigeons[GiftedPlayer.UserId] or {}
    Pigeons[GiftedPlayer.UserId][PigeonId] = pigeonData

    -- 6. Remove from gifting player's inventory
    --inventoryService:RemoveItem(GiftingPlayer, pigeonData.Name, "Pigeon", {ID = pigeonData.ID})
    ReplicatedStorage.Remotes.Notification:FireClient(GiftingPlayer, "Gift successful!")
    ReplicatedStorage.Remotes.Notification:FireClient(GiftedPlayer, "Gift successful!")
    warn("✔ Gift COMPLETED.")
    warn("----- GIFT FUNCTION END -----")

    return true, "Gift successful"
end




function PigeonService:StorePigeon(player, pigeonId)
	local pigeons = Pigeons[player.UserId]
	if not pigeons then return false, "No pigeons found" end
	local pigeonData = pigeons[pigeonId]
	if not pigeonData then
		return false, "Pigeon not found"
	end
	if pigeonData.Model and pigeonData.Model.Parent then
		pigeonData.Model:Destroy()
		
	end
	pigeons[pigeonId] = nil
	local inventoryService = Knit.GetService("InventoryService")
	--inventoryService:AddItem(player, pigeonData.Name, 1, pigeonData)
	local success, message = inventoryService:AddItem(player, pigeonData.Name, "Pigeon", {
		ID = newId(),
		--Name = "PigeonName",
		Weight = pigeonData.Weight,       -- from PigeonService:RewardPigeon
		Mutation = pigeonData.Mutation    -- "none" or mutation type
	})

	if not success then
		warn("[Inventory] Failed to add pigeon:", message)
		return
	end

	local profile = DataService:GetProfile(player)
	if profile then
		if profile.Data.PlacedPigeons then
			for i = #profile.Data.PlacedPigeons, 1, -1 do
				if profile.Data.PlacedPigeons[i].ID == pigeonId then
					table.remove(profile.Data.PlacedPigeons, i)
					sendFullUpdate(player)
					break
				end
			end
		end
		self:SavePigeons(player, profile)
	end
	return true, pigeonData
end

local function serializeCFrame(cf)
	return {cf:GetComponents()}
end

function PigeonService:PlacePigeon(player, pigeonData, position, relative)
	local plot = PlotService:GetPlayerPlot(player)
	if not plot then
		return false, "No plot"
	end

	local template = pigeonFolder:FindFirstChild(pigeonData.Name)
	if not template then
		return false, "No pigeon template for " .. tostring(pigeonData.Name)
	end

	local clone = template:Clone()
	local pigeonsFolder = plot:FindFirstChild("Pigeons") or Instance.new("Folder", plot)
	pigeonsFolder.Name = "Pigeons"
	pigeonsFolder.Parent = plot
	clone.Parent = pigeonsFolder

	local profile = DataService:GetProfile(player)

	-- SECURITY FIX: Strict Duplicate Check
    -- If a pigeon with the same ID exists in PlacedPigeons, remove it immediately.
    -- This prevents the "dupe" where a pigeon exists both in the world and in the inventory.
	if profile and profile.Data.PlacedPigeons then
        for i = #profile.Data.PlacedPigeons, 1, -1 do
            if profile.Data.PlacedPigeons[i].ID == pigeonData.ID then
                warn("[Security] Removing duplicate placed pigeon for " .. player.Name .. " ID: " .. pigeonData.ID)
                table.remove(profile.Data.PlacedPigeons, i)
                
                -- Also clean up the physical model if it exists
                local existingPigeon = Pigeons[player.UserId] and Pigeons[player.UserId][pigeonData.ID]
                if existingPigeon and existingPigeon.Model then
                    existingPigeon.Model:Destroy()
                end
                if Pigeons[player.UserId] then
                    Pigeons[player.UserId][pigeonData.ID] = nil
                end
            end
        end
    end

	local scale = getScale(pigeonData.Weight or 3)
	if pigeonData.Name ~= "Pigeon" then
		clone:ScaleTo(scale)
	end

	clone:SetPrimaryPartCFrame(position)
	clone:SetAttribute("Owner", player.UserId)
	clone:SetAttribute("PigeonID", pigeonData.ID)

	local plot = PlotService:GetPlayerPlot(player)
	local plotRoot = plot.Model:FindFirstChild("Floor").Part
	local rayDirection = Vector3.new(0, -10, 0)
	local worldCFrame = plotRoot.CFrame:ToWorldSpace(relative)
	local Pos = position.Position
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = { plotRoot }
	local result = workspace:Raycast(Pos, rayDirection, rayParams)

	local function getPivotOffset(model)
		local primary = model.PrimaryPart
		local size = model:GetExtentsSize()
		local cf = model:GetBoundingBox()
		local bottomY = (cf.Position - Vector3.new(0, size.Y / 2, 0)).Y
		local pivotY = primary.Position.Y
		return pivotY - bottomY
	end

	local offsetY = getPivotOffset(clone)
	if result then
		
		local groundOffset = clone:GetAttribute("GroundOffset") or 0
		
		local scaleDiff = scale/template:GetAttribute("Scale")
		groundOffset *= scaleDiff
		
		worldCFrame = CFrame.new(Vector3.new(
			worldCFrame.Position.X,
			result.Position.Y + offsetY - groundOffset,
			worldCFrame.Position.Z
			)) * CFrame.Angles(worldCFrame:ToEulerAnglesXYZ())
		--[[
		worldCFrame = CFrame.new(Vector3.new(worldCFrame.Position.X, result.Position.Y + offsetY, worldCFrame.Position.Z))
			* CFrame.Angles(worldCFrame:ToEulerAnglesXYZ())		
		--]]
	end

	if clone.PrimaryPart then
		clone:SetPrimaryPartCFrame(worldCFrame)
	else
		clone:PivotTo(worldCFrame)
	end

	local info = PigeonInfo[pigeonData.Name]
	local board = ReplicatedStorage.Game.PigeonBillboard:Clone()
	board.Adornee = clone:WaitForChild("Head")
	board.Parent = clone

	local mutationText = ""
	local list = ensureMutationList(pigeonData.Mutation)
	local filtered = {}
	for _, m in ipairs(list) do
		if m ~= "Normal" then
			table.insert(filtered, m)
		end
	end

	if next(filtered) then
		mutationText = " (" .. table.concat(filtered, ", ") .. ")"
	end
    local refRate = info.RelativeMultiplier and GetHighestBaseRate(player.UserId) or 0
	local rate = Beaks:GetBeaksPerSecond(pigeonData.Weight, info, refRate)
	print("L977 Base Rate:", rate)
	board.PigeonName.Text = pigeonData.Name .. " [" .. (pigeonData.Weight or "?") .. "Kg]" .. mutationText

	local mutationList = ensureMutationList(pigeonData.Mutation)
	rate = rate * computeMutationMultiplier(mutationList)
	board.AmountPerSecond.Text = FormatWithCommas(rate or 0) or 0 --string.format("%.1f $/s", rate or 0)

	board.SavedMoney.Amount.Text = player.Name .. "'s Pigeon"

	local list = ensureMutationList(pigeonData.Mutation)
	if pigeonData.Mutation then
		for _, m in ipairs(list) do
			if board.Mutations[m] then
				board.Mutations[m].Visible = true
			end
		end
	end

	if pigeonData.Mutation then
		addMutationVisual(clone, ensureMutationList(pigeonData.Mutation))
	end

	playIdleAnimation(clone)

	local plotRoot = plot.Model:FindFirstChild("Floor").Part
	position = worldCFrame
	local relativeCFrame = plotRoot.CFrame:ToObjectSpace(position)

	Pigeons[player.UserId] = Pigeons[player.UserId] or {}
	Pigeons[player.UserId][pigeonData.ID] = {
		ID = pigeonData.ID,
		Name = pigeonData.Name,
		Rarity = pigeonData.Rarity,
		RelativeCFrame = { relativeCFrame:GetComponents() },
		Weight = pigeonData.Weight,
		EarnedBeaks = pigeonData.EarnedBeaks or 0,
        LastUpdate = os.time(), -- Added for server-side calculation
		Model = clone,
		Mutation = pigeonData.Mutation,
		Board = board
	}

	if profile then
		profile.Data.PlacedPigeons = profile.Data.PlacedPigeons or {}
		table.insert(profile.Data.PlacedPigeons, {
			ID = pigeonData.ID,
			Name = pigeonData.Name,
			Rarity = pigeonData.Rarity,
			RelativeCFrame = { relativeCFrame:GetComponents() },
			Weight = pigeonData.Weight,
			EarnedBeaks = pigeonData.EarnedBeaks or 0,
			Mutation = pigeonData.Mutation
		})
		sendFullUpdate(player)
	end

	return true, clone
end


_G.getPigeonDatafromid = function(player,pigeonId)
	local inv = Knit.GetService("InventoryService")

	local uniques = inv:GetInventory(player)
	if not uniques or not uniques.Pigeons then
		return nil
	end

	local pigeonData
	for i, pigeon in ipairs(uniques.Pigeons) do
		if pigeon.ID == pigeonId then
			pigeonData = pigeon
			-- Ensure Weight has a default value
			if pigeonData and pigeonData.Weight == nil then
				pigeonData.Weight = 5
			end
			break
		end
	end
	return pigeonData
end

function PigeonService:PlaceFromInventory(player, pigeonId, position, pigeonName,relative)
	local inv = Knit.GetService("InventoryService")
	local uniques = inv:GetInventory(player)
	if not uniques then
		warn("No pigeons in inventory")
		return false, "No pigeons in inventory"
	end
	
    -- SECURITY FIX: Ensure pigeonId is provided
    if not pigeonId then
        warn("[Security] Player " .. player.Name .. " tried to place pigeon without ID")
        return false, "Invalid ID"
    end

	local pigeonData
	for i, pigeon in ipairs(uniques.Pigeons) do
		if pigeon.ID == pigeonId then
			pigeonData = pigeon
			break
		end
	end

    -- SECURITY FIX: Removed the fallback that generated a new pigeon if ID wasn't found.
    -- This prevents exploiters from sending fake IDs to generate free pigeons.
	if not pigeonData then
        warn("[Security] Player " .. player.Name .. " tried to place non-existent pigeon ID: " .. tostring(pigeonId))
        return false, "Pigeon not found in inventory"
	end
    
    -- SECURITY FIX: Check if this ID is already placed (Anti-Dupe)
    if Pigeons[player.UserId] and Pigeons[player.UserId][pigeonId] then
         warn("[Security] Player " .. player.Name .. " tried to place already placed pigeon ID: " .. tostring(pigeonId))
         return false, "Pigeon already placed"
    end

	local success, clone = self:PlacePigeon(player, pigeonData, position,relative)
	if success and uniques.Pigeons then
		-- only remove from inventory if it existed there
		for i, pigeon in ipairs(uniques.Pigeons) do
			if pigeon.ID == pigeonData.ID then
				inv:RemoveItem(player, pigeonData.Name, "Pigeon", {ID = pigeonData.ID})
				local profile = DataService:GetProfile(player)
				if profile then
					inv:SaveInventory(player, profile)
				end
				break
			end
		end
	end
	return success, clone
end


function PigeonService:StealPigeon(thief, pigeonId)
	local ownerUserId
	local pigeonData
	for uid, list in pairs(Pigeons) do
		if list[pigeonId] then
			ownerUserId = uid
			pigeonData = list[pigeonId]
			break
		end
	end
	if not pigeonData then return false, "Pigeon not found" end
	if ownerUserId == thief.UserId then return false, "Cannot steal your own pigeon" end
	if pigeonData.Model and pigeonData.Model.Parent then
		pigeonData.Model:Destroy()
	end
	local cloneData = table.clone(pigeonData)
	cloneData.ID = newId()
	cloneData.Model = nil
	cloneData.EarnedBeaks = 0
	local inv = Knit.GetService("InventoryService")
	local success, message = inv:AddItem(thief, cloneData.Name, "Pigeon", {
		Mutation = cloneData.Mutation,
		Weight = cloneData.Weight
	})

	if not success then
		warn("[Inventory] Failed to add pigeon for " .. thief.Name .. ": " .. tostring(message))
		return
	end

	local thiefProfile = DataService:GetProfile(thief)
	if thiefProfile then
		inv:SaveInventory(thief, thiefProfile)
	end
	if Pigeons[ownerUserId] then
		Pigeons[ownerUserId][pigeonId] = nil
	end
	local ownerPlayer = Players:GetPlayerByUserId(ownerUserId)
	for _, PlayerNoti in game.Players:GetChildren() do
		if PlayerNoti:IsA("Player") then
			game.ReplicatedStorage.Remotes.Notification:FireClient(PlayerNoti, thief.Name .. " Stole a pigeon from " .. ownerPlayer.Name)
		end
	end
	if ownerPlayer then
		local profile = DataService:GetProfile(ownerPlayer)
		if profile and profile.Data.PlacedPigeons then
			for i = #profile.Data.PlacedPigeons, 1, -1 do
				if profile.Data.PlacedPigeons[i].ID == pigeonId then
					table.remove(profile.Data.PlacedPigeons, i)
					break
				end
			end
			self:SavePigeons(ownerPlayer, profile)
		end
	end
	return true, cloneData
end

function PigeonService.Client:PlaceFromInventory(player, pigeonId, position,name,relative)
	return self.Server:PlaceFromInventory(player, pigeonId, position,name,relative)
end

function PigeonService.Client:Store(player, id)
	return self.Server:StorePigeon(player, id)
end

local clientSave = {}
function PigeonService:SavePigeons(player, profile)
	repeat wait() until clientSave[player.UserId]
	local pigeons = Pigeons[player.UserId] or {}
	profile.Data.PlacedPigeons = {}
    warn("Server saving",pigeons)
    local seen = {}
    for _, pigeon in pairs(pigeons) do
        if seen[pigeon.ID] then
            warn("Duplicate pigeon during save:", pigeon.ID)
            continue
        end
        seen[pigeon.ID] = true
		table.insert(profile.Data.PlacedPigeons, {
			ID = pigeon.ID,
			Name = pigeon.Name,
			Rarity = pigeon.Rarity,
			RelativeCFrame = pigeon.RelativeCFrame,
			Weight = pigeon.Weight,
			EarnedBeaks = pigeon.EarnedBeaks or 0,
			Mutation = pigeon.Mutation
		})
	end
	profile.Data.LastSave = game.ReplicatedStorage.CurrentTime.Value

end

function PigeonService:LoadPigeons(player, profile)
    
	Pigeons[player.UserId] = {}
	local plot = PlotService:GetPlayerPlot(player)
	if not plot then return end
	local now = game.ReplicatedStorage.CurrentTime.Value
	local lastSave = profile.Data.LastSave or now
    local cycles = OfflineCollection:GetOfflineCycles(lastSave)
    local seenIDs = {}
    for _, pigeonData in ipairs(profile.Data.PlacedPigeons or {}) do
        if seenIDs[pigeonData.ID] then
            warn("Duplicate pigeon in datastore:", pigeonData.ID)
            continue
        end
        seenIDs[pigeonData.ID] = true
		local template = pigeonFolder:FindFirstChild(pigeonData.Name)
		if not template then
			continue
        end
        local info = PigeonInfo[pigeonData.Name]
        if pigeonData.Name == "Triple Pigeon" and pigeonData.Weight < 20 then
            continue
        end
        if pigeonData.Name == "Alien Pigeon" and pigeonData.Weight < 20 then
            continue
        end
        if pigeonData.Name == "Cyborg Pigeon" and pigeonData.Weight < 20 then
            continue
        end
		local clone = template:Clone()
		local pigeonsFolder = plot:FindFirstChild("Pigeons") or Instance.new("Folder", plot)
		pigeonsFolder.Name = "Pigeons"
		pigeonsFolder.Parent = plot
		clone.Parent = pigeonsFolder
		local scale = getScale(pigeonData.Weight)
		if pigeonData.Name ~= "Pigeon" then
			clone:ScaleTo(scale)
        end
        print(pigeonData)
        local Attempts = 0
        
        --repeat wait(1) Attempts += 1 until pigeonData.RelativeCFrame or Attempts > 3
        pcall(function()
        local relativeCFrame = CFrame.new(unpack(pigeonData.RelativeCFrame))
		local plotRoot = plot.Model:FindFirstChild("Floor").Part
		local worldCFrame = plotRoot.CFrame:ToWorldSpace(relativeCFrame)
		local function getPivotOffset(model)
			local primary = model.PrimaryPart
			local size = model:GetExtentsSize()
			local cf = model:GetBoundingBox()
			local bottomY = (cf.Position - Vector3.new(0, size.Y/2, 0)).Y
			local pivotY = primary.Position.Y
			return pivotY - bottomY
		end
		local rayOrigin = worldCFrame.Position + Vector3.new(0, 5, 0)
		local rayDirection = Vector3.new(0, -10, 0)
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Include
		rayParams.FilterDescendantsInstances = {plotRoot}
		local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
		local offsetY = getPivotOffset(clone)
		if result then
						
			local scaleDiff = scale/template:GetAttribute("Scale")
			local groundOffset = clone:GetAttribute("GroundOffset") or 0
			groundOffset *= scaleDiff
			
			worldCFrame = CFrame.new(Vector3.new(
				worldCFrame.Position.X,
				result.Position.Y + offsetY - groundOffset,
				worldCFrame.Position.Z
				)) * CFrame.Angles(worldCFrame:ToEulerAnglesXYZ())

			--worldCFrame = CFrame.new(Vector3.new(worldCFrame.Position.X, result.Position.Y + offsetY, worldCFrame.Position.Z)) * CFrame.Angles(worldCFrame:ToEulerAnglesXYZ())
		end
		if clone.PrimaryPart then
			clone:SetPrimaryPartCFrame(worldCFrame)
		else
			clone:PivotTo(worldCFrame)
		end
		clone:SetAttribute("Owner", player.UserId)
		clone:SetAttribute("PigeonID", pigeonData.ID)
		
		local earned = pigeonData.EarnedBeaks or 0
		if cycles > 0 and info then
            local refRate = info.RelativeMultiplier and GetHighestBaseRate(player.UserId) or 0
			local rate = Beaks:GetBeaksPerSecond(pigeonData.Weight, info, refRate)
			print("L1285 Base Rate:", rate)
			if pigeonData.Mutation then
				rate = rate * (MutationInfo.Multipliers[pigeonData.Mutation] or 1)
			end
			local perCycle = rate * OfflineCollection.Cycle * OfflineCollection.Scaling
			local totalGain = perCycle * cycles
			earned = (earned or 0) + totalGain
		end
		local board = ReplicatedStorage.Game.PigeonBillboard:Clone()
		board.Parent = clone
		board.Adornee = clone:WaitForChild("Head")
		local mutationText = ""
		local list = ensureMutationList(pigeonData.Mutation)
		local filtered = {}
		for _, m in ipairs(list) do
			if m ~= "Normal" then
				table.insert(filtered, m)
			end
		end
		if next(filtered) then
			mutationText = " ("..table.concat(filtered, ", ")..")"
		end
		board.PigeonName.Text = pigeonData.Name.." ["..(pigeonData.Weight or "?").."Kg]"..mutationText
		
		local mutationList = ensureMutationList(pigeonData.Mutation)
		local refrate = info.RelativeMultiplier and GetHighestBaseRate(player.UserId) or 0
		local rate = Beaks:GetBeaksPerSecond(pigeonData.Weight, info, refrate)
		rate = rate * computeMutationMultiplier(mutationList)
		print("L1313 Base Rate:", rate)
		board.AmountPerSecond.Text = FormatWithCommas(rate or 0) or 0 --string.format("%.1f $/s", rate or 0)

		board.SavedMoney.Amount.Text = player.Name .. "'s Pigeon"

		local list = ensureMutationList(pigeonData.Mutation)

		if pigeonData.Mutation then
			
			for _, m in ipairs(list) do
				if board.Mutations[m] then
					board.Mutations[m].Visible = true
				end
			end
		end
		if pigeonData.Mutation then
			addMutationVisual(clone, ensureMutationList(pigeonData.Mutation))
		end
		playIdleAnimation(clone)
		Pigeons[player.UserId][pigeonData.ID] = {
			ID = pigeonData.ID,
			Name = pigeonData.Name,
			Rarity = pigeonData.Rarity,
			RelativeCFrame = pigeonData.RelativeCFrame,
			Weight = pigeonData.Weight,
			EarnedBeaks = earned,
            LastUpdate = os.time(), -- Added for server-side calculation
			Model = clone,
			Mutation = pigeonData.Mutation,
			Board = board
        }
        end)
	end
end



function PigeonService:SetMutation(pigeonid, mutation)
	for userId, list in pairs(Pigeons) do
		for id, pd in pairs(list) do
			if pd.ID == pigeonid then
				pd.Mutation = ensureMutationList(pd.Mutation)
				for _, m in ipairs(pd.Mutation) do
					if m == mutation then
						return true, pd
					end
				end
				table.insert(pd.Mutation, mutation)
				warn("MUTATIONS ARE THE FOLLOWING",pd.Mutation)
				if pd.Model then
					addMutationVisual(pd.Model, pd.Mutation)
					
					local info = PigeonInfo[pd.Name]
					local refRate = info.RelativeMultiplier and GetHighestBaseRate(userId) or 0
					local rate = Beaks:GetBeaksPerSecond(pd.Weight, info, refRate)
					rate = rate * computeMutationMultiplier(pd.Mutation)
					print("L1369 Base Rate:", rate)
					local board = pd.Model:FindFirstChild("PigeonBillboard", true)
					if board then
							local plrr = game.Players:GetPlayerByUserId(userId)
							game.ReplicatedStorage.Remotes.Notification:FireClient(plrr, "Your " .. pd.Name .. " [" .. pd.Weight .. "Kg]" .. " Got " .. mutation .. " Mutation")
							local Highlight = Instance.new("Highlight", pd.Model)
							Highlight.FillColor = Color3.new(1, 1, 1)
							game.Debris:AddItem(Highlight, 4)
						--[[if mutation == "Wealth" then
							_G.AddAchiev(plrr,{"WealthMutation"},1)
						end]]
						board.AmountPerSecond.Text = FormatWithCommas(rate or 0) or 0 --string.format("%.1f $/s", rate or 0)
						local mutationText = ""
						local list = ensureMutationList(pd.Mutation)
						local filtered = {}
						for _, m in ipairs(list) do
							if m ~= "Normal" then
								table.insert(filtered, m)
							end
						end
						if next(filtered) then
							mutationText = " ("..table.concat(filtered, ", ")..")"
						end
						board.PigeonName.Text = pd.Name.." ["..(pd.Weight or "?").."Kg]"..mutationText	
						local totalMutations = #filtered
						local current = _G.GetAchievValue(game.Players:GetPlayerByUserId(userId), {"TotalMutations"})

						if totalMutations > (current) or 0 then
							_G.SetAchiev(game.Players:GetPlayerByUserId(userId), {"TotalMutations"}, totalMutations)
						end
						for _, m in ipairs(pd.Mutation) do
							for _, m in ipairs(list) do
								if board.Mutations[m] then
									board.Mutations[m].Visible = true
								end
							end
						end
					end
					sendFullUpdate(game.Players:GetPlayerByUserId(userId))
				end
				return true, pd
			end
		end
	end
	return false, "Pigeon not found"
end

function PigeonService:TryCollectNearby(player, range)
	local userPigeons = Pigeons[player.UserId]
	if not userPigeons then return end

	for id, pigeon in pairs(userPigeons) do
		if (pigeon.EarnedBeaks or 0) > 0 and pigeon.Model and isNear(player, pigeon.Model, range or 2) then
			local earned = pigeon.EarnedBeaks
			local profile = DataService:GetProfile(player)

			if profile then
				profile.Data.Beaks = (profile.Data.Beaks or 0) + earned
				if profile.Data.Gamepasses and profile.Data.Gamepasses.x2Beaks == true then
					profile.Data.Beaks += earned
				end

				pigeon.EarnedBeaks = 0

				-- Fire old effect remote
				Remote:FireClient(player, earned, getModelCenter(pigeon.Model))

				-- Fire new GUI update remote
				PigeonUpdate:FireClient(player, {
					Type = "Collected",
					PigeonId = pigeon.ID,
					NewBeaks = profile.Data.Beaks
				})
			end
		end
	end
end
local function getMyPlot(player)
	for _, plot in ipairs(workspace.Map.Plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId and ownerId == player.UserId then
			return plot
		end
	end
	return nil
end
function PigeonService:KnitStart()
	PlotService = Knit.GetService("PlotService")
	DataService = Knit.GetService("DataService")

	game.Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function(char)
			task.wait(1)
			repeat wait() until getMyPlot(plr) and getMyPlot(plr):FindFirstChild("Pigeons")
			sendFullUpdate(plr)
		end)
		
	end)

	local PigeonUpdate = ReplicatedStorage.Remotes:WaitForChild("PigeonUpdate")
	local PigeonCollectRequest = ReplicatedStorage.Remotes:WaitForChild("PigeonCollectRequest")

	local COLLECTION_RANGE = 9

	PigeonCollectRequest.OnServerEvent:Connect(function(player, pigeonId, earned,save)
        local userId = player.UserId
        local serverPigeons = Pigeons[userId]
        if not serverPigeons then return end

        -- Helper function to update earnings based on time
		local function updatePigeonEarnings(pigeon)
            if not pigeon.LastUpdate then pigeon.LastUpdate = os.time() end
            local now = os.time()
            local delta = now - pigeon.LastUpdate
            
            if delta > 0 then
                local info = PigeonInfo[pigeon.Name]
                if info then
					local refrate = info.RelativeMultiplier and GetHighestBaseRate(userId) or 0
                    local rate = Beaks:GetBeaksPerSecond(pigeon.Weight, info, refrate)
                    local mutationList = ensureMutationList(pigeon.Mutation)
                    rate = rate * computeMutationMultiplier(mutationList)
					print("L1491 Base Rate:", rate)
                    
                    local gain = rate * delta
                    pigeon.EarnedBeaks = (pigeon.EarnedBeaks or 0) + gain
                    pigeon.LastUpdate = now
                end
            end
        end

		if save then
			clientSave[userId] = true
            -- SECURITY FIX: Validate input type
            if type(pigeonId) ~= "table" then return end
            
			for id, data in pairs(pigeonId) do
				if serverPigeons[id] then
                    -- SECURITY FIX: Update earnings server-side instead of trusting client
                    updatePigeonEarnings(serverPigeons[id])
				end
			end
		else
			--warn("Attempting to earn")
			if not serverPigeons then  			warn("UserPigeons not found") return end
			--warn("COLLECTING")
			for _, pigeon in pairs(serverPigeons) do
				if pigeon.ID == pigeonId then
					local model = pigeon.Model
					if model then
                        -- SECURITY FIX: Update earnings before collecting
                        updatePigeonEarnings(pigeon)

						local profile = DataService:GetProfile(player)
						if profile then
                            -- SECURITY FIX: Ignore client-provided 'earned' amount. Use server-tracked value.
							local beaksToGive = math.floor(pigeon.EarnedBeaks or 0)

							if beaksToGive > 0 then
								
								profile.Data.Beaks = (profile.Data.Beaks or 0) + beaksToGive
								
								if profile.Data.Gamepasses and profile.Data.Gamepasses.x2Beaks then
									profile.Data.Beaks += beaksToGive
								end
								player.leaderstats.Beaks.Value = profile.Data.Beaks
								pigeon.EarnedBeaks = 0
                                pigeon.LastUpdate = os.time() -- Reset timer

								--PigeonUpdate:FireClient(player, {
								--	Type = "Collected",
								--	PigeonId = pigeon.ID,
								--	NewBeaks = profile.Data.Beaks
								--})
								--Remote:FireClient(player, beaksToGive, getModelCenter(pigeon.Model))

							end
						end
					end
					break
				end
			end
		end
		
	end)
end






return PigeonService
