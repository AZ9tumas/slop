local waitline = {}

script.Parent.ChildAdded:Connect(function(c)
	if string.find(c.Name,"Sort_") then
		table.insert(waitline,{f=c, val = tonumber(string.split(c.Name,"_")[2])})
	end
end)

script.Parent.Parent.ChildRemoved:Connect(function()
	if #script.Parent.Parent:GetChildren()-3 < script.Parent.Parent.Parent.Defaults:GetAttribute("1_MaxPopUps") and #waitline > 0 then
		
		table.sort(waitline, function(a, b) return a.val < b.val end)
		local move = waitline[1]
		move.f.Parent = script.Parent.Parent
		move.f.Name = "Sort_"..tick()
		move.f.Locate.Enabled = true
		table.remove(waitline,1)
		
	end
end)
