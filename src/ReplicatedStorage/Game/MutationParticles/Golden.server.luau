local TweenService = game:GetService("TweenService")

local Gold = script.Golden:Clone()
Gold.Parent = script.Parent.Parent.PrimaryPart or script.Parent.Parent.HumanoidRootPart or script.Parent.Parent.Handle

for _, part in script.Parent.Parent:GetDescendants() do
	if part:IsA("BasePart") or part:IsA("UnionOperation") then
		part.Material = Enum.Material.Metal
		part.Color = Color3.fromRGB(255, 191, 0)
		if part:IsA("UnionOperation") then
			part.UsePartColor = true
		end
	end
end
