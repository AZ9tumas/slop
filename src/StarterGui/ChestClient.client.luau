repeat wait(5) until game.Players.LocalPlayer:FindFirstChild("leaderstats") and game.Players.LocalPlayer:GetAttribute("PlayTime")

local Player = game:GetService("Players").LocalPlayer

local ChestFolder = game:GetService("Workspace"):WaitForChild("Chest")
local InfoBoard = ChestFolder:FindFirstChild("Info")
local Chest = ChestFolder:FindFirstChild("Chest")
local Prompt  = Chest.PromptPos.ProximityPrompt

local UI = InfoBoard.Root:FindFirstChild("SurfaceGui")

local ShakeAnim = Chest.Humanoid:LoadAnimation(script.ShakeAnim)
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ParticleBorder = require(ReplicatedStorage:WaitForChild("ParticleBorder"))

task.delay(10, function()
    local Reward = ReplicatedStorage.Remotes.GenerateEggRarity:InvokeServer()
    print(Reward)
end)

local function CheckClaimed()
	if Player:GetAttribute("ClaimedChest") and Player:GetAttribute("ClaimedChest") == true then
		if not ChestFolder then return end
		ChestFolder:Destroy()
	end
end

task.delay(8, function()
	CheckClaimed()
	wait(5)
	CheckClaimed()
end)


local function UpdateBoard()
	if not Player:GetAttribute("PlayTime") then return end
	if not ChestFolder or not Chest or not InfoBoard or not InfoBoard.Root.SurfaceGui or not UI or not UI.Quest1 then return end
	local PlayTimepercent = math.clamp(Player:GetAttribute("PlayTime") / 3600, 0, 1)
    UI.Quest1.ProgressBar.Bar.Size = UDim2.new(PlayTimepercent, 0, 1, 0)
	local Expandspercent = math.clamp(Player:GetAttribute("TotalExpands") / 10, 0, 1)
	UI.Quest2.ProgressBar.Bar.Size = UDim2.new(Expandspercent, 0, 1, 0)
	local Beakspercent = math.clamp(Player:FindFirstChild("leaderstats").Beaks.Value / 500000, 0, 1)
	UI.Quest3.ProgressBar.Bar.Size = UDim2.new(Beakspercent, 0, 1, 0)
	--local EggsBoughtpercent = math.clamp(Player:GetAttribute("TotalEggsBought") / 175, 0, 1)
    --UI.Quest4.ProgressBar.Bar.Size = UDim2.new(EggsBoughtpercent, 0, 1, 0)
   -- UI.Quest4.QuestText.Text = "Buy 175 Eggs: " .. Player:GetAttribute("TotalEggsBought") .. "/175"
	--InfoBoard.u.Size = UDim2.new(percent, 0, 1, 0)
end

local function HatchChest()
	local Hatched = false
	local HitAmount = 0
	local BlockS = Instance.new("BoolValue", game.Players.LocalPlayer.Character)
	BlockS.Name = "BlockLeaveCutscene"
	local Fade = Player.PlayerGui.ImpactFrames.Black
	Fade.Transparency = 1
	Fade.Visible = true
	for _, UI in Player.PlayerGui:GetChildren() do
		if UI:IsA("ScreenGui") and UI.Name ~= "ImpactFrames" then
			local OldStat = UI.Enabled
			UI.Enabled = false
			script.Hatched:GetPropertyChangedSignal("Value"):Connect(function()
				if script.Hatched.Value == false then return end
				UI.Enabled = OldStat
			end)
		end
	end
	game.TweenService:Create(Fade, TweenInfo.new(1), {Transparency = 0}):Play()
	task.wait(1)
	local DisplayChest = game:GetService("ReplicatedStorage").Game.DisplayChest:Clone()
	DisplayChest.Parent = ChestFolder
	game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	game.Workspace.CurrentCamera.CFrame = game.Workspace.Map.Cameras.ChestHatch.CFrame
	task.wait(1)
	game.TweenService:Create(Fade, TweenInfo.new(1), {Transparency = 1}):Play()
	wait(1)
	Fade.Transparency = 1
	Fade.Visible = false
	local DShakeAnim = DisplayChest.Humanoid:LoadAnimation(script.ShakeAnim)
	task.spawn(function()
	while wait(3) do
		if HitAmount ~= 0 or Hatched == true then break end
			DShakeAnim:Play()
			DisplayChest.Prox.Shake:Play()
	    end
	end)
	Player.PlayerGui.ImpactFrames.ClickScreen.Visible = true
	local function Tick()
		if not script.Ticks:FindFirstChild(HitAmount) then return end
		local RandomSound = script.Ticks[HitAmount] --script.Ticks:GetChildren()[math.random(1, #script.Ticks:GetChildren())]
		RandomSound:Play()
		local HightLight = Instance.new("Highlight", DisplayChest)
		HightLight.OutlineTransparency = 1
		HightLight.FillColor = Color3.fromRGB(255, 255, 255)
		HightLight.FillTransparency = 0
		game.TweenService:Create(HightLight, TweenInfo.new(0.5), {FillTransparency = 1}):Play()
		game.Debris:AddItem(HightLight, 0.5)
	end
	local function CheckToHatch()
		if HitAmount >= 7 then
			local Reward = ReplicatedStorage.Remotes.GenerateEggRarity:FireServer()
			game.ReplicatedStorage.Remotes.GiveChestReward:FireServer(Reward)
			Player.PlayerGui.ImpactFrames.ClickScreen.Visible = false
			local OpenAnim = DisplayChest.Humanoid:LoadAnimation(script.OpenAnim)
			OpenAnim:Play()
			game.TweenService:Create(game.Workspace.CurrentCamera, TweenInfo.new(0.5), {CFrame = game.Workspace.Map.Cameras.ChestHatch2.CFrame}):Play()
			script.Woosh1:Play()
			wait(0.5)
			game.TweenService:Create(game.Workspace.CurrentCamera, TweenInfo.new(0.5), {CFrame = game.Workspace.Map.Cameras.ChestHatch3.CFrame}):Play()
			script.Woosh2:Play()
            wait(.45)
            
			script.Unlock:Play()
			local Egg = game.ReplicatedStorage.Game.Eggs[Reward].Egg:Clone()
			Egg.Parent = ChestFolder
			Egg.BillboardGui:Destroy()
			Egg.PrimaryPart.CFrame = DisplayChest.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
			local HightLight = Instance.new("Highlight", Egg)
			HightLight.OutlineTransparency = 1
			HightLight.FillColor = Color3.fromRGB(255, 255, 255)
            HightLight.FillTransparency = 0
            task.spawn(function()
            local confettiFolder = ReplicatedStorage.Particles.Confetti

            ParticleBorder.createFromTop(
                confettiFolder,
                0.5,    -- seconds of emission
                1.3   -- screen coverage multiplier
            )
            end)
			game.TweenService:Create(HightLight, TweenInfo.new(0.5), {FillTransparency = 1}):Play()
			game.Debris:AddItem(HightLight, 0.5)
			wait(3)
			local Fade = Player.PlayerGui.ImpactFrames.Black
			Fade.Transparency = 1
			Fade.Visible = true
			game.TweenService:Create(Fade, TweenInfo.new(1), {Transparency = 0}):Play()
			wait(1)
			game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			script.Hatched.Value = true
			task.wait(1)
			game.TweenService:Create(Fade, TweenInfo.new(0.5), {Transparency = 1}):Play()
			wait(0.5)
			_G.Notification("You got a " .. Reward .. " Egg!")
			Fade.Transparency = 1
			Fade.Visible = false
			DisplayChest:Destroy()
			CheckClaimed()
		end
	end
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if Hatched == true or HitAmount >= 7 then return end
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Tick()
			HitAmount += 1
			CheckToHatch()
		elseif input.UserInputType == Enum.UserInputType.Touch then
			Tick()
			HitAmount += 1
			CheckToHatch()
		elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
			Tick()
			HitAmount += 1
			CheckToHatch()
		else
			Tick()
			HitAmount += 1
			CheckToHatch()
		end
	end)
end

local function Shake()
    if not ChestFolder or not Chest then return end
    ShakeAnim:Play()
    if ChestFolder and Chest.Prox then
    Chest.Prox.Shake:Play()
    end
end

local function OpenChest()
	if Player and Player:GetAttribute("PlayTime") >= 3600 and Player:GetAttribute("TotalExpands") >= 10 and Player:FindFirstChild("leaderstats").Beaks.Value >= 500000 --[[and Player:GetAttribute("TotalEggsBought") >= 175]] then
		HatchChest()
	else
		Shake()
		_G.Notification("Complete the tasks first.")
	end
end

Player:GetAttributeChangedSignal("PlayTime"):Connect(function()
    if Player:GetAttribute("ClaimedChest") or not ChestFolder then return end
	UpdateBoard()
end)



task.spawn(function()
while wait(10) do
	Shake()
end
end)

Prompt.Triggered:Connect(function(TP)
	if TP == Player then
		OpenChest()
	end
end)

--[[local targetDate = os.time({
	year = 2025,
	month = 11,
	day = 27,
	hour = 12,
	min = 0,
	sec = 0
})

targetDate = targetDate - (3 * 60 * 60)

local textLabel = Chest.Display.Remain

-- Function to update the countdown display
local function updateCountdownDisplay()
	-- Get current real UTC time
	local currentUTC = DateTime.now().UnixTimestamp
	local secondsLeft = targetDate - currentUTC

	-- Stop countdown if expired
	if secondsLeft <= 0 then
		textLabel.Text = "Expired"
		ChestFolder:Destroy()
		return false
	end

	-- Break down remaining time
	local days = math.floor(secondsLeft / 86400)
	local hours = math.floor((secondsLeft % 86400) / 3600)
	local minutes = math.floor((secondsLeft % 3600) / 60)
	local seconds = math.floor(secondsLeft % 60)

	-- Smart formatting
	if days >= 1 then
		textLabel.Text = string.format("%dd Remaining", days)
	elseif hours >= 1 then
		textLabel.Text = string.format("%dh:%02dm Remaining", hours, minutes)
	elseif minutes >= 1 then
		textLabel.Text = string.format("%dm:%02ds Remaining", minutes, seconds)
	else
		textLabel.Text = string.format("%ds Remaining", seconds)
	end

	return true
end

-- Update every second
while task.wait(1) do
	if not ChestFolder then break end
	if not updateCountdownDisplay() then
		break
	end
end

]]