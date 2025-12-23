game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.MaxHealth = math.huge
		humanoid.Health = humanoid.MaxHealth
		humanoid.HealthChanged:Connect(function()
			humanoid.Health = humanoid.MaxHealth
		end)
		humanoid.Died:Connect(function()
			humanoid.Health = humanoid.MaxHealth
		end)
		humanoid.StateChanged:Connect(function(_, newState)
			if newState == Enum.HumanoidStateType.Dead then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end)
end)
