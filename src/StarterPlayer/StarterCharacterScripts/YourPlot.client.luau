local worldPlots = workspace:WaitForChild("Map"):WaitForChild("Plots")

local function getMyPlot(player)
	for _, plot in ipairs(worldPlots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId and ownerId == player.UserId then
			return plot
		end
	end
	return nil
end

task.wait(16)

getMyPlot(game.Players.LocalPlayer):FindFirstChild("Model").YourPlot.Enabled = true

