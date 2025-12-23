local targetDate = os.time({
	year = 2025,
	month = 11,
	day = 27,
	hour = 18,
	min = 30,
	sec = 0
})

targetDate = targetDate - (3 * 60 * 60)

local textLabel = script.Parent

-- Function to update the countdown display
local function updateCountdownDisplay()
	-- Get current real UTC time
	local currentUTC = DateTime.now().UnixTimestamp
	local secondsLeft = targetDate - currentUTC

	-- Stop countdown if expired
	if secondsLeft <= 0 then
		textLabel.Text = "Done."
        script.Parent.Parent.Parent.Parent.Parent.Visible = false
        game.Players.LocalPlayer.PlayerGui.MainUI.RightButtons.AdminAbuse.Visible = false
		return false
	end

	-- Break down remaining time
	local days = math.floor(secondsLeft / 86400)
	local hours = math.floor((secondsLeft % 86400) / 3600)
	local minutes = math.floor((secondsLeft % 3600) / 60)
	local seconds = math.floor(secondsLeft % 60)

	-- Smart formatting
	if days >= 1 then
        textLabel.Text = string.format("Admin abuse starts in %dd:%dh", days, hours)
	elseif hours >= 1 then
        textLabel.Text = string.format("Admin abuse starts in %dh:%02dm", hours, minutes)
	elseif minutes >= 1 then
        textLabel.Text = string.format("Admin abuse starts in %dm:%02ds", minutes, seconds)
	else
        textLabel.Text = string.format("Admin abuse starts in %ds", seconds)
	end

	return true
end

-- Update every second
while task.wait(1) do
	if not updateCountdownDisplay() then
		break
	end
end
