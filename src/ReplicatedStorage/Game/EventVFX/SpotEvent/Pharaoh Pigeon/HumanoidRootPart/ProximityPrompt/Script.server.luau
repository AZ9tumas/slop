local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CustomTweenService = require(ReplicatedStorage.TweenV2.ReplicatedTweening)
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)



script.Parent.Triggered:Connect(function(Player)
	local plot = Knit.GetService("PlotService"):GetPlayerPlot(Player)
	if not plot then return nil end
	local pigeonsFolder = plot:FindFirstChild("Pigeons") or Instance.new("Folder", plot)
	pigeonsFolder.Name = "Pigeons"
	pigeonsFolder.Parent = plot
	local validPigeons = {}
	for _, child in ipairs(pigeonsFolder:GetChildren()) do
		if child:GetAttribute("PigeonID") ~= nil then
			table.insert(validPigeons, child)
		end
	end
    if #validPigeons <= 0 then ReplicatedStorage.Remotes.Notification:FireClient(Player, "You dont have any pigeons placed.", Color3.new(1, 0, 0)) return end
	script.Parent.Enabled = false
	local randomChild = validPigeons[math.random(1, #validPigeons)]
	Knit.GetService("PigeonService"):SetMutation(randomChild:GetAttribute("PigeonID"),"Spotted")
	local tweenInfo = TweenInfo.new(25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = CustomTweenService:GetTweenObject(script.Parent.Parent.Parent.HumanoidRootPart, tweenInfo, {CFrame = workspace.Map.Points.FlyPoint.CFrame})
	tween:Play()
	script.Parent.Parent.Parent.AnimationController:LoadAnimation(script.FlyAnim):Play()
	wait(25)
	script.Parent.Parent.Parent:Destroy()
end)