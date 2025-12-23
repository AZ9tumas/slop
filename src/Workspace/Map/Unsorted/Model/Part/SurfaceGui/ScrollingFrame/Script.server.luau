local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CoinsDataStore = DataStoreService:GetOrderedDataStore("EbLDataStore_V1")

local leaderboardPart = script.Parent.Parent.Parent
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local RefreshRate = 60

local function ShortenNumber(num)
    local suffixes = {
        "K","M","B","T","Qa","Qi","Sx","Sp","Oc","No","Dc"
    }

    if num < 1000 then
        return tostring(num)
    end

    local suffixIndex = 0

    while num >= 1000 and suffixIndex < #suffixes do
        num = num / 1000
        suffixIndex += 1
    end

    -- 1 decimal only
    local shortened = string.format("%.1f", num)

    -- remove .0
    shortened = shortened:gsub("%.0$", "")

    return shortened .. suffixes[suffixIndex]
end


local function RefreshLeaderboard()

    for i, Player in pairs(Players:GetPlayers()) do
        local profile = Knit.GetService("DataService"):GetProfile(Player)
        if Player.UserId ~= 8850353662 and profile then
        local bps = profile.Data.EggsBought or 0

        -- FIX: DataStores do NOT allow floats → convert to integer
        if bps then
            bps = math.floor(bps)
        else
            bps = 0
        end

        CoinsDataStore:SetAsync(Player.UserId, bps)
        end
    end

    local Success, Error = pcall(function()

        local Data = CoinsDataStore:GetSortedAsync(false, 60)
        local RollsPage = Data:GetCurrentPage()

        for Rank, SavedData in ipairs(RollsPage) do

            local userId = tonumber(SavedData.key)
            local Coins = SavedData.value

            if Coins and Coins > 0 then

                local Username = Players:GetNameFromUserIdAsync(userId)
                
                local inGame = Players:GetPlayerByUserId(userId)
                if inGame and game.Players:FindFirstChild(inGame.Name) then
                    task.delay(11, function()
                        if inGame.Character then
                            if not inGame.Character.Head:FindFirstChild("DisplayRank") then
                                local Clone = script.DisplayRank:Clone()
                                Clone.Parent = inGame.Character.Head
                                Clone.Egg.Visible = true
                                Clone.Egg.RankLabel.Text = "#" .. Rank
                            else
                                inGame.Character.Head:FindFirstChild("DisplayRank").Egg.Visible = true
                                inGame.Character.Head:FindFirstChild("DisplayRank").Egg.RankLabel.Text = "#" .. Rank
                            end
                        end
                    end)
                end
                
                local NewSample = script:WaitForChild("Template"):Clone()

                NewSample.Parent = leaderboardPart.SurfaceGui:WaitForChild("ScrollingFrame").Container
                NewSample.Name = Username

                NewSample.RankLabel.Text = Rank
                NewSample.NameLabel.Text = Username
                NewSample.NumberLabel.Text = ShortenNumber(Coins)

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
end

while true do

    for i, Frame in pairs(leaderboardPart.SurfaceGui:WaitForChild("ScrollingFrame").Container:GetChildren()) do

        if Frame.Name ~= "Template" and Frame:IsA("Frame") then

            Frame:Destroy()
        end
    end

    RefreshLeaderboard()

    task.wait(RefreshRate)
end
