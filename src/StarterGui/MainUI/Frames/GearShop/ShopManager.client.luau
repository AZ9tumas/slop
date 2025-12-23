local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local RestockEvent = Remotes:WaitForChild("RestockEvent")
local ShopEvent = Remotes:WaitForChild("BuyTool")

local ToolInfo = require(ReplicatedStorage.Info.ToolInfo)
local ScrollingFrame = script.Parent.ScrollingFrame
local timerLabel = script.Parent.Top.Restock

local MarketplaceService= game:GetService("MarketplaceService")

local templates = {}
local nextRestockAt = 0

local db = false

function FormatWithCommas(number)
    if type(number) ~= "number" then
        warn("FormatWithCommas expects a number, got", type(number))
        return tostring(number)
    end

    local formatted = tostring(math.floor(number))
    local k

    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end

    return formatted
end

script.Parent.Top.Close.MouseButton1Click:Connect(function()
    script.Parent.Visible = false
end)

-- Build GUI once
for toolName, toolData in pairs(ToolInfo) do
if toolData.Price then
    local Template = script.Template:Clone()
    Template.ToolName.Text = toolName
    Template.Buy.Title.Text = "$".. FormatWithCommas(toolData.Price) 
    Template.Description.Text = toolData.Description
    Template.Parent = ScrollingFrame
    Template.LayoutOrder = toolData.LayoutOrder
    Template.Icon.Image = toolData.Icon
    Template.Buy.MouseButton1Click:Connect(function()
        if db then return end
        db = true
        task.delay(0.6, function()
            db = false
        end)

        ShopEvent:FireServer(toolName)

        -- Update only THIS tool’s visual state
        local personalTemplate = templates[toolName]
        local personalStock = personalTemplate.Stock.Text
        local toolInfo = ToolInfo[toolName]

        if personalStock == "x0 Stock" then
            if toolInfo.BoughtWithRobux == true then
                local success, infotable = pcall(function()
                    return MarketplaceService:GetProductInfo(toolInfo.ID, Enum.InfoType.Product)
                end)
                if success and infotable then
                    personalTemplate.Buy.Title.Text = infotable.PriceInRobux .. ""
                else
                    personalTemplate.Buy.Title.Text = "Error."
                    warn("Failed to fetch product info for", toolName)
                end
            end

            personalTemplate.Buy:FindFirstChild("Background").UIGradient.Enabled = false
            personalTemplate.Buy:FindFirstChild("Background").UIGradientNONE.Enabled = true
            personalTemplate.Buy.UIStroke.Color = Color3.fromRGB(109, 0, 0)
            personalTemplate.Buy.Title.UIStroke.Color = Color3.fromRGB(148, 0, 0)
        else
            personalTemplate.Buy:FindFirstChild("Background").UIGradient.Enabled = true
            personalTemplate.Buy:FindFirstChild("Background").UIGradientNONE.Enabled = false
            personalTemplate.Buy.UIStroke.Color = Color3.fromRGB(11, 111, 18)
            personalTemplate.Buy.Title.UIStroke.Color = Color3.fromRGB(12, 85, 7)
        end
    end)


    templates[toolName] = Template
end
end

-- Update stock + next restock timestamp
RestockEvent.OnClientEvent:Connect(function(stock, restockAt)
    warn("Fired")
    for toolName, Template in pairs(templates) do
        local personalAmount = stock[toolName] or 0
        Template.Stock.Text = "x" .. personalAmount .. " Stock"

        if personalAmount == 0 then
            if ToolInfo[toolName].BoughtWithRobux == true then
                local infotable = MarketplaceService:GetProductInfo(ToolInfo[toolName].ID, Enum.InfoType.Product)
                Template.Buy.Title.Text = infotable.PriceInRobux .. ""
            end
            Template.Buy:FindFirstChild("Background").UIGradient.Enabled = false
            Template.Buy:FindFirstChild("Background").UIGradientNONE.Enabled = true
            Template.Buy.UIStroke.Color = Color3.fromRGB(109, 0, 0)
            Template.Buy.Title.UIStroke.Color = Color3.fromRGB(148, 0, 0)
        else
            Template.Buy.Title.Text = "$".. FormatWithCommas(ToolInfo[toolName].Price) 
            Template.Buy:FindFirstChild("Background").UIGradient.Enabled = true
            Template.Buy:FindFirstChild("Background").UIGradientNONE.Enabled = false
            Template.Buy.UIStroke.Color = Color3.fromRGB(11, 111, 18)
            Template.Buy.Title.UIStroke.Color = Color3.fromRGB(12, 85, 7)
        end

    end
    nextRestockAt = restockAt
end)

local replicatedTime = game.ReplicatedStorage.CurrentTime

RestockEvent.OnClientEvent:Connect(function(stock, restockAt)
    nextRestockAt = restockAt
end)

-- Countdown loop
task.spawn(function()
    while true do
        if nextRestockAt > 0 then
            local remaining = math.max(0, nextRestockAt - replicatedTime.Value)
            if remaining > 0 then
                local mins = math.floor(remaining / 60)
                local secs = remaining % 60
                timerLabel.Text = string.format("Restock in %02d:%02d", mins, secs)
            else
                timerLabel.Text = "Restock in 00:00"
            end
        end
        task.wait(1)
    end
end)

