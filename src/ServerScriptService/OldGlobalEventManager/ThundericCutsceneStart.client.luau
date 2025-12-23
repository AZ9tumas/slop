game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
game.Workspace.CurrentCamera.CFrame = game.Workspace.Map.Cameras.ThundericCutscene2.CFrame
local player = game.Players.LocalPlayer
local CameraEffect = require(game.ReplicatedStorage.Modules.Camera)
CameraEffect.shake({shake = "Earthquake"})