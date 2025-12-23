game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
local player = game.Players.LocalPlayer
local CameraEffect = require(game.ReplicatedStorage.Modules.Camera)
CameraEffect.shake({shake = "Heavy_Bump"})