wait(0.8)
--[[local blackhole = game.ReplicatedStorage.Game.BlackholeVFX:Clone()

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
]]

for _, Part in script.Parent.Parent:GetDescendants() do
    if Part:IsA("BasePart") and Part.Transparency ~= 1 and not script.Parent.Parent:FindFirstChild("AlreadyFrozen") then
        local Ice = Part:Clone()
        Ice.Parent = script.Parent.Parent
        Ice.Material = Enum.Material.Ice
        Ice.Transparency = 0.5
        Ice.Size = Ice.Size * 1.25
        Ice.Anchored = true
        Ice.Color = Color3.fromRGB(1, 208, 255)
        if Ice:IsA("UnionOperation") then
            Ice.UsePartColor = true
        end
    end
end

local Int = Instance.new("BoolValue", script.Parent.Parent)
Int.Name = "AlreadyFrozen"