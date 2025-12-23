local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local AddAchievementEvent = ReplicatedStorage.Remotes.AddAchievement
local GetAchievementsFunction = ReplicatedStorage.Remotes.GetQuestState

local AchievementModule = {}

if isServer then
	local Players = game:GetService("Players")
	local PlayerAchievements = {}

	local function GetPlayerData(player)
		if PlayerAchievements[player] then
			return PlayerAchievements[player]
		end

		local profile = Knit.GetService("DataService"):GetProfile(player)
		if not profile then
			warn("Profile missing for " .. player.Name)
			return {}
		end

		-- ✅ Ensure Achievements table exists in ProfileService data
		if not profile.Data.Achievements then
			profile.Data.Achievements = {}
		end

		PlayerAchievements[player] = profile.Data.Achievements
		return PlayerAchievements[player]
	end

	local function ModifyAchievement(player, path, value, isSet)
		task.spawn(function()
			local data = GetPlayerData(player)
			local ref = data

			for i = 1, #path - 1 do
				local key = path[i]
				if not ref[key] then ref[key] = {} end
				ref = ref[key]
			end

			local lastKey = path[#path]
			local old = ref[lastKey]

			if isSet then
				ref[lastKey] = value
			else
				if type(old) == "number" and type(value) == "number" then
					ref[lastKey] = old + value
				else
					ref[lastKey] = value
				end
			end
		end)
	end

	local function AddAchievementServer(player, path, value)
		ModifyAchievement(player, path, value, false)
	end

	local function SetAchievementServer(player, path, value)
		ModifyAchievement(player, path, value, true)
	end

	_G.GetAchievValue = function(player, path)
		local data = GetPlayerData(player)
		local ref = data
		for _, key in ipairs(path) do
			ref = ref[key]
			if not ref then return 0 end
		end
		return type(ref) == "number" and ref or 0
	end

	AddAchievementEvent.OnServerEvent:Connect(AddAchievementServer)

	_G.AddAchiev = AddAchievementServer
	_G.SetAchiev = SetAchievementServer

	GetAchievementsFunction.OnServerInvoke = function(player)
		return GetPlayerData(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		PlayerAchievements[player] = nil
	end)

	AchievementModule.Add = AddAchievementServer
	AchievementModule.Get = GetPlayerData

else
	AddAchievementEvent = ReplicatedStorage.Remotes:WaitForChild("AddAchievement")
	GetAchievementsFunction = ReplicatedStorage.Remotes:WaitForChild("GetQuestState")

	function AchievementModule.Add(path, value)
		AddAchievementEvent:FireServer(path, value)
	end

	function AchievementModule.Get()
		return GetAchievementsFunction:InvokeServer()
	end
end

return AchievementModule
