local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")

local H

task.wait(2)

game.ReplicatedStorage.Remotes.RequestTool:InvokeServer(nil,nil,1,nil,true)
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player:WaitForChild("Backpack")
local gui = player.PlayerGui:WaitForChild("MainUI")

local container = ReplicatedStorage.Modules
local Icon = require(container.Topbar)
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local InventoryButton = Icon.new()
    :setLabel("Inventory")
    :setImage(96943151264418, "Deselected")
    :setImage(96943151264418, "Selected")

local hotbar = gui:WaitForChild("Hotbar")
local inventoryFrame = gui.Frames:WaitForChild("Inventory")
local scrollFrame = inventoryFrame.Holder:WaitForChild("ScrollingFrame")
local searchBox = inventoryFrame.Search:WaitForChild("TextBox")

local pigeonButton = inventoryFrame.Buttons:WaitForChild("Pigeons")
local eggButton = inventoryFrame.Buttons:WaitForChild("Eggs")
local gearButton = inventoryFrame.Buttons:WaitForChild("Gears")

local previousInventory = { Pigeon = {}, Egg = {}, Gear = {} }
local categoryButtons = { Pigeon = pigeonButton, Egg = eggButton, Gear = gearButton }
local selectedItem = nil
local favorites = {}
local rawInventory 
local InventoryService
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
_G.ClearInventory = function()
    for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and not favorites[tool:GetAttribute("PigeonId") or tool:GetAttribute("EggId")] then
            local lowerName = tool.Name:lower()
            if not lowerName:find("pigeon") and not lowerName:find("egg") then continue end
            tool:Destroy()
        end
    end
    for _, tool in ipairs(character:GetChildren()) do
		if tool:IsA("Tool") and not favorites[tool:GetAttribute("PigeonId") or tool:GetAttribute("EggId")] then
            local lowerName = tool.Name:lower()
            if not lowerName:find("pigeon") and not lowerName:find("egg") then continue end
            tool:Destroy()
        end
    end
end

_G.SellTool = function(toolName)
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == toolName then
            tool.Parent = backpack
            task.wait()
            if tool and tool.Parent then tool:Destroy() end
            task.wait(0.1)
            return true
        end
    end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == toolName then
            tool.Parent = backpack
            task.wait()
            if tool and tool.Parent then tool:Destroy() end
            task.wait(0.1)
            return true
        end
    end
    return false
end

local hotbarSlots = {}
for i = 1, 9 do
    hotbarSlots[i] = hotbar:WaitForChild("Slot" .. i)
end

local currentCategory = "Pigeons"
local lastCategory = nil
local inventoryData = { Pigeon = {}, Egg = {}, Gear = {} }
local icons = { ["Egg"] = "rbxassetid://79192961641227", ["Gear"] = "rbxassetid://95439986234721", ["Pigeon"] = "rbxassetid://125126736270718" }

local function clearScrollFrame()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") and child.Name ~= "Template" then
            child:Destroy()
        end
    end
end

local uiEquipped = {}
local equippedItems = {}
local activeSlot = nil

local function toolExists(tool)
    for _, v in pairs(player.Character:GetChildren()) do
        local id = v:GetAttribute("EggId") or v:GetAttribute("PigeonId") or v:GetAttribute("Id")
        if id == tool then return true end
    end
    for _, v in pairs(player.Backpack:GetChildren()) do
        local id = v:GetAttribute("EggId") or v:GetAttribute("PigeonId") or v:GetAttribute("Id")
        if id == tool then return true end
    end
    return false
end

local function updateInventoryHighlights()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") and child:FindFirstChild("UIStroke") then
            local stroke = child.UIStroke
            local inHotbar = false
            local childId = child:GetAttribute("EggId") or child:GetAttribute("PigeonId") or child:GetAttribute("Id") or "none"

            for _, slotItem in ipairs(uiEquipped) do
                if slotItem then
                    local slotId = slotItem.Tool and (slotItem.Tool:GetAttribute("EggId") or slotItem.Tool:GetAttribute("PigeonId") or slotItem.Tool:GetAttribute("Id")) or slotItem.Id
                    if slotId == childId then
                        inHotbar = true
                        break
                    end
                end
            end
            
            

            if inHotbar then
                child.Visible = false
            elseif favorites[childId] then
                --stroke.Color = Color3.fromRGB(255, 0, 0)
                child.Fav.Visible = true
                if selectedItem == childId then
                    stroke.Color = Color3.fromRGB(255, 255, 255)
                else
                    stroke.Color = Color3.fromRGB(10, 25, 38)
                end
            elseif selectedItem == childId then
                stroke.Color = Color3.fromRGB(255, 255, 255)
                child.Fav.Visible = false
            else
                stroke.Color = Color3.fromRGB(10, 25, 38)
                child.Fav.Visible = false
            end
        end
    end
end

local function createEggTool(eggId)
    local entry
    for _, eggData in ipairs(rawInventory.Eggs) do
        if eggData.ID == eggId then entry = eggData break end
    end
    if not entry then return nil end
    local words = entry.Name:split(" ")
    local firstWord = words[1]
    local eggTemplate = game.ReplicatedStorage.Game.Eggs[firstWord]
    if not eggTemplate then return nil end
    local EggTool = game.ReplicatedStorage.Remotes.RequestTool:InvokeServer("Egg",eggTemplate.Name,eggId,nil,nil,entry.Mutation)
    return EggTool
end

local function rebuildHotbar()
    equippedItems = {}
    for i = 1, #hotbarSlots do
        local slotItem = uiEquipped[i]
        if slotItem and slotItem.Tool and toolExists(slotItem.Id) then
            equippedItems[i] = slotItem
        else
            uiEquipped[i] = nil
            equippedItems[i] = nil
        end
    end

    local seen = {}
    for i = 1, #hotbarSlots do
        local slotItem = equippedItems[i]
        if slotItem and slotItem.Tool then
            local id = slotItem.Tool:GetAttribute("EggId") or slotItem.Tool:GetAttribute("PigeonId") or slotItem.Tool:GetAttribute("Id")
            if id then seen[slotItem.Tool.Name .. "_" .. tostring(id)] = true end
        end
    end

    for _, container in ipairs({backpack, character}) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local id = tool:GetAttribute("EggId") or tool:GetAttribute("PigeonId") or tool:GetAttribute("Id")
                if id and not seen[tool.Name .. "_" .. tostring(id)] then
                    for slotIndex = 1, #hotbarSlots do
                        if not equippedItems[slotIndex] then
                            local newItem = { Name = tool.Name, Tool = tool, Id = id }
                            equippedItems[slotIndex] = newItem
                            uiEquipped[slotIndex] = newItem
                            seen[tool.Name .. "_" .. tostring(id)] = true
                            break
                        end
                    end
                end
            end
        end
    end

    local function ensureMutationList(m)
        if not m then return {} end
        if type(m) == "string" then return {m} end
        return m
    end

    for i, slot in ipairs(hotbarSlots) do
        local item = equippedItems[i]
        if item and item.Tool and toolExists(item.Id) then
            slot.Title.Text = item.Name
            if slot.Title.Text == "Shovel" then
                slot.Title.Text = "Shovel [Pick up/Expand]"
            end
            slot.Amount.Visible = false
            
            if toolExists(item.Id) and favorites[item.Id] then
                if slot then
                    slot.Fav.Visible = true
                end
            else
                if slot then
                    slot.Fav.Visible = false
                end
            end
            
            if item.Mutation then
                local mutationText = ""
                local list = ensureMutationList(item.Mutation)
                local filtered = {}
                for _, m in ipairs(list) do
                    if m ~= "Normal" then table.insert(filtered, m) end
                end
                if next(filtered) then mutationText = " ("..table.concat(filtered, ", ")..")" end
                slot.Amount.Text = tostring(mutationText) or ""
                slot.Amount.Visible = true
            end
        else
            equippedItems[i] = nil
            uiEquipped[i] = nil
            slot.Title.Text = ""
            slot.Amount.Text = ""
            slot.Amount.Visible = false
            slot.Icon.Image = ""
            slot.Fav.Visible = false
        end

        local stroke = slot:FindFirstChild("UIStroke")
        if stroke then stroke.Color = (i == activeSlot) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(10, 25, 38) end
    end
    updateInventoryHighlights()
end

Players.LocalPlayer.Backpack.Changed:Connect(rebuildHotbar)

local function unequipAllTools()
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then tool.Parent = backpack end
    end
    activeSlot = nil
end

local function updateCategoryHighlights()
    for category, button in pairs(categoryButtons) do
        if button:FindFirstChild("UIStroke") then
            button.UIStroke.Color = (category == currentCategory) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(10, 25, 38)
        end
    end
end



local function moveToHotbar(itemName, quant, slotIndex)
    uiEquipped[slotIndex] = { Name = itemName, Amount = math.min(1, quant) }
    rebuildHotbar()
    updateInventoryHighlights()
end

local favoriteButton = inventoryFrame.Heart
favoriteButton.MouseButton1Click:Connect(function()
    if selectedItem then
        if favorites[selectedItem] then
            InventoryService:Favourite(selectedItem,false)
            favorites[selectedItem] = nil
        else
            InventoryService:Favourite(selectedItem,true)
            favorites[selectedItem] = true
        end
        updateInventoryHighlights()
    end
end)

-- Drag & Swap Vars
local draggingItem
local dragClone
local dragMoveConn
local dragReleaseConn
local dragOffset
local dragSourceSlot
local dragSourceItem
local function isInHotbar(itemId)
	for _, equipped in pairs(uiEquipped) do
		if equipped and equipped.Id == itemId then
			return true
		end
	end
	return false
end

-- Create Inventory Button
local function createInventoryButton(itemName, itemId, category, mutation,weight)
    if isInHotbar(itemId) then return end
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") and child:GetAttribute("Id") == itemId then return end
    end
    
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") and child:GetAttribute("Id") == itemId then return end
    end

    local clone
    if category == "Egg" then clone = script.Egg:Clone()
    elseif category == "Pigeon" then clone = script.Pigeon:Clone()
    else clone = script.Gear:Clone()
    end
	if isInHotbar(itemId) then
		return
	end
    clone.Name = itemId
    local function ensureMutationList(m)
        if not m then return {} end
        if type(m) == "string" then return {m} end
        return m
    end

    clone.Title.Text = itemName
    if clone.Title.Text == "Shovel" then
        clone.Title.Text = "Shovel [Pick Up/Expand]"
    end
    if mutation then
        local mutationText = ""
        local list = ensureMutationList(mutation)
        local filtered = {}
        for _, m in ipairs(list) do if m ~= "Normal" then table.insert(filtered, m) end end
        if next(filtered) then mutationText = " ("..table.concat(filtered, ", ")..")" end
        clone.Amount.Text = tostring(mutationText) or ""
    else clone.Amount.Text = "" end

    clone.Visible = true
    clone.Parent = scrollFrame
    clone:SetAttribute("Id",itemId)

    -- DRAG SUPPORT (PC & Mobile)
	local function startDrag(input)
		if typeof(input) ~= "Instance" or input.ClassName ~= "InputObject" then
			return
		end
		if not input or not input.UserInputType then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            selectedItem = itemId
            if dragClone then dragClone:Destroy() end
            draggingItem = {Name = itemName, Category = category, Mutation = tostring(mutation)}
            dragClone = clone:Clone()
            dragClone.Parent = gui
            dragClone.ZIndex = 1000
            dragClone.AnchorPoint = Vector2.new(0.5,0.5)
            local absSize = clone.AbsoluteSize
            dragClone.Size = UDim2.fromOffset(absSize.X, absSize.Y)
            local mousePos = UserInputService:GetMouseLocation()
            dragClone.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)

            dragMoveConn = RunService.RenderStepped:Connect(function()
                if dragClone then
                    local pos = UserInputService:GetMouseLocation()
                    dragClone.Position = UDim2.fromOffset(pos.X, pos.Y)
                end
            end)

            dragReleaseConn = UserInputService.InputEnded:Connect(function(releaseInput)
                if releaseInput.UserInputType ~= Enum.UserInputType.MouseButton1 and releaseInput.UserInputType ~= Enum.UserInputType.Touch then return end
                if not dragClone then return end
                local mousePos = releaseInput.Position
                local guiObjects = player.PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
                local targetSlotIndex
                if guiObjects then
                    for _, obj in ipairs(guiObjects) do
                        for i, slot in ipairs(hotbarSlots) do
                            if obj:IsDescendantOf(slot) or obj == slot then
                                targetSlotIndex = i
                                break
                            end
                        end
                        if targetSlotIndex then break end
                    end
                end

                if targetSlotIndex then
                    local lowerName = itemName:lower()
                    local tool
                    if lowerName:find("egg") then
                        tool = createEggTool(itemId)
                    elseif lowerName:find("pigeon") then
                        tool = game.ReplicatedStorage.Remotes.RequestTool:InvokeServer("Pigeon",itemName,itemId)
                    else
                        if ReplicatedStorage.ShopTools:FindFirstChild(itemName) then
                            tool = game.ReplicatedStorage.Remotes.RequestTool:InvokeServer("Gear",itemName,itemId)
                        end
                    end
                    if tool then
                        tool.Parent = backpack
                        uiEquipped[targetSlotIndex] = { Name = tool.Name, Tool = tool, Id = tool:GetAttribute("EggId") or tool:GetAttribute("PigeonId") or tool:GetAttribute("Id"), Mutation = mutation }
                        equippedItems[targetSlotIndex] = uiEquipped[targetSlotIndex]
                        rebuildHotbar()
					end
					clone:Destroy()
                end

				dragClone:Destroy()
				
                dragClone = nil
                draggingItem = nil
                updateInventoryHighlights()
                if dragMoveConn then dragMoveConn:Disconnect() dragMoveConn=nil end
                if dragReleaseConn then dragReleaseConn:Disconnect() dragReleaseConn=nil end
            end)
        end
    end

    clone.MouseButton1Down:Connect(startDrag)
    clone.InputBegan:Connect(startDrag)

    clone.MouseButton2Click:Connect(function()
        if favorites[itemId] then
            InventoryService:Favourite(itemId,false)
            favorites[itemId] = nil
        else
            InventoryService:Favourite(itemId,true)
            favorites[itemId] = true
        end
        updateInventoryHighlights()
    end)
    -- MOBILE DOUBLE TAP FAVOURITE
    local lastTap = 0
    clone.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local t = tick()
            if t - lastTap <= 0.55 then
                -- double tap detected
                if favorites[itemId] then
                    InventoryService:Favourite(itemId,false)
                    favorites[itemId] = nil
                else
                    InventoryService:Favourite(itemId,true)
                    favorites[itemId] = true
                end
                updateInventoryHighlights()
            end
            lastTap = t
        end
    end)

end

-- ... The rest of your inventory refresh/update functions remain unchanged ...



local function updateInventoryUI(forceRebuild)
	local searchText = searchBox.Text:lower()
	if forceRebuild or currentCategory ~= lastCategory then
		clearScrollFrame()
		if currentCategory == "Egg" and rawInventory.Eggs then
            for _, eggData in ipairs(rawInventory.Eggs) do
                local eggId = eggData.ID
                if eggId and not isInHotbar(eggId) then
                    if searchText == "" or eggData.Name:lower():sub(1, #searchText) == searchText then
                        createInventoryButton(eggData.Name, eggId, "Egg", eggData.Mutation)
                    end
                end
            end
		elseif currentCategory == "Pigeon" and rawInventory.Pigeons then
            for _, pigeonData in ipairs(rawInventory.Pigeons) do
                local pigeonId = pigeonData.ID
                -- check if this pigeon is already in hotbar
                if pigeonId and not isInHotbar(pigeonId) then
                    if searchText == "" or pigeonData.Name:lower():sub(1, #searchText) == searchText then
                        createInventoryButton(pigeonData.Name, pigeonId, "Pigeon", pigeonData.Mutation, pigeonData.Weight)
                    end
                end
            end
		elseif currentCategory == "Gear" and rawInventory.Tools then
			for _, toolData in pairs(rawInventory.Tools) do
				if searchText == "" or toolData.Name:lower():sub(1, #searchText) == searchText then
					createInventoryButton(toolData.Name, toolData.ID, "Tool")
				end
			end
		end
		lastCategory = currentCategory
		updateInventoryHighlights()
		updateCategoryHighlights()
	end
end


local function refreshInventory(load)
	InventoryService:GetInventory():andThen(function(rawInventorys)
		rawInventory = rawInventorys

		local newInventory = {
			Pigeon = {},
			Egg = {},
			Gear = {}
		}

		-- Populate newInventory with current counts/names from rawInventory
		if rawInventory.Eggs then
			for _, eggData in ipairs(rawInventory.Eggs) do
				newInventory.Egg[eggData.ID] = eggData
				if eggData.Fav == true then
					favorites[eggData.ID] = true
				end
			end
		end

		if rawInventory.Pigeons then
			for _, pigeonData in ipairs(rawInventory.Pigeons) do
				newInventory.Pigeon[pigeonData.ID] = pigeonData
				if pigeonData.Fav == true then
					favorites[pigeonData.ID] = true
				end
			end
		end

		if rawInventory.Tools then
			for toolName, toolData in pairs(rawInventory.Tools) do
				newInventory.Gear[toolData.ID] = {
					Name = toolData.Name,
					ID = toolData.ID,
					Fav = toolData.Fav or false
				}
				if toolData.Fav == true then
					favorites[toolData.ID] = true
				end
			end
		end

		-- Update inventoryData
		inventoryData = table.clone(newInventory)

		updateInventoryUI(true)
		updateInventoryHighlights()

		-- Auto-equip new items if this is not the initial load
		if not load then
			-- Check Eggs
			for id, egg in pairs(newInventory.Egg) do
				if not previousInventory.Egg[id] then
					for i, slot in ipairs(hotbarSlots) do
						if not equippedItems[i] then
							local tool = createEggTool(id)
							if tool then
								uiEquipped[i] = { Name = tool.Name, Tool = tool, Id = id ,Mutation = egg.Mutation }
								equippedItems[i] = uiEquipped[i]
							end
							break
						end
					end
				end
			end

			-- Check Pigeons
			for id, pigeon in pairs(newInventory.Pigeon) do
				if not previousInventory.Pigeon[id] then
					for i, slot in ipairs(hotbarSlots) do
						if not equippedItems[i] then
							local tool = game.ReplicatedStorage.Remotes.RequestTool:InvokeServer("Pigeon",pigeon.Name,id)

							uiEquipped[i] = { Name = tool.Name, Tool = tool, Id = id,Mutation = pigeon.Mutation }
							equippedItems[i] = uiEquipped[i]
							break
						end
					end
				end
			end

			-- Check Gear (Tools)
			-- Check Gear (Tools)
			for id, toolData in pairs(newInventory.Gear) do
				if not previousInventory.Gear[id] then
					for i, slot in ipairs(hotbarSlots) do
						if not equippedItems[i] then

							if ReplicatedStorage.ShopTools:FindFirstChild(toolData.Name) then

								local tool = game.ReplicatedStorage.Remotes.RequestTool:InvokeServer("Gear",toolData.Name,id)

								uiEquipped[i] = { Name = tool.Name, Tool = tool, Id = id,Mutation = toolData.Mutation }
								equippedItems[i] = uiEquipped[i]
							end
							break
						end
					end
				end
			end

		end


		rebuildHotbar()
		updateInventoryHighlights()
		previousInventory = {
			Pigeon = table.clone(newInventory.Pigeon or {}),
			Egg = table.clone(newInventory.Egg or {}),
			Gear = table.clone(newInventory.Gear or {})
		}
	end):catch(function(err)
		warn("Failed to fetch inventory data:", err)
	end)
end


_G.SellToolId = function(toolName)

	game.ReplicatedStorage.Remotes.RequestTool:InvokeServer(nil,nil,toolName,true)
	task.wait()
	refreshInventory()
end




UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Backquote then
		selectedItem = nil
		refreshInventory()
		inventoryFrame.Visible = not inventoryFrame.Visible
	end
end)


local slotCooldowns = {}
local globalEquipCooldown = false
local equipCooldownTime = 0.2

local function equipTool(tool, slotIndex)
pcall(function()
	if globalEquipCooldown or slotCooldowns[slotIndex] then return end

	-- set cooldowns
	globalEquipCooldown = true
	slotCooldowns[slotIndex] = true
	task.delay(equipCooldownTime, function()
		globalEquipCooldown = false
		slotCooldowns[slotIndex] = nil
	end)
	if activeSlot == slotIndex and character:FindFirstChild(tool.Name) then
		if tool then
			game.ReplicatedStorage.Remotes.ToolManagement:FireServer("Character",tool.Name,"Backpack")
			--tool.Parent = backpack
			activeSlot = nil
		end

	else
		if activeSlot and equippedItems[activeSlot] and equippedItems[activeSlot].Tool then
			local currentTool = equippedItems[activeSlot].Tool
			if currentTool.Parent == character then
				game.ReplicatedStorage.Remotes.ToolManagement:FireServer("Character",currentTool.Name,"Backpack")
				--currentTool.Parent = backpack
				repeat task.wait() until currentTool.Parent == backpack
			end
		end
		if player.Character:FindFirstChild(tool.Name) then
			local id = player.Character:FindFirstChild(tool.Name):GetAttribute("Id") or   player.Character:FindFirstChild(tool.Name):GetAttribute("EggId") or player.Character:FindFirstChild(tool.Name):GetAttribute("PigeonId")
			local toolid =tool:GetAttribute("Id") or   tool:GetAttribute("EggId") or tool:GetAttribute("PigeonId")
			if id == toolid then
				activeSlot = slotIndex
				return 
			end
		end

		tool.Parent = character
		activeSlot = slotIndex

		if not tool:FindFirstChild("DestroyingConnected") then
			local marker = Instance.new("BoolValue")
			marker.Name = "DestroyingConnected"
			marker.Parent = tool
			tool.Destroying:Connect(function()
				if activeSlot == slotIndex then
					activeSlot = nil
					uiEquipped[slotIndex] = nil
					task.wait()
					rebuildHotbar()
					refreshInventory()
				end
			end)
		end

	end
	rebuildHotbar()
end)
end

local SwitchDB = false

local function setupConsoleHotbarControls()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if SwitchDB == true then return end
		if gameProcessed then return end
		if not UserInputService.GamepadEnabled then return end

		if input.UserInputType == Enum.UserInputType.Gamepad1 then
			if input.KeyCode == Enum.KeyCode.ButtonR1 or input.KeyCode == Enum.KeyCode.ButtonL1 then
				local targetSlot
				SwitchDB = true
				task.delay(0.2, function()
					SwitchDB = false
				end)

				if activeSlot then
					if input.KeyCode == Enum.KeyCode.ButtonR1 then
						-- Move right, skip empty slots
						for i = activeSlot + 1, #hotbarSlots do
							if equippedItems[i] and equippedItems[i].Tool then
								targetSlot = i
								break
							end
						end
						-- if nothing found → deselect (rightmost slot behavior)
						if not targetSlot then
							if activeSlot and equippedItems[activeSlot] and equippedItems[activeSlot].Tool then
								equipTool(equippedItems[activeSlot].Tool, activeSlot) -- toggle off
							end
							activeSlot = nil
							rebuildHotbar()
							return
						end
					elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
						-- Move left, skip empty slots
						for i = activeSlot - 1, 1, -1 do
							if equippedItems[i] and equippedItems[i].Tool then
								targetSlot = i
								break
							end
						end
						-- if nothing found → deselect (leftmost slot behavior)
						if not targetSlot then
							if activeSlot and equippedItems[activeSlot] and equippedItems[activeSlot].Tool then
								equipTool(equippedItems[activeSlot].Tool, activeSlot) -- toggle off
							end
							activeSlot = nil
							rebuildHotbar()
							return
						end
					end
				else
					-- Nothing selected: R1 = select first non-empty slot, L1 = do nothing
					if input.KeyCode == Enum.KeyCode.ButtonR1 then
						for i = 1, #hotbarSlots do
							if equippedItems[i] and equippedItems[i].Tool then
								targetSlot = i
								break
							end
						end
					else
						return
					end
				end

				-- Equip or deselect target slot
				if targetSlot and equippedItems[targetSlot] and equippedItems[targetSlot].Tool then
					equipTool(equippedItems[targetSlot].Tool, targetSlot)
				else
					-- Target slot empty → deselect everything
					if activeSlot and equippedItems[activeSlot] and equippedItems[activeSlot].Tool then
						equipTool(equippedItems[activeSlot].Tool, activeSlot) -- toggle off current tool
					end
					activeSlot = nil
					rebuildHotbar()
				end
			end
		end
	end)
end

setupConsoleHotbarControls()



for i, slot in ipairs(hotbarSlots) do
	local function startDrag(x, y)
	pcall(function()
		if isDragging then return end -- prevents multiple slots from starting at once
		isDragging = true

		local item = equippedItems[i]
		if not item then isDragging = false return end
		if globalEquipCooldown then isDragging = false return end

		-- Equip normally if inventory is closed
		if not inventoryFrame.Visible then
			if item.Tool then
				equipTool(item.Tool, i)
			else
				activeSlot = (activeSlot == i) and nil or i
				rebuildHotbar()
			end
			isDragging = false
			return
		end

		-- Don't allow certain items or invisible GUI
		if string.find(item.Tool.Name, "Shovel") then isDragging = false return end
		if script.Parent.Visible == false then isDragging = false return end

		-- Prepare drag clone
		if dragClone then dragClone:Destroy() end
		draggingItem = {SlotIndex = i, Item = item}

		dragClone = slot:Clone()
		dragClone.Parent = gui
		dragClone.ZIndex = 1000
		dragClone.AnchorPoint = Vector2.new(0.5, 0.5)
		local absSize = slot.AbsoluteSize
		dragClone.Size = UDim2.fromOffset(absSize.X, absSize.Y)

		local clickPos = Vector2.new(x, y)
		local centerPos = slot.AbsolutePosition + (slot.AbsoluteSize / 2)
		dragOffset = centerPos - clickPos
		dragClone.Position = UDim2.fromOffset(clickPos.X + dragOffset.X, clickPos.Y + dragOffset.Y)

		-- Drag movement
		dragMoveConn = UserInputService.InputChanged:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragClone then
				local pos = input.Position
				dragClone.Position = UDim2.fromOffset(pos.X + dragOffset.X, pos.Y - dragOffset.Y)
			end
		end)

		-- On release
		dragReleaseConn = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			if not dragClone or not draggingItem then return end

			local pos = input.Position
			local guiObjects = player.PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)

			local targetSlotIndex
			local droppedInInventory = false

			-- Check if released over inventory
			if guiObjects then
				for _, obj in ipairs(guiObjects) do
					if obj:IsDescendantOf(scrollFrame) or obj == scrollFrame then
						droppedInInventory = true
						break
					end
				end
			end

			-- Check if released over another hotbar slot
			if not droppedInInventory and guiObjects then
				for _, obj in ipairs(guiObjects) do
					for j, targetSlot in ipairs(hotbarSlots) do
						if obj:IsDescendantOf(targetSlot) or obj == targetSlot then
							targetSlotIndex = j
							break
						end
					end
					if targetSlotIndex then break end
				end
			end

			local sourceIndex = draggingItem.SlotIndex

			-- Swap hotbar items
			if targetSlotIndex then
				local temp = equippedItems[targetSlotIndex]
				equippedItems[targetSlotIndex] = equippedItems[sourceIndex]
				equippedItems[sourceIndex] = temp

				local tempUI = uiEquipped[targetSlotIndex]
				uiEquipped[targetSlotIndex] = uiEquipped[sourceIndex]
				uiEquipped[sourceIndex] = tempUI

				-- Update activeSlot if needed
				if activeSlot == sourceIndex then
					activeSlot = targetSlotIndex
				elseif activeSlot == targetSlotIndex then
					activeSlot = sourceIndex
				end

				rebuildHotbar()
			end

			-- Move to inventory
			if droppedInInventory then
				uiEquipped[sourceIndex] = nil
				equippedItems[sourceIndex] = nil
				_G.SellToolId(item.Tool:GetAttribute("Id") or item.Tool:GetAttribute("PigeonId") or item.Tool:GetAttribute("EggId"))
				if activeSlot == sourceIndex then activeSlot = nil end
				rebuildHotbar()
				updateInventoryHighlights()
			end

			-- Clean up
			if dragClone then dragClone:Destroy() end
			dragClone = nil
			draggingItem = nil
			if dragMoveConn then dragMoveConn:Disconnect() dragMoveConn = nil end
			if dragReleaseConn then dragReleaseConn:Disconnect() dragReleaseConn = nil end

			isDragging = false -- ✅ allow new drags now
		end)
	end)
	end

	-- PC click
	slot.MouseButton1Down:Connect(function(x, y)
		if not isDragging then
			pcall(function()
			startDrag(x, y)
			end)
		end
	end)

	-- Mobile tap
	slot.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch and not isDragging then
			pcall(function()
			startDrag(input.Position.X, input.Position.Y)
			end)
		end
	end)
end


--[[for i, slot in ipairs(hotbarSlots) do
	local function startDrag(x, y)
		local item = equippedItems[i]
		if globalEquipCooldown then return end
		if not item then return end

		if item and item.Tool then
			equipTool(item.Tool, i)
		else
			activeSlot = (activeSlot == i) and nil or i
			rebuildHotbar()
		end
		if string.find(item.Tool.Name, "Shovel") then return end
		if script.Parent.Visible == false then return end

		if dragClone then dragClone:Destroy() end
		draggingItem = slot

		dragClone = slot:Clone()
		dragClone.Parent = gui
		dragClone.ZIndex = 1000
		dragClone.AnchorPoint = Vector2.new(0.5, 0.5)
		local absSize = slot.AbsoluteSize
		dragClone.Size = UDim2.fromOffset(absSize.X, absSize.Y)

		local clickPos = Vector2.new(x, y)
		local centerPos = slot.AbsolutePosition + (slot.AbsoluteSize / 2)
		dragOffset = centerPos - clickPos
		dragClone.Position = UDim2.fromOffset(clickPos.X + dragOffset.X, clickPos.Y)

		dragMoveConn = UserInputService.InputChanged:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragClone then
				local pos = input.Position
				dragClone.Position = UDim2.fromOffset(pos.X + dragOffset.X, pos.Y - dragOffset.Y)
			end
		end)

		dragReleaseConn = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local pos = input.Position
				local guiObjects = player.PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)

				local droppedInInventory = false
				if guiObjects and #guiObjects > 0 then
					for _, obj in ipairs(guiObjects) do
						if obj:IsDescendantOf(scrollFrame) or obj == scrollFrame then
							droppedInInventory = true
							break
						end
					end
				end
				if dragClone then dragClone:Destroy() end
				dragClone = nil
				draggingItem = nil
				if dragMoveConn then dragMoveConn:Disconnect() dragMoveConn = nil end
				if dragReleaseConn then dragReleaseConn:Disconnect() dragReleaseConn = nil end

				if droppedInInventory then
					uiEquipped[i] = nil
					equippedItems[i] = nil
					_G.SellToolId(item.Tool:GetAttribute("Id") or item.Tool:GetAttribute("PigeonId") or item.Tool:GetAttribute("EggId"))
					activeSlot = (activeSlot == i) and nil or i
					rebuildHotbar()
					updateInventoryHighlights()
				end
			end
		end)
	end

	-- PC click
	slot.MouseButton1Down:Connect(function(x, y)
		startDrag(x, y)
	end)

	-- Mobile tap
	slot.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			startDrag(input.Position.X, input.Position.Y)
		end
	end)
end]]

--for i, slot in ipairs(hotbarSlots) do
--	slot.MouseButton1Click:Connect(function()
--		local item = equippedItems[i]
--		if item and item.Tool then
--			equipTool(item.Tool, i)
--		else
--			activeSlot = (activeSlot == i) and nil or i
--			rebuildHotbar()
--		end
--	end)
--end



UserInputService.InputBegan:Connect(function(input, gameProcessed)
	pcall(function()
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

	local kc = input.KeyCode

	if kc == Enum.KeyCode.One or kc == Enum.KeyCode.KeypadOne then
		local item = equippedItems[1]
		if item then
			if item.Tool then equipTool(item.Tool, 1) else activeSlot = (activeSlot == 1) and nil or 1 rebuildHotbar() end
		end
	elseif kc == Enum.KeyCode.Two or kc == Enum.KeyCode.KeypadTwo then
		local item = equippedItems[2]
		if item then
			if item.Tool then equipTool(item.Tool, 2) else activeSlot = (activeSlot == 2) and nil or 2 rebuildHotbar() end
		end
	elseif kc == Enum.KeyCode.Three or kc == Enum.KeyCode.KeypadThree then
		local item = equippedItems[3]
		if item then
			if item.Tool then equipTool(item.Tool, 3) else activeSlot = (activeSlot == 3) and nil or 3 rebuildHotbar() end
		end
	elseif kc == Enum.KeyCode.Four or kc == Enum.KeyCode.KeypadFour then
		local item = equippedItems[4]
		if item then
			if item.Tool then equipTool(item.Tool, 4) else activeSlot = (activeSlot == 4) and nil or 4 rebuildHotbar() end
		end
	elseif kc == Enum.KeyCode.Five or kc == Enum.KeyCode.KeypadFive then
		local item = equippedItems[5]
		if item then
			if item.Tool then equipTool(item.Tool, 5) else activeSlot = (activeSlot == 5) and nil or 5 rebuildHotbar() end
		end
	elseif kc == Enum.KeyCode.Six or kc == Enum.KeyCode.KeypadSix then
		local item = equippedItems[6]
		if item then
			if item.Tool then equipTool(item.Tool, 6) else activeSlot = (activeSlot == 6) and nil or 6 rebuildHotbar() end
		end
	elseif kc == Enum.KeyCode.Seven or kc == Enum.KeyCode.KeypadSeven then
		local item = equippedItems[7]
		if item then
			if item.Tool then equipTool(item.Tool, 7) else activeSlot = (activeSlot == 7) and nil or 7 rebuildHotbar() end
		end
	elseif kc == Enum.KeyCode.Eight or kc == Enum.KeyCode.KeypadEight then
		local item = equippedItems[8]
		if item then
			if item.Tool then equipTool(item.Tool, 8) else activeSlot = (activeSlot == 8) and nil or 8 rebuildHotbar() end
		end
	elseif kc == Enum.KeyCode.Nine or kc == Enum.KeyCode.KeypadNine then
		local item = equippedItems[9]
		if item then
			if item.Tool then equipTool(item.Tool, 9) else activeSlot = (activeSlot == 9) and nil or 9 rebuildHotbar() end
		end
	end
end)
end)



backpack.ChildAdded:Connect(rebuildHotbar)
backpack.ChildRemoved:Connect(rebuildHotbar)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    refreshInventory()
	updateInventoryUI(false)
end)

searchBox.Changed:Connect(function()
    refreshInventory()
    updateInventoryUI(false)
end)

searchBox.FocusLost:Connect(function()
    refreshInventory()
    updateInventoryUI(false)
end)

pigeonButton.MouseButton1Click:Connect(function()
	pcall(function()
	refreshInventory()
	if currentCategory ~= "Pigeon" then
		currentCategory = "Pigeon"
		updateInventoryUI(true)
	end
	end)
end)

eggButton.MouseButton1Click:Connect(function()
	pcall(function()
	refreshInventory()
	if currentCategory ~= "Egg" then
		currentCategory = "Egg"
		updateInventoryUI(true)
	end
	end)
end)

gearButton.MouseButton1Click:Connect(function()
	pcall(function()
	refreshInventory()
	if currentCategory ~= "Gear" then
		currentCategory = "Gear"
		updateInventoryUI(true)
	end
	end)
end)

Knit.OnStart():andThen(function()
	InventoryService = Knit.GetService("InventoryService")
	refreshInventory()
	updateCategoryHighlights()
	rebuildHotbar()
end)

_G.UpdateInvs = function()
	refreshInventory()
end

--game.ReplicatedStorage.Remotes.InventoryUpdate.OnClientEvent:Connect(function()
--	refreshInventory()

--end)
InventoryButton:bindEvent("selected", function()
	inventoryFrame.Visible = true
	selectedItem = nil
	refreshInventory()
end)
InventoryButton:bindEvent("deselected", function()
	inventoryFrame.Visible = false
	selectedItem = nil
	refreshInventory()
end)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)