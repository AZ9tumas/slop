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

local placingInProgress = false
local moveSpeed = 1

local function getMyPlot(player)
	for _, plot in ipairs(workspace.Map.Plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId and ownerId == player.UserId then
			return plot
		end
	end
	return nil
end

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
	if equipped == false then return end
	if canPlace == false or placingInProgress then return end

	if getMyPlot(game.Players.LocalPlayer):FindFirstChild("Eggs") then
		if #getMyPlot(game.Players.LocalPlayer).Eggs:GetChildren() >= require(game.ReplicatedStorage.Info.InventoryInfo).PlacableEggs then
			_G.Notification("Reached max amount of placable eggs")
			return
		end
	end
	if not previewCFrame or not canPlace then return end

	placingInProgress = true
	canPlace = false

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
	if result and result.Instance.Parent.Name == "Floor" and result.Instance:IsDescendantOf(getMyPlot(player)) and nearbyInvalid == false then
		local floorCFrame = result.Instance.CFrame
		local relativeCFrame = floorCFrame:ToObjectSpace(previewCFrame)

		-- Removed timeout to prevent exploit where lag allows multiple clicks
		local timedOut = false
		
		local ok, promise = pcall(function()
			return EggManager:PlaceEgg(tool.Name, {relativeCFrame:GetComponents()}, tool:GetAttribute("Mutation"), tool:GetAttribute("EggId"))
		end)
		if not ok or not promise then
			placingInProgress = false
			task.delay(1.5, function() canPlace = true end)
			_G.Notification("Failed to place egg")
			return
		end

		local handled = false
		if promise.andThen then
			promise:andThen(function(success)
				if handled then return end
				handled = true
				if success then
					task.defer(function()
						game.ReplicatedStorage.Remotes.RequestTool:InvokeServer(nil,nil,tool:GetAttribute("EggId"),true)
						if tool then tool:Destroy() game.ReplicatedStorage.Remotes.DeleteItem:FireServer(tool) game.Players.LocalPlayer.PlayerGui.MainUI.ConsoleTut.Visible = false end
					end)
				else
					_G.Notification("Failed to place egg")
				end
				placingInProgress = false
				task.delay(1.4, function() canPlace = true end)
			end)
			if promise.catch then
				promise:catch(function()
					if handled then return end
					handled = true
					_G.Notification("Failed to place egg")
					placingInProgress = false
					task.delay(1.5, function() canPlace = true end)
				end)
			end
		else
			local ok2, res = pcall(function() return promise:await() end)
			if ok2 and res then
				task.defer(function()
					game.ReplicatedStorage.Remotes.RequestTool:InvokeServer(nil,nil,tool:GetAttribute("EggId"),true)
					if tool then tool:Destroy() game.ReplicatedStorage.Remotes.DeleteItem:FireServer(tool) end
				end)
			else
				_G.Notification("Failed to place egg")
			end
			placingInProgress = false
			task.delay(1.5, function() canPlace = true end)
		end

		local ui = player.PlayerGui:FindFirstChild("MobilePlacingUI")
		if ui then ui.Enabled = false end
	else
		placingInProgress = false
		task.delay(1.5, function() canPlace = true end)
	end
end

tool.Equipped:Connect(function()
	equipped = true
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")

	for i,v in pairs(script.Parent:WaitForChild("Handle"):GetDescendants()) do
		if v:IsA("ProximityPrompt")  then v:Destroy() end
		if v:IsA("BasePart") then v.CanCollide = false end
		if v.Name == "HandleWeld" then v:Destroy() end
	end
	game.ReplicatedStorage.Remotes.Delete:InvokeServer(tool.Name)
	if game.UserInputService.GamepadEnabled then
		game.Players.LocalPlayer.PlayerGui.MainUI.ConsoleTut.Visible = true
	end

	script.Parent:WaitForChild("Handle").BillboardGui.Price.Visible = false
	local highlight = script.Parent:WaitForChild("Handle"):FindFirstChild("Highlight") or Instance.new("Highlight",script.Parent:WaitForChild("Handle"))
	highlight.FillColor = Color3.new(0.5, 1, 0)
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = .5

	if UIS.TouchEnabled then
		local ui = player.PlayerGui:WaitForChild("MobilePlacingUI")
		ui.Enabled = true

		-- 🔁 Rotate + instantly show the rotation
		ui.Main.Holder.Rotate.MouseButton1Click:Connect(function()
			rotateEgg()
			if previewCFrame then
				local pos = previewCFrame.Position
				local rotation = CFrame.Angles(0, math.rad(rotationY), 0)
				previewCFrame = CFrame.new(pos) * rotation
				model:SetPrimaryPartCFrame(previewCFrame)
			end
		end)

		ui.Main.Holder.Place.MouseButton1Click:Connect(function() placeEgg(humanoid) end)
		ui.Main.Holder.Reset.MouseButton1Click:Connect(function() updateEggPosition(root) end)

		local camera = workspace.CurrentCamera
		local tapCooldown = false

		UIS.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.UserInputType ~= Enum.UserInputType.Touch then return end
			if placingInProgress or not equipped then return end
			if tapCooldown then return end

			tapCooldown = true
			task.delay(0.12, function() tapCooldown = false end)

			local screenPos = input.Position
			local ray = camera:ScreenPointToRay(screenPos.X, screenPos.Y)
			local rayOrigin = ray.Origin
			local rayDirection = ray.Direction * 500

			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			rayParams.FilterDescendantsInstances = {model, player.Character}

			local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
			if not result or not result.Instance then return end

			local plot = getMyPlot(player)
			local hitPart = result.Instance
			local highlight = model:FindFirstChildOfClass("Highlight")
			local isOnFloor = hitPart.Parent.Name == "Floor" and plot and hitPart:IsDescendantOf(plot)

			-- 🟥 Always move preview even if invalid
			local size = model:GetExtentsSize()
			local cf = model:GetBoundingBox()
			local bottomY = (cf.Position - Vector3.new(0, size.Y / 2, 0)).Y
			local pivotY = model.PrimaryPart.Position.Y
			local offsetY = pivotY - bottomY
			local rotation = CFrame.Angles(0, math.rad(rotationY), 0)
			local baseCFrame = CFrame.new(result.Position.X, result.Position.Y + offsetY, result.Position.Z)
			previewCFrame = baseCFrame * rotation
			model:SetPrimaryPartCFrame(previewCFrame)

			-- Check overlap
			local nearbyInvalid = false
			for _, nearby in ipairs(workspace:GetPartBoundsInRadius(model.PrimaryPart.Position, 2)) do
				local parentModel = nearby:FindFirstAncestorOfClass("Model")
				if parentModel and (string.find(parentModel.Name, "Egg") or string.find(parentModel.Name, "Pigeon")) then
					nearbyInvalid = true
					break
				end
			end

			if highlight then
				if isOnFloor and not nearbyInvalid then
					highlight.FillColor = Color3.new(0.5, 1, 0)
				else
					highlight.FillColor = Color3.new(1, 0, 0)
				end
			end
		end)

		connection = rs.RenderStepped:Connect(function()
			for _, v in pairs(tool.Handle:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency = 0
					v.CanCollide = false
				end
				if v.Name == "HandleWeld" then v:Destroy() end
			end
			script.Parent:WaitForChild("Handle").PrimaryPart.Anchored = true
		end)
	else
		local mouse = player:GetMouse()
		mouse.Button1Down:Connect(function() if equipped then placeEgg(humanoid) end end)
		connection = rs.RenderStepped:Connect(function()
			for i,v in pairs(tool.Handle:GetDescendants()) do
				if v:IsA("BasePart") then v.Transparency = 0 end
			end
			local pos = mouse.Hit.p
			local rotation = CFrame.Angles(0, math.rad(rotationY), 0)
			local rayOrigin = pos + Vector3.new(0, 50, 0)
			local rayDirection = Vector3.new(0, -200, 0)
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			rayParams.FilterDescendantsInstances = {model}
			local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
			if result then
				local size = model:GetExtentsSize()
				local cf = model:GetBoundingBox()
				local bottomY = (cf.Position - Vector3.new(0, size.Y / 2, 0)).Y
				local pivotY = model.PrimaryPart.Position.Y
				local offsetY = pivotY - bottomY
				local baseCFrame = CFrame.new(result.Position.X, result.Position.Y + offsetY, result.Position.Z)
				previewCFrame = baseCFrame * rotation
				model:SetPrimaryPartCFrame(previewCFrame)
				local highlight = model:FindFirstChild("Highlight")
				local isOnFloor = result.Instance.Parent.Name == "Floor" and result.Instance:IsDescendantOf(getMyPlot(player))
				local nearbyInvalid = false
				for _, nearby in ipairs(workspace:GetPartBoundsInRadius(model.PrimaryPart.Position, 2)) do
					local parentModel = nearby:FindFirstAncestorOfClass("Model")
					if parentModel and (string.find(parentModel.Name, "Egg") or string.find(parentModel.Name, "Pigeon")) then
						nearbyInvalid = true
						break
					end
				end
				if isOnFloor and not nearbyInvalid then
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
	if connection then connection:Disconnect() connection=nil end
	local ui = player.PlayerGui:FindFirstChild("MobilePlacingUI")
	if ui then ui.Enabled = false end
end)

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if tool.Parent == player.Character and (input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.ButtonB) then
		rotateEgg()
		if previewCFrame then
			local pos = previewCFrame.Position
			local rotation = CFrame.Angles(0, math.rad(rotationY), 0)
			previewCFrame = CFrame.new(pos) * rotation
			model:SetPrimaryPartCFrame(previewCFrame)
		end
	end
end)
