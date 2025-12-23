local ts = game:GetService("TweenService")

local frame = script.Parent
local defaults = frame.Parent.Parent.Defaults
local count,ticks,loc

local function getpos()

	ticks = {}
	for i,v in pairs(script.Parent.Parent:GetChildren()) do
		if string.find(v.Name,"Sort_") then
			table.insert(ticks,{s=tonumber(string.split(v.Name,"_")[2]),y=v.Size.Y.Scale})
		end
	end

	if defaults:GetAttribute("0_ReverseSort") then
		table.sort(ticks, function(a, b) return a.s < b.s end)
	else
		table.sort(ticks, function(a, b) return a.s > b.s end)
	end

	for i,v in pairs(ticks) do
		if v.s == tonumber(string.split(script.Parent.Name,"_")[2]) then loc = i end
	end

	local newpos = UDim2.new(0.5,0,0,0)
	for i=1,loc-1 do
		newpos = newpos+UDim2.new(0,0,-(0.15+ticks[i].y),-5)
	end

	if defaults:GetAttribute("0_ReverseDirection") then
		newpos = UDim2.new(0.5,0,-newpos.Y.Scale,-newpos.Y.Offset)
	end

	return newpos

end


frame.Position = getpos()
frame.Visible = true

script.Parent.Parent.ChildAdded:Connect(function(c)

	local transin = c:FindFirstChild("TransIn")
	if transin then
		if transin.Value == "" then transin.Changed:Wait() end
	end

	local newpos = getpos()

	if transin then
		transin = transin.Value
		if transin == "FadeIn" then
			local info = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
			ts:Create(frame,info,{Position = newpos}):Play()

		elseif transin == "Typewriter" then
			local info = TweenInfo.new(0.1,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
			ts:Create(frame,info,{Position = newpos}):Play()

		elseif transin == "Drop" then
			local info = TweenInfo.new(0.05,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
			ts:Create(frame,info,{Position = newpos}):Play()
		end
	else
		local info = TweenInfo.new(0.1,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
		ts:Create(frame,info,{Position = newpos}):Play()
	end


end)

script.Parent.Parent.ChildRemoved:Connect(function(c)

	local newpos = getpos()

	local info = TweenInfo.new(0.1,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
	ts:Create(frame,info,{Position = newpos}):Play()

end)