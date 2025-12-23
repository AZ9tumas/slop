local tool = script.Parent
local remote = tool:WaitForChild("SlapEvent")
local Players = game:GetService("Players")

local RANGE = 8
local FORCE = 120
local VERTICAL_MULT = 0.4
local COOLDOWN = 0.5
local debounce = {}

remote.OnServerEvent:Connect(function(player)
	if debounce[player] then return end
	debounce[player] = true
	local character = player.Character
	if not character then debounce[player] = false return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then debounce[player] = false return end
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local otherChar = otherPlayer.Character
			if otherChar then
				local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
				local humanoid = otherChar:FindFirstChildOfClass("Humanoid")
				if otherRoot and humanoid and humanoid.Health > 0 then
					local offset = otherRoot.Position - root.Position
					if offset.Magnitude <= RANGE then
						local dir = offset.Unit
						local bodyVel = Instance.new("BodyVelocity")
						bodyVel.Velocity = dir * FORCE + Vector3.new(0, FORCE * VERTICAL_MULT, 0)
						bodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
						bodyVel.Parent = otherRoot
						game:GetService("Debris"):AddItem(bodyVel, 0.2)
					end
				end
			end
		end
	end
	task.wait(COOLDOWN)
	debounce[player] = false
end)
