
game.ReplicatedStorage.Remotes:WaitForChild("Notification").OnClientEvent:Connect(function(message, Color)
    if message == "Like the game and join the group to claim the reward!" then
        game:GetService("GroupService"):PromptJoinAsync(590837616, game.Players.LocalPlayer)
    end
    if Color then
        local module = require(game.ReplicatedStorage.Modules.PopUp)
        module:SetDefaultTransition(--dont touch this, its not important
            module.TransitionIn.Fade,
            module.TransitionOut.Shrink
        )



        module.Pop.Local(--use the same settings for the global chat notification
            message,
            Color,
            6,
            {"Drop", "Fade"},
            nil
        )
    else
        local module = require(game.ReplicatedStorage.Modules.PopUp)
        module:SetDefaultTransition(--dont touch this, its not important
            module.TransitionIn.Fade,
            module.TransitionOut.Shrink
        )



        module.Pop.Local(--use the same settings for the global chat notification
            message,
            Color3.new(225, 225, 225),
            6,
            {"Drop", "Fade"},
            nil
        )
    end

end)

_G.LingeringNotification = function(message)

	local module = require(game.ReplicatedStorage.Modules.PopUp)
	--module:SetDefaultTransition(--dont touch this, its not important
	--	module.TransitionIn.Fade,
	--	module.TransitionOut.Shrink
	--)

	warn("Lingering")

	module.Pop.Local(--use the same settings for the global chat notification
		message,
		Color3.new(225, 225, 225),
		1000,
		{"Drop", "Fade"},
		nil
	)
end


_G.ClearLingering = function()
	local module = require(game.ReplicatedStorage.Modules.PopUp)

	module.Pop.LocalClear(0.5) -- fades out over 0.5 seconds

end
_G.Notification = function(message, Color : Color3)
    if message == "Like the game and join the group to claim the reward!" then
        game:GetService("GroupService"):PromptJoinAsync(590837616, game.Players.LocalPlayer)
    end
    if Color then
        local module = require(game.ReplicatedStorage.Modules.PopUp)
        module:SetDefaultTransition(--dont touch this, its not important
            module.TransitionIn.Fade,
            module.TransitionOut.Shrink
        )



        module.Pop.Local(--use the same settings for the global chat notification
            message,
            Color,
            6,
            {"Drop", "Fade"},
            nil
        )
    else
        local module = require(game.ReplicatedStorage.Modules.PopUp)
        module:SetDefaultTransition(--dont touch this, its not important
            module.TransitionIn.Fade,
            module.TransitionOut.Shrink
        )



        module.Pop.Local(--use the same settings for the global chat notification
            message,
            Color3.new(225, 225, 225),
            6,
            {"Drop", "Fade"},
            nil
        )
    end
end


script.Parent.PopUps.ChildAdded:Connect(function(s)
	if s:FindFirstChild("AnNotification") then
		task.delay(20, function()
			if s then
				s:Destroy()
			end
		end)
	end
end)