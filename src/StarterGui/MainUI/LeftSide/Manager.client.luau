local player = game.Players.LocalPlayer
local UITweening = require(game.ReplicatedStorage.Modules.UITweening)



script.Parent.Buttons.Quests.MouseButton1Click:Connect(function()
	script.Parent.Parent.Frames.Quests.Visible = not script.Parent.Parent.Frames.Quests.Visible 
end)

script.Parent.Buttons.Update.MouseButton1Click:Connect(function()
	script.Parent.Parent.Frames.UpdateLog.Visible = not script.Parent.Parent.Frames.UpdateLog.Visible 
end)

script.Parent.Buttons.Settings.MouseButton1Click:Connect(function()
	script.Parent.Parent.Frames.Settings.Visible = not script.Parent.Parent.Frames.Settings.Visible
end)

script.Parent.Buttons.Daily.MouseButton1Click:Connect(function()
	script.Parent.Parent.Frames.DailyRewards.Visible = not script.Parent.Parent.Frames.DailyRewards.Visible 
end)

script.Parent.Parent.Frames.Quests.Top.Close.MouseButton1Click:Connect(function()
	script.Parent.Parent.Frames.Quests.Visible = false
end)

script.Parent.Parent.Frames.UpdateLog.Top.Close.MouseButton1Click:Connect(function()
	script.Parent.Parent.Frames.UpdateLog.Visible = false
end)

script.Parent.Parent.Frames.Settings.Top.Close.MouseButton1Click:Connect(function()
	script.Parent.Parent.Frames.Settings.Visible = false
end)

script.Parent.Buttons.Index.MouseButton1Click:Connect(function()
    script.Parent.Parent.Frames.Index.Visible = not script.Parent.Parent.Frames.Index.Visible
end)

script.Parent.Parent.Frames.Index.Top.Close.MouseButton1Click:Connect(function()  
    script.Parent.Parent.Frames.Index.Visible = false
end)
script.Parent.Buttons.Store.MouseButton1Click:Connect(function()

    script.Parent.Parent.Frames.Store.Visible = not script.Parent.Parent.Frames.Store.Visible
end)

--[[script.Parent.Buttons.AdminAbuse.MouseButton1Click:Connect(function()
    script.Parent.Parent.Frames.AdminAbuse.Visible = not script.Parent.Parent.Frames.AdminAbuse.Visible
    if script.Parent.Parent.Frames.AdminAbuse.Visible == true then
        script.Sound:Play()
    end
end)

script.Parent.Parent.Frames.AdminAbuse.Top.Close.MouseButton1Click:Connect(function()
    script.Parent.Parent.Frames.AdminAbuse.Visible = false
end)]]