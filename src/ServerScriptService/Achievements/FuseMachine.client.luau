game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

game.TweenService:Create(game.Workspace.CurrentCamera, TweenInfo.new(1.4), {CFrame = game.Workspace.Map.Cameras.FuseMachine.CFrame}):Play()
wait(0.7)
_G.Notification("You can use the fuse machine now!", Color3.new(0, 0.701961, 1))
wait(5.5)
_G.Notification("Put in 2 pigeons and get an egg!", Color3.new(0, 0.701961, 1))
wait(3)
game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
