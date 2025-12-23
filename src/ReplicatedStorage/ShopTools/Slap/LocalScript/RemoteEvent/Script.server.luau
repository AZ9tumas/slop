local Cooldown = 2

local Knockback = 35

local DB = false
local RagdollModule = require(game.ReplicatedStorage.Modules["Ragdoll Module"])

script.Parent.OnServerEvent:Connect(function(Player)
	print("slap")
	local Char = Player.Character
	local Humanoid = Char:FindFirstChild("Humanoid")
	
	if not Char or Humanoid.Health < 0 or DB == true then return end
	DB = true
	
	task.delay(Cooldown, function()
		DB = false
	end)
	
	local Animation = Humanoid:LoadAnimation(script.Animation)
	Animation:Play()
	wait(.14)
	local Hitbox = Instance.new("Part", workspace)
	Hitbox.Parent = workspace
	Hitbox.CanCollide = false
	Hitbox.Anchored = true
	Hitbox.Size = Vector3.new(8,8,8)
	Hitbox.BrickColor = BrickColor.new("Really red")
	Hitbox.Transparency = 1
	Hitbox.CFrame = Char.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3)
	game.Debris:AddItem(Hitbox, .1)
	local Hitlist = {}
	local HitContent = workspace:GetPartBoundsInBox(Hitbox.CFrame, Hitbox.Size)
	for i, v in pairs(HitContent) do
		if v and v.Parent and v.Parent:FindFirstChild("Humanoid") and v.Parent ~= Char and not Hitlist[v.Parent] and not v.Parent:FindFirstChild("IsRagdoll") and game.Players:FindFirstChild(v.Parent.Name) then
			local Enemy = v.Parent
			local EnemyHum = Enemy:FindFirstChild("Humanoid")
			local EnemyRoot = Enemy:FindFirstChild("HumanoidRootPart")
			local KnockbackVel = Instance.new("BodyVelocity", EnemyRoot)
			KnockbackVel.P = math.huge
			KnockbackVel.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
			KnockbackVel.Velocity = Char.HumanoidRootPart.CFrame.LookVector * Knockback + Vector3.new(0, 30, 0)
			task.spawn(function()
			RagdollModule.TimedRagdoll(Enemy, 1.9)
			end)
			local IsRagdolled = Instance.new("IntValue", Enemy)
			IsRagdolled.Name = "IsRagdoll"
			game.Debris:AddItem(IsRagdolled, 2.15)
			local sound = script.Sound:Clone()
			sound.Parent = EnemyRoot
			sound:Play()
			game.Debris:AddItem(sound, 5)
			game.Debris:AddItem(KnockbackVel, .1)
			Hitlist[v.Parent] = true
		end
	end
end)