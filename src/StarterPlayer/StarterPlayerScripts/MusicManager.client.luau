local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local songs = {
	84967962346556,
	107079802729440
	
}
--[[1839492396,
	1843535552,
	1847812286,
	9039953638,
	9045766377,
	9045766074,
	1847795501,]]
local currentIndex = math.random(1, #songs)
local sound = Instance.new("Sound")
sound.Parent = SoundService
sound.Looped = false
sound.Volume = 0.18
sound.Name = "Music"
sound:SetAttribute("IsMusic", true)

local function playSong(index)
	sound.SoundId = "rbxassetid://" .. songs[index]
	sound:Play()
end

sound.Ended:Connect(function()
	currentIndex = currentIndex + 1
	if currentIndex > #songs then
		currentIndex = 1
	end
	playSong(currentIndex)
end)

task.wait(5)

playSong(currentIndex)

local player = Players.LocalPlayer
local ui = player:WaitForChild("PlayerGui")
	:WaitForChild("MainUI")
	:WaitForChild("Frames")
	:WaitForChild("Settings")
	:WaitForChild("ScrollingFrame")
	:WaitForChild("Music")

local turnOff = ui:WaitForChild("BoolTrue")
local turnOn = ui:WaitForChild("BoolFalse")

local muted = false

-- apply initial state based on which button is visible
if turnOff.Visible then
	muted = false
	sound.Volume = 0.18
elseif turnOn.Visible then
	muted = true
	sound.Volume = 0
end

turnOff.MouseButton1Click:Connect(function()
	turnOff.Visible = false
	turnOn.Visible = true
	muted = true
	sound.Volume = 0
end)

turnOn.MouseButton1Click:Connect(function()
	turnOff.Visible = true
	turnOn.Visible = false
	muted = false
	sound.Volume = 0.18
end)
