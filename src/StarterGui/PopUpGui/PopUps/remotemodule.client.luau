local module = game.ReplicatedStorage.Modules.PopUp
local req = require(module)

module.PopUpEvent.OnClientEvent:Connect(req.Pop.Local)

module.SetDefaultTransition.OnClientEvent:Connect(function(tIn, tOut)
	req:SetDefaultTransition(tIn, tOut)
end)