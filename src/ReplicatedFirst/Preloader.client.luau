local CP = game:GetService("ContentProvider")
local Animations = script:WaitForChild("Animations")

warn("Preloading Animations...")
CP:PreloadAsync(Animations:GetChildren())
print("Animations Preloaded!")
