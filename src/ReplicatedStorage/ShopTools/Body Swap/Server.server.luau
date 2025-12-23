local SwapWith = script.Parent:FindFirstChild("SwapWith")

if not SwapWith then return warn(`No {SwapWith}!`) end
local DB = false
local Num = script.Parent.Cooldown.Value
function roundNumber(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end
SwapWith.OnServerEvent:Connect(function(player, character2, mouseHit, mouseTarget)
	local Player2 = game.Players:GetPlayerFromCharacter(character2)
	if not Player2 then return end
	if Player2 == player then return end
	if DB == false then
		DB = true
		
		local character1 = player.Character
		local character2 = character2

		local character1Pivot = character1:GetPivot()
		local character2Pivot = character2:GetPivot()

		local humanoid1 = character1:FindFirstChildWhichIsA("Humanoid")
		local humanoid2: Humanoid = character2:FindFirstChildWhichIsA("Humanoid")


		humanoid1:UnequipTools()
		humanoid2:UnequipTools()

		task.wait()

		character1:PivotTo(character2Pivot)
		character2:PivotTo(character1Pivot)
		repeat task.wait(0.1)
			Num-=0.1
		until Num<=0
		Num = script.Parent.Cooldown.Value
		DB = false
	end
end)

spawn(function()
	while task.wait() do
		if DB == false then
			script.Parent.BillboardGui.TextLabel.TextColor3 = Color3.fromRGB(85, 255, 0)
			script.Parent.BillboardGui.TextLabel.Text = "Ready"
		else
			script.Parent.BillboardGui.TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
			script.Parent.BillboardGui.TextLabel.Text = tostring(roundNumber(Num,1))
		end
	end
end)