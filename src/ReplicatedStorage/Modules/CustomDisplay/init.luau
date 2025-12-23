local module = {}

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local UISounds = require(script:WaitForChild("UISounds"))

local rewardQueue = {}
local isShowing = false

local NotificationTemplate = script:WaitForChild("Notification") -- UI template

local function showNextReward()
	if #rewardQueue == 0 then
		isShowing = false
		return
	end

	isShowing = true
	local reward = table.remove(rewardQueue, 1)
	local icon, topText, bottomText = unpack(reward)

	-- Blur
	local Blur = Instance.new("BlurEffect")
	Blur.Size = 0
	Blur.Parent = Lighting
	TweenService:Create(Blur, TweenInfo.new(0.6), {Size = 20}):Play()

	-- UI
	local UI = NotificationTemplate:Clone()
	UI.Parent = player:WaitForChild("PlayerGui")
	UI.Main.ImageLabel.Image = icon
	UI.Main.TopText.Text = topText
	UI.Main.BottomText.Text = bottomText

	local TweenStartLine = TweenService:Create(UI.Main, TweenInfo.new(0.27, Enum.EasingStyle.Quart), {
		Size = UDim2.new(1, 0, 0.026, 0),
		Position = UDim2.new(0, 0, 0.538, 0)
	})
	local TweenStart = TweenService:Create(UI.Main, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
		Size = UDim2.new(1, 0, 0.45, 0),
		Position = UDim2.new(0, 0, 0.274, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	})
	local TweenEnd = TweenService:Create(UI.Main, TweenInfo.new(0.55, Enum.EasingStyle.Circular), {
		Size = UDim2.new(1, 0, 0.001, 0),
		Position = UDim2.new(0, 0, 0.494, 0)
	})

	TweenStartLine:Play()
	UISounds:Play("OnSwipe")
	TweenService:Create(UI.Main.UIStroke, TweenInfo.new(0.3), {Thickness = 6.6}):Play()
	task.wait(0.3)
	TweenService:Create(UI.Main.UIStroke, TweenInfo.new(0.3), {Thickness = 0}):Play()
	TweenStart:Play()

	UI.Main.ImageLabel.Visible = true
	UI.Main.TopText.Visible = true
	UI.Main.BottomText.Visible = true

	task.wait(0.75)
	UISounds:Play("ItemThere")
	UI.Main.Close.Visible = true

	local connection
	connection = UserInputService.InputBegan:Connect(function(input, processed)
		--if processed then return end

		if input.UserInputType == Enum.UserInputType.Touch 
			or input.UserInputType == Enum.UserInputType.MouseButton1 
			or input.UserInputType == Enum.UserInputType.Gamepad1 then
			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				local key = input.KeyCode
				if key ~= Enum.KeyCode.ButtonA and key ~= Enum.KeyCode.ButtonB then
					return
				end
			end

			connection:Disconnect()
			UI.Main.Close.Visible = false
			UISounds:Play("OffSwipe")

			TweenService:Create(UI.Main.ImageLabel, TweenInfo.new(0.43), {ImageTransparency = 1}):Play()
			TweenService:Create(UI.Main.TopText, TweenInfo.new(0.43), {Transparency = 1}):Play()
			TweenService:Create(UI.Main.BottomText, TweenInfo.new(0.43), {Transparency = 1}):Play()
			TweenService:Create(Blur, TweenInfo.new(0.65), {Size = 0}):Play()
			TweenEnd:Play()

			task.wait(0.55)
			Blur:Destroy()
			UI:Destroy()
			showNextReward()
		end

	end)
end

function module.QueueReward(icon, topText, bottomText)
	table.insert(rewardQueue, {icon, topText, bottomText})
	if not isShowing then
		showNextReward()
	end
end

return module
