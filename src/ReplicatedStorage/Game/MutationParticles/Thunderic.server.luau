for _, part in script.Parent.Parent:GetDescendants() do
	if part:IsA("Part") or part:IsA("UnionOperation") then
		part.Material = Enum.Material.Neon
	end
end

local VFX = script.Thunderic:Clone()
VFX.Parent = script.Parent

