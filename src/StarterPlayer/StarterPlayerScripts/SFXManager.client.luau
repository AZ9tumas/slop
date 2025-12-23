local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ui = player:WaitForChild("PlayerGui"):WaitForChild("MainUI"):WaitForChild("Frames"):WaitForChild("Settings"):WaitForChild("ScrollingFrame"):WaitForChild("SFXS")
local turnOff = ui:WaitForChild("BoolTrueS")
local turnOn = ui:WaitForChild("BoolFalseS")

local sfxMuted = false

local function applySFXMute(sound)
	if sound:IsA("Sound") and not sound:GetAttribute("IsMusic") then
		if sfxMuted then
			if not sound:GetAttribute("OriginalVolume") then
				sound:SetAttribute("OriginalVolume", sound.Volume)
			end
			sound.Volume = 0
		else
			local original = sound:GetAttribute("OriginalVolume")
			if original then
				sound.Volume = original
			end
		end
	end
end

for _, descendant in ipairs(workspace:GetDescendants()) do
	applySFXMute(descendant)
end
for _, descendant in ipairs(game:GetService("SoundService"):GetDescendants()) do
	applySFXMute(descendant)
end

workspace.DescendantAdded:Connect(applySFXMute)
game:GetService("SoundService").DescendantAdded:Connect(applySFXMute)

turnOff.MouseButton1Click:Connect(function()
	sfxMuted = true
	turnOff.Visible = false
	turnOn.Visible = true
	for _, descendant in ipairs(workspace:GetDescendants()) do
		applySFXMute(descendant)
	end
	for _, descendant in ipairs(game:GetService("SoundService"):GetDescendants()) do
		applySFXMute(descendant)
	end
end)

turnOn.MouseButton1Click:Connect(function()
	sfxMuted = false
	turnOff.Visible = true
	turnOn.Visible = false
	for _, descendant in ipairs(workspace:GetDescendants()) do
		applySFXMute(descendant)
	end
	for _, descendant in ipairs(game:GetService("SoundService"):GetDescendants()) do
		applySFXMute(descendant)
	end
end)
