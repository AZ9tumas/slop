script.Parent.Activated:Connect(function()
	if game.Players.LocalPlayer.Character:FindFirstChild("Trapped") or game.Players.LocalPlayer.Character.Humanoid.Health < 1 then return end
	script.RemoteEvent:FireServer()
end)