local player = game.Players.LocalPlayer
local tool = script.Parent
local rs = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PigeonService = Knit.GetService("PigeonService")

local model = tool.Handle
local primaryPart = model.PrimaryPart
local connection
local previewCFrame = nil
local rotationY = 90
local oldWalkSpeed, oldJumpPower
local placingInProgress = false -- anti-duplication flag

local function getMyPlot(player)
	for _, plot in ipairs(workspace.Map.Plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId and ownerId == player.UserId then
			return plot
		end
	end
	return nil
end

local moveSpeed = 1

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
	
	
	-- 20/10/25
	local groundOffset = model:GetAttribute("GroundOffset") or 0
	model:SetPrimaryPartCFrame(previewCFrame - Vector3.new(0, groundOffset, 0))

	--model:SetPrimaryPartCFrame(previewCFrame)
end

local canPlace = true
local equipped = false

local function placeEgg(humanoid)
	if not equipped or not canPlace or placingInProgress then return end
	placingInProgress = true
	canPlace = false
	task.delay(1, function()
		placingInProgress = false
	end)

	if getMyPlot(player):FindFirstChild("Pigeons") then
		if #getMyPlot(player).Pigeons:GetChildren() >= require(game.ReplicatedStorage.Info.InventoryInfo).PlacablePigeons then
			_G.Notification("Reached max amount of placable pigeons")
			canPlace = true
			placingInProgress = false
			return
		end
	end

	if not previewCFrame then
		canPlace = true
		placingInProgress = false
		return
	end

	model:SetPrimaryPartCFrame(previewCFrame)

	local rayOrigin = previewCFrame.Position + Vector3.new(0, 10, 0)
	local rayDirection = Vector3.new(0, -50, 0)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {model}
	local nearbyInvalid = false

	for _, nearby in ipairs(workspace:GetPartBoundsInRadius(model.PrimaryPart.Position, 3)) do
		local parentModel = nearby:FindFirstAncestorOfClass("Model")
		if parentModel and (string.find(parentModel.Name, "Egg") or string.find(parentModel.Name, "Pigeon")) then
			nearbyInvalid = true
			break
		end
	end

	local result = workspace:Raycast(rayOrigin, rayDirection, params)
	if result and result.Instance.Parent.Name == "Floor" and result.Instance:IsDescendantOf(getMyPlot(player)) and not nearbyInvalid then
		local floorCFrame = result.Instance.CFrame
		local relativeCFrame = floorCFrame:ToObjectSpace(previewCFrame)

		local success = false
		local ok, res = pcall(function()
			return PigeonService:PlaceFromInventory(tool:GetAttribute("PigeonId"), previewCFrame, tool.Name, relativeCFrame):await()
		end)

		if ok and res then success = true end

		if success then
			task.defer(function()
				if humanoid and oldWalkSpeed and oldJumpPower then
					humanoid.WalkSpeed = oldWalkSpeed
					humanoid.JumpPower = oldJumpPower
				end
				if tool then tool:Destroy() game.ReplicatedStorage.Remotes.DeleteItem:FireServer(tool) game.Players.LocalPlayer.PlayerGui.MainUI.ConsoleTut.Visible = false end
			end)
		else
			_G.Notification("Failed to place pigeon")
		end

		local ui = player.PlayerGui:FindFirstChild("MobilePlacingUI")
		if ui then ui.Enabled = false end
	end

	task.delay(0.4, function()
		canPlace = true
	end)
end

tool.Equipped:Connect(function()
	equipped = true
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")

	for _, v in pairs(tool.Handle:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v:Destroy()
		end
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	game.ReplicatedStorage.Remotes.Delete:InvokeServer(tool.Name)
	if game.UserInputService.GamepadEnabled then
		game.Players.LocalPlayer.PlayerGui.MainUI.ConsoleTut.Visible = true
	end
	for i,v in pairs(tool.Handle:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 0
		end
	end
	oldWalkSpeed = humanoid.WalkSpeed
	oldJumpPower = humanoid.JumpPower

	local highlight = model:FindFirstChild("Highlight") or Instance.new("Highlight", model)
	highlight.FillColor = Color3.new(0.5, 1, 0)
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = 0.5

	if UIS.TouchEnabled then
		local ui = player.PlayerGui:WaitForChild("MobilePlacingUI")
		ui.Enabled = true
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		ui.Main.Holder.Rotate.MouseButton1Click:Connect(rotateEgg)
		ui.Main.Holder.Place.MouseButton1Click:Connect(function() placeEgg(humanoid) end)
		ui.Main.Holder.Reset.MouseButton1Click:Connect(function() updateEggPosition(root) end)

		updateEggPosition(root)

		local function getPivotOffset(model)
			local primary = model.PrimaryPart
			local size = model:GetExtentsSize()
			local cf = model:GetBoundingBox()
			local bottomY = (cf.Position - Vector3.new(0, size.Y / 2, 0)).Y
			local pivotY = primary.Position.Y
			return pivotY - bottomY
		end

		connection = rs.RenderStepped:Connect(function()
			for i,v in pairs(tool.Handle:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency = 0
				end
			end
			for i,v in pairs(script.Parent:WaitForChild("Handle"):GetDescendants()) do
				if v:IsA("ProximityPrompt")  then
					v:Destroy()
				end
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
				if v.Name == "HandleWeld" then
					v:Destroy()
				end
				script.Parent:WaitForChild("Handle").PrimaryPart.Anchored = true
			end
			local moveVec = humanoid.MoveDirection * moveSpeed
			local newPos = previewCFrame.Position + moveVec
			local rotation = CFrame.Angles(0, math.rad(rotationY), 0)

			local rayOrigin = newPos + Vector3.new(0, 50, 0)
			local rayDirection = Vector3.new(0, -100, 0)
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			rayParams.FilterDescendantsInstances = {model}
			local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
			local floorY = result and (result.Position.Y) or newPos.Y
			local offsetY = getPivotOffset(model)
			local groundOffset = model:GetAttribute("GroundOffset") or 0
			
			-- 20/10/25:
			local baseCFrame = CFrame.new(result.Position.X, result.Position.Y + offsetY - groundOffset, result.Position.Z)
			previewCFrame = baseCFrame * rotation
			model:SetPrimaryPartCFrame(previewCFrame)

			--[[
			local baseCFrame = CFrame.new(result.Position.X, result.Position.Y + offsetY, result.Position.Z)
			previewCFrame = baseCFrame * rotation
			model:SetPrimaryPartCFrame(previewCFrame)
			--]]


			local nearbyInvalid = false
			for _, nearby in ipairs(workspace:GetPartBoundsInRadius(model.PrimaryPart.Position, 3)) do
				local parentModel = nearby:FindFirstAncestorOfClass("Model")
				if parentModel and (string.find(parentModel.Name, "Egg") or string.find(parentModel.Name, "Pigeon")) then
					nearbyInvalid = true
					break
				end
			end

			if result and result.Instance.Parent.Name == "Floor" and result.Instance:IsDescendantOf(getMyPlot(player)) and not nearbyInvalid then
				highlight.FillColor = Color3.new(.5, 1, 0)
			else
				highlight.FillColor = Color3.new(1, 0, 0)
			end
		end)
	else
		local mouse = player:GetMouse()
		mouse.Button1Down:Connect(function()
			if equipped then placeEgg(humanoid) end
		end)

		local function getPivotOffset(model)
			local primary = model.PrimaryPart
			local size = model:GetExtentsSize()
			local cf = model:GetBoundingBox()
			local bottomY = (cf.Position - Vector3.new(0, size.Y / 2, 0)).Y
			local pivotY = primary.Position.Y
			return pivotY - bottomY
		end

		connection = rs.RenderStepped:Connect(function()
			for i,v in pairs(tool.Handle:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency = 0
				end
			end
			for i,v in pairs(script.Parent:WaitForChild("Handle"):GetDescendants()) do
				if v:IsA("ProximityPrompt")  then
					v:Destroy()
				end
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
				if v.Name == "HandleWeld" then
					v:Destroy()
				end
				script.Parent:WaitForChild("Handle").PrimaryPart.Anchored = true
			end
			local pos = mouse.Hit.p
			local rotation = CFrame.Angles(0, math.rad(rotationY), 0)

			local rayOrigin = pos + Vector3.new(0, 50, 0)
			local rayDirection = Vector3.new(0, -200, 0)
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			rayParams.FilterDescendantsInstances = {model}
			local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
			local nearbyInvalid = false

			for _, nearby in ipairs(workspace:GetPartBoundsInRadius(model.PrimaryPart.Position, 3)) do
				local parentModel = nearby:FindFirstAncestorOfClass("Model")
				if parentModel and (string.find(parentModel.Name, "Egg") or string.find(parentModel.Name, "Pigeon")) then
					nearbyInvalid = true
					break
				end
			end

			if result then
				
				-- 20/10/25
				
				local offsetY = getPivotOffset(model)
				local groundOffset = model:GetAttribute("GroundOffset") or 0
				local baseCFrame = CFrame.new(result.Position.X, result.Position.Y + offsetY - groundOffset, result.Position.Z)
				previewCFrame = baseCFrame * rotation
				model:SetPrimaryPartCFrame(previewCFrame)

				--[[
				local offsetY = getPivotOffset(model)
				local baseCFrame = CFrame.new(result.Position.X, result.Position.Y + offsetY, result.Position.Z)
				previewCFrame = baseCFrame * rotation
				model:SetPrimaryPartCFrame(previewCFrame)	
				--]]


				if result.Instance.Parent.Name == "Floor" and result.Instance:IsDescendantOf(getMyPlot(player)) and not nearbyInvalid then
					highlight.FillColor = Color3.new(.5, 1, 0)
				else
					highlight.FillColor = Color3.new(1, 0, 0)
				end
			end
		end)
	end
end)

tool.Unequipped:Connect(function()
	
	equipped = false
	game.Players.LocalPlayer.PlayerGui.MainUI.ConsoleTut.Visible = false
	if connection then connection:Disconnect() connection = nil end
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		if oldWalkSpeed then humanoid.WalkSpeed = oldWalkSpeed end
		if oldJumpPower then humanoid.JumpPower = oldJumpPower end
		if humanoid.WalkSpeed < 5 then humanoid.WalkSpeed = 21 end
	end
	local ui = player.PlayerGui:FindFirstChild("MobilePlacingUI")
	if ui then ui.Enabled = false end
end)

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if tool.Parent == player.Character and input.KeyCode == Enum.KeyCode.R then
		rotateEgg()
	elseif  tool.Parent == player.Character and input.KeyCode == Enum.KeyCode.ButtonB then
		rotateEgg()
	end
end)
