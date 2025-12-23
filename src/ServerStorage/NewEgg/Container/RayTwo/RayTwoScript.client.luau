local TweenService = game:GetService("TweenService")
local Object = script.Parent

local tweenInfo = TweenInfo.new(
	15, -- The time the tween takes to complete
	Enum.EasingStyle.Linear, -- The tween style.
	Enum.EasingDirection.Out, -- EasingDirection
	-1, -- How many times you want the tween to repeat. If you make it less than 0 it will repeat forever.
	false, -- Reverse?
	0 -- Delay
)

local rotateTween = TweenService:Create(Object, tweenInfo, {Rotation = 360}) -- Creates the tween with the TweenInfo and what properties you want to change
rotateTween:Play()




