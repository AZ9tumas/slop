local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RequestTool = ReplicatedStorage.Remotes:WaitForChild("RequestTool")

RequestTool.OnServerInvoke = function(player, toolType,toolName, toolId,delete,shovel,mutation)
	
	local backpack = player:WaitForChild("Backpack")
	if shovel == true then
		local shovel = script.Shovel:Clone()
		shovel.Parent = backpack
		shovel:SetAttribute("Id",toolId)
	end
	if delete == true then
		warn("DELETING")
		for _, tool in ipairs(backpack:GetChildren()) do
			local localtoolId = tool:GetAttribute("EggId") or tool:GetAttribute("PigeonId") or tool:GetAttribute("Id")
			if localtoolId == toolId then
				tool:Destroy()
				task.wait(0.1)
			end
		end
		
		for _, tool in ipairs(player.Character:GetChildren()) do
			if tool:IsA("Tool") then
				local localtoolId = tool:GetAttribute("EggId") or tool:GetAttribute("PigeonId") or tool:GetAttribute("Id")
				if localtoolId == toolId then
					player.Character.Humanoid:UnequipTools()
					tool.Parent = backpack  -- Optional, only if you need it in backpack
					task.wait(0.05)         -- give time for hotbar
					tool:Destroy()          -- Destroy after it’s safe
				end
			end
		end

		return
	else
		local newTool

		if toolType == "Egg" then
			local entry = ReplicatedStorage.Game.Eggs:FindFirstChild(toolName)
			if entry then
				newTool = Instance.new("Tool")
				newTool.Name = toolName.." Egg"
				newTool.RequiresHandle = false
				newTool.CanBeDropped = false
				newTool:SetAttribute("EggId", toolId)
				newTool:SetAttribute("Mutation", mutation)

				local eggHandle = entry.Egg:Clone()
				eggHandle.Name = "Handle"
				eggHandle.Parent = newTool
				
				if newTool:FindFirstChild("EggPlacingHandler") then
					newTool:FindFirstChild("EggPlacingHandler"):Destroy()
				end

				local handler = ReplicatedStorage.GameHandlers.EggPlacingHandler:Clone()
				handler.Parent = newTool
				handler.Enabled = true
				local serverhandler = ReplicatedStorage.GameHandlers.EggPlacingHandlerServer:Clone()
				serverhandler.Parent = newTool
				serverhandler.Enabled = true
			end

		elseif toolType == "Pigeon" then
			local entry = ReplicatedStorage.Game.Pigeons:FindFirstChild(toolName)
			if entry then
				newTool = Instance.new("Tool")
				newTool.Name = toolName
				newTool.RequiresHandle = false
				newTool.CanBeDropped = false
				newTool:SetAttribute("PigeonId", toolId)

				local handle = entry:Clone()
				handle.Name = "Handle"
				handle.Parent = newTool
				
				if newTool:FindFirstChild("PiggeonPlacingHandler") then
					newTool:FindFirstChild("PiggeonPlacingHandler"):Destroy()
				end

				local handler = ReplicatedStorage.GameHandlers.PiggeonPlacingHandler:Clone()
				handler.Parent = newTool
				handler.Enabled = true
				
				local serverhandler = ReplicatedStorage.GameHandlers.PiggeonPlacingHandlerServer:Clone()
				serverhandler.Parent = newTool
				serverhandler.Enabled = true
			end

		elseif toolType == "Gear" then
			local entry = ReplicatedStorage.ShopTools:FindFirstChild(toolName)
			if entry then
				newTool = entry:Clone()
				newTool:SetAttribute("Id", toolId)
			end
		end

		if newTool then
			newTool.Parent = backpack -- server owns it
			return newTool
		else
			return nil
		end
	end
	
end


game.ReplicatedStorage.Remotes.ToolManagement.OnServerEvent:Connect(function(player,parent,name,endParent)
	if parent == "Character" then
		local tool = player.Character:FindFirstChild(name)
		tool.Parent = player.Backpack
	end
	if parent == "Backpack" then
		local tool = player.Backpack:FindFirstChild(name)
		tool.Parent = player.Character
	end
end)