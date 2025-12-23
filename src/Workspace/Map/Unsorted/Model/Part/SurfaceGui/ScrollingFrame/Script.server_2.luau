local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CoinsDataStore = DataStoreService:GetOrderedDataStore("BpsLDataStore_V1")

local leaderboardPart = script.Parent.Parent.Parent
local RefreshRate = 125

-- =========================
-- BLACKLIST (UserIds)
-- =========================
local BLACKLIST = {
    [10178051457] = true, -- example Player2
    [10691563] = true,
    [9389767344] = true,
    [10179173527] = true,
    [10186341895] = true,
    -- [UserId] = true,
}

-- =========================
-- NUMBER SHORTENER
-- =========================
local function ShortenNumber(num)
    local suffixes = {
        "K","M","B","T","Qa","Qi","Sx","Sp","Oc","No","Dc"
    }

    if num < 1000 then
        return tostring(num)
    end

    local suffixIndex = 0

    while num >= 1000 and suffixIndex < #suffixes do
        num /= 1000
        suffixIndex += 1
    end

    local shortened = string.format("%.1f", num)
    shortened = shortened:gsub("%.0$", "")

    return shortened .. suffixes[suffixIndex]
end

-- =========================
-- LEADERBOARD REFRESH
-- =========================
local function RefreshLeaderboard()

    -- SAVE PLAYER DATA (skip blacklisted)
    for _, Player in pairs(Players:GetPlayers()) do
        if Player:GetAttribute("BasePerSecond")
            and Player.UserId ~= 8850353662
            and not BLACKLIST[Player.UserId]
            and Player:GetAttribute("BasePerSecond") > 1000000 then

            local bps = Player:GetAttribute("BasePerSecond")
            bps = math.floor(bps or 0)

            CoinsDataStore:SetAsync(Player.UserId, bps)
        end
    end

    -- LOAD & DISPLAY
    local Success, Error = pcall(function()
        local Data = CoinsDataStore:GetSortedAsync(false, 50)
        local RollsPage = Data:GetCurrentPage()

        local VisibleRank = 0

        for _, SavedData in ipairs(RollsPage) do
            local userId = tonumber(SavedData.key)
            local Coins = SavedData.value

            -- SKIP BLACKLISTED USERS
            if BLACKLIST[userId] then
                continue
            end

            if Coins and Coins > 0 then
                VisibleRank += 1
                local Rank = VisibleRank

                local Username
                pcall(function()
                    
                    Username = Players:GetNameFromUserIdAsync(userId)
                end)

                if not Username then
                    continue
                end
                

                -- HEAD RANK DISPLAY (INGAME ONLY)
                local inGame = Players:GetPlayerByUserId(userId)
                if inGame and not BLACKLIST[inGame.UserId] then
                    task.delay(10, function()
                        if inGame.Character and inGame.Character:FindFirstChild("Head") then
                            local head = inGame.Character.Head
                            local display = head:FindFirstChild("DisplayRank")

                            if not display then
                                display = script.DisplayRank:Clone()
                                display.Parent = head
                            end

                            display.Base.Visible = true
                            display.Base.RankLabel.Text = "#" .. Rank
                        end
                    end)
                end

                -- UI ENTRY
                local NewSample = script:WaitForChild("Template"):Clone()
                NewSample.Parent = leaderboardPart.SurfaceGui.ScrollingFrame.Container
                NewSample.Name = Username

                NewSample.RankLabel.Text = Rank
                NewSample.NameLabel.Text = Username
                NewSample.NumberLabel.Text = ShortenNumber(Coins) .. "/s"

                if Rank == 1 then
                    NewSample.BackgroundColor3 = Color3.fromRGB(182, 182, 0)
                    NewSample.Layout.ImageColor3 = Color3.fromRGB(245, 245, 0)
                elseif Rank == 2 then
                    NewSample.BackgroundColor3 = Color3.fromRGB(182, 182, 182)
                    NewSample.Layout.ImageColor3 = Color3.fromRGB(229, 229, 229)
                elseif Rank == 3 then
                    NewSample.BackgroundColor3 = Color3.fromRGB(182, 84, 4)
                    NewSample.Layout.ImageColor3 = Color3.fromRGB(229, 107, 0)
                else
                    NewSample.BackgroundColor3 = Color3.fromRGB(0, 140, 182)
                    NewSample.Layout.ImageColor3 = Color3.fromRGB(0, 160, 229)
                end
            end
        end
    end)

    if not Success then
        warn("Leaderboard error:", Error)
    end
end

-- =========================
-- LOOP
-- =========================
while true do
    for _, Frame in pairs(leaderboardPart.SurfaceGui.ScrollingFrame.Container:GetChildren()) do
        if Frame:IsA("Frame") and Frame.Name ~= "Template" then
            Frame:Destroy()
        end
    end

    RefreshLeaderboard()
    task.wait(RefreshRate)
end
