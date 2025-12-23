local tool = script.Parent
local handleA = tool:WaitForChild("Handle")

tool.Equipped:Connect(function()
	local character = tool.Parent
	local handle = handleA:Clone()

	handle.Name = "ExampleHandle"
	handle.Parent = tool
	for _, v in pairs(handle:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v:Destroy()
		end
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Anchored = false
			v.CanQuery = false
			v.Massless = true
			v.CanTouch = false
		end
	end
	handle.BillboardGui.Enabled = false

	handle.PrimaryPart.Anchored = false
	local rightArm = character:WaitForChild("Right Arm")

	local weld = Instance.new("Weld")
	weld.Name = "HandleWeld"
	weld.Part0 = rightArm
	weld.Part1 = handle.PrimaryPart
	weld.C1 = CFrame.new(0, 0, 2) * CFrame.Angles(math.rad(90),0,0)
	weld.Parent = handle
end)

tool.Unequipped:Connect(function()
	local handle = tool:FindFirstChild("ExampleHandle")
	if handle then
		handle:Destroy()
	end
end)
