Tool = script.Parent
ToolParent = nil
faceTexture = ""
function OnEquipped()
	
	Spawn(function()
		Handle = Tool.Handle
		Cape = Handle:Clone()
		Cape.Name = 'Cape'
		local weld = Instance.new('Weld')
		weld.Part0 = Torso
		weld.Part1 = Cape
		weld.C0 = CFrame.new(0, -0.15, 0.4)
		weld.Parent = Cape
		Cape.Parent = Character
	end)
	
	ToolParent = Tool.Parent
	for i = 1,10 do
		for a,b in pairs(ToolParent:GetChildren()) do
			if b:IsA("BasePart") and b.Name ~= "HumanoidRootPart" then
				b.Transparency = i/10
			elseif b:FindFirstChild("Handle") then
				b:FindFirstChild("Handle").Transparency = i/10
			end
		end
		wait(.01)
	end
	faceTexture = ToolParent.Head.face.Texture
	ToolParent.Head.face.Texture = ""
end
function OnUnequipped()
	for i = 1,10 do
		for c,d in pairs(ToolParent:GetChildren()) do
			print(d.Name)
			if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
				d.Transparency = 1-i/10
			elseif d:FindFirstChild("Handle") then
				d:FindFirstChild("Handle").Transparency = 1-i/10
			end
		end
		wait(.01)
	end
	ToolParent.Head.face.Texture = faceTexture
end
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)