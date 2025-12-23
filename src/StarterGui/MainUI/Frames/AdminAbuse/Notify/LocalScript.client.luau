local S = game:GetService("SocialService")
local ID = "488393001035104920"

script.Parent.MouseButton1Click:Connect(function() 
    S:PromptRsvpToEventAsync(ID) 
end)
