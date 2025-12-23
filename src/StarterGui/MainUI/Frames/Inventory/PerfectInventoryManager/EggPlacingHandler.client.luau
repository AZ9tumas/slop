local player = game.Players.LocalPlayer
local tool = script.Parent
local rs = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local EggManager = Knit.GetService("EggService")

local model = tool.Handle
local primaryPart = model.PrimaryPart
local connection
local previewCFrame = nil
local rotationY = 90
local oldWalkSpeed, oldJumpPower



local function getMyPlot(player)
	for _, plot in ipairs(workspace.Map.Plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId and ownerId == player.UserId then
			return plot
		end
	end
	return nil
end
local moveSpeed = 1 -- slower speed for smoother control

local function getModelSize(model)
	local size = Vector3.new(0,0,0)
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

local function rotateEgg()
	rotationY = (rotationY + 90) % 360
end

local function updateEggPosition(root)
	local modelSize = getModelSize(model)
	local offsetY = modelSize.Y / 2
	local initialPosition = root.Position + root.CFrame.LookVector * 5
	local rayOrigin = initialPosition + Vector3.new(0, 50, 0)
	local rayDirection = Vector3.new(0, -100, 0)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {model}
	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	local yPos = (result and result.Position.Y + offsetY) or (initialPosition.Y + offsetY)
	previewCFrame = CFrame.new(Vector3.new(initialPosition.X, yPos, initialPosition.Z)) * CFrame.Angles(0, math.rad(rotationY), 0)
	
	model:SetPrimaryPartCFrame(previewCFrame)
end

local canPlace = true
local equipped = false
local function placeEgg(humanoid)
	if equipped == false then
		return
	end
	if canPlace == false then
		task.delay(0.3, function()
			canPlace = true
		end)
		return
	end
	
	if getMyPlot(game.Players.LocalPlayer):FindFirstChild("Eggs") then
		if #getMyPlot(game.Players.LocalPlayer).Eggs:GetChildren() >= require(game.ReplicatedStorage.Info.InventoryInfo).PlacableEggs then
			_G.Notification("Reached max amount of placable eggs")
			return
		end
	end
	if not previewCFrame or not canPlace then return end
	canPlace = false

	model:SetPrimaryPartCFrame(previewCFrame)

	local rayOrigin = previewCFrame.Position + Vector3.new(0, 10, 0)
	local rayDirection = Vector3.new(0, -50, 0)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {model}

	local result = workspace:Raycast(rayOrigin, rayDirection, params)
	if result and result.Instance.Parent.Name == "Floor" and result.Instance:IsDescendantOf(getMyPlot(player)) then
		local floorCFrame = result.Instance.CFrame
		local relativeCFrame = floorCFrame:ToObjectSpace(previewCFrame)
		
		EggManager:PlaceEgg(tool.Name, {relativeCFrame:GetComponents()}, tool:GetAttribute("Mutation"),tool:GetAttribute("EggId")):andThen(function(success)
			if success then
				if humanoid and oldWalkSpeed and oldJumpPower then
					humanoid.WalkSpeed = oldWalkSpeed
					humanoid.JumpPower = oldJumpPower
				end
				tool:Destroy()
			end
		end)
		local ui = player.PlayerGui:FindFirstChild("MobilePlacingUI")
		if ui then ui.Enabled = false end
	end

	-- reset after a short delay to prevent multiple placements
	task.delay(0.3, function()
		canPlace = true
	end)
end




tool.Equipped:Connect(function()
	equipped = true
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")
	
	for i,v in pairs(script.Parent:WaitForChild("Handle"):GetDescendants()) do
		if v:IsA("ProximityPrompt")  then
			v:Destroy()
		end
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	-- freeze player
	oldWalkSpeed = humanoid.WalkSpeed
	oldJumpPower = humanoid.JumpPower
	script.Parent:WaitForChild("Handle").BillboardGui.Price.Visible = false
	local highlight = script.Parent:WaitForChild("Handle"):FindFirstChild("Highlight") or Instance.new("Highlight",script.Parent:WaitForChild("Handle"))
	highlight.FillColor = Color3.new(0.5, 1, 0)
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = .5
	if UIS.TouchEnabled then
		local ui = player.PlayerGui:WaitForChild("MobilePlacingUI")
		ui.Enabled = true
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		-- rotate button
		ui.Main.Holder.Rotate.MouseButton1Click:Connect(rotateEgg)
		-- place button
		ui.Main.Holder.Place.MouseButton1Click:Connect(function() placeEgg(humanoid) end)
		-- reset button
		ui.Main.Holder.Reset.MouseButton1Click:Connect(function() updateEggPosition(root) end)

		-- initialize egg in front
		updateEggPosition(root)

		connection = rs.RenderStepped:Connect(function(delta)
			local moveVec = humanoid.MoveDirection * moveSpeed
			local newPos = previewCFrame.Position + moveVec

			-- raycast down for floor Y
			local rayOrigin = newPos + Vector3.new(0,50,0)
			local rayDirection = Vector3.new(0,-100,0)
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			rayParams.FilterDescendantsInstances = {model}
			local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
			local floorY = result and (result.Position.Y + getModelSize(model).Y/2) or newPos.Y

			-- always apply rotation, even if moveVec is zero
			previewCFrame = CFrame.new(Vector3.new(newPos.X, floorY, newPos.Z)) * CFrame.Angles(0, math.rad(rotationY), 0)
			model:SetPrimaryPartCFrame(previewCFrame)
			local rayOrigin = previewCFrame.Position + Vector3.new(0, 50, 0)
			local rayDirection = Vector3.new(0, -100, 0)
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			rayParams.FilterDescendantsInstances = {model}
			local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
			if result and result.Instance.Parent.Name == "Floor" and result.Instance:IsDescendantOf(getMyPlot(player)) then
				script.Parent:WaitForChild("Handle"):FindFirstChild("Highlight").FillColor = Color3.new(.5,1,0)
			else
				script.Parent:WaitForChild("Handle"):FindFirstChild("Highlight").FillColor = Color3.new(1, 0, 0)
			end
		end)
	else
		-- PC fallback
		local mouse = player:GetMouse()
		mouse.Button1Down:Connect(function() placeEgg(humanoid) end)

		local function getPivotOffset(model)
			local primary = model.PrimaryPart
			local size = model:GetExtentsSize()
			local cf = model:GetBoundingBox()
			local bottomY = (cf.Position - Vector3.new(0, size.Y/2, 0)).Y
			local pivotY = primary.Position.Y
			return pivotY - bottomY
		end

		connection = rs.RenderStepped:Connect(function()
			local pos = mouse.Hit.p
			local rotation = CFrame.Angles(0, math.rad(rotationY), 0)

			local rayOrigin = pos + Vector3.new(0, 50, 0)
			local rayDirection = Vector3.new(0, -200, 0)
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			rayParams.FilterDescendantsInstances = {model}
			local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)

			if result then
				local offsetY = getPivotOffset(model)
				local baseCFrame = CFrame.new(result.Position.X, result.Position.Y + offsetY, result.Position.Z)
				previewCFrame = baseCFrame * rotation
				model:SetPrimaryPartCFrame(previewCFrame)

				if result.Instance.Parent.Name == "Floor"  and result.Instance:IsDescendantOf(getMyPlot(player))  then
					script.Parent:WaitForChild("Handle"):FindFirstChild("Highlight").FillColor = Color3.new(.5,1,0)
				else
					script.Parent:WaitForChild("Handle"):FindFirstChild("Highlight").FillColor = Color3.new(1,0,0)
				end
			end
		end)


	end
end)

tool.Unequipped:Connect(function()
	equipped = false
	if connection then connection:Disconnect() connection=nil end
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		if oldWalkSpeed then humanoid.WalkSpeed = oldWalkSpeed end
		if oldJumpPower then humanoid.JumpPower = oldJumpPower end
	end
	local ui = player.PlayerGui:FindFirstChild("MobilePlacingUI")
	if ui then ui.Enabled = false end
end)

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if tool.Parent == player.Character and input.KeyCode == Enum.KeyCode.R then
		rotateEgg()
	end
end)
