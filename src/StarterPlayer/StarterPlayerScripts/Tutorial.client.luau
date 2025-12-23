local remote = game.ReplicatedStorage.Remotes:WaitForChild("TutorialRemote")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
repeat wait() remote = game.ReplicatedStorage.Remotes:WaitForChild("TutorialRemote") until remote

task.wait(16)

local currentBeam = game.ReplicatedStorage.Game.TutorialBeam:Clone()
local function getMyPlot(player)
	for _, plot in ipairs(workspace.Map.Plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId and ownerId == player.UserId then
			return plot
		end
	end
	return nil
end
local inventoryUpdated = false
remote.OnClientEvent:Connect(function(progress)
	if progress == 1 then
		wait(.1)
		pcall(function()
		_G.ClearLingering()
		_G.LingeringNotification("Buy your first common egg")
		end)
		currentBeam.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
		currentBeam.Attachment0 = game.Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
		local conn = workspace.ChildAdded:Connect(function(child)
			local nearest, dist = nil, math.huge
			for _, egg in ipairs(workspace:GetDescendants()) do
				if egg:IsA("Model") and egg.Name == "Egg" and egg:GetAttribute("Rarity") == "Common" and egg.PrimaryPart then
					local d = (egg.PrimaryPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
					if d < dist then nearest, dist = egg, d end
				end
			end
			if nearest then
				currentBeam.Attachment1 = Instance.new("Attachment", nearest.PrimaryPart)
			end
		end)
		local foundCommonEgg = false
		repeat 
			task.wait(1)
			local Ainventory
			Knit.GetService("InventoryService"):GetInventory():andThen(function(inventory)
				
				Ainventory = inventory
				for i,v in pairs(Ainventory.Eggs) do
					if string.find(v.Name, "Common") then
						foundCommonEgg = true
					end
				end
				
			end)
		until foundCommonEgg == true
		warn("FOUND THE COMMON EGG BOUGHT")
		pcall(function()
		_G.ClearLingering()
		conn:Disconnect()
		currentBeam.Enabled = false
		_G.ClearLingering()
		remote:FireServer(progress+1)
		_G.ClearLingering()
		end)
	end
	if progress == 2 then
		wait(.1)
		pcall(function()
        _G.ClearLingering()
        _G.Notification("Place the egg on your plot!")
		--_G.LingeringNotification("Place the egg on your plot")
		end)
		currentBeam.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
		currentBeam.Attachment0 = game.Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
		currentBeam.Enabled = true
		currentBeam.Attachment1 = getMyPlot(game.Players.LocalPlayer).Model.Floor.Part:FindFirstChildWhichIsA("Attachment")
		
		repeat wait() until getMyPlot(game.Players.LocalPlayer):FindFirstChild("Eggs")
		warn("FOUND EGG FOLDER")
		pcall(function()
		_G.ClearLingering()
		remote:FireServer(progress+1)
		end)
	end
	if progress == 3 then
		wait(.1)
		pcall(function()
        _G.ClearLingering()
        _G.Notification("Wait for the egg to finish hatching!")
		--_G.LingeringNotification("Wait for the egg to finish hatching")
		end)
		currentBeam.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
		currentBeam.Attachment0 = game.Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
		currentBeam.Enabled = true
		local attach = Instance.new("Attachment",getMyPlot(game.Players.LocalPlayer).Eggs:FindFirstChildWhichIsA("Model").PrimaryPart)
		currentBeam.Attachment1 = attach
		local egg = attach.Parent.Parent
		repeat wait() until attach.Parent.Parent:GetAttribute("DoneHatching")
		pcall(function()
		_G.ClearLingering()

		_G.LingeringNotification("Hatch the Egg")
		end)
		egg.Destroying:Wait()
		remote:FireServer(progress+1)

		
		pcall(function()
		_G.ClearLingering()
		--_G.Notification("Tutorial Completed")
		--currentBeam.Attachment0 = game.Workspace.TaskShop.HumanoidRootPart.RootAttachment
		--_G.TrackFirstQuest()
		end)
	end
	if progress == 4 then
		wait(.1)
		
		currentBeam.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
		currentBeam.Attachment0 = game.Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
		currentBeam.Enabled = true
		currentBeam.Attachment1 = game.Workspace.TaskShop.HumanoidRootPart.RootAttachment
		pcall(function()
			_G.ClearLingering()
		end)
		_G.Notification("Go claim your first task!")
		local Triggered = false
		game.Workspace.TaskShop.ProximityPrompt.Triggered:Connect(function(p)
			if p == game.Players.LocalPlayer and Triggered == false then
				Triggered = true
				pcall(function()
					_G.ClearLingering()
					_G.LingeringNotification("Click 'Give me a task.'")
				end)
				repeat wait(0.1) until _G.HasTracked == true
				pcall(function()
					_G.ClearLingering()
					_G.Notification("Nice! Now finish the task!")
                    currentBeam.Enabled = false
                    local PlotService = Knit.GetService("PlotService")
                    PlotService:TeleportSpawn()
				end)
				repeat wait(1) until _G.HasReadyToClaim == true
				currentBeam.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
				currentBeam.Attachment0 = game.Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
				currentBeam.Enabled = true
				currentBeam.Attachment1 = game.Workspace.TaskShop.HumanoidRootPart.RootAttachment
				local TalkedF = false
				game.Workspace.TaskShop.ProximityPrompt.Triggered:Connect(function(pp)
					if pp == game.Players.LocalPlayer and TalkedF == false then
						currentBeam.Enabled = false
						TalkedF = true
					end
				end)
				pcall(function()
					_G.ClearLingering()
					_G.Notification("Good! now go talk to the task NPC!")
					currentBeam.Enabled = true
				end)
				remote:FireServer(progress+1)
			end
		end)
	end
end)


game.ReplicatedStorage.Remotes.InventoryUpdate.OnClientEvent:Connect(function()
	inventoryUpdated = true
end)