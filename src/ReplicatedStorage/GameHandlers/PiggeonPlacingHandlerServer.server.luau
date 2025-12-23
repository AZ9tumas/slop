local tool = script.Parent
local handleA = tool:WaitForChild("Handle")

local function getScale(weight)
    weight = weight or 5
    local minWeight, maxWeight = 2.5, 20.8
    local minScale, maxScale = 0.1955, 0.4455

    if weight > 400 then
        minScale = 1.0555 
        maxScale = 1.5955

    elseif weight > 310 then
        minScale = 0.9955 
        maxScale = 1.1955

    elseif weight > 230 then
        minScale = 0.8755 
        maxScale = 0.9955

    elseif weight > 160 then
        minScale = 0.7255 
        maxScale = 0.8755

    elseif weight > 105 then
        minScale = 0.6655 
        maxScale = 0.7955

    elseif weight > 70 then
        minScale = 0.5155 
        maxScale = 0.6455

        -- 🆕 added more mid-small brackets
    elseif weight > 55 then
        minScale = 0.4555
        maxScale = 0.5955

    elseif weight > 40 then
        minScale = 0.4155
        maxScale = 0.5455

    elseif weight > 35 then
        minScale = 0.3655
        maxScale = 0.5155

    elseif weight > 25 then
        minScale = 0.3355
        maxScale = 0.4955

    elseif weight > 20 then
        minScale = 0.3155
        maxScale = 0.4855

    elseif weight > 15 then
        minScale = 0.2955
        maxScale = 0.4755

    elseif weight > 10 then
        minScale = 0.2655
        maxScale = 0.4555

    elseif weight > 7.5 then
        minScale = 0.2355
        maxScale = 0.4455

    elseif weight > 4.8 then
        minScale = 0.2055
        maxScale = 0.4355

    else
        minScale = 0.1955
        maxScale = 0.3655
    end

    if weight < minWeight then
        weight = minWeight
    elseif weight > maxWeight then
        weight = maxWeight
    end

    return minScale + ((weight - minWeight) / (maxWeight - minWeight)) * (maxScale - minScale)
end

tool.Equipped:Connect(function()
	local character = tool.Parent
	local handle = handleA:Clone()

	handle.Name = "ExampleHandle"
	handle.Parent = tool
	handle.PrimaryPart.CFrame = character["Right Arm"].CFrame
	for _, v in pairs(handle:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v:Destroy()
		end
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Massless = true
			v.CanQuery = false
			v.CanTouch = false
			v.Anchored = false
		end
	end
	handle.PrimaryPart.Anchored = false
	local rightArm = character:WaitForChild("Right Arm")

	local data = _G.getPigeonDatafromid(game.Players:GetPlayerFromCharacter(character),tool:GetAttribute("PigeonId"))
	local Scale
	if data.Weight then
	    Scale = getScale(data.Weight or 5)
	end
	if not tool:GetAttribute("Weight") then
		tool:SetAttribute("Weight",data.Weight or 5)
	end
	
	if not tool:GetAttribute("Weight") then
		tool:SetAttribute("Weight",data.Mutation)
	end
	print(data)
	if data.Weight then
	handle:ScaleTo(Scale)
	end
	_G.addmutationvisualGlobal(handle,data.Mutation)
	local weld = Instance.new("ManualWeld")
	weld.Name = "HandleWeld"
	weld.Part0 = rightArm
	weld.Part1 = handle.PrimaryPart
	weld.C1 = CFrame.new(1, -1, 0)
	weld.C1 *= CFrame.Angles(math.rad(-90),math.rad(180),math.rad(90))
	weld.Parent = handle
end)

tool.Unequipped:Connect(function()
	local handle = tool:FindFirstChild("ExampleHandle")
	if handle then
		handle:Destroy()
	end
end)
