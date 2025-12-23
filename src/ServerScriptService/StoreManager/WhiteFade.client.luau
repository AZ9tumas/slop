local UI = game.Players.LocalPlayer.PlayerGui.ImpactFrames.White

UI.Transparency = 1
UI.Visible = true
game.TweenService:Create(UI, TweenInfo.new(1), {Transparency = 0}):Play()
game.TweenService:Create(game.Workspace.CurrentCamera, TweenInfo.new(1), {FieldOfView = 90}):Play()
wait(1.9)
game.TweenService:Create(UI, TweenInfo.new(1), {Transparency = 1}):Play()
game.TweenService:Create(game.Workspace.CurrentCamera, TweenInfo.new(1), {FieldOfView = 70}):Play()
script.Sound:Play()
wait(1)
UI.Transparency = 1
UI.Visible = false
wait(3)
script:Destroy()