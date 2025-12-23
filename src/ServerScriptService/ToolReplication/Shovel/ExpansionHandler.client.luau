local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local ExpansionService = Knit.GetService("ExpansionService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local worldPlots = workspace:WaitForChild("Map"):WaitForChild("Plots")

local function getMyPlot(player)
	for _, plot in ipairs(worldPlots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId and ownerId == player.UserId then
			return plot
		end
	end
	return nil
end

local answer = nil
local AreYouSure = player.PlayerGui.MainUI.Frames.AreYouSure

local function resetPrompt()
	answer = nil
	AreYouSure.Visible = false
end

AreYouSure.Holder.Yes.MouseButton1Click:Connect(function()
	answer = "Yes"
	AreYouSure.Visible = false
end)

AreYouSure.Holder.No.MouseButton1Click:Connect(function()
	answer = "No"
	AreYouSure.Visible = false
end)

AreYouSure.Top.Close.MouseButton1Click:Connect(function()
	answer = "No"
	AreYouSure.Visible = false
end)

local equipped = false
script.Parent.Equipped:Connect(function()
	equipped = true
end)

script.Parent.Unequipped:Connect(function()
	equipped = false
	resetPrompt()
end)

local selectingPlot = false

local PickDB = false

local function handleTarget(target)
	if not target or not equipped or PickDB == true then return end
	PickDB = true
	task.delay(0.1, function()
		PickDB = false
	end)
	local model = target:FindFirstAncestorWhichIsA("Model")
	if model then
		if model:GetAttribute("Owner") == player.UserId and string.find(model.Name, "Pigeon") then
			local PigeonService = Knit.GetService("PigeonService")
			PigeonService:Store(model:GetAttribute("PigeonID"))
			local sound = game.ReplicatedStorage.Game.Shove:Clone()
			sound.Parent = player.Character.PrimaryPart
			sound:Play()
			return
		end
	end

	if equipped and not selectingPlot then
		local plot = getMyPlot(player)
		if not plot then return end
		if target.Name ~= "ExpandFloor" or not target:IsDescendantOf(plot) then return end

		resetPrompt()
		selectingPlot = true

		ExpansionService:GetNextExpansionPrice():andThen(function(price)
			if price then
				AreYouSure.Price.Text = "$" .. tostring(price)
			else
				AreYouSure.Price.Text = "Unavailable"
			end
		end):catch(function(err)
			warn("Failed to fetch expansion price:", err)
		end)
        wait(.1)
        local Val = Instance.new("BoolValue", player.Character)
        Val.Name = "ClickedPlot"
        game.Debris:AddItem(Val, 1.5)
		AreYouSure.Visible = true
		repeat task.wait() until answer == "Yes" or answer == "No" or not equipped

		if answer ~= "Yes" or not equipped then
			resetPrompt()
			selectingPlot = false
			return
		end

		resetPrompt()
		selectingPlot = false
		ExpansionService:BuyExpansion(target.Parent.Name)

		local sound = game.ReplicatedStorage.Game.Shove:Clone()
		sound.Parent = player.Character.PrimaryPart
		sound:Play()
	end
end

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = player:GetMouse()
		handleTarget(mouse.Target)
	end
end)

UIS.TouchTapInWorld:Connect(function(position, processedByUI)
	if processedByUI then return end
	local ray = workspace:Raycast(camera.CFrame.Position, (camera:ViewportPointToRay(position.X, position.Y).Direction) * 1000)
	if ray and ray.Instance then
		handleTarget(ray.Instance)
	end
end)

local currentHighlight, currentTarget = nil, nil
RunService.RenderStepped:Connect(function()
	local mouse = player:GetMouse()
	local target = equipped and mouse.Target or nil
	local highlightTarget = nil

	if target then
		if target.Parent and target.Parent:IsA("Model") then
			local ownerAttr = target.Parent:GetAttribute("Owner")
			if ownerAttr == player.UserId then
				highlightTarget = target.Parent
			end
		end
		if not highlightTarget and target.Name == "ExpandFloor" then
			local plot = getMyPlot(player)
			if plot and target:IsDescendantOf(plot) then
				highlightTarget = target.Parent
			end
		end
	end

	if highlightTarget and highlightTarget ~= currentTarget then
		if currentHighlight then currentHighlight:Destroy() end
		currentTarget = highlightTarget
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.FillTransparency = 0.5
		highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineTransparency = 1
		highlight.Adornee = highlightTarget
		highlight.Parent = highlightTarget
		currentHighlight = highlight
	elseif not highlightTarget then
		if currentHighlight then
			currentHighlight:Destroy()
			currentHighlight = nil
			currentTarget = nil
		end
	end
end)
