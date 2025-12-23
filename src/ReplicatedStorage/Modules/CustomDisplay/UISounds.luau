--// SERVICES;
local Debris = game:GetService("Debris")

--// ITERATION;
local UISounds = {}

function UISounds:Play(sound, properties)
	local foundSound = script:FindFirstChild(sound)
	if foundSound == nil then return end
	local x = foundSound:Clone()
	x.Parent = foundSound.Parent
	if properties ~= nil then
		for property, value in pairs(properties) do
			x[property] = value
		end
	end
	x:Play()
	Debris:AddItem(x,foundSound.TimeLength)
end


return UISounds
