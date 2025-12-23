local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages:WaitForChild("Knit"))

local function setupViewportModel(viewport, model)
	for _, child in ipairs(viewport:GetChildren()) do
		if not child:IsA("UIBase") then
			child:Destroy()
		end
	end

	local modelClone = model:Clone()
	modelClone.Parent = viewport

	if not modelClone.PrimaryPart then
		local primary = modelClone:FindFirstChildWhichIsA("BasePart")
		if primary then modelClone.PrimaryPart = primary end
	end

	if modelClone.PrimaryPart then
		local offset = modelClone.PrimaryPart.Position
		for _, part in ipairs(modelClone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Position = part.Position - offset
			end
		end
	end

	local cam = Instance.new("Camera")
	cam.Parent = viewport
	viewport.CurrentCamera = cam
	local cf, size = modelClone:GetBoundingBox()
	local centerY = size.Y / 2
	local maxDim = math.max(size.X, size.Y, size.Z)
	local padding = 1.2
	local dist = maxDim * padding

	cam.CFrame = CFrame.new(Vector3.new(0, centerY - 1, dist), Vector3.new(0, centerY, 0)) * CFrame.new(0, 0, -2)
	local startRotation = modelClone.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(240), 0)
	modelClone:SetPrimaryPartCFrame(startRotation)

	local ROTATION_SPEED = math.rad(75)
	local spinning = false
	local rotationConn = nil

	local function startSpin()
		if spinning then return end
		spinning = true
		local last = tick()
		rotationConn = RunService.RenderStepped:Connect(function()
			local now = tick()
			local dt = now - last
			last = now
			if modelClone and modelClone.PrimaryPart and modelClone.PrimaryPart.CFrame then
			    modelClone:SetPrimaryPartCFrame(modelClone.PrimaryPart.CFrame * CFrame.Angles(0, ROTATION_SPEED * dt, 0))
			end	
			end)
	end

	local function stopSpin()
		spinning = false
		modelClone:SetPrimaryPartCFrame(startRotation)
		if rotationConn then
			rotationConn:Disconnect()
			rotationConn = nil
		end
	end

	return startSpin, stopSpin
end

local template = script.Template
local scrollingFrame = script.Parent.Holder.ScrollingFrame
local InventoryService = Knit.GetService("InventoryService")
local unlocked 

local function addHoverStroke(uiObject, strokeThickness, tweenTime)
	strokeThickness = strokeThickness or 4
	tweenTime = tweenTime or 0.15

	local uiStroke = uiObject:FindFirstChildWhichIsA("UIStroke")
	if not uiStroke then return end
	local originalThickness = 2.6

	uiObject.MouseEnter:Connect(function()
		TweenService:Create(
			uiStroke,
			TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Thickness = strokeThickness}
		):Play()
	end)

	uiObject.MouseLeave:Connect(function()
		TweenService:Create(
			uiStroke,
			TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Thickness = originalThickness}
		):Play()
	end)
end

repeat 
	task.wait() 
	InventoryService:GetUnlocked():andThen(function(rawInventory)
		unlocked = rawInventory
	end)
until unlocked

local function SortPigeons(pigeons)
	local sorted = {}
	for name, data in pairs(pigeons) do
		table.insert(sorted, { Name = name, Data = data })
	end
	table.sort(sorted, function(a, b)
		if a.Data.Price == b.Data.Price then
			return a.Data.Multiplier < b.Data.Multiplier
		end
		return a.Data.Price < b.Data.Price
	end)
	return sorted
end

local EggInfo = require(game.ReplicatedStorage.Info.EggInfo)
local PigeonToEgg = {}
for eggName, eggData in pairs(EggInfo) do
	for _, pigeon in ipairs(eggData.Pigeons) do
		PigeonToEgg[pigeon.Name] = eggName
	end
end

local tooltip = Instance.new("TextLabel")
tooltip.Size = UDim2.new(0, 150, 0, 30)
tooltip.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
tooltip.BackgroundTransparency = 0.7
tooltip.TextColor3 = Color3.new(1, 1, 1)
tooltip.TextScaled = true
tooltip.Visible = false
tooltip.Parent = script.Parent.Parent.Parent.Parent.MainUI
tooltip.Font = Enum.Font.BuilderSansBold
tooltip.AnchorPoint = Vector2.new(0.5, 0)
tooltip.Position = UDim2.new(0.5, 0, 0.05, 0)

local UICorner = Instance.new("UICorner", tooltip)
UICorner.CornerRadius = UDim.new(0, 6)

local Stroke = Instance.new("UIStroke", tooltip)
Stroke.Thickness = 2

-- Centralized function to update tooltip position (safe-guards included)
local function updateTooltipPosition(pos)
	if not tooltip.Visible then return end
	if not pos then return end

	-- Keep tooltip inside screen bounds a bit (optional small clamp)
	local screenX = math.clamp(pos.X + 15, 8, math.max(8, tonumber(tostring(workspace.CurrentCamera.ViewportSize.X)) - tooltip.Size.X.Offset - 8))
	local screenY = math.clamp(pos.Y + 15, 8, math.max(8, tonumber(tostring(workspace.CurrentCamera.ViewportSize.Y)) - tooltip.Size.Y.Offset - 8))

	-- Using fromOffset to match original behavior
	tooltip.Position = UDim2.fromOffset(screenX, screenY)
end

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Global input handlers for mouse and touch movement
UserInputService.InputChanged:Connect(function(input)
	-- Mouse movement (PC)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if tooltip.Visible then
			updateTooltipPosition(input.Position)
		end
		-- Touch can also appear here on some devices, handle it too
	elseif input.UserInputType == Enum.UserInputType.Touch then
		if tooltip.Visible then
			updateTooltipPosition(input.Position)
		end
	end
end)

-- TouchMoved event is a direct way to track touch drags on mobile
if UserInputService.TouchMoved then
	UserInputService.TouchMoved:Connect(function(touch)
		if tooltip.Visible then
			updateTooltipPosition(touch.Position)
		end
	end)
end

local function buildInventoryUI()
pcall(function()
	local CountUnlockedPigeons = 0
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextButton") then

			child:Destroy()
		end
	end
	task.wait(.1)

	local index = SortPigeons(require(game.ReplicatedStorage.Info.PigeonInfo))
	local count = 0
	for k, v in pairs(unlocked) do
		count = count + 1
	end
	local GoodLimit = 0
	for _, data in pairs(index) do
		if not scrollingFrame:FindFirstChild(data.Name) then
		task.wait()
		local pigeonName = data.Name
		local model = game.ReplicatedStorage.Game.Pigeons:FindFirstChild(pigeonName)
		if unlocked[pigeonName] then CountUnlockedPigeons += 1 end
		if not model then
			continue
		end
		GoodLimit += 1
		local button = template:Clone()
		button.Title.Text = pigeonName
		button.Parent = scrollingFrame
		button.Visible = true

		if GoodLimit > 22 and GoodLimit < 31 then
			button.UIStroke.Color = Color3.fromRGB(204, 0, 255)
			button.UIStroke.Transparency = 0
		elseif GoodLimit > 30 and GoodLimit < 39 then
			button.UIStroke.Color = Color3.fromRGB(255, 225, 0)
			button.UIStroke.Transparency = 0
		elseif GoodLimit > 38 and GoodLimit < 45 then
			button.UIStroke.Color = Color3.fromRGB(255, 38, 0)
			button.UIStroke.Transparency = 0
		elseif GoodLimit > 44 then
			button.UIStroke.Transparency = 0
			button.UIStroke.Color = Color3.fromRGB(255, 255, 255)
			local rainbowc = script.RainbowColor:Clone()
			rainbowc.Parent = button.UIStroke
		end

		local viewport = button:FindFirstChildWhichIsA("ViewportFrame")
		if viewport then
			local startSpin, stopSpin = setupViewportModel(viewport, model)
			button.MouseEnter:Connect(startSpin)
			button.MouseLeave:Connect(stopSpin)
			if unlocked then
				if not unlocked[pigeonName] then
					viewport.ImageColor3 = Color3.new(0, 0, 0)
				end
			end


			-- Reusable function to show tooltip for a given pigeon name (keeps code DRY)
			local function showTooltipForPigeon()
				local eggName = PigeonToEgg[pigeonName]
				if eggName then
					tooltip.Text = eggName
					tooltip.Visible = true
					if tooltip:FindFirstChildWhichIsA("UIGradient") then
						tooltip:FindFirstChildWhichIsA("UIGradient"):Destroy()
					end
					local EggNameS = eggName
					local resultName = eggName:gsub("%sEgg$", "")
					if game.ReplicatedStorage.Game["Eggs"]:FindFirstChild(resultName)
						and game.ReplicatedStorage.Game["Eggs"]:FindFirstChild(resultName).Egg
						and game.ReplicatedStorage.Game["Eggs"]:FindFirstChild(resultName).Egg.BillboardGui
						and game.ReplicatedStorage.Game["Eggs"]:FindFirstChild(resultName).Egg.BillboardGui:FindFirstChild("Name")
					then
						-- original cloning logic (kept but guarded)
						-- note: we keep the original logic below but with safe checks
					end

					-- Safely attempt to apply UIGradient from egg (preserve original intent with safety)
					local ok, egg = pcall(function()
						return game.ReplicatedStorage.Game["Eggs"]:FindFirstChild(resultName)
					end)
					if ok and egg and egg:FindFirstChild("Egg") and egg.Egg:FindFirstChild("BillboardGui") then
						local nameGui = egg.Egg.BillboardGui:FindFirstChild("Name")
						if nameGui and nameGui:FindFirstChild("UIGradient") then
							local ColorClone = nameGui:FindFirstChild("UIGradient"):Clone()
							ColorClone.Parent = tooltip
						end
					end
				end
			end

			-- keep original MouseEnter behavior but call the DRY function
			button.MouseEnter:Connect(function()
				startSpin()
				showTooltipForPigeon()
				
			end)

			button.MouseLeave:Connect(function()
				stopSpin()
				tooltip.Visible = false
			end)

			-- Mobile: show tooltip on touch begin and follow touch; hide on touch end
			button.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					-- Show tooltip text & position it at the touch start
					showTooltipForPigeon()
					if input.Position then
						updateTooltipPosition(input.Position)
					end
				end
			end)

			button.InputChanged:Connect(function(input)
				-- If the touch moves on this button, update tooltip
				if input.UserInputType == Enum.UserInputType.Touch then
					if tooltip.Visible and input.Position then
						updateTooltipPosition(input.Position)
					end
				end
			end)

			button.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					tooltip.Visible = false
				end
			end)
		end

		addHoverStroke(button)
	end
	end
	script.Parent.Top.Title.Text = "Index ("..CountUnlockedPigeons.."/"..#index..")"
	end)
end

buildInventoryUI()


game.ReplicatedStorage.Remotes.InventoryUpdate.OnClientEvent:Connect(function(newInventory)
	warn("Calling Inventory")
	_G.UpdateInvs()
	local currentUnlock = false
	repeat
		task.wait()
		warn("Attempting")
		InventoryService:GetUnlocked():andThen(function(rawInventory)

			unlocked = rawInventory
			currentUnlock = true
		end)
	until currentUnlock == true
	buildInventoryUI()
	warn("Built inventory")
end)

script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	--if script.Parent.Visible then
	--	InventoryService:GetUnlocked():andThen(function(rawInventory)
	--		unlocked = rawInventory
	--	end)
	--	buildInventoryUI()
	--end
end)

-- Keep existing mouse movement behavior intact as a fallback
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if tooltip.Visible then
			local mouse = input.Position
			tooltip.Position = UDim2.fromOffset(mouse.X + 15, mouse.Y + 15)
		end
	end
end)