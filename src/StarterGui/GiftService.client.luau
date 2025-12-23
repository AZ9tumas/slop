local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local char = player.Character


char.ChildAdded:Connect(function(Pigeon)
    if Pigeon:IsA("Tool") and Pigeon:GetAttribute("PigeonId") then
        for _, PTG in game.Players:GetChildren() do
            if PTG:IsA("Player") and PTG ~= player then
                local Prox = script.Gift:Clone()
                Prox.Parent = PTG.Character.HumanoidRootPart
                Prox.Enabled = true
                Prox.Triggered:Connect(function()
                    ReplicatedStorage.Remotes.GiftService:FireServer(PTG, Pigeon:GetAttribute("PigeonId"))
                    print("gift")
                end)
                char.ChildRemoved:Connect(function(same)
                    if same == Pigeon then
                        if not Prox then return end
                        Prox:Destroy()
                    end
                end)
            end
        end
    end
end)