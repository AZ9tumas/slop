script.Parent.Activated:Connect(function()
	if game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Humanoid.Health > 0 and not game.Players.LocalPlayer.Character:FindFirstChild("Trapped") then
		script.Parent.RemoteEvent:FireServer()
		script.Parent:Destroy()
	end
end)