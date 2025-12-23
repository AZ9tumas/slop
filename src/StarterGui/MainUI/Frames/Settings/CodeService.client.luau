script.Parent.ScrollingFrame.Codes.Redeem.MouseButton1Click:Connect(function()
    game.ReplicatedStorage.Remotes.RedeemCode:FireServer(script.Parent.ScrollingFrame.Codes.TextBox.ContentText)
end)