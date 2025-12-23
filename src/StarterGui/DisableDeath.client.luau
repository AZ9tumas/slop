local StarterGui = game:GetService("StarterGui")

local function safeSetCore(name, value)
	while true do
		local success = pcall(function()
			StarterGui:SetCore(name, value)
		end)
		if success then break end
		task.wait(0.1)
	end
end

safeSetCore("ResetButtonCallback", false)
