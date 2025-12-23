local Player = game.Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local Camera = workspace.CurrentCamera
local CutscenePart = workspace.Map.Cameras.LeaveCutscene

GuiService.MenuOpened:Connect(function()
	if Player.Character:FindFirstChild("BlockLeaveCutscene") then return end
	Camera.CameraType = Enum.CameraType.Scriptable

	local tween = TweenService:Create(
		Camera,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{CFrame = CutscenePart.CFrame}
	)
    tween:Play()
    Player.PlayerGui.MainUI.Top.ComeBack.Visible = true
    Player.PlayerGui.MainUI.Top.Holder.Visible = false
end)

GuiService.MenuClosed:Connect(function()
	if Player.Character:FindFirstChild("BlockLeaveCutscene") then return end
    Camera.CameraType = Enum.CameraType.Scriptable
    Player.PlayerGui.MainUI.Top.ComeBack.Visible = false
    Player.PlayerGui.MainUI.Top.Holder.Visible = true
	local root = Player.Character:WaitForChild("HumanoidRootPart")

	local tween = TweenService:Create(
		Camera,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{CFrame = CFrame.new(root.Position + Vector3.new(0, 5, -10), root.Position)}
	)
	tween:Play()

	tween.Completed:Connect(function()
		if Camera.CameraType == Enum.CameraType.Scriptable then
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = Player.Character:WaitForChild("Humanoid")
		end
	end)
end)
