local function getMyPlot(player)
    for _, plot in ipairs(workspace.Map.Plots:GetChildren()) do
        local ownerId = plot:GetAttribute("OwnerUserId")
        if ownerId and ownerId == player.UserId then
            return plot
        end
    end
    return nil
end

pcall(function()
    _G.ClearLingering()
    task.wait()
    _G.LingeringNotification("Lets expand your plot, equip your shovel!")

end)
game.Players.LocalPlayer.PlayerGui.MainUI.Hotbar.Slot1.Tutorial.Visible = true
game.Players.LocalPlayer.PlayerGui.MainUI.Hotbar.Slot1.Tutorial.LocalScript.Enabled = true
repeat wait(0.5) until game.Players.LocalPlayer.Character:FindFirstChild("Shovel")
game.Players.LocalPlayer.PlayerGui.MainUI.Hotbar.Slot1.Tutorial.Visible = false
game.Players.LocalPlayer.PlayerGui.MainUI.Hotbar.Slot1.Tutorial.LocalScript.Enabled = false
pcall(function()
    _G.ClearLingering()
    task.wait()
    _G.LingeringNotification("Now click the slot so you can Buy it!")
end)
task.spawn(function()
getMyPlot(game.Players.LocalPlayer).Model.Expansions["21"].Highlight.Enabled = true
end)
local currentBeam = game.ReplicatedStorage.Game.TutorialBeam:Clone()
currentBeam.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
currentBeam.Attachment0 = game.Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
local Att = Instance.new("Attachment", getMyPlot(game.Players.LocalPlayer).Model.Expansions["21"].ExpandFloor)
currentBeam.Attachment1 = Att
repeat wait(1) until game.Players.LocalPlayer.Character:FindFirstChild("ClickedPlot")
currentBeam:Destroy()
getMyPlot(game.Players.LocalPlayer).Model.Expansions["21"].Highlight.Enabled = false

pcall(function()
    _G.ClearLingering()
    task.wait()
    _G.Notification("Great! now buy it if you want!", Color3.new(0.266667, 1, 0))
end)