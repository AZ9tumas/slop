local player = game.Players.LocalPlayer


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

local LastCheck = beaks.Value

beaks.Changed:Connect(function(NewValue)
    local change = NewValue - LastCheck
    if change > 0 then
        local SignText = script.Gain:Clone()
        SignText.Text = "+" .. FormatWithCommas(change) .. "$"
        SignText.Parent = script.Parent
        wait(1.5)
        game.TweenService:Create(SignText, TweenInfo.new(1.5), {TextTransparency = 1}):Play()
        game.TweenService:Create(SignText.UIStroke, TweenInfo.new(1.5), {Transparency = 1}):Play()
        game.Debris:AddItem(SignText, 1.5)
    elseif change < 0 then
        local SignText = script.Lose:Clone()
        SignText.Text = FormatWithCommas(change) .. "$"
        SignText.Parent = script.Parent
        wait(1.5)
        game.TweenService:Create(SignText, TweenInfo.new(1.5), {TextTransparency = 1}):Play()
        game.TweenService:Create(SignText.UIStroke, TweenInfo.new(1.5), {Transparency = 1}):Play()
        game.Debris:AddItem(SignText, 1.5)
    end
    LastCheck = NewValue
    
end)