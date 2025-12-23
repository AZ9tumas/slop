local TweenService = game:GetService("TweenService")


local rainbowColors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 127, 0),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(75, 0, 130),
	Color3.fromRGB(148, 0, 211)
}

local function applyRainbow(part)
	task.spawn(function()
		while part.Parent do 
			for i = 1, #rainbowColors do
				local nextColor = rainbowColors[i]
				part.Color = nextColor
				wait(2)
			end
		end
	end)
end

for _, part in script.Parent.Parent:GetDescendants() do
	if part:IsA("Part") or part:IsA("UnionOperation") then
		part.Material = Enum.Material.Neon
		if part:IsA("UnionOperation") then
			part.UsePartColor = true
		end
		applyRainbow(part)
	end
end
