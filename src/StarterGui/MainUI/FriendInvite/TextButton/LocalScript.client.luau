script.Parent.MouseButton1Click:Connect(function()
	game:GetService("SocialService"):PromptGameInvite(game.Players.LocalPlayer)
end)