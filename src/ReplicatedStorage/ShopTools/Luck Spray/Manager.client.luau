local tool = script.Parent
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local remote = game.ReplicatedStorage.Remotes.SprayEvent

local maxCharges = 1
local cooldown = 2 -- seconds
local charges = maxCharges
local onCooldown = false
local pending = false
tool.Activated:Connect(function()
	if  not onCooldown then
		charges = charges - 1
		remote:FireServer("Luck",tool.Name,tool:GetAttribute("Id"))
		onCooldown = true
		pending = true
		task.spawn(function()
			local TweenService = game:GetService("TweenService")
			local part = script.Parent.Handle.Liquid

			part.Transparency = 1

			local tweenInfo = TweenInfo.new(
				1,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)

			local toInvisible = TweenService:Create(part, tweenInfo, {Transparency = 1})
			local toVisible = TweenService:Create(part, tweenInfo, {Transparency = 0})
			
			toInvisible:Play()
			toInvisible.Completed:Wait()
			toVisible:Play()
		end)
		wait(cooldown)
		onCooldown = false
		
	end
end)


remote.OnClientEvent:Connect(function(spraytype, ID)
	if spraytype == "Luck" and tool:GetAttribute("Id") == ID then
		game.ReplicatedStorage.Remotes.DeleteItem:FireServer(tool)
	end
end)