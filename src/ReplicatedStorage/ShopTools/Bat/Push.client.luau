local tool = script.Parent
local remote = tool:WaitForChild("SlapEvent")

tool.Activated:Connect(function()
	remote:FireServer()
end)
