local function CheckFramesToBlur()
	local Count = 0
	for _, Frames in script.Parent:WaitForChild("MainUI").Frames:GetChildren() do
		if Frames:IsA("Frame") and Frames.Name ~= "Inventory" then
			if Frames.Visible == true then
				Count += 1
			end
		end
	end
	if Count > 0 then
		game.TweenService:Create(game.Lighting.Blur, TweenInfo.new(0.3), {Size = 15}):Play()
		game.TweenService:Create(game.Workspace.CurrentCamera, TweenInfo.new(0.3), {FieldOfView = 50}):Play()
	else
		game.TweenService:Create(game.Lighting.Blur, TweenInfo.new(0.3), {Size = 0}):Play()
		game.TweenService:Create(game.Workspace.CurrentCamera, TweenInfo.new(0.3), {FieldOfView = 70}):Play()
	end
end

for _, Frames in script.Parent:WaitForChild("MainUI").Frames:GetChildren() do
    
	if Frames:IsA("Frame") and Frames.Name ~= "Inventory" and Frames.Name ~= "Reward" then
		Frames:GetPropertyChangedSignal("Visible"):Connect(function()
			CheckFramesToBlur()
			if Frames.Visible == true then
				for _, OtherFrames in script.Parent.MainUI.Frames:GetChildren() do
                    if OtherFrames:IsA("Frame") and Frames.Name ~= "Inventory" and OtherFrames.Name ~= "Reward" and OtherFrames ~= Frames then
						OtherFrames.Visible = false
					end
				end
			end
		end)
	end
end

script.Parent:WaitForChild("MainUI").Frames.ChildAdded:Connect(function()
    CheckFramesToBlur()
end)
script.Parent:WaitForChild("MainUI").Frames.ChildRemoved:Connect(function()
    CheckFramesToBlur()
end)
