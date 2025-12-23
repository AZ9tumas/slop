local player = game.Players.LocalPlayer
local UITweening = require(game.ReplicatedStorage.Modules.UITweening)


local leaderstats = player:FindFirstChild("leaderstats")
repeat task.wait() leaderstats = player:FindFirstChild("leaderstats") until leaderstats
function FormatWithCommas(number)
	if type(number) ~= "number" then
		warn("FormatWithCommas expects a number, got", type(number))
		return tostring(number)
	end

	local formatted = tostring(math.floor(number))
	local k

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end

	return formatted
end
local beaks = leaderstats:WaitForChild("Beaks")

script.Parent.Main.Text = FormatWithCommas(tonumber(beaks.Value)) .. " $"

beaks.Changed:Connect(function()
	script.Parent.Main.Text = FormatWithCommas(tonumber(beaks.Value)) .. " $"
end)