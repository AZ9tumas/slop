game.ReplicatedStorage.Remotes.UpdateSettings.OnClientEvent:Connect(function(Music)
	if Music == true then
		script.Parent.ScrollingFrame.Music.BoolTrue.Visible = true
		script.Parent.ScrollingFrame.Music.BoolFalse.Visible = false
		game.SoundService.BackgroundMusic:Play()
	else
		script.Parent.ScrollingFrame.Music.BoolTrue.Visible = false
		script.Parent.ScrollingFrame.Music.BoolFalse.Visible = true
		game.SoundService.BackgroundMusic:Stop()
	end
end)