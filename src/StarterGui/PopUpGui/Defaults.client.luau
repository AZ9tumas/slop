local clone = script.Parent.PopUps.cloneframe
local text = clone.TextLabel

text.FontFace = script:GetAttribute("1_DefaultFont")
if script:GetAttribute("0_ReverseDirection") then clone.AnchorPoint = Vector2.new(0.5,0) end