local tool = script.Parent
local character = game.Players.LocalPlayer.Character
local humanoid = character:FindFirstChildOfClass("Humanoid")

tool.Equipped:Connect(function()
	local character = tool.Parent
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 30
		script.Sound:Play()
	end
end)

tool.Unequipped:Connect(function()
	local character = game.Players.LocalPlayer.Character
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 22
	end
end)
