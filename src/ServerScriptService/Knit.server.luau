local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- Add all services from ServerStorage/Services folder
Knit.AddServices(game:GetService("ServerStorage").Services)

require(game.ReplicatedStorage.Modules.AddAchievment)
Knit.Start():andThen(function()
	


end)




-- Start Knit and handle the successful start
