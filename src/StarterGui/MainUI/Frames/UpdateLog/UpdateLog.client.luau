local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local container = ReplicatedStorage.Modules
local Icon = require(container.Topbar)
local InventoryButton = Icon.new()
	:setLabel("Update Log")
	:setImage(114127804740858, "Deselected")
	:setImage(114127804740858, "Selected")
	:setOrder(2)
	:setRight()
InventoryButton:bindEvent("selected", function()
	Players.LocalPlayer.PlayerGui.MainUI.Frames.UpdateLog.Visible = true
end)
InventoryButton:bindEvent("deselected", function()
	Players.LocalPlayer.PlayerGui.MainUI.Frames.UpdateLog.Visible = false
end)