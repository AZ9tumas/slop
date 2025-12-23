game.ReplicatedStorage.Remotes.NewPigeon.OnClientEvent:Connect(function(PigeonName)
    local model = game.ReplicatedStorage.Game.Pigeons:FindFirstChild(PigeonName)
    local Temp = script.NewPet:Clone()
    Temp.Parent = script.Parent
    local ts = game.TweenService

    local originalSize = Temp.Size
    local originalPos = Temp.Position

    -- start slightly smaller & lower
    Temp.Size = UDim2.new(
        originalSize.X.Scale * 0.9, originalSize.X.Offset,
        originalSize.Y.Scale * 0.9, originalSize.Y.Offset
    )
    Temp.Position = originalPos + UDim2.fromScale(0, 0.03)

    -- pop in
    ts:Create(
        Temp,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = originalSize,
            Position = originalPos,
        }
    ):Play()

    local viewport = Temp.Viewport.ViewportFrame
    local modelClone = model:Clone()
    modelClone.Parent = viewport
    if not modelClone.PrimaryPart then
        local primary = modelClone:FindFirstChildWhichIsA("BasePart")
        if primary then modelClone.PrimaryPart = primary end
    end
    
    game.TweenService:Create(Temp.Viewport.ImageLabel, TweenInfo.new(5, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
    task.delay(4.6, function()


        -- pop in
        ts:Create(
            Temp,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(
                    originalSize.X.Scale * 0.1, originalSize.X.Offset,
                    originalSize.Y.Scale * 0.1, originalSize.Y.Offset
                ),
                Position = originalPos,
            }
        ):Play()
    end)
    game.Debris:AddItem(Temp, 5)
    script.Sound:Play()
    if modelClone.PrimaryPart then
        local offset = modelClone.PrimaryPart.Position
        for _, part in ipairs(modelClone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Position = part.Position - offset
            end
        end
    end
    
    if modelClone.PrimaryPart then
        modelClone:SetPrimaryPartCFrame(
            CFrame.Angles(0, math.rad(140), 0)
        )
    end


    local cam = Instance.new("Camera")
    cam.Parent = viewport
    viewport.CurrentCamera = cam
    local cf, size = modelClone:GetBoundingBox()
    local centerY = size.Y / 2
    local maxDim = math.max(size.X, size.Y, size.Z)
    local padding = 1.2
    local dist = maxDim * padding

    cam.CFrame = CFrame.new(Vector3.new(0, centerY - 1, dist - 0.38), Vector3.new(0, centerY, 0)) * CFrame.new(0, 0, -1)
end)