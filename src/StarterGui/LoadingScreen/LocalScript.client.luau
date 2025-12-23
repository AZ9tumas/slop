local RunService = game:GetService("RunService")
local isS = RunService:IsStudio()

if isS then return end

local PCount = 0

script.Parent.Enabled = true

game.Players.LocalPlayer:WaitForChild("PlayerGui").MainUI.Enabled = false
repeat wait() until game.Workspace.CurrentCamera 
game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
game.Workspace.CurrentCamera.CFrame = game.Workspace.Map.Cameras.LoadingScreen.CFrame
local BlockS = Instance.new("BoolValue", game.Players.LocalPlayer.Character)
BlockS.Name = "BlockLeaveCutscene"
game.Lighting.TurorialBlur.Enabled = true

for i = 1, 100 do
	PCount += 1
	script.Parent.Progress.Text = PCount .. "%"
	task.wait(0.09)
end

script.Parent.Progress.Text = "Loading Data.."

repeat wait(0.5) until game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("leaderstats")

script.Parent.Progress.Text = "Done!"

wait(2.5)
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

script.Parent.Enabled = false

game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
game.Lighting.TurorialBlur.Enabled = false

game.Players.LocalPlayer:WaitForChild("PlayerGui").MainUI.Enabled = true
BlockS:Destroy()
