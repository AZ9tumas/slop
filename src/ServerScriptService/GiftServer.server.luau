local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


game.ReplicatedStorage.Remotes.GiftService.OnServerEvent:Connect(function(Gifting, Gifted:Player, ID)
    if Gifted.Character:FindFirstChild("BusyGift") then ReplicatedStorage.Remotes.Notification:FireClient(Gifting, Gifted.Name .. " Has a gift request, please wait until he is done.") return end
    ReplicatedStorage.Remotes.Notification:FireClient(Gifting, "Gift request sent!")
    local UI = script.Template:Clone()
    local Busy = Instance.new("BoolValue", Gifted.Character)
    Busy.Name = "BusyGift"
    local data
    pcall(function()
        data = _G.getPigeonDatafromid(game.Players:GetPlayerFromCharacter(Gifting.Character), ID)
    end)

    local mutationText = ""
    if data.Mutation and #data.Mutation > 0 then
        -- filter out "Normal"
        local filtered = {}
        for _, m in ipairs(data.Mutation) do
            if m ~= "Normal" then
                table.insert(filtered, m)
            end
        end
        if #filtered > 0 then
            mutationText = " [" .. table.concat(filtered, ", ") .. "]"
        end
    end

    UI.PName.Text = (data.Name or "Pigeon") .. " [" .. (data.Weight or "?") .. "Kg]" .. mutationText

    UI.Title.Text = "Gift from: @" .. Gifting.Name
    UI.Parent = Gifted.PlayerGui.MainUI.GiftRequests
    game.Debris:AddItem(UI, 30)
    game.Debris:AddItem(Busy, 30)
    task.delay(31, function()
        if Busy then
            Busy:Destroy()
        end
    end)
    UI.Holder.No.MouseButton1Click:Connect(function()
        UI:Destroy()
        if Busy then
        Busy:Destroy()
        end
    end)
    UI.Holder.Yes.MouseButton1Click:Connect(function()
        UI:Destroy()
        if Busy then
        Busy:Destroy()
        end
        local PigeonService = Knit.GetService("PigeonService")
        PigeonService:GiftFunction(Gifting, Gifted, ID)
    end)
end)