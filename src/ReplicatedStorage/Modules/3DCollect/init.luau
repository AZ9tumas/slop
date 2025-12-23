local Orbs = {}

local player = game.Players.LocalPlayer


local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraEffect = require(game.ReplicatedStorage.Modules.Camera)


local OrbObject = ReplicatedStorage.Game.VFX.Star

function Orbs.Play(duration : number, position : Vector3)
	local Character = player.Character
	task.delay(duration, function()
		local cs = script.CollectSound:Clone()
		cs.Parent = Character
		cs.PlaybackSpeed = math.random(1.1, 1.5)
		cs:Play()
		game.Debris:AddItem(cs, 5)
		local Shine = ReplicatedStorage.Game.VFX.Shine.Main:Clone()
		Shine.Parent = Character.HumanoidRootPart
		Shine.Light:Emit(2)
		CameraEffect.shake({shake = "Heavy_Bump"})
		local Highlight = Instance.new("Highlight", Character)
		Highlight.FillTransparency = 0
		Highlight.OutlineTransparency = 1
		Highlight.FillColor = Color3.fromRGB(55, 255, 0)
		Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		local Tween = TweenService:Create(Highlight, TweenInfo.new(1), {FillTransparency = 1})
		Tween:Play()
		task.delay(1, function()
			Highlight:Destroy()
		end)
	end)
		local Clone = OrbObject:Clone()
		Clone.Position = position
		Clone.Parent = workspace

		local t = 0
		local Connection = nil

		local RandomX = Random.new():NextInteger(-6, 25)
		local RandomY = Random.new():NextInteger(-6, 15)

		local spinSpeed = 400

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

return Orbs
