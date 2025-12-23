local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local finish = Workspace.Map.Points:WaitForChild("End")

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = {workspace.Map.Unsorted.ConveyorBelt}

local BoughtTimes = 0
local OnFastCooldown = false

local function moveEggClient(egg)
	if egg:GetAttribute("Moving") then return end
	egg:SetAttribute("Moving", true)
	task.delay(51, function()
		if egg then
			egg:Destroy()
		end
	end)

	local primary = egg.PrimaryPart
	local duration = egg:GetAttribute("Duration")
	if not primary or not duration then return end

	local startPos = primary.Position
	local endPos = finish.Position
	local size = egg:GetExtentsSize()
	local cf = egg:GetBoundingBox()
	local bottomY = (cf.Position - Vector3.new(0, size.Y / 2, 0)).Y
	local offsetY = primary.Position.Y - bottomY
	local startTime = os.clock()

	local connection
	connection = RunService.RenderStepped:Connect(function()
		if not egg.Parent then
			connection:Disconnect()
			return
		end

		local elapsed = os.clock() - startTime
		local alpha = math.clamp(elapsed / duration, 0, 1)
		local pos = startPos:Lerp(endPos, alpha)

		local result = workspace:Raycast(pos + Vector3.new(0, 50, 0), Vector3.new(0, -200, 0), rayParams)
		if result then
			local groundedPos = Vector3.new(pos.X, result.Position.Y + offsetY, pos.Z)
			primary.CFrame = CFrame.new(groundedPos, endPos)
		else
			primary.CFrame = CFrame.new(pos, endPos)
		end

		if alpha >= 1 then
			connection:Disconnect()
		end
	end)
	task.delay(0.1, function()
	local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		local cd = false
		prompt.Triggered:Connect(function()
			if not cd then
				if OnFastCooldown == true then
						local player = game.Players.LocalPlayer
						local CameraEffect = require(game.ReplicatedStorage.Modules.Camera)
						CameraEffect.shake({shake = "Light_Bump"})

						script.Sound:Play()
					game.Players.LocalPlayer.PlayerGui.MainUI.Frames.Cooldown.Visible = true
				end
				if BoughtTimes == 6 then
					
					if not OnFastCooldown  then
						OnFastCooldown = true
							local player = game.Players.LocalPlayer
							local CameraEffect = require(game.ReplicatedStorage.Modules.Camera)
							CameraEffect.shake({shake = "Light_Bump"})

							script.Sound:Play()
						game.Players.LocalPlayer.PlayerGui.MainUI.Frames.Cooldown.Visible = true
						task.delay(6, function()
							game.Players.LocalPlayer.PlayerGui.MainUI.Frames.Cooldown.Visible = false
							OnFastCooldown = false
						end)
					end
					return
					
						--[[local module = require(game.ReplicatedStorage.Modules.PopUp)
						module:SetDefaultTransition(
							module.TransitionIn.Fade,
							module.TransitionOut.Shrink
						)
						module.Pop.Local(--use the same settings for the global chat notification
							"WOAH! your buying eggs way to quickly, your on a cooldown please wait.",
							Color3.new(1, 0, 0.0156863),
							5,
							{"Drop", "Fade"},
							nil
						)]]
				end
				cd = true
				game.ReplicatedStorage.Remotes:WaitForChild("BuyEgg"):FireServer(egg:GetAttribute("SpawnId"))
				BoughtTimes += 1
				local CurrentStat = BoughtTimes
				task.delay(6, function()
					if BoughtTimes == CurrentStat then
						BoughtTimes = 0
					end
				end)
				task.delay(0.4, function() cd = false end)
			end
		end)
	end
	end)
end
-- Continuously ensure every egg is being handled
RunService.Heartbeat:Connect(function()
	for _, egg in ipairs(Workspace:GetChildren()) do
		if egg:IsA("Model") and egg:GetAttribute("Duration") and egg.PrimaryPart and not egg:GetAttribute("Moving") then
            moveEggClient(egg)
            task.wait(3)
		end
	end
end)

