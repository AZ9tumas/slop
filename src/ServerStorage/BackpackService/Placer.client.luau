local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local tool = script.Parent
local rs = game:GetService("RunService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local EggManager = Knit.GetService("EggManagerService")

local model = tool.Handle
local primaryPart = model.PrimaryPart
local connection
local placedCFrame = nil

local function getModelSize(model)
	local size = Vector3.new(0, 0, 0)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			size = Vector3.new(
				math.max(size.X, part.Size.X),
				math.max(size.Y, part.Size.Y),
				math.max(size.Z, part.Size.Z)
			)
		end
	end
	return size
end

tool.Equipped:Connect(function()
	connection = rs.RenderStepped:Connect(function()
		local pos = mouse.Hit.p
		local rayOrigin = Vector3.new(pos.X, 500, pos.Z)
		local rayDirection = Vector3.new(0, -1000, 0)

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {model}

		local result = workspace:Raycast(rayOrigin, rayDirection, params)
		if result then
			local modelSize = getModelSize(model)
			local offsetY = modelSize.Y / 2
			model:SetPrimaryPartCFrame(CFrame.new(result.Position + Vector3.new(0, offsetY, 0)))
		end
	end)

	mouse.Button1Down:Connect(function()
		local rayOrigin = primaryPart.Position
		local rayDirection = Vector3.new(0, -50, 0)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {model}

		local result = workspace:Raycast(rayOrigin, rayDirection, params)
		if result and result.Instance.Name == "Part" and result.Instance.Parent.Name == "Floor" then
			local modelSize = getModelSize(model)
			local offsetY = modelSize.Y / 2
			placedCFrame = CFrame.new(result.Position + Vector3.new(0, offsetY, 0))
			model:SetPrimaryPartCFrame(placedCFrame)
			print("Placed at:", placedCFrame)

			-- compute relative CFrame to the floor
			local floorCFrame = result.Instance.CFrame
			local relativeCFrame = floorCFrame:ToObjectSpace(placedCFrame)

			-- send relative CFrame to server
			EggManager:PlaceEgg(tool.Name, {relativeCFrame:GetComponents()}):andThen(function(success)
				if success then
					print("Egg placement confirmed by server")
					tool:Destroy() -- remove placement tool
				else
					warn("Egg placement failed")
				end
			end)
		end
	end)
end)

tool.Unequipped:Connect(function()
	if connection then
		connection:Disconnect()
		connection = nil
	end
end)
