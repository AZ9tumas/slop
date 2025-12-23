task.wait(5)
local TweenService = game:GetService("TweenService")

local HOVER_SCALE = 1.08 
local CLICK_SCALE = 0.95
local TWEEN_TIME = 0.15

local function tweenObject(obj, goal, time)
	local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(obj, tweenInfo, goal)
	tween:Play()
	return tween
end

local function applyButtonEffect(button)
	local originalSize = button.Size
	local hoverSize = UDim2.new(originalSize.X.Scale * HOVER_SCALE, originalSize.X.Offset,
		originalSize.Y.Scale * HOVER_SCALE, originalSize.Y.Offset)
	local clickSize = UDim2.new(originalSize.X.Scale * CLICK_SCALE, originalSize.X.Offset,
		originalSize.Y.Scale * CLICK_SCALE, originalSize.Y.Offset)

	button.MouseEnter:Connect(function()
		tweenObject(button, {Size = hoverSize}, TWEEN_TIME)
		local sound = script.Hover:Clone()
		sound.Parent = script
		sound:Play()
		game.Debris:AddItem(sound, 5)
	end)

	button.MouseLeave:Connect(function()
		tweenObject(button, {Size = originalSize}, TWEEN_TIME)
	end)

	button.MouseButton1Down:Connect(function()
		tweenObject(button, {Size = clickSize}, TWEEN_TIME * 0.8)
		local sound = script.Click:Clone()
		sound.Parent = script
		sound:Play()
		game.Debris:AddItem(sound, 5)
	end)

	button.MouseButton1Up:Connect(function()
		local mouse = game.Players.LocalPlayer:GetMouse()
		if button.AbsolutePosition.X <= mouse.X and mouse.X <= button.AbsolutePosition.X + button.AbsoluteSize.X
			and button.AbsolutePosition.Y <= mouse.Y and mouse.Y <= button.AbsolutePosition.Y + button.AbsoluteSize.Y then
			tweenObject(button, {Size = hoverSize}, TWEEN_TIME)
		else
			tweenObject(button, {Size = originalSize}, TWEEN_TIME)
		end
	end)
end

local player = game.Players.LocalPlayer
local function scanGui(gui)
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextButton") or obj:IsA("ImageButton") then
			applyButtonEffect(obj)
		end
	end
end

for _, gui in ipairs(player:WaitForChild("PlayerGui"):GetChildren()) do
	scanGui(gui)
end

player.PlayerGui.MainUI.ChildAdded:Connect(scanGui)
player.PlayerGui.MobilePlacingUI.ChildAdded:Connect(scanGui)
player.PlayerGui.dialog.ChildAdded:Connect(scanGui)
player.PlayerGui.MainUI.Frames.ChildAdded:Connect(scanGui)
