local CoinEffect = game.ReplicatedStorage.Game.VFX.Beaks:Clone()
CoinEffect.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
CoinEffect:Emit(12)
game.Debris:AddItem(CoinEffect, 5)
script.Sound:Play()
