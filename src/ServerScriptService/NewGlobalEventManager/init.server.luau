local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local MessagingService = game:GetService("MessagingService")
local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local CustomTweenService = require(ReplicatedStorage.TweenV2.ReplicatedTweening)

local RunningEventsFolder = ReplicatedStorage:WaitForChild("RunningEvents")

local volcanoLabel = Workspace.Map.Unsorted.EventTimer.Root.SurfaceGui.Holder.Volcano.Timer
local thunderLabel = Workspace.Map.Unsorted.EventTimer.Root.SurfaceGui.Holder.Thunderstorm.Timer

local shakeTemplate = script:WaitForChild("Shake")
local thunderTemplatePath = ReplicatedStorage.Game.EventVFX:WaitForChild("Thunder")
local thundericTemplatePath = ReplicatedStorage.Game.EventVFX:WaitForChild("ThundericStrike")
local thundericcharTemplatePath = ReplicatedStorage.Game.EventVFX:WaitForChild("ThundericCharacter")


local rainGroundTemplate = ReplicatedStorage.Game.EventVFX:WaitForChild("RainGround")
local rainGroundthunericTemplate = ReplicatedStorage.Game.EventVFX:WaitForChild("RainGroundThunderic")

local BeakRainTemplate = ReplicatedStorage.Game.EventVFX:WaitForChild("BeakRain")

local rainTopTemplate = ReplicatedStorage.Game.EventVFX:WaitForChild("RainTop")
local rainTopthunericTemplate = ReplicatedStorage.Game.EventVFX:WaitForChild("RainTopThunderic")

local HTTP = game:GetService("HttpService")

local webhook = "https://webhook.lewisakura.moe/api/webhooks/1426535606032269332/0IQ7eRmPyM6-DSk8QF25qRONN3IUVwQDNzMOcAI_6d0ULRpwiA3kGplvgEy2bqzTVnug"

local volcanoTemplatePath = ReplicatedStorage.Game.EventVFX:WaitForChild("Volcano")

local VOLCANO_INTERVAL = require(game.ReplicatedStorage.Info.EventTimer).Volcano
local THUNDER_INTERVAL =  require(game.ReplicatedStorage.Info.EventTimer).Thunder
local EVENT_DURATION = 90

local function spawnSpotEvent(duration)
    local MainGame = ReplicatedStorage.Game.EventVFX.SpotEvent:Clone()
    MainGame.Parent = Workspace
    ReplicatedStorage.Remotes.Notification:FireAllClients("Pigeons have spawned around the map, Find them to get spot mutation!")
    wait(duration)
    MainGame:Destroy()
end

local function spawn4xLuck(duration)
    local OldX = game.Workspace:GetAttribute("ServerLuck")
    local MainGame = ReplicatedStorage.Game.EventVFX.Rainbow:Clone()
    MainGame.Parent = Workspace
    ReplicatedStorage.Remotes.Notification:FireAllClients("4x Luck has been activated!")
    game.Workspace:SetAttribute("ServerLuck", 4)
    wait(duration)
    game.Workspace:SetAttribute("ServerLuck", OldX)
    MainGame:Destroy()
end

local function spawnEarthquakeEvent(duration)
    ReplicatedStorage.Remotes.Notification:FireAllClients("The ground is shaking..")
    local Rocks = ReplicatedStorage.Game.EventVFX.Earthquake:Clone()
    Rocks.Parent = Workspace
    for i = 1, 30 do
        local clone = thunderTemplatePath:Clone()
        clone.Parent = Workspace
        clone.End:Destroy()

        local x = math.random(-160, 160)
        local z = math.random(-190, 190)
        local y = 104
        clone.Position = Vector3.new(x, y, -509.588 + z)
        game.Debris:AddItem(clone, 4)
        local hitRadius = 14.5
        local pigeons = {}
        for _, obj in pairs(Workspace.Map.Plots:GetDescendants()) do
            if obj.Parent and obj.Parent.Name:lower():find("pigeon") and not pigeons[obj.Parent] and obj:IsA("BasePart") then
                local id = obj.Parent:GetAttribute("PigeonID")
                pigeons[obj.Parent] = true
                local distance = (obj.Position - clone.Position).Magnitude
                if distance <= hitRadius and id then
                    Knit.GetService("PigeonService"):SetMutation(id,"Cracked")
                end
            end
        end

        for _, Player in game.Players:GetPlayers() do
            if Player.Character then
                local shake = script.Earthquake2:Clone()
                shake.Parent = Player.Character
                shake.Enabled = true
                game.Debris:AddItem(shake, 10)
            end
        end
        wait(2)
    end
    for _, VFX in Rocks:GetChildren() do
        VFX.Enabled = false
    end
    game.Debris:AddItem(Rocks, 5)
end



local function spawnBlackholeEvent(duration)
    for _, Player in game.Players:GetPlayers() do
        if Player.Character then
            local shake = script.ThundericSnap:Clone()
            shake.Parent = Player.Character
            shake.Enabled = true
            game.Debris:AddItem(shake, 10)
        end
    end
    wait(.2)
    game.Workspace.Gravity = 5
    game.Lighting.ClockTime = 3
    local Blackhole = ReplicatedStorage.Game.EventVFX.Blackholes:Clone()
    Blackhole.Parent = Workspace
    game.SoundService.BlackholeSpawn:Play()
    task.delay(0.4, function()
        game.SoundService.BlackholeIdle:Play()
    end)
    local active = true
    task.spawn(function()
        task.wait(duration)
        active = false
        game.Lighting.ClockTime = 14
        game.Workspace.Gravity = 196.2
        Blackhole:Destroy()
    end)
    while active do
        local clone = thunderTemplatePath:Clone()
        clone.Parent = Workspace
        clone.End:Destroy()

        local x = math.random(-160, 160)
        local z = math.random(-190, 190)
        local y = 104
        clone.Position = Vector3.new(x, y, -509.588 + z)
        game.Debris:AddItem(clone, 4)
        local hitRadius = 9
        local pigeons = {}
        for _, obj in pairs(Workspace.Map.Plots:GetDescendants()) do
            if obj.Parent and obj.Parent.Name:lower():find("pigeon") and not pigeons[obj.Parent] and obj:IsA("BasePart") then
                local id = obj.Parent:GetAttribute("PigeonID")
                pigeons[obj.Parent] = true
                local distance = (obj.Position - clone.Position).Magnitude
                if distance <= hitRadius and id then
                    Knit.GetService("PigeonService"):SetMutation(id,"Blackhole")
                end
            end
        end
        task.wait(4)
    end
end

local function SpawnThunderic(duration)
    local RainGround = rainGroundthunericTemplate:Clone()
    RainGround.Parent = Workspace
    local RainTop = rainTopthunericTemplate:Clone()
    RainTop.Parent = Workspace
    local Theme2 = script.ThundericTheme2:Clone()
    Theme2.Parent = Workspace
    Theme2:Play()
    local char = thundericcharTemplatePath:Clone()
    char.Parent = Workspace
    TweenService:Create(game.Workspace.Terrain.Clouds, TweenInfo.new(8), {Cover = 0.75}):Play()
    TweenService:Create(game.Lighting, TweenInfo.new(8), {ClockTime = 3}):Play()
    for _, player in game.Players:GetChildren() do
        if player:IsA("Player") then
            local Cam = script.ThundericCutsceneStart:Clone()
            Cam.Parent = player.PlayerGui
            Cam.Enabled = true
            game.Debris:AddItem(Cam, 10)
        end
    end
    local Animation = char.Humanoid:LoadAnimation(script.ThundericAnimation)
    Animation:Play()
    local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = CustomTweenService:GetTweenObject(char.HumanoidRootPart, tweenInfo, {CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 85, 0)})
    tween:Play()
    TweenService:Create(Theme2, TweenInfo.new(10), {Volume = 0.3}):Play()
    wait(10.6)
    for _, player in game.Players:GetChildren() do
        if player:IsA("Player") then
            local snap = script.ThundericSnap:Clone()
            snap.Parent = player.PlayerGui
            snap.Enabled = true
            game.Debris:AddItem(snap, 10)
        end
    end
    wait(1.2)
    for _, player in game.Players:GetChildren() do
        if player:IsA("Player") then
            local Cam = script.ThundericCutsceneEnd:Clone()
            Cam.Parent = player.PlayerGui
            Cam.Enabled = true
            game.Debris:AddItem(Cam, 5)
        end
    end
    local Theme = script.ThundericTheme:Clone()
    Theme.Parent = Workspace
    Theme:Play()
    TweenService:Create(Theme, TweenInfo.new(2), {Volume = 0.75}):Play()
    TweenService:Create(Theme2, TweenInfo.new(2), {Volume = 0.75}):Play()
    wait(.1)
    local active = true
    task.spawn(function()
        task.wait(duration)
        active = false
        RainGround:Destroy()
        RainTop:Destroy()
    end)
    task.spawn(function()
        while active do

            local clone = thunderTemplatePath:Clone()
            clone.Parent = Workspace
            if clone:FindFirstChild("Sound") then
                clone.Sound:Play()
            end
            local x = math.random(-155, 155)
            local z = math.random(-180, 180)
            local y = 104
            clone.Position = Vector3.new(x, y, -509.588 + z)
            for _,v in pairs(clone:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = true
                    v:Emit(v:GetAttribute("EmitCount") or 5)
                end
                if v:IsA("Beam") then
                    v.Enabled = true
                end
            end
            task.delay(0.5,function()
                for _,v in pairs(clone:GetDescendants()) do
                    if v:IsA("Beam") or v:IsA("ParticleEmitter") then
                        v.Enabled = false
                    end
                end
            end)
            game.Debris:AddItem(clone, 4)
            local hitRadius = 10
            local pigeons = {}
            for _, obj in pairs(Workspace.Map.Plots:GetDescendants()) do
                if obj.Parent and obj.Parent.Name:lower():find("pigeon") and not pigeons[obj.Parent] and obj:IsA("BasePart") then
                    local id = obj.Parent:GetAttribute("PigeonID")
                    pigeons[obj.Parent] = true
                    local distance = (obj.Position - clone.Position).Magnitude
                    if distance <= hitRadius and id then
                        Knit.GetService("PigeonService"):SetMutation(id,"Thunderic")
                    end
                end
            end
            task.wait(2)
        end
    end)
    while active do

        local clone = thundericTemplatePath:Clone()
        clone.Parent = Workspace
        if clone:FindFirstChild("Sound") then
            clone.Sound:Play()
        end
        local x = math.random(-160, 160)
        local z = math.random(-190, 190)
        local y = 104
        clone.Position = Vector3.new(x, y, -509.588 + z)
        for _,v in pairs(clone:GetDescendants()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = true
                v:Emit(v:GetAttribute("EmitCount") or 5)
            end
            if v:IsA("Beam") then
                v.Enabled = true
            end
        end
        task.delay(0.5,function()
            for _,v in pairs(clone:GetDescendants()) do
                if v:IsA("Beam") or v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
            end
        end)
        game.Debris:AddItem(clone, 4)
        local hitRadius = 9
        local pigeons = {}
        for _, obj in pairs(Workspace.Map.Plots:GetDescendants()) do
            if obj.Parent and obj.Parent.Name:lower():find("pigeon") and not pigeons[obj.Parent] and obj:IsA("BasePart") then
                local id = obj.Parent:GetAttribute("PigeonID")
                pigeons[obj.Parent] = true
                local distance = (obj.Position - clone.Position).Magnitude
                if distance <= hitRadius and id then
                    Knit.GetService("PigeonService"):SetMutation(id,"Thunderic")
                end
            end
        end
        task.wait(1.9)
    end
    char:Destroy()
    TweenService:Create(game.Workspace.Terrain.Clouds, TweenInfo.new(1), {Cover = 0}):Play()
    TweenService:Create(game.Lighting, TweenInfo.new(1), {ClockTime = 14.6}):Play()

    TweenService:Create(Theme, TweenInfo.new(1), {Volume = 0}):Play()
    TweenService:Create(Theme2, TweenInfo.new(1), {Volume = 0}):Play()
    game.Debris:AddItem(Theme2, 1)
    game.Debris:AddItem(Theme, 1)
end

local function spawnBeakRain(duration)
    for _, Player in game.Players:GetPlayers() do
        if Player.Character then
            local shake = shakeTemplate:Clone()
            shake.Parent = Player.Character
            shake.Enabled = true
            game.Debris:AddItem(shake, 10)
        end
    end
    local BeakRain = BeakRainTemplate:Clone()
    BeakRain.Parent = Workspace
    local active = true
    task.spawn(function()
        task.wait(duration)
        active = false
        BeakRain:Destroy()
    end)
    task.spawn(function()
    while active do
        for _, Player in game.Players:GetChildren() do
            if Player:IsA("Player") and Player:FindFirstChild("leaderstats") then
                local DataService = Knit.GetService("DataService")
                local profile = DataService:GetProfile(Player)
                if profile then
                    local RandomAmount = math.random(25000, 55000)
                    profile.Data.Beaks += RandomAmount
                    Player.leaderstats.Beaks.Value = profile.Data.Beaks
                    game.ReplicatedStorage.Remotes.Notification:FireClient(Player, "You got " .. RandomAmount .. "$ Beaks from the beak rain!", Color3.new(1, 1, 0.0588235))
                end
            end
        end
        wait(15)
    end
    end)
    task.spawn(function()
    while active do
        local clone = thunderTemplatePath:Clone()
        clone.Parent = Workspace
        clone.End:Destroy()

        local x = math.random(-160, 160)
        local z = math.random(-190, 190)
        local y = 104
        clone.Position = Vector3.new(x, y, -509.588 + z)
        game.Debris:AddItem(clone, 4)
        local hitRadius = 15
        local pigeons = {}
        for _, obj in pairs(Workspace.Map.Plots:GetDescendants()) do
            if obj.Parent and obj.Parent.Name:lower():find("pigeon") and not pigeons[obj.Parent] and obj:IsA("BasePart") then
                local id = obj.Parent:GetAttribute("PigeonID")
                pigeons[obj.Parent] = true
                local distance = (obj.Position - clone.Position).Magnitude
                if distance <= hitRadius and id then
                    Knit.GetService("PigeonService"):SetMutation(id,"Wealth")
                end
            end
        end
        task.wait(5)
    end
    end)
end

local function spawnThunder(duration)
    for _, Player in game.Players:GetPlayers() do
        if Player.Character then
            local shake = shakeTemplate:Clone()
            shake.Parent = Player.Character
            shake.Enabled = true
            game.Debris:AddItem(shake, 10)
        end
    end
    local startsound = script.ThunderActivate:Clone()
    startsound.Parent = Workspace
    startsound:Play()
    game.Debris:AddItem(startsound, 4)
    local RainGround = rainGroundTemplate:Clone()
    RainGround.Parent = Workspace
    local RainTop = rainTopTemplate:Clone()
    RainTop.Parent = Workspace
    local active = true
    task.spawn(function()
        task.wait(duration)
        active = false
        RainGround:Destroy()
        RainTop:Destroy()
    end)
    while active do
        local clone = thunderTemplatePath:Clone()
        clone.Parent = Workspace
        if clone:FindFirstChild("Sound") then
            clone.Sound:Play()
        end
        local x = math.random(-160, 160)
        local z = math.random(-190, 190)
        local y = 104
        clone.Position = Vector3.new(x, y, -509.588 + z)
        for _,v in pairs(clone:GetDescendants()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = true
                v:Emit(v:GetAttribute("EmitCount") or 10)
            end
            if v:IsA("Beam") then
                v.Enabled = true
            end
        end
        task.delay(1,function()
            for _,v in pairs(clone:GetDescendants()) do
                if v:IsA("Beam") or v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
            end
        end)
        game.Debris:AddItem(clone, 4)
        local hitRadius = 17
        local pigeons = {}
        for _, obj in pairs(Workspace.Map.Plots:GetDescendants()) do
            if obj.Parent and obj.Parent.Name:lower():find("pigeon") and not pigeons[obj.Parent] and obj:IsA("BasePart") then
                local id = obj.Parent:GetAttribute("PigeonID")
                pigeons[obj.Parent] = true
                local distance = (obj.Position - clone.Position).Magnitude
                if distance <= hitRadius and id then
                    Knit.GetService("PigeonService"):SetMutation(id,"Shocked")
                end
            end
        end
        task.wait(7)
    end
end


local function spawnVolcano(duration)
    for _, Player in game.Players:GetPlayers() do
        if Player.Character then
            local shake = shakeTemplate:Clone()
            shake.Parent = Player.Character
            shake.Enabled = true
            game.Debris:AddItem(shake, 10)
        end
    end
    local Volcano = volcanoTemplatePath:Clone()
    Volcano.Parent = workspace.Map.Unsorted
    local eruptionPoint = Volcano:WaitForChild("EruptionPoint")
    if eruptionPoint:FindFirstChild("Sound") then
        eruptionPoint.Sound:Play()
    end
    local active = true
    task.spawn(function()
        task.wait(duration)
        active = false
    end)
    while active do
        local rock = Instance.new("Part")
        rock.Shape = Enum.PartType.Block
        rock.Color = Color3.fromRGB(255, 204, 0)
        rock.Material = Enum.Material.Neon
        rock.Size = Vector3.new(3,3,3)
        rock.Anchored = false
        rock.CanCollide = true
        rock.Position = eruptionPoint.Position
        rock.Parent = Workspace
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(
            math.random(40,250),
            math.random(80,120),
            math.random(-60,60)
        )
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.Parent = rock
        game.Debris:AddItem(bodyVelocity, 0.5)
        local touchedConnection
        touchedConnection = rock.Touched:Connect(function(hit)
            pcall(function()
                if not hit or not hit.Parent then return end
                if hit.Parent:IsDescendantOf(workspace.Map) and not hit.Parent:IsDescendantOf(workspace.Map.Unsorted.Volcano) then
                    if touchedConnection then
                        touchedConnection:Disconnect()
                    end
                    local finalPos = rock.Position
                    local hitRadius = 16
                    local pigeons = {}
                    for _, obj in pairs(Workspace.Map.Plots:GetDescendants()) do
                        if obj.Parent and obj.Parent.Name:lower():find("pigeon") and not pigeons[obj.Parent] and obj:IsA("BasePart") then
                            local id = obj.Parent:GetAttribute("PigeonID")
                            if id then
                                local distance = (obj.Position - finalPos).Magnitude
                                if distance <= hitRadius then
                                    Knit.GetService("PigeonService"):SetMutation(id,"Volcanic")

                                end
                            end
                            pigeons[obj.Parent] = true
                        end
                    end
                    local tween = TweenService:Create(rock, TweenInfo.new(4), {Size = Vector3.new(0,0,0)})
                    tween:Play()
                    tween.Completed:Connect(function()
                        game.Debris:AddItem(rock, 0)
                    end)
                end
            end)
        end)
        game.Debris:AddItem(rock, 20)
        task.wait(1.6)
    end
    Volcano:Destroy()
end

local function startEvent(eventName)
	--[[if eventName ~= "AllEvents" then
	    game.ReplicatedStorage.Remotes.Notification:FireAllClients(eventName.." EVENT STARTED")
	end]]
    if eventName == "Volcano" then
        if RunningEventsFolder.Volcano.Value == true then return end
        RunningEventsFolder.Volcano.Value = true
        if game.Lighting:FindFirstChild("VolcanoEvent") then
            game.Lighting.VolcanoEvent.Enabled = true
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local tween = CustomTweenService:GetTweenObject(game.Lighting.VolcanoEvent, tweenInfo, {Brightness = 0.3, Contrast = 1, Saturation = 0.5, TintColor = Color3.fromRGB(156,55,55)})
            tween:Play()
        end
        spawnVolcano(EVENT_DURATION)
        RunningEventsFolder.Volcano.Value = false
        if game.Lighting:FindFirstChild("VolcanoEvent") then
            game.Lighting.VolcanoEvent.Enabled = false
        end
    elseif eventName == "Lightning" then
        if RunningEventsFolder.Lightning.Value == true then return end
        RunningEventsFolder.Lightning.Value = true
        if game.Lighting:FindFirstChild("ThunderEvent") then
            game.Lighting.ThunderEvent.Enabled = true
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local tween = CustomTweenService:GetTweenObject(game.Lighting.ThunderEvent, tweenInfo, {Brightness = 0.6, Contrast = 1, Saturation = 0.6, TintColor = Color3.fromRGB(61,61,74)})
            tween:Play()
        end
        spawnThunder(EVENT_DURATION)
        RunningEventsFolder.Lightning.Value = false
        if game.Lighting:FindFirstChild("ThunderEvent") then
            game.Lighting.ThunderEvent.Enabled = false
        end
    elseif eventName == "Beak Rain" then
        if RunningEventsFolder["Beak Rain"].Value == true then return end
        RunningEventsFolder["Beak Rain"].Value = true
        spawnBeakRain(EVENT_DURATION)
        RunningEventsFolder["Beak Rain"].Value = false
    elseif eventName == "Blackhole" then
        if RunningEventsFolder["Blackhole"].Value == true then return end
        RunningEventsFolder["Blackhole"].Value = true
        spawnBlackholeEvent(EVENT_DURATION)
        RunningEventsFolder["Blackhole"].Value = false
    elseif eventName == "Earthquake" then
        if RunningEventsFolder["Earthquake"].Value == true then return end
        RunningEventsFolder["Earthquake"].Value = true
        spawnEarthquakeEvent(EVENT_DURATION)
        RunningEventsFolder["Earthquake"].Value = false
    elseif eventName == "Spot" then
        if RunningEventsFolder["Spot"].Value == true then return end
        RunningEventsFolder["Spot"].Value = true
        spawnSpotEvent(EVENT_DURATION)
        RunningEventsFolder["Spot"].Value = false
    elseif eventName == "Luck4x" then
        if RunningEventsFolder["Luck4x"].Value == true then return end
        RunningEventsFolder["Luck4x"].Value = true
        spawn4xLuck(70)
        RunningEventsFolder["Luck4x"].Value = false
    elseif eventName == "Thunderic" then
        if RunningEventsFolder.Thunderic.Value == true then return end
        RunningEventsFolder.Thunderic.Value = true
        if game.Lighting:FindFirstChild("ThunderEvent") then
            game.Lighting.ThunderEvent.Enabled = true
        end
        SpawnThunderic(35)
        RunningEventsFolder.Thunderic.Value = false
        game.Lighting.ThunderEvent.Enabled = false
    elseif eventName == "AllEvents" then
        task.spawn(function()
            startEvent("Beak Rain")
        end)
        task.spawn(function()
            startEvent("Blackhole")
        end)
        task.spawn(function()
            startEvent("Earthquake")
        end)
        task.spawn(function()
            startEvent("Spot")
        end)
        task.spawn(function()
            startEvent("Luck4x")
        end)
        task.spawn(function()
            if game.Lighting:FindFirstChild("VolcanoEvent") then
                game.Lighting.VolcanoEvent.Enabled = true
                local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = CustomTweenService:GetTweenObject(game.Lighting.VolcanoEvent, tweenInfo, {Brightness = 0.3, Contrast = 1, Saturation = 0.5, TintColor = Color3.fromRGB(156,55,55)})
                tween:Play()
            end
            startEvent("Volcano")
            if game.Lighting:FindFirstChild("VolcanoEvent") then
                game.Lighting.VolcanoEvent.Enabled = false
            end
        end)
        task.spawn(function()
            if game.Lighting:FindFirstChild("ThunderEvent") then
                game.Lighting.ThunderEvent.Enabled = true
                local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = CustomTweenService:GetTweenObject(game.Lighting.ThunderEvent, tweenInfo, {Brightness = 0.6, Contrast = 1, Saturation = 0.6, TintColor = Color3.fromRGB(61,61,74)})
                tween:Play()
            end
            startEvent("Lightning")
            if game.Lighting:FindFirstChild("ThunderEvent") then
                game.Lighting.ThunderEvent.Enabled = false
            end
        end)
    end
end

-- MessagingService subscription for global triggers
MessagingService:SubscribeAsync("GlobalEventTrigger", function(message)
    if message.Data then
        startEvent(message.Data)
    end
end)


-- Admin global command
_G.Event = function(eventName)
    if eventName == "Volcano" or eventName == "Lightning" or eventName == "Beak Rain" or eventName == "Thunderic" or eventName == "Blackhole" or eventName == "Spot" or eventName == "Luck4x" or eventName == "Earthquake" then
        startEvent(eventName)
        MessagingService:PublishAsync("GlobalEventTrigger", eventName)
    end
end


local Oldevents = {--IGNORE!
    { Event = "Earthquake", Chance = 40, EveryMins = 6 },
    { Event = "Volcano",    Chance = 59, EveryMins = 12 },
    { Event = "Lightning",  Chance = 60, EveryMins = 17 },
    { Event = "Blackhole",  Chance = 70, EveryMins = 25 },
}

local events = {
    { Event = "Earthquake", Chance = 35, EveryMins = 7 },
    { Event = "Volcano",    Chance = 55, EveryMins = 12 },
    { Event = "Lightning",  Chance = 40, EveryMins = 9 },
    { Event = "Blackhole",  Chance = 25, EveryMins = 15 },
}

local function rollChance(percent)
    return math.random(1, 100) <= percent
end

-- track which events have already triggered this minute
local triggeredThisMinute = {}

task.spawn(function()
    while true do
        local t = os.date("*t")
        local key = t.hour .. "-" .. t.min -- unique per minute

        if triggeredThisMinute[key] == nil then
            for _, data in ipairs(events) do
                if t.min % data.EveryMins == 0 then
                    if rollChance(data.Chance) then
                        startEvent(data.Event)
                    end
                end
            end
            triggeredThisMinute[key] = true
        end

        -- clean old keys to avoid memory buildup
        for k in pairs(triggeredThisMinute) do
            if tonumber(k:match("%-(%d+)$")) ~= t.min then
                triggeredThisMinute[k] = nil
            end
        end

        task.wait(1)
    end
end)
