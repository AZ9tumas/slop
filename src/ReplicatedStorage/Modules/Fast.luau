local TweenService = game:GetService("TweenService")

return function (Instance: Instance, TweenInfo: TweenInfo, Properties: { [string]: any })
    local Tween = TweenService:Create(Instance, TweenInfo, Properties)

    Tween:Play()

    return Tween
end