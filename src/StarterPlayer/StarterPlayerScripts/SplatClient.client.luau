local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PigeonInfo = require(ReplicatedStorage.Info.PigeonInfo)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local splatTemplate = ReplicatedStorage.Game.VFX:WaitForChild("Splat")

local function spawnSplat(pigeon)
	if not pigeon.PrimaryPart then return end

	local splat = pigeon:FindFirstChild("Splat")
	if not splat then
		splat = splatTemplate:Clone()
		splat.Name = "Splat"
		splat.CFrame = pigeon.PrimaryPart.CFrame * CFrame.new(1.5, -1, 0)
		splat.Parent = pigeon
	end

	local sound = splat:FindFirstChild("Sound")
	if not sound then
		sound = script.Sound:Clone()
		sound.Name = "Sound"
		sound.Parent = splat
	end
	sound:Play()

	for _, emitter in ipairs(splat:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			local count = emitter:GetAttribute("EmitCount") or 1
			emitter:Emit(count)
		end
	end
end

local function getMyPlot(player)
	for _, plot in ipairs(workspace.Map.Plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId and ownerId == player.UserId then
			return plot
		end
	end
	return nil
end

task.spawn(function()
	while true do
		pcall(function()
			for _, obj in ipairs(getMyPlot(player).Pigeons:GetChildren()) do
				if obj:IsA("Model") and obj:GetAttribute("PigeonID") then
					spawnSplat(obj)
					task.wait(0.11, 0.34)
				end
			end
		end)
		task.wait(1.5)
	end
end)

task.spawn(function()
	while true do
		pcall(function()
			for _, obj in ipairs(getMyPlot(player).Pigeons:GetChildren()) do
				task.wait()
				if obj:IsA("Model") and obj:GetAttribute("PigeonID") then
                    if obj.HumanoidRootPart:FindFirstChild("PigeonSound") then
                        if PigeonInfo[obj.Name].CustomSound then
                            obj.HumanoidRootPart:FindFirstChild("PigeonSound").SoundId = PigeonInfo[obj.Name].CustomSound
                        end
						obj.HumanoidRootPart:FindFirstChild("PigeonSound"):Play()
					else
						local sound = script.PigeonSound:Clone()
                        sound.Parent = obj.HumanoidRootPart
                        if PigeonInfo[obj.Name].CustomSound then
                            obj.HumanoidRootPart:FindFirstChild("PigeonSound").SoundId = PigeonInfo[obj.Name].CustomSound
                        end
						sound:Play()
					end
					wait(math.random(1.2, 3.2))
				end
			end
		end)
		task.wait(math.random(3.5, 8))
	end
end)