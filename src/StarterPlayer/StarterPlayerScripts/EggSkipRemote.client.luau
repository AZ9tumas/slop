local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local GAMEPASS_ID = 3405147695 -- replace with your actual id

local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EggSkipRemote")
local Shake = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shake")
local requestRemote = ReplicatedStorage.Remotes.RequestSkipEgg

remote.OnClientEvent:Connect(function(eggModel, state, eggId)
	if state == "Hatching" and eggModel and eggModel.PrimaryPart then
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = eggModel.Name
		prompt.ActionText = "Skip Timer"
		prompt.HoldDuration = 0
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 10
		prompt.Parent = eggModel.PrimaryPart
		prompt.Name = "Skip"
		prompt.Style = "Custom"
		prompt:SetAttribute("Theme", "DefaultGreen")
		prompt.Triggered:Connect(function()
			requestRemote:FireServer(eggId)
			MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, GAMEPASS_ID)
		end)
		repeat wait() until eggModel:GetAttribute("DoneHatching") or not eggModel
		prompt:Destroy()
	end
	if state == "Skipped" then
		for i,v in pairs(eggModel.PrimaryPart:GetDescendants()) do
			if v.Name == "Skip" then
				v:Destroy()
			end
		end
	end
end)
function SetupEggModel(Egg: Model)
	for _, Descendant in Egg:GetDescendants() do
		if not Descendant:IsA("BasePart") then
			continue
		end

		Descendant.CanCollide = false
		Descendant.Anchored = true
		Descendant.CanQuery = false
		Descendant.CanTouch = false
	end

	local Highlight = Instance.new("Highlight")

	Highlight.FillTransparency = 1
	Highlight.FillColor = Color3.fromRGB(255, 255, 255)
	Highlight.OutlineTransparency = 0.8
	Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)

	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	Highlight.Parent = Egg

	local Trail = Instance.new("Trail")
	local A0, A1 = Instance.new("Attachment"), Instance.new("Attachment")

	A0.Parent = Egg.PrimaryPart
	A1.Parent = Egg.PrimaryPart

	A0.CFrame = A0.CFrame - Vector3.yAxis * 3
	A1.CFrame = A1.CFrame + Vector3.yAxis * 3

	Trail.Attachment0 = A0
	Trail.Attachment1 = A1

	Trail.Lifetime = 0.15

	Trail.Parent = Egg
end
local TweenFast = require(game.ReplicatedStorage.Modules.Fast)
local EmitWorldConfetti = require(game.ReplicatedStorage.Modules.WorldConfetti)
local function ShakeAndExplodeEgg(EggModel:Model, Rarity: string)
--	SetupEggModel(EggModel)
	if EggModel.Handle:FindFirstChild("HatchPrompt") then
		EggModel.Handle.HatchPrompt.Enabled = false
	end
	local Circular = true
	local EggSpeed = 1
	local VFX = game.ReplicatedStorage.Game
	-- setup pivot value
	local CFrameValue = Instance.new("CFrameValue", EggModel)
	CFrameValue.Value = EggModel:GetPivot()

	-- setup scale + transparency controls
	local ScaleValue = Instance.new("NumberValue", EggModel)
	ScaleValue.Value = 1

	local TransparencyValue = Instance.new("NumberValue", EggModel)
	TransparencyValue.Value = 0
	-- initial shake variables
	local InitialShakeTime = EggSpeed * 1
	local Angle = math.rad(10)
	local Shakes = 15
	local Amplitude = 8
	local Origin = CFrameValue.Value

	-- attach VFX
	local Stars = VFX.Stars:Clone()
	Stars.Parent = EggModel.PrimaryPart

	local Impact = VFX.Impact:Clone()
	local Attachment = Instance.new("Attachment", EggModel.PrimaryPart)
	Attachment.CFrame = CFrame.new(0, 0.2, 0)
	Impact.Parent = Attachment

	-- shaking loop
	local TweenService = game:GetService("TweenService")

	for i = 1, Shakes do
		warn("Shake")

		local tweenInfo = TweenInfo.new(0.5 / i, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local tween1 = TweenService:Create(EggModel.PrimaryPart, tweenInfo, {
			CFrame = Origin * (Circular and CFrame.Angles(0, 0, Angle) or CFrame.Angles(Angle, 0, 0))
		})
		tween1:Play()
		Stars:Emit(Stars:GetAttribute("EmitCount"))
		Impact:Emit(Impact:GetAttribute("EmitCount"))
		tween1.Completed:Wait()
		local sound = game.ReplicatedStorage.Game.HatchingEggSound:Clone()
		sound.Parent = game.Players.LocalPlayer.Character.PrimaryPart
		sound:Play()
		game.Debris:AddItem(sound,4)
		local tween2 = TweenService:Create(EggModel.PrimaryPart, tweenInfo, {
			CFrame = Origin * (Circular and CFrame.Angles(0, 0, -Angle) or CFrame.Angles(-Angle, 0, 0))
		})
		tween2:Play()
		Stars:Emit(Stars:GetAttribute("EmitCount"))
		Impact:Emit(Impact:GetAttribute("EmitCount"))
		tween2.Completed:Wait()
		local sound = game.ReplicatedStorage.Game.HatchingEggSound:Clone()
		sound.Parent = game.Players.LocalPlayer.Character.PrimaryPart
		sound:Play()
		game.Debris:AddItem(sound,4)
	end


	-- reset position
	--TweenFast(CFrameValue, TweenInfo.new(InitialShakeTime / 10, Enum.EasingStyle.Linear), { Value = Origin }).Completed:Wait()

	-- EXPLOSION EFFECTS


	EmitWorldConfetti(EggModel, 30, 2, 2)

	local TweenService = game:GetService("TweenService")
	local model :Model= EggModel
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

	local targetScale = 1.4
	local tweenTime = 0.3

	local originalSizes = {}
	local originalCFrames = {}

	local cf = primaryPart.CFrame

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			originalSizes[part] = part.Size
			originalCFrames[part] = part.CFrame
			local transparencyTween = TweenService:Create(part, TweenInfo.new(tweenTime), {Transparency = 1})
			transparencyTween:Play()
		end
	end

	for part, originalSize in pairs(originalSizes) do
		if part.Parent then
			local goalSize = originalSize * targetScale
			local goalCFrame = cf * CFrame.new((originalCFrames[part].Position - cf.Position) * targetScale)
			local sizeTween = TweenService:Create(part, TweenInfo.new(tweenTime), {Size = goalSize, CFrame = goalCFrame})
			sizeTween:Play()
		end
	end

	wait(tweenTime)
	local sound = game.ReplicatedStorage.Game.HatchedEgg:Clone()
	sound.Parent = game.Players.LocalPlayer.Character.PrimaryPart
	sound:Play()
    local CollectPart = Instance.new("Part", workspace.Map.Unsorted)
	CollectPart.Anchored = true
    CollectPart.Transparency = 1
    CollectPart.CanCollide = false
   	CollectPart.CanTouch = false
	CollectPart.CFrame = model:GetPivot() or model.Handle.CFrame or model.Part.CFrame
	game.Debris:AddItem(CollectPart, 6)
	if Rarity and require(game.ReplicatedStorage.Info.EggInfo)[Rarity .. " Egg"] and require(game.ReplicatedStorage.Info.EggInfo)[Rarity .. " Egg"].HatchVFX then		
		local VFX = require(game.ReplicatedStorage.Info.EggInfo)[Rarity .. " Egg"].HatchVFX:Clone()
		VFX.Parent = CollectPart
		VFX:Emit(10)
	end
	if require(game.ReplicatedStorage.Info.EggInfo)[Rarity .. " Egg"].HatchSound then
		local soundH = Instance.new("Sound", CollectPart)
		soundH.SoundId = require(game.ReplicatedStorage.Info.EggInfo)[Rarity .. " Egg"].HatchSound
		soundH.Volume = 1.5
		soundH.RollOffMaxDistance = 150
		soundH:Play()
	end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part:Destroy()
		end
	end
	
	
	--local VFX = ReplicatedStorage.Info.EggInfo[EggModel]
	game.Debris:AddItem(sound,4)
	model:Destroy()

end
Shake.OnClientInvoke =function(egg, R)
	
	ShakeAndExplodeEgg(egg, R)
end