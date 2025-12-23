-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--modules
local DialogModule = require(ReplicatedStorage.DialogModule)

--references
local player = game.Players.LocalPlayer
local npc = script.Parent -- Reference to the NPC model
local npcGui = npc:WaitForChild("Head"):WaitForChild("gui")
local prompt = npc:WaitForChild("ProximityPrompt")

local dialogObject = DialogModule.new("Showcase NPC", npc, prompt)
dialogObject:addDialog("How may I assist you?", {"I want to trade this.","Show me your items.", "Nevermind."})


local pigeonInfo = require(game.ReplicatedStorage.Info.PigeonInfo)
local eggInfo = require(game.ReplicatedStorage.Info.EggInfo)
local toolInfo = require(game.ReplicatedStorage.Info.ToolInfo)
local MutationInfo = require(game.ReplicatedStorage.Info.MutationsInfo)
local CameraEffect = require(game.ReplicatedStorage.Modules.Camera)
local ParticleBorder = require(ReplicatedStorage:WaitForChild("ParticleBorder"))

--
local function GetBeaksPerSecond(pigeonWeight, pigeonInfo)
    if not pigeonInfo or not pigeonInfo.Weight then
        return 1
    end

    -- Clamp weight within its defined range
    local weight = math.clamp(pigeonWeight, pigeonInfo.Weight.Min, pigeonInfo.Weight.Max)

    local weightRange = pigeonInfo.Weight.Max - pigeonInfo.Weight.Min
    local normalisedWeight = (weight - pigeonInfo.Weight.Min) / (weightRange > 0 and weightRange or 1)

    -- Formula: base * multiplier * (1 + normalisedWeight)
    local beaksPerSecond = 0.79 * (pigeonInfo.Multiplier or 1) * (1 + normalisedWeight * 1.1)
    return beaksPerSecond
end


local function TableMutations(Tool: Tool)
    local Mutations = {}
    if Tool:IsA("Tool") and Tool:FindFirstChild("ExampleHandle") then
        local root = Tool.ExampleHandle:FindFirstChild("Torso")
        if root then
            for _, Mutation in ipairs(root:GetChildren()) do
                local name = Mutation.Name
                local suffix = string.match(name, "_([^_]+)$")
                if suffix then
                    -- Check both SpawnChances and Multipliers
                    if MutationInfo.SpawnChances[suffix] or MutationInfo.Multipliers[suffix] then
                        table.insert(Mutations, suffix)
                    end
                end
            end
        end
    end

    print(Mutations)
    return Mutations
end

local function computeMutationMultiplier(mutations)
    if not mutations then return 1 end
    local mult = 1
    for _, m in ipairs(mutations) do
        if m and m ~= "Normal" and MutationInfo and MutationInfo.Multipliers and MutationInfo.Multipliers[m] then
            mult = mult * MutationInfo.Multipliers[m]
        end
    end
    return mult
end

local function SendReward(Table)
    local Template = script.Reward:Clone()
    Template.Holder.First.Title.Text = Table.Reward1.Item
    Template.Holder.First.Main.Title.Text = Table.Reward1.Amount .. "x"
    Template.Holder.First.Main.Icon.Image = Table.Reward1.Icon
    if Table.Reward1.Item == "Wealth Egg" then
        Template.Holder.First.Title.TextColor3 = Color3.new(1, 0.921569, 0.0431373)
        
    end
    Template.Holder.Second.Title.Text = Table.Reward2.Item
    Template.Holder.Second.Main.Icon.Image = Table.Reward2.Icon
    Template.Holder.Second.Main.Title.Text = Table.Reward2.Amount .. "x"
    if Table.Reward2.Item == "Wealth Egg" then
        Template.Holder.Second.Title.TextColor3 = Color3.new(1, 0.921569, 0.0431373)
    end
    Template.Holder.Third.Title.Text = Table.Reward3.Item
    Template.Holder.Third.Main.Icon.Image = Table.Reward3.Icon
    Template.Holder.Third.Main.Title.Text = Table.Reward3.Amount .. "x"
    if Table.Reward3.Item == "Wealth Egg" then
        Template.Holder.Third.Title.TextColor3 = Color3.new(1, 0.921569, 0.0431373)
    end
    Template.Parent = player.PlayerGui.MainUI.Frames
    Template.Holder.First.Claim.MouseButton1Click:Connect(function()
        Template:Destroy()
        -- Send Reward Index (1)
        ReplicatedStorage.Remotes.WealthReward:FireServer(nil, "TradePigeon", 1)
        local confettiFolder = ReplicatedStorage.Particles.Confetti

        ParticleBorder.createFromTop(
            confettiFolder,
            0.5,    -- seconds of emission
            1.3   -- screen coverage multiplier
        )
    end)
    Template.Holder.Second.Claim.MouseButton1Click:Connect(function()
        Template:Destroy()
        -- Send Reward Index (2)
        ReplicatedStorage.Remotes.WealthReward:FireServer(nil, "TradePigeon", 2)
        local confettiFolder = ReplicatedStorage.Particles.Confetti

        ParticleBorder.createFromTop(
            confettiFolder,
            0.5,    -- seconds of emission
            1.3   -- screen coverage multiplier
        )
    end)
    Template.Holder.Third.Claim.MouseButton1Click:Connect(function()
        Template:Destroy()
        -- Send Reward Index (3)
        ReplicatedStorage.Remotes.WealthReward:FireServer(nil, "TradePigeon", 3)
        local confettiFolder = ReplicatedStorage.Particles.Confetti

        ParticleBorder.createFromTop(
            confettiFolder,
            0.5,    -- seconds of emission
            1.3   -- screen coverage multiplier
        )
    end)
end

ReplicatedStorage.Remotes.WealthReward.OnClientEvent:Connect(function(Type, Data)
    if Type == "ShowOptions" then
        SendReward(Data)
    end
end)

function GetEquippedToolName(player)
    if not player.Character then return nil end
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            return tool.Name
        end
    end
    return nil
end
function GetEquippedId(player)
    if not player.Character then return nil end
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            return tool:GetAttribute("EggId") or tool:GetAttribute("PigeonId") or tool:GetAttribute("Id")
        end
    end
    return nil
end



-- what happens when triggered
prompt.Triggered:Connect(function(player)
	dialogObject:triggerDialog(player, 1)
end)

-- logic to go through dialogs
dialogObject.responded:Connect(function(responseNum, dialogNum)
	if dialogNum == 1 then
		if responseNum == 1 then
                local toolName = GetEquippedToolName(player)
                if not toolName then
                    dialogObject:hideGui("Empty-handed, I see.")
                    return
                end
                if string.find(toolName,"Pigeon") then
                    local tool = player.Character:FindFirstChildWhichIsA("Tool")
                    local pigeonID = tool:GetAttribute("PigeonId")
                    if pigeonID then
                        local currentPigeon = pigeonInfo[toolName]
                        if currentPigeon then
                            local AmountF = math.floor(GetBeaksPerSecond(tool:GetAttribute("Weight"), currentPigeon) * 20 * computeMutationMultiplier(TableMutations(tool)))
                            if AmountF > 3000 then
                                ReplicatedStorage.Remotes.WealthReward:FireServer(pigeonID, "InitiateTrade")
                                dialogObject:hideGui("Interessting. Which one would you like?")
                            else
                                dialogObject:hideGui("I take only Pigeons worth 3,000 or more.")
                            end
                        else
                            dialogObject:hideGui("I don't know that one.")
                        end
                    else
                        dialogObject:hideGui("I don't know that one.")
                    end
                elseif string.find(toolName,"Egg") then
                    dialogObject:hideGui("I accept only pigeons.")
                else
                   dialogObject:hideGui("I accept only pigeons.")
                end


		end
		if responseNum == 2 then
            dialogObject:hideGui("As you wish.")
            player.PlayerGui.MainUI.Frames.WealthRewards.Visible = true
        end
        if responseNum == 3 then
            local Speeches = {
                "You’re testing my patience.",
                "Make it worth my time.",
                "I don’t have time for this."
            }
            local randomIndex = math.random(1, #Speeches)
            local randomMessage = Speeches[randomIndex]
            dialogObject:hideGui(randomMessage)
        end
	end
end)