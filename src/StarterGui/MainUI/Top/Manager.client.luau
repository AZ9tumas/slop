local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)



script.Parent.Holder.Plot.MouseButton1Click:Connect(function()
	local PlotService = Knit.GetService("PlotService")
	PlotService:TeleportSpawn()
end)

script.Parent.Holder.Sell.MouseButton1Click:Connect(function()
	game.Players.LocalPlayer.Character.PrimaryPart.CFrame = workspace.SellPart.CFrame * CFrame.new(0,3,0)
end)