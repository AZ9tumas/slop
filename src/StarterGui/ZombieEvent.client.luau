wait(10)
local Template = game.ReplicatedStorage.Game.EventVFX.ZombieCutscene:Clone()
Template.Parent = workspace
game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
game.Lighting.ClockTime = 3

local connection
connection = game["Run Service"].RenderStepped:Connect(function()
	if script.Done.Value == true then
		connection:Disconnect()
	end
	if not Template then return end
	game.Workspace.CurrentCamera.CFrame = Template.camRig.Cam.CFrame
	for _, Egg in game.Workspace:GetChildren() do
		if Egg:IsA("Model") and Egg:GetAttribute("Rarity") then
			Egg:Destroy()
		end
	end
end)
for _, Players in game.Players:GetChildren() do
	if Players:IsA("Player") and Players.Character then
		for _, Parts in Players.Character:GetDescendants() do
			if Parts:IsA("BasePart") then
				local OldTrans = Parts.Transparency
				task.delay(0.5, function()
				Parts.Transparency = 1
				end)
				script.Done:GetPropertyChangedSignal("Value"):Connect(function()
					if script.Done.Value == true then
					Parts.Transparency = OldTrans
					end
				end)
			end
		end
	end
end

for _, Accesories in game.Players.LocalPlayer.Character:GetChildren() do
	if Accesories:IsA("Accessory") then
		local Clone = Accesories:Clone()
		local NameOfPart = Clone.Handle.AccessoryWeld.Part1.Name
		Clone.Parent = Template.Player
		Clone.Handle.AccessoryWeld.Part1 = Template.Player[NameOfPart]
	end
end

if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Pants") then
	local Clone = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Pants"):Clone()
	Clone.Parent = Template.Player
end
if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Shirt") then
	local Clone = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Shirt"):Clone()
	Clone.Parent = Template.Player
end
if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("ShirtGraphic") then
	local Clone = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("ShirtGraphic"):Clone()
	Clone.Parent = Template.Player
end
if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("BodyColors") then
	local Clone = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("BodyColors"):Clone()
	Clone.Parent = Template.Player
end
if game.Players.LocalPlayer.Character.Head:FindFirstChildWhichIsA("Decal") then
	local Clone = game.Players.LocalPlayer.Character.Head:FindFirstChildWhichIsA("Decal"):Clone()
	Clone.Parent = Template.Player.Head
end


script.Done.Changed:Connect(function()
	if script.Done.Value == true then
		Template:Destroy()
		game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		
	end
end)

task.delay(19.1, function()
	game.Players.LocalPlayer.PlayerGui.ImpactFrames.Black.Visible = true
	game.Players.LocalPlayer.PlayerGui.ImpactFrames.Black.Transparency = 1
	game.TweenService:Create(game.Players.LocalPlayer.PlayerGui.ImpactFrames.Black, TweenInfo.new(0.7), {Transparency = 0}):Play()
	wait(0.65)
	script.Done.Value = true
	wait(.2)
	game.Players.LocalPlayer.PlayerGui.ImpactFrames.Black.Visible = true
	game.Players.LocalPlayer.PlayerGui.ImpactFrames.Black.Transparency = 0
	game.TweenService:Create(game.Players.LocalPlayer.PlayerGui.ImpactFrames.Black, TweenInfo.new(0.7), {Transparency = 1}):Play()
	wait(1)
	game.Players.LocalPlayer.PlayerGui.ImpactFrames.Black.Visible = false
	game.Players.LocalPlayer.PlayerGui.ImpactFrames.Black.Transparency = 1
end)

task.delay(0.1, function()
	Template.Zombie4.HumanoidRootPart.Rocks:Emit(5)
end)

task.spawn(function()--SOUNDS
	task.delay(0.1, function()
	    script.ComeOut:Play()
	end)
	task.delay(1.2, function()
		script.ZombieOutSound:Play()
	end)
	task.delay(2.3, function()
		script.GroundTab:Play()
	end)
	task.delay(3.2, function()
		script.GroundTab:Play()
	end)
	task.delay(4.15, function()
		script.OutAir:Play()
	end)
	task.delay(5.07, function()
		script.Land:Play()
	end)
	task.delay(7.18, function()
		script.Scream:Play()
	end)
	task.delay(9.1, function()
		script.Step:Play()
		script.ZombieOutSound:Play()
	end)
	task.delay(10.15, function()
		script.Step:Play()
	end)
	task.delay(11.3, function()
		script.ZombieOutSound:Play()
	end)
	task.delay(13, function()
		script.Step:Play()
	end)
	task.delay(14.1, function()
		script.Growl:Play()
	end)
	task.delay(16.05, function()
		script.ZombieOutSound:Play()
	end)
end)

for _, Rigs in Template:GetChildren() do
	if Rigs:IsA("Model") and Rigs:FindFirstChild("Animation") then
		local Animator = Rigs:FindFirstChild("Humanoid") or Rigs:FindFirstChild("AnimationController")
		local AnimTrack = Animator:LoadAnimation(Rigs.Animation)
		AnimTrack:Play()

	end
end

