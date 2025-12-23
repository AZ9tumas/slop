local IDModule = require(game.ReplicatedStorage.Info.ProductIds)

script.Parent.Touched:Connect(function(Part)
	if Part and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
		local Player = game.Players:GetPlayerFromCharacter(Part.Parent)
		if Player then
			game:GetService("MarketplaceService"):PromptGamePassPurchase(Player, IDModule.StarterPack)
		end
	end
end)