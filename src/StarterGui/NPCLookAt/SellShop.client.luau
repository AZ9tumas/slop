local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LookBackOnNil = true
local PartToLookAt = "Head"
local HeadHorFactor = 0.8
local HeadVertFactor = 0.5
local BodyHorFactor = 0.4
local BodyVertFactor = 0.4
local UpdateSpeed = 0.6
local UpdateDelay = 0.05

local Ang = CFrame.Angles
local aTan = math.atan

local Body = game.Workspace.SellShop
local Head = Body:WaitForChild("Head")
local Hum = Body:WaitForChild("Humanoid")
local Core = Body:WaitForChild("HumanoidRootPart")
local IsR6 = (Hum.RigType.Value == 0)
local Trso = (IsR6 and Body:WaitForChild("Torso"))
local Neck = (IsR6 and Trso:WaitForChild("Neck")) or Head:WaitForChild("Neck")	
local Waist = (not IsR6 and Trso:WaitForChild("Waist"))

local NeckOrgnC0 = Neck.C0
local WaistOrgnC0 = (not IsR6 and Waist.C0)

local LookingAtValue = Instance.new("ObjectValue")
LookingAtValue.Parent = Body
LookingAtValue.Name = "LookingAt"

local function GetValidPartToLookAt(Char, bodypart)
	if not Char then return nil end
	local pHum = Char:FindFirstChild("Humanoid")
	if not pHum then return nil end
	if bodypart == "Torso" or bodypart == "UpperTorso" then
		bodypart = (pHum.RigType.Value == 0 and "Torso")
	end
	return Char:FindFirstChild(bodypart) or Char:FindFirstChild("HumanoidRootPart")
end

local function LookAt(NeckC0, WaistC0)
	if Neck then Neck.C0 = Neck.C0:Lerp(NeckC0, UpdateSpeed/2) end
	if Waist then Waist.C0 = Waist.C0:Lerp(WaistC0, UpdateSpeed/2) end
end

local lastUpdate = 0
RunService.Heartbeat:Connect(function(dt)
	lastUpdate += dt
	if lastUpdate < UpdateDelay then return end
	lastUpdate = 0

	local TrsoLV = Trso.CFrame.LookVector
	local HdPos = Head.CFrame.p
	local playerChar = Players.LocalPlayer.Character
	if not playerChar then
		if LookBackOnNil then
			LookAt(NeckOrgnC0, WaistOrgnC0)
		end
		return
	end

	local LookAtPart = GetValidPartToLookAt(playerChar, PartToLookAt)
	if LookAtPart then
		local is_in_front = Core.CFrame:ToObjectSpace(LookAtPart.CFrame).Z < 0
		if is_in_front then
			if LookingAtValue.Value ~= playerChar then
				LookingAtValue.Value = playerChar
			end

			local Diff = Head.CFrame.Y - LookAtPart.CFrame.Y
			local Dist = (HdPos - LookAtPart.CFrame.p).Magnitude

			if not IsR6 then
				LookAt(
					NeckOrgnC0 * Ang(-(aTan(Diff/Dist)*HeadVertFactor), (((HdPos-LookAtPart.CFrame.p).Unit):Cross(TrsoLV)).Y*HeadHorFactor, 0),
					WaistOrgnC0 * Ang(-(aTan(Diff/Dist)*BodyVertFactor), (((HdPos-LookAtPart.CFrame.p).Unit):Cross(TrsoLV)).Y*BodyHorFactor, 0)
				)
			else
				LookAt(
					NeckOrgnC0 * Ang((aTan(Diff/Dist)*HeadVertFactor), 0, (((HdPos-LookAtPart.CFrame.p).Unit):Cross(TrsoLV)).Y*HeadHorFactor)
				)
			end
		elseif LookBackOnNil then
			LookAt(NeckOrgnC0, WaistOrgnC0)
			LookingAtValue.Value = nil
		end
	elseif LookBackOnNil then
		LookAt(NeckOrgnC0, WaistOrgnC0)
		LookingAtValue.Value = nil
	end
end)
