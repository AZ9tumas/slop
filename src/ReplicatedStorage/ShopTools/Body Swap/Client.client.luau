local bodySwap = script.Parent
local SwapWith = bodySwap:FindFirstChild("SwapWith")

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local function getTargetFromInput(inputPosition)
	local camera = workspace.CurrentCamera
	local ray = camera:ScreenPointToRay(inputPosition.X, inputPosition.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {player.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(ray.Origin, ray.Direction * 700, raycastParams)
	if result then
		return result.Instance, result.Position
	end

end

local function trySwapAtPosition(inputPosition)
	local character1 = player.Character
	if not character1 then return end
	if character1:FindFirstChild("Trapped") or character1.Humanoid.Health < 1 then return end

	local humanoid1 = character1:FindFirstChildWhichIsA("Humanoid")
	if not humanoid1 then return end

	local charPrimary = character1.PrimaryPart
	if not charPrimary then return end

	local target, position = getTargetFromInput(inputPosition)
	if target then
		local character2 = target:FindFirstAncestorWhichIsA("Model")
		local humanoid2 = character2 and character2:FindFirstChildWhichIsA("Humanoid")

		if humanoid2 and character2.Name ~= character1.Name and character2.PrimaryPart then
			local distance = (character2.PrimaryPart.Position - charPrimary.Position).Magnitude
			if distance <= 160 then
				SwapWith:FireServer(character2, CFrame.new(position), target)
			end
		end
	end

end

-- Function to swap with nearest player (console support)
local function swapWithNearest()
	local character1 = player.Character
	if not character1 then return end
	if character1:FindFirstChild("Trapped") or character1.Humanoid.Health < 1 then return end
	local charPrimary = character1.PrimaryPart
	if not charPrimary then return end

	local nearestPlayer
	local nearestDistance = math.huge

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.PrimaryPart then
			local dist = (plr.Character.PrimaryPart.Position - charPrimary.Position).Magnitude
			if dist < nearestDistance then
				nearestDistance = dist
				nearestPlayer = plr
			end
		end
	end

	if nearestPlayer and nearestDistance <= 160 then
		SwapWith:FireServer(nearestPlayer.Character, nearestPlayer.Character.PrimaryPart.CFrame, nearestPlayer.Character.PrimaryPart)
	end

end

-- Connect for GUI button activation (if using Tool)
bodySwap.Activated:Connect(function()
	if UIS.GamepadEnabled then
		-- Console / Gamepad: swap with nearest player
		swapWithNearest()
	elseif UIS.TouchEnabled then
		-- Mobile
		local lastInput = UIS:GetLastInputObject()
		if lastInput and lastInput.UserInputType == Enum.UserInputType.Touch then
			trySwapAtPosition(lastInput.Position)
		end
	else
		-- PC / Mouse
		local mouse = player:GetMouse()
		if mouse.Target then
			local character2 = mouse.Target:FindFirstAncestorOfClass("Model")
			local humanoid2 = character2 and character2:FindFirstChildWhichIsA("Humanoid")
			local charPrimary = player.Character and player.Character.PrimaryPart
			if humanoid2 and charPrimary and character2.Name ~= player.Name then
				local distance = (character2.PrimaryPart.Position - charPrimary.Position).Magnitude
				if distance <= 160 then
					SwapWith:FireServer(character2, mouse.Hit, mouse.Target)
				end
			end
		end
	end
end)

-- Optional: detect direct screen touches for mobile
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Touch and bodySwap.Parent == game.Players.LocalPlayer.Character then
		trySwapAtPosition(input.Position)
	end
end)
