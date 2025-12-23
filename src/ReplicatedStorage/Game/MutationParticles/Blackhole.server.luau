wait(0.8)
local blackhole = game.ReplicatedStorage.Game.BlackholeVFX:Clone()

local model-- = script.Parent.Parent
if script.Parent.Parent:IsA("Model") then
	model = script.Parent.Parent
else
	model = script.Parent.Parent.Parent
end
local primaryCFrame, size = model:GetBoundingBox()

-- Calculate the top world position of the model
local topPosition = primaryCFrame.Position + Vector3.new(0, size.Y / 2, 0)

-- Set blackhole above the top with a 90° Y rotation
blackhole:SetPrimaryPartCFrame(
	CFrame.new(topPosition) * CFrame.Angles(math.rad(90), 0, 0)
)

-- Weld blackhole to model
local weld = Instance.new("Weld")
weld.Part0 = model.PrimaryPart
weld.Part1 = blackhole.Main
weld.C0 = model.PrimaryPart.CFrame:ToObjectSpace(blackhole.Main.CFrame)
weld.Parent = blackhole.Main

blackhole.Parent = model