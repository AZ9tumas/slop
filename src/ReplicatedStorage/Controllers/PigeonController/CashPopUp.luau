local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer


local Amount = 0--dont change
local Billboard = game.ReplicatedStorage.Game.VFX:WaitForChild("Popup")

local TimerDuration = 2
local ActivePart = nil

local TweenInInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenOutInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local LastResetId = 0

local function TweenIn(ui)
	TweenService:Create(ui.ImageLabel, TweenInInfo, {ImageTransparency = 0}):Play()
	TweenService:Create(ui.Amount, TweenInInfo, {TextTransparency = 0}):Play()
	TweenService:Create(ui.Amount.UIStroke, TweenInInfo, {Transparency = 0}):Play()
end

local function TweenOut(part, ui)
	local FadeImage = TweenService:Create(ui.ImageLabel, TweenOutInfo, {ImageTransparency = 1})
	local FadeText = TweenService:Create(ui.Amount, TweenOutInfo, {TextTransparency = 1})
	TweenService:Create(ui.Amount.UIStroke, TweenOutInfo, {Transparency = 1}):Play()

	FadeImage:Play()
	FadeText:Play()

	FadeText.Completed:Once(function()
		if part then part:Destroy() end
	end)
end

return function(added: number)
	local Character = Player.Character
	Amount += added
	
	LastResetId += 1
	local ThisResetId = LastResetId
	
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	local StartPosition = HumanoidRootPart.Position
	local EndPosition = HumanoidRootPart.Position + vector.create(0, 1, 0)

	if not ActivePart then
		local Part = Instance.new("Part")
		Part.Name = "CurrencyPart"
		Part.Anchored = true
		Part.Size = Vector3.one
		Part.Position = StartPosition
		Part.Transparency = 1
		Part.CanCollide = false
		Part.Parent = workspace
		ActivePart = Part

		local ClonedBillboard = Billboard:Clone()
		ClonedBillboard.Adornee = Part
		ClonedBillboard.Parent = Part
		ClonedBillboard.Amount.Text = math.floor(Amount)

		ClonedBillboard.ImageLabel.ImageTransparency = 1
		ClonedBillboard.Amount.TextTransparency = 1
		ClonedBillboard.Amount.UIStroke.Transparency = 1

		TweenIn(ClonedBillboard)

		TweenService:Create(Part, TweenInInfo, {Position = EndPosition}):Play()
	else
		ActivePart.Position = StartPosition
		TweenService:Create(ActivePart, TweenInInfo, {Position = EndPosition}):Play()

		local ClonedBillboard = ActivePart[Billboard.Name]
		if ClonedBillboard then
			ClonedBillboard.Amount.Text = math.floor(Amount)
		end
	end

	task.delay(TimerDuration, function()
		if ThisResetId == LastResetId then
			Amount = 0

			if ActivePart then
				local clonedBillboard = ActivePart:FindFirstChild(Billboard.Name)
				if clonedBillboard then
					TweenOut(ActivePart, clonedBillboard)
				else
					ActivePart:Destroy()
				end
				ActivePart = nil
			end
		end
	end)
end