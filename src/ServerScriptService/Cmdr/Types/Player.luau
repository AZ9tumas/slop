local Players = game:GetService("Players")

return function(registry)
	registry:RegisterType("playerName", {
		Parse = function(str)
			return Players:FindFirstChild(str)
		end,
		Autocomplete = function(str)
			local suggestions = {}
			for _, player in pairs(Players:GetPlayers()) do
				if string.find(string.lower(player.Name), string.lower(str)) then
					table.insert(suggestions, player.Name)
				end
			end
			return suggestions
		end,
		Validate = function(player)
			return player ~= nil, "Player not found"
		end
	})
end
