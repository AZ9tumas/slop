--local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local HttpService = game:GetService("HttpService")
--local EggManagerService = Knit.CreateService {
--	Name = "EggManagerService",
--	Client = {}
--}

--local eggFolder = ReplicatedStorage.Game:WaitForChild("Eggs")
--local PlotService
--local DataService
--local HatchingService

--function EggManagerService:KnitStart()
--	PlotService = Knit.GetService("PlotService")
--	DataService = Knit.GetService("DataService")
--	HatchingService = Knit.GetService("HatchingService")
--end

--local function placeEgg(player, rarity, modelName, relativeCFrame, save, eggId)
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

--	-- Register or reuse existing ID
	

--	if save then
--		if HatchingService then
--			HatchingService:RegisterEgg(player, modelName, rarity, eggId, clone)
--		end
--		DataService:AddPlacedEgg(player, {
--			ID = eggId,
--			Rarity = rarity,
--			Name = modelName,
--			RelativeCFrame = {relativeCFrame:GetComponents()}
--		})
--	end

--	return clone
--end

--function EggManagerService.Client:PlaceEgg(player, eggFullName, cframeData)
--	local split = string.split(eggFullName, " ")
--	if #split ~= 2 then return false end

--	local rarity = split[1]
--	local modelName = split[2]

--	local relativeCFrame = CFrame.new(unpack(cframeData))
--	local eggId = HttpService:GenerateGUID(false)
--	local egg = placeEgg(player, rarity, modelName, relativeCFrame, true, eggId)

--	return egg ~= nil
--end

--function EggManagerService:LoadEggs(player, profile)
--	local plot = PlotService:GetPlayerPlot(player)
--	local tries = 0
--	while not plot and tries < 50 do
--		task.wait(0.1)
--		plot = PlotService:GetPlayerPlot(player)
--		tries += 1
--	end
--	if not plot then return end

--	for _, eggData in ipairs(profile.Data.PlacedEggs or {}) do
--		if eggData.RelativeCFrame and type(eggData.RelativeCFrame) == "table" then
--			local relativeCFrame = CFrame.new(unpack(eggData.RelativeCFrame))
--			local clone = placeEgg(player, eggData.Rarity, eggData.Name, relativeCFrame, false, eggData.ID)
--			if clone and HatchingService then
--				warn("attaching model")
--				HatchingService:AttachModel(player, eggData.ID, clone)
--			end
--		end
--	end
--end

--return EggManagerService
