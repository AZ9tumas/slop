local Orbs = {}

local player = game.Players.LocalPlayer


local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraEffect = require(game.ReplicatedStorage.Modules.Camera)

local OrbObject = ReplicatedStorage.Game.VFX.CashEffect

function Orbs.Play(duration : number, amount : number, position : Vector3, GemPitch : NumberValue)
	local Character = player.Character
	task.delay(duration, function()
		local clonesound = script.CollectSound:Clone()
		clonesound.Parent = Character.HumanoidRootPart
		clonesound.PlaybackSpeed = math.random(1, 1.25)
		clonesound:Play()
		local Pitch = math.min(0.96 + (GemPitch.Value/25), 2.5)
		clonesound.PitchShiftSoundEffect.Octave = Pitch
		game.Debris:AddItem(clonesound, 3)
		local CollectPart = Instance.new("Part", workspace.Map.Unsorted)
		CollectPart.Anchored = true
		CollectPart.Transparency = 1
		CollectPart.CanCollide = false
		CollectPart.CanTouch = false
		CollectPart.CFrame = Character.HumanoidRootPart.CFrame
		
		local VFX = script.VFX:Clone()
		VFX.Parent = CollectPart
		VFX:Emit(8)
		game.Debris:AddItem(CollectPart, 4)
		--CameraEffect.shake({shake = "Light_Bump"})
		local Highlight = Instance.new("Highlight", Character)
		Highlight.FillTransparency = 0
		Highlight.OutlineTransparency = 1
		Highlight.FillColor = Color3.fromRGB(255, 225, 1)
		Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		local Tween = TweenService:Create(Highlight, TweenInfo.new(0.2), {FillTransparency = 1})
		Tween:Play()
		task.delay(0.2, function()
			Highlight:Destroy()
		end)
	end)
	for i = 1, amount do 
		local Clone = OrbObject:Clone()
		Clone.Position = position
		Clone.Parent = workspace

		local t = 0
		local Connection = nil

		local RandomX = Random.new():NextInteger(-3, 20)
		local RandomY = Random.new():NextInteger(-3, 10)

		local spinSpeed = 720

		Connection = RunService.RenderStepped:Connect(function(Delta : number)
			t = math.clamp(t + Delta / duration, 0, 1)

			local p0 = position
			local p2 = Character.HumanoidRootPart.Position
			local midpoint = (p0 + p2) / 2
			local p1 = midpoint + Vector3.new(RandomX, RandomY, 0)

			local NewPos = (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
			Clone.Position = NewPos


local currentRotation = Clone.Orientation
			local newYaw = (currentRotation.Y + spinSpeed * Delta) % 360
			Clone.Orientation = Vector3.new(currentRotation.X, newYaw, currentRotation.Z)

			if t >= 1 then
				Connection:Disconnect()
				Connection = nil

				local Tween = TweenService:Create(Clone, TweenInfo.new(0.5), {Transparency = 1})
				Tween:Play()

				Tween.Completed:Connect(function()
					
					Clone:Destroy()
				end)
			end
		end)
	end
end

return Orbs
