script.Snap:Play()
local black = script.BlackScreen:Clone()
black.Enabled = true
black.Parent = game.Lighting
wait(.1)
black.TintColor = Color3.fromRGB(19, 64, 66)
wait(.1)
black.TintColor = Color3.fromRGB(0, 0, 0)

game.Debris:AddItem(black, 1)
