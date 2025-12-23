local tool = script.Parent
local event = tool:WaitForChild("RemoteEvent")
local Knit = require(game.ReplicatedStorage.Packages.Knit)


event.OnServerEvent:Connect(function(player)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {char}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist

	local rayOrigin = hrp.Position
	local rayDir = Vector3.new(0, -20, 0)
	local result = workspace:Raycast(rayOrigin, rayDir, rayParams)

	local placePos--cframe
	if result then
		placePos = result.Position + Vector3.new(0, handle.Size.Y / 2, 0)
	else
		placePos = hrp.Position - Vector3.new(0, 3, 0)
	end
	local Trap = game.ReplicatedStorage.Game.TrapOpen:Clone()
	Trap.Parent = workspace
	Trap.CFrame = CFrame.new(placePos)
	Trap.PlaceSound:Play()
	Knit.GetService("InventoryService"):RemoveItem(player,script.Parent.Name, "Tool", {ID = script.Parent:GetAttribute("Id")})
	tool:Destroy()
	
	local Open = true
	Trap.Touched:Connect(function(Hit)
		if Hit and Hit.Parent and Hit.Parent:FindFirstChild("Humanoid") and game.Players:FindFirstChild(Hit.Parent.Name) and Hit.Parent ~= char and Open == true then
			Open = false
			local CloseTrap = game.ReplicatedStorage.Game.ClosedTrap:Clone()
			CloseTrap.Parent = workspace
			CloseTrap.CFrame = Trap.CFrame
			CloseTrap.Trap:Play()
			Trap:Destroy()
			local TrapVal = Instance.new("IntValue", Hit.Parent)
			TrapVal.Name = "Trapped"
			game.Debris:AddItem(TrapVal, 4)
			Hit.Parent.HumanoidRootPart.Anchored = true
			task.delay(4, function()
				if not Hit.Parent then return end
				Hit.Parent.HumanoidRootPart.Anchored = false
				CloseTrap:Destroy()
			end)
		end
	end)
end)
