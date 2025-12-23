function checkQ()
	if script.Parent:FindFirstChild("QuestTemplate") and script.Parent:FindFirstChild("QuestTemplate").Visible == true then
		script.Parent.Title.Visible = true
	else
		script.Parent.Title.Visible = false
	end
end

script.Parent.ChildAdded:Connect(function(s:Frame)
	checkQ()
	if s:IsA("Frame") and s.Name == "QuestTemplate" then
		s:GetPropertyChangedSignal("Visible"):Connect(function()
			checkQ()
		end)
	end
end)

checkQ()