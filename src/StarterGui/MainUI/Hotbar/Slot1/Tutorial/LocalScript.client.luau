local t = game:GetService("TweenService")
local ui = script.Parent
local pos = ui.Position

while true do
    t:Create(ui, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = pos + UDim2.new(0,0,0,-6)}):Play()
    task.wait(1.5)
    t:Create(ui, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = pos + UDim2.new(0,0,0,6)}):Play()
    task.wait(1.5)
end
