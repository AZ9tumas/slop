--local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
--local HttpService = game:GetService("HttpService")
--local Players = game:GetService("Players")

--local HatchingService = Knit.CreateService {
--	Name = "HatchingService",
--	Client = {}
--}

--local RarityHatchTimes = {
--	Common   = 60,
--	Uncommon = 120,
--	Rare     = 300,
--	Beach    = 180,
--	Epic     = 600,
--	Kingdom  = 900,
--	Zombie   = 1200,
--	Secret   = 1800
--}

---- ActiveEggs[player.UserId] = { {ID, EggName, Rarity, Remaining, HatchTime, Model, LastTick}, ... }
--local ActiveEggs = {}
--local DataService

--local function formatTime(seconds)
--	local h = math.floor(seconds / 3600)
--	local m = math.floor((seconds % 3600) / 60)
--	local s = seconds % 60
--	return string.format("%02d:%02d:%02d", h, m, s)
--end

--function HatchingService:KnitStart()
--	DataService = Knit.GetService("DataService")

--	-- when profile is loaded
--	DataService.PlayerProfileLoaded.Event:Connect(function(player)
--		local profile = DataService:GetProfile(player)
--		repeat task.wait() warn("Searching For Profile") profile = DataService:GetProfile(player) until profile
--		if profile then
--			self:LoadEggs(player, profile)
--		end
--	end)


--	-- tick loop
--	task.spawn(function()
--		while true do
			
--			for userId, eggs in pairs(ActiveEggs) do
				
--				for i = #eggs, 1, -1 do
--					local egg = eggs[i]

--					-- decrement Remaining based on elapsed since last tick
--					egg.Remaining = math.max(egg.Remaining - 1, 0)

--					if egg.Remaining <= 0 then
--						print("[HATCHED]", egg.EggName, egg.Rarity, "for player", userId)
--						-- TODO: reward player
--						--table.remove(eggs, i)
--					else
--						-- update UI
--						if egg.Model and egg.Model:FindFirstChild("BillboardGui") then
						
--							local gui = egg.Model.BillboardGui
--							local bar = gui:FindFirstChild("ProgressBar")
--							if bar then
--								bar.Visible = true
--								if gui:FindFirstChild("Price") then
--									gui.Price.Visible = false
--								end
--								if bar:FindFirstChild("Progress") then
--									local ratio = egg.Remaining / egg.HatchTime
--									bar.Progress.Size = UDim2.new(ratio, 0, 1, 0)
--									if bar:FindFirstChild("AmountLeft") then
--										bar.AmountLeft.Text = formatTime(egg.Remaining)
--									end
--								end
--							end
--						else
						
--						end
--					end
--				end
--			end
--			task.wait(1)
--		end
--	end)
--end

--function HatchingService:RegisterEgg(player, eggName, rarity, id, model)
--	if not ActiveEggs[player.UserId] then
--		ActiveEggs[player.UserId] = {}
--	end

--	local hatchTime = RarityHatchTimes[rarity] or 300

--	table.insert(ActiveEggs[player.UserId], {
--		ID = id,
--		EggName = eggName,
--		Rarity = rarity,
--		Remaining = hatchTime, -- countdown starts full
--		HatchTime = hatchTime,
--		Model = model,
--		LastTick = os.time()
--	})

--	return id
--end

--function HatchingService:AttachModel(player, eggId, model)
--	local playerEggs = ActiveEggs[player.UserId]
--	repeat wait() playerEggs = ActiveEggs[player.UserId] until playerEggs
--	if not playerEggs then
--		warn("No eggs found for player:", player.Name)
--		return
--	end

--	for _, eggArray in pairs(playerEggs) do
--		for _, egg in ipairs(eggArray) do
--			if egg.ID == eggId then
--				egg.Model = model
				
--				return
--			end
--		end
--	end

--	warn("Could not find egg with ID:", eggId, "for player:", player.Name)
--end


--function HatchingService:GetRemainingTime(player, eggId)
--	local eggs = ActiveEggs[player.UserId]
--	if not eggs then return nil end
--	for _, egg in ipairs(eggs) do
--		if egg.ID == eggId then
--			return egg.Remaining
--		end
--	end
--	return nil
--end

--function HatchingService:SaveEggs(player, profile)
--	local eggs = ActiveEggs[player.UserId] or {}
--	profile.Data.HatchingEggs = {}
--	profile.Data.LastSave = os.time()
--warn("Saving Data")
--	for _, egg in ipairs(eggs) do
--		-- only pure Lua values
--		table.insert(profile.Data.HatchingEggs, {
--			ID = egg.ID,
--			EggName = egg.EggName,
--			Rarity = egg.Rarity,
--			Remaining = egg.Remaining,
--			HatchTime = egg.HatchTime
--		})
--	end
--end


--function HatchingService:LoadEggs(player, profile)
--	ActiveEggs[player.UserId] = {}
--	local now = os.time()
--	local lastSave = profile.Data.LastSave or now
--	local offlineElapsed = now - lastSave

--	for _, eggData in ipairs(profile.Data.HatchingEggs or {}) do
--		warn(eggData)
--		local remaining = (eggData.Remaining or eggData.HatchTime) - offlineElapsed
--		if remaining > 0 then
--			table.insert(ActiveEggs[player.UserId], {
--				ID = eggData.ID,
--				EggName = eggData.EggName,
--				Rarity = eggData.Rarity,
--				Remaining = remaining,
--				HatchTime = eggData.HatchTime,
--				Model = nil 
--			})
--		else
--			print("[INFO]", eggData.EggName, "hatched while offline")
--		end
--	end
--end


--return HatchingService
