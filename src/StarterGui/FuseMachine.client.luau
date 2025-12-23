local Data

local FirstPlaced = false
local SecondPlaced = false

local MachineStarting = false

local function CheckP(FuseData)
    if FirstPlaced == false and FuseData.First ~= nil and game.ReplicatedStorage.Game.Pigeons:FindFirstChild(FuseData.First) then
        local Pigeon = game.ReplicatedStorage.Game.Pigeons:FindFirstChild(FuseData.First):Clone()
        Pigeon.Parent = workspace.FuseMachine
        if Pigeon and Pigeon:IsA("Model") then
            local pigeon = Pigeon
            local hrp = pigeon:WaitForChild("HumanoidRootPart")
            local holder = workspace.FuseMachine.Machine.Base.HolderFirst
            FirstPlaced = true
            holder.ProximityPrompt.Enabled = false
            
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { game.Players.LocalPlayer.Character }

            local ray = workspace:Raycast(holder.Position + Vector3.new(0,5,0), Vector3.new(0,-20,0), params)
            if ray then
                -- find lowest Y point of the whole rig
                local minY = math.huge
                for _, part in ipairs(pigeon:GetDescendants()) do
                    if part:IsA("BasePart") then
                        minY = math.min(minY, part.Position.Y - (part.Size.Y/2))
                    end
                end

                local bottomOffset = (hrp.Position.Y - minY)
                local bottomOffset2 = Pigeon:GetAttribute("GroundOffset") or 0

                pigeon:PivotTo(
                    CFrame.new(ray.Position + Vector3.new(0, bottomOffset, 0))
                        * CFrame.Angles(0, math.rad(90), 0)
                )


            end


        end
    end
    if SecondPlaced == false and FuseData.Second ~= nil and game.ReplicatedStorage.Game.Pigeons:FindFirstChild(FuseData.Second) then
        local Pigeon = game.ReplicatedStorage.Game.Pigeons:FindFirstChild(FuseData.Second):Clone()
        Pigeon.Parent = workspace.FuseMachine
        if Pigeon and Pigeon:IsA("Model") then
            local pigeon = Pigeon
            local hrp = pigeon:WaitForChild("HumanoidRootPart")
            local holder = workspace.FuseMachine.Machine.Base.HolderSecond
            
            holder.ProximityPrompt.Enabled = false
            SecondPlaced = true
            
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { game.Players.LocalPlayer.Character }

            local ray = workspace:Raycast(holder.Position + Vector3.new(0,5,0), Vector3.new(0,-20,0), params)
            if ray then
                -- find lowest Y point of the whole rig
                local minY = math.huge
                for _, part in ipairs(pigeon:GetDescendants()) do
                    if part:IsA("BasePart") then
                        minY = math.min(minY, part.Position.Y - (part.Size.Y/2))
                    end
                end

                local bottomOffset = (hrp.Position.Y - minY)
                local bottomOffset2 = Pigeon:GetAttribute("GroundOffset") or 0

                pigeon:PivotTo(
                    CFrame.new(ray.Position + Vector3.new(0, bottomOffset, 0))
                        * CFrame.Angles(0, math.rad(90), 0)
                )


            end


        end
    end
    if FuseData.Running == false then
        print("has stopped")
        game.Workspace.FuseMachine.Machine.Machine.Sign.Color = Color3.fromRGB(17, 17, 17)
        workspace.FuseMachine.Machine.Base.HolderFirst.ProximityPrompt.Enabled = true
        workspace.FuseMachine.Machine.Base.HolderSecond.ProximityPrompt.Enabled = true
        workspace.FuseMachine.Machine.Machine.Main.Fuse.Enabled = true
        FirstPlaced = false
        SecondPlaced = false
        MachineStarting = false
        local holder = workspace.FuseMachine.Machine.Base.HolderFirst
        for _, P in holder:GetChildren() do
            if P:IsA("ParticleEmitter") then
                P.Enabled = false
            end
        end
        local holder2 = workspace.FuseMachine.Machine.Base.HolderSecond
        for _, P in holder2:GetChildren() do
            if P:IsA("ParticleEmitter") then
                P.Enabled = false
            end
        end
        if workspace.FuseMachine.Machine.Machine.Main:FindFirstChild("Loop") then
            workspace.FuseMachine.Machine.Machine.Main.Loop:Destroy()
        end
        for _, Pigeons in game.Workspace.FuseMachine:GetChildren() do
            if Pigeons.Name ~= "Machine" and Pigeons:IsA("Model") and Pigeons:FindFirstChild("HumanoidRootPart") then
                Pigeons:Destroy()
            end
        end
    elseif FuseData.Running == true then
        MachineStarting = true
        game.Workspace.FuseMachine.Machine.Machine.Sign.Color = Color3.new(1, 0, 0)
        script.Start:Play()
        wait(.1)
        local Loop = script.Loop:Clone()
        Loop.Parent = workspace.FuseMachine.Machine.Machine.Main
        Loop:Play()
        workspace.FuseMachine.Machine.Machine.Main.Fuse.Enabled = false
        local holder = workspace.FuseMachine.Machine.Base.HolderFirst
        for _, P in holder:GetChildren() do
            if P:IsA("ParticleEmitter") then
                P.Enabled = true
            end
        end
        local holder2 = workspace.FuseMachine.Machine.Base.HolderSecond
        for _, P in holder2:GetChildren() do
            if P:IsA("ParticleEmitter") then
                P.Enabled = true
            end
        end
        for _, Pigeons in game.Workspace.FuseMachine:GetChildren() do
            if Pigeons.Name ~= "Machine" and Pigeons:IsA("Model") and Pigeons:FindFirstChild("HumanoidRootPart") then
                for _, Part in Pigeons:GetDescendants() do
                    if Part:IsA("BasePart") and Part.Transparency ~= 1 then
                        Part.Transparency = 0.4
                    end
                end
            end
        end
    end
end

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds)) -- safety clamp

    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60

    return string.format("%02d:%02d", minutes, secs)
end

game.ReplicatedStorage.Remotes.FuseMachine.OnClientEvent:Connect(function(FuseData)
    Data = FuseData
    print(Data)
    CheckP(Data)
end)

game.ReplicatedStorage.Remotes.FuseMachineUpdateNumber.OnClientEvent:Connect(function(Left)
    if Left == 0 then
        workspace.FuseMachine.Machine.Machine.Display.TimeLeft.Text = ""
    else
        workspace.FuseMachine.Machine.Machine.Display.TimeLeft.Text = "Time Left: " .. FormatTime(Left)
    end
end)


game.Workspace.FuseMachine.Machine.Base.HolderFirst.ProximityPrompt.Triggered:Connect(function(Plr)
    if Plr == game.Players.LocalPlayer and Plr.Character and Plr.Character:FindFirstChildWhichIsA("Tool") and Plr.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId") and Data.First == nil then
        script.Put:Play()
        game.ReplicatedStorage.Remotes.FuseMachinePutIn:FireServer(Plr.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId"), Plr.Character:FindFirstChildWhichIsA("Tool").Name, "First")
        Plr.Character:FindFirstChildWhichIsA("Tool"):Destroy()
        game.Players.LocalPlayer.PlayerGui.MobilePlacingUI.Enabled = false
    end
end)

game.Workspace.FuseMachine.Machine.Base.HolderSecond.ProximityPrompt.Triggered:Connect(function(Plr)
    if Plr == game.Players.LocalPlayer and Plr.Character and Plr.Character:FindFirstChildWhichIsA("Tool") and Plr.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId") and Data.Second == nil then
        script.Put:Play()
        game.ReplicatedStorage.Remotes.FuseMachinePutIn:FireServer(Plr.Character:FindFirstChildWhichIsA("Tool"):GetAttribute("PigeonId"), Plr.Character:FindFirstChildWhichIsA("Tool").Name, "Second")
        Plr.Character:FindFirstChildWhichIsA("Tool"):Destroy()
        game.Players.LocalPlayer.PlayerGui.MobilePlacingUI.Enabled = false
    end
end)

game.Workspace.FuseMachine.Machine.Machine.Main.Fuse.Triggered:Connect(function(plr)
    if plr ~= game.Players.LocalPlayer then return end
    game.ReplicatedStorage.Remotes.FuseMachineFusePrompt:FireServer()
    if plr == game.Players.LocalPlayer and FirstPlaced == true and SecondPlaced == true and MachineStarting == false and plr.leaderstats.Beaks.Value >= 15000 then
        MachineStarting = true
        game.Workspace.FuseMachine.Machine.Machine.Sign.Color = Color3.new(1, 0, 0)
        script.Start:Play()
        wait(.1)
        local Loop = script.Loop:Clone()
        Loop.Parent = workspace.FuseMachine.Machine.Machine.Main
        Loop:Play()
        workspace.FuseMachine.Machine.Machine.Main.Fuse.Enabled = false
        local holder = workspace.FuseMachine.Machine.Base.HolderFirst
        for _, P in holder:GetChildren() do
            if P:IsA("ParticleEmitter") then
                P.Enabled = true
            end
        end
        local holder2 = workspace.FuseMachine.Machine.Base.HolderSecond
        for _, P in holder2:GetChildren() do
            if P:IsA("ParticleEmitter") then
                P.Enabled = true
            end
        end
        for _, Pigeons in game.Workspace.FuseMachine:GetChildren() do
            if Pigeons.Name ~= "Machine" and Pigeons:IsA("Model") and Pigeons:FindFirstChild("HumanoidRootPart") then
                for _, Part in Pigeons:GetDescendants() do
                    if Part:IsA("BasePart") and Part.Transparency ~= 1 then
                        Part.Transparency = 0.4
                    end
                end
            end
        end
    end
end)

