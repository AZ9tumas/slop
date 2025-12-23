local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PigeonController = Knit.CreateController { Name = "PigeonController" }
local PigeonUpdate = ReplicatedStorage.Remotes:WaitForChild("PigeonUpdate")
local PigeonCollectRequest = ReplicatedStorage.Remotes:WaitForChild("PigeonCollectRequest")

local LocalPigeons = {}
local LocalBeaks = 0
local collectCooldowns = {}
local COLLECTION_COOLDOWN = 1.5
local SYNC_INTERVAL = 1.5
local COLLECTION_RANGE = 10

local FriendBoostInfo = require(game.ReplicatedStorage.Info.FriendBoostInfo)
local MutationInfo = require(game.ReplicatedStorage.Info.MutationsInfo)

function FormatWithCommas(number)
	if type(number) ~= "number" then
		warn("FormatWithCommas expects a number, got", type(number))
		return tostring(number)
	end

	local integerPart, decimalPart = math.modf(number)
	local formatted = tostring(math.floor(math.abs(integerPart)))
	local k

	-- Add commas
	repeat
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0

	-- Add negative sign back if needed
	if number < 0 then
		formatted = "-" .. formatted
	end

	-- Add decimal if not zero
	if decimalPart ~= 0 then
		local decimalStr = string.format("%.1f", decimalPart)
		decimalStr = string.sub(decimalStr, 3) -- remove "0."
		formatted = formatted .. "." .. decimalStr
	end

	-- Add "/s" if not already there
	if not string.match(formatted, "/s$") then
		formatted = formatted .. "/s"
	end

	return formatted
end



local function IsFriendInGame(player)
	if not player or not player:IsA("Player") then
		return false
	end
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			if player:IsFriendsWith(otherPlayer.UserId) then
				return true, otherPlayer
			end
		end
	end
	return false, nil
end
local function CountFriendsInGame(player)
	if not player or not player:IsA("Player") then
		return 0
	end
	local count = 0
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and player:IsFriendsWith(otherPlayer.UserId) then
			count += 1
		end
	end
	return math.min(count, 3) -- cap at 3 friends
end

local function getMyPlot(player)
	for _, plot in ipairs(workspace.Map.Plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId and ownerId == player.UserId then
			return plot
		end
	end
	return nil
end
local function ensureMutationList(m)
	if not m then return {} end
	if type(m) == "string" then
		return {m}
	end
	if type(m) == "table" then
		return m
	end
	return {}
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

local CollectPitch = Instance.new("NumberValue")
CollectPitch.Value = 1

CollectPitch.Changed:Connect(function(newPitch)
	task.wait(2)
	if CollectPitch.Value == newPitch then
		CollectPitch.Value = 1
	end
end)
local collect = function(amount, pos, PigeonModel)
    local suc,er = pcall(function()
		local module = require(script.CashEffect3D)
		local module2 = require(script.CashPopUp)
		CollectPitch.Value += 0.25 -- 0.5
		module.Play(0.7, 12, pos,CollectPitch)-- the 0.7 is the duration of it reaching you and the 15 is the amount of coins it spawns
		wait(0.7)
		module2(amount)
	end)
end


Players.PlayerRemoving:Connect(function(player)
	if player == Players.LocalPlayer then
		local dataToSend = {}
		for id, pigeon in pairs(LocalPigeons) do
			dataToSend[id] = {
				EarnedBeaks = pigeon.EarnedBeaks
			}
		end

		PigeonCollectRequest:FireServer(dataToSend, nil, "Save")
	end
end)

function PigeonController:KnitStart()
	local lastSyncTime = tick()
	local firstCollection = false

	game.ReplicatedStorage.Remotes.GetCurrent.OnClientInvoke = function()
		return LocalPigeons
	end

	PigeonUpdate.OnClientEvent:Connect(function(data)
		if data.Type == "BeakUpdate" then
			firstCollection = true
			LocalBeaks = data.Beaks
			for _, p in ipairs(data.Pigeons or {}) do
				LocalPigeons[p.ID] = p
			end
		elseif data.Type == "Collected" then
			LocalBeaks = data.NewBeaks
			if LocalPigeons[data.PigeonId] then
				LocalPigeons[data.PigeonId].EarnedBeaks = 0
			end
		end
		lastSyncTime = tick()
	end)

	local setCount = 0
	task.spawn(function()
		while true do
			local dt = 0.1 -- 1
			pcall(function()
				local player = Players.LocalPlayer
				local char = player.Character
				if not char or not char.PrimaryPart then
					task.wait(dt)
					return
				end
				local charPos = char.PrimaryPart.Position

				local totalRate = 0
				for _, pigeon in pairs(LocalPigeons) do
					local s, e = pcall(function()
					if pigeon.Rate then
						local rate = pigeon.Rate
						local mult = computeMutationMultiplier(ensureMutationList(pigeon.Mutation))
						rate = rate * mult
						local friendCount = CountFriendsInGame(player)
						--[[if friendCount == 0 then
							player.PlayerGui.MainUI.FriendBoost.Visible = false
						else
							player.PlayerGui.MainUI.FriendBoost.Visible = true
						end]]
						player.PlayerGui.MainUI.FriendInvite.FriendBoost.Text = "+"..friendCount * 5 .. "% Friend Boost"
						
						if friendCount > 0 then
							rate = rate * (1 + FriendBoostInfo.MoneyMultiplier * friendCount)
						end

						pigeon.EarnedBeaks = ((pigeon.EarnedBeaks or 0) + rate * dt)
						pigeon.EarnedBeaks = math.min(pigeon.EarnedBeaks,20000000)
						pigeon.CalculatedRate = rate
						totalRate += (rate / 10)			
					end
					end)
					if e then
						warn(e)
					end

				end
				LocalBeaks = LocalBeaks + totalRate * dt
				for _, pigeon in pairs(LocalPigeons) do
					task.spawn(function()
						local model
						for _, desc in ipairs(getMyPlot(player).Pigeons:GetChildren()) do
							task.wait()
							if desc:IsA("Model") and desc:GetAttribute("PigeonID") == pigeon.ID then
								model = desc

								break
							end
						end
						pigeon.EarnedBeaks = math.min(pigeon.EarnedBeaks,10000000)
						if model then
							local attr = model:GetAttribute("Mutation")
							local list = ensureMutationList(attr or pigeon.Mutation)
							if not next(list) then
								list = ensureMutationList(pigeon.Mutation)
							end
							if next(list) then
								pigeon.Mutation = list
								local board = model:FindFirstChild("PigeonBillboard", true)
								if board then
									for _, m in ipairs(list) do
										if board.Mutations[m] then
											board.Mutations[m].Visible = true
										end
									end
									board.PigeonName.Text = pigeon.Name.." ["..(pigeon.Weight or "?").."Kg]".." ("..table.concat(list, ", ")..")"
								end
							end
							local board = model:FindFirstChild("PigeonBillboard", true)
							if board then
								board.SavedMoney.Amount.Text = "$"..tostring(math.floor(pigeon.EarnedBeaks or 0))
								--board.AmountPerSecond.Text = string.format("%.1f $/s", pigeon.CalculatedRate or 0)
								board.AmountPerSecond.Text = "$"..FormatWithCommas(pigeon.CalculatedRate or 0) or 0 --string.format("$%.1f/s", pigeon.CalculatedRate or 0)
							end
							
							-- For giving beaks:
							
							
							local center = model.PrimaryPart and model.PrimaryPart.Position or model:GetModelCFrame().Position
							if (charPos - center).Magnitude <= COLLECTION_RANGE and (pigeon.EarnedBeaks or 0) > 0 then
								local now = tick()
								local lastCollect = collectCooldowns[pigeon.ID] or 0
								if now - lastCollect >= COLLECTION_COOLDOWN then
									warn("FIRING SERVER")
									
									PigeonCollectRequest:FireServer(pigeon.ID,pigeon.EarnedBeaks)
									task.spawn(function()
										collect(pigeon.EarnedBeaks,model.PrimaryPart.Position, model)
									end)
									pigeon.EarnedBeaks = 0
									collectCooldowns[pigeon.ID] = now
								end
							end
							--if mutation then
							--	if board.Mutations[mutation] then
							--		board.Mutations[mutation].Visible = true
							--	end
							--end
						end
					end)
				end

				if player:FindFirstChild("PlayerGui") then
					local statsGui = player.PlayerGui:FindFirstChild("StatsGui")
					if statsGui and statsGui:FindFirstChild("BeaksLabel") then
						statsGui.BeaksLabel.Text = tostring(math.floor(LocalBeaks))
					end
				end

				if tick() - lastSyncTime > SYNC_INTERVAL then
					lastSyncTime = tick()
				end
			end)
			task.wait(dt)
			setCount += 0.1
		end
	end)
end

return PigeonController
