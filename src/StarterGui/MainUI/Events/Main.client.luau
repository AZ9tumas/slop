local function Check()
	for _, Event in game.ReplicatedStorage:WaitForChild("RunningEvents"):GetChildren() do
		if Event:IsA("BoolValue") and script.Parent:FindFirstChild(Event.Name) then
			script.Parent[Event.Name].Visible = Event.Value
		end
	end
end

for _, Event in game.ReplicatedStorage:WaitForChild("RunningEvents"):GetChildren() do
	if Event:IsA("BoolValue") and script.Parent:FindFirstChild(Event.Name) then
		script.Parent[Event.Name].Visible = Event.Value
		Event:GetPropertyChangedSignal("Value"):Connect(function()
			Check()
		end)
	end
end

for _, Button in script.Parent:GetChildren() do
    if Button:IsA("TextButton") then
        Button.MouseEnter:Connect(function()
            if Button:FindFirstChild("Info") then
                Button.Info.Visible = true
            end
        end)
        Button.MouseLeave:Connect(function()
            if Button:FindFirstChild("Info") then
                Button.Info.Visible = false
            end
        end)
    end
end

Check()