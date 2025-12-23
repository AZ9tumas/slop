local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local BackpackService = Knit.CreateService {
	Name = "BackpackService",
	Client = {}
}

local DataService
local EggPlacingHandler = script:WaitForChild("EggPlacingHandler")

-- Save backpack: just store tool names and types
function BackpackService:SaveBackpack(player, profile)
	if not profile then return end
	local data = {}

	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			if tool.Name:match("Egg") then
				table.insert(data, {Name = tool.Name, Type = "EggTool"})
			else
				table.insert(data, {Name = tool.Name, Type = "TemplateTool"})
			end
		end
	end

	profile.Data.Backpack = data
end

-- Load backpack
function BackpackService:LoadBackpack(player, profile)
	if not profile then return end
	for _, toolData in ipairs(profile.Data.Backpack or {}) do
		if toolData.Type == "EggTool" then
			local split = string.split(toolData.Name, " ") -- e.g., "Rare Egg"
			if #split ~= 2 then
				warn("Invalid egg tool name:", toolData.Name)
				continue
			end

			local rarity = split[1]
			local modelName = split[2]

			local rarityFolder = ReplicatedStorage.Game.Eggs:FindFirstChild(rarity)
			if not rarityFolder then
				warn("Missing rarity folder:", rarity)
				continue
			end

			local eggTemplate = rarityFolder:FindFirstChild(modelName)
			if not eggTemplate then
				warn("Missing egg model inside rarity folder:", modelName)
				continue
			end

			-- Create tool
			local EggTool = Instance.new("Tool")
			EggTool.Name = toolData.Name
			EggTool.RequiresHandle = false
			EggTool.CanBeDropped = false
			EggTool.Parent = player.Backpack

			local eggAsHandle = eggTemplate:Clone()
			eggAsHandle.Name = "Handle"
			eggAsHandle.Parent = EggTool
			
			if EggTool:FindFirstChild("EggPlacingHandler") then
				EggTool.EggPlacingHandler:Destroy()
			end

			local handlerClone = EggPlacingHandler:Clone()
			handlerClone.Parent = EggTool
		elseif toolData.Type == "TemplateTool" then
			local template = ReplicatedStorage.Tools:FindFirstChild(toolData.Name)
			if template then
				template:Clone().Parent = player.Backpack
			else
				warn("Missing template tool:", toolData.Name)
			end
		end
	end
end

-- Handle a player safely
function BackpackService:HandlePlayer(player)
	spawn(function()
		local profile
		repeat task.wait(0.1)
			profile = DataService:GetProfile(player)
		until profile

		self:LoadBackpack(player, profile)

		player.AncestryChanged:Connect(function(_, parent)
			if not parent and profile then
				self:SaveBackpack(player, profile)
			end
		end)
	end)
end

-- KnitStart
function BackpackService:KnitStart()
	DataService = Knit.GetService("DataService")

	for _, player in ipairs(Players:GetPlayers()) do
		self:HandlePlayer(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:HandlePlayer(player)
	end)
end

return BackpackService
