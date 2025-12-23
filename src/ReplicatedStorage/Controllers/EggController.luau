local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local EggController = Knit.CreateController { Name = "EggController" }

local SyncedTime = require(game:GetService("ReplicatedStorage").Modules:WaitForChild("SyncedTime"))


local LocalEggs = {}

local function formatTime(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	return string.format("%02d:%02d:%02d", h, m, s)
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
local function flashEgg(egg)
	task.spawn(function()
		wait(math.random(1.1, 3.5))
		if egg and egg.Model and egg.Model.PrimaryPart then
			for i = 1, 3 do
				if not egg.Model.PrimaryPart:FindFirstChild("HatchPrompt") or egg.Model.PrimaryPart:FindFirstChild("HatchPrompt").Enabled == false then return end
				-- Create or get highlight
				local highlight = egg.Model:FindFirstChild("ReadyHighlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "ReadyHighlight"
					highlight.FillColor = Color3.fromRGB(255, 255, 255)
					highlight.OutlineTransparency = 1
					highlight.FillTransparency = 1
					highlight.Parent = egg.Model
				end

				-- Tween FillTransparency for flash
				local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local tweenIn = game.TweenService:Create(highlight, tweenInfo, {FillTransparency = 0})
				local tweenOut = game.TweenService:Create(highlight, tweenInfo, {FillTransparency = 1})
				tweenIn:Play()
				tweenIn.Completed:Connect(function()
					tweenOut:Play()
				end)

				-- Play tick sound
				if egg.Model.PrimaryPart:FindFirstChild("ReadyTick") then
					egg.Model.PrimaryPart.ReadyTick:Play()
				else
					local Tick = script.Tick:Clone()
					Tick.Name = "ReadyTick"
					Tick.Parent = egg.Model.PrimaryPart
					Tick:Play()
				end

				-- Make the egg jump
				-- Store the base position once
				local primary = egg.Model.PrimaryPart
				if not egg._BaseCFrame then
					egg._BaseCFrame = primary.CFrame
				end
				local baseCFrame = egg._BaseCFrame

				-- Jump tween
				local jumpHeight = 1.8
				local jumpUp = game.TweenService:Create(primary, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = baseCFrame * CFrame.new(0, jumpHeight, 0)})
				local jumpDown = game.TweenService:Create(primary, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {CFrame = baseCFrame})

				jumpUp:Play()
				jumpUp.Completed:Connect(function()
					jumpDown:Play()
				end)


				wait(0.4) -- small delay between ticks
			end
		end

	end)
end

function EggController:KnitStart()
	local EggUpdate = game.ReplicatedStorage.Remotes:WaitForChild("EggUpdate")
	if EggUpdate then
		warn("EggUpdate found")
	end
	EggUpdate.OnClientEvent:Connect(function(data)
		warn("Updated")
		if data.Type == "EggList" then
			-- replace all eggs
			LocalEggs = {}
			for _, egg in pairs(data.Eggs) do
				LocalEggs[egg.ID] = egg
			end
		elseif data.Type == "EggAdded" then
			LocalEggs[data.Egg.ID] = data.Egg
		elseif data.Type == "EggRemoved" then
			LocalEggs[data.ID] = nil
		end
	end)
	-- GUI update loop
	task.spawn(function()
		while true do
			local now = game.ReplicatedStorage.CurrentTime.Value
			--	warn("Eggs ",LocalEggs)
			for _, egg in pairs(LocalEggs) do -- Loop through every single egg
				-- If you want to know the errors, you can do this:
				-- s, e = success, error
				local s, e = pcall(function() -- If anything wrapped inside the pcall is bugged, it still continues onto the next egg, and the while true do loop continues.
					task.wait()
					if egg and egg.Model then
						if egg.Model:GetAttribute("Skipped") then
							egg.EndTime = now 
						end
					end
					local remaining = math.max(egg.EndTime - now, 0)


					if egg and egg.Model and egg.Model:FindFirstChild("BillboardGui") and remaining > 0 then
						local gui = egg.Model.BillboardGui
						local bar = gui:WaitForChild("ProgressBar")
						if gui:FindFirstChild("Price") then
							gui.Price.Visible = false
						end
                        bar.Visible = true
                        --[[if egg.Model:GetAttribute("LuckBoost") or egg.Model:GetAttribute("SizeBoost") then
                            local StatsE
                            if egg.Model.PrimaryPart:FindFirstChild("EggStats") then
                                StatsE = egg.Model.PrimaryPart:FindFirstChild("EggStats")
                            else
                                StatsE = game.ReplicatedStorage.Game.EggStats:Clone()
                                StatsE.Parent = egg.Model.PrimaryPart
                                StatsE.Adornee = egg.Model.PrimaryPart
                            end
                            if egg.Model:GetAttribute("LuckBoost") then
                                StatsE.Luck.Visible = true
                                StatsE.Luck.Text = "Luck: " .. egg.Model:GetAttribute("LuckBoost") .. "%"
                                
                            end
                            if egg.Model:GetAttribute("SizeBoost") then
                                StatsE.Luck.Visible = true
                                StatsE.Size.Text = "Size: " .. egg.Model:GetAttribute("SizeBoost") .. "%"

                            end
                        end]]
						if bar then
							local leadRemaining = math.max(remaining - 1, 0) -- don't go below 0
							local newSize = UDim2.new(leadRemaining / egg.HatchTime, 0, 1, 0)

							local tweenInfo = TweenInfo.new(
								1.2,  -- duration of the tween
								Enum.EasingStyle.Linear,
								Enum.EasingDirection.Out
							)

							local tween = game.TweenService:Create(bar.Progress, tweenInfo, {Size = newSize})
							tween:Play()

							-- Keep the actual remaining time for display
							bar.AmountLeft.Text = formatTime(remaining)
						end
					end
					if egg.Mutation ~= nil then
						local gui = egg.Model.BillboardGui
						local mutationsImage = gui:FindFirstChild("MutationsLabel")
						if mutationsImage then
							mutationsImage[egg.Mutation].Visible = true
						else
							mutationsImage = game.ReplicatedStorage.Game.MutationsLabel:Clone()
							mutationsImage.Parent = egg.Model.BillboardGui
							mutationsImage[egg.Mutation].Visible = true
						end
					end
					if egg.Mutation ~= nil and egg.Model:GetAttribute("Mutation") then
						local gui = egg.Model.BillboardGui
						local mutationsImage = gui:FindFirstChild("MutationsLabel")
						if mutationsImage then
							mutationsImage[egg.Model:GetAttribute("Mutation")].Visible = true
							if egg.Mutation ~= "Normal" then
								local MutationVFX = game.ReplicatedStorage.Game.MutationParticles[egg.Mutation]:Clone()
								MutationVFX.Parent = egg.Model.PrimaryPart
								MutationVFX.Enabled = true
							end
						else
							mutationsImage = game.ReplicatedStorage.Game.MutationsLabel:Clone()
							mutationsImage.Parent = egg.Model.BillboardGui
							mutationsImage[egg.Model:GetAttribute("Mutation")].Visible = true
							if egg.Mutation ~= "Normal" then
								local MutationVFX = game.ReplicatedStorage.Game.MutationParticles[egg.Mutation]:Clone()
								MutationVFX.Parent = egg.Model.PrimaryPart
								MutationVFX.Enabled = true
							end
						end
					end
					if egg.Ready then
						if not egg._NextFlash or tick() >= egg._NextFlash then
							flashEgg(egg)
							egg._NextFlash = tick() + 7
						end
					end
					if remaining <= 0 and not egg.Ready then

						if egg.Model then
							egg.Model:SetAttribute("DoneHatching",true)
							egg.Ready = true
							local gui = egg.Model.BillboardGui
							local bar = gui:WaitForChild("ProgressBar")
							local gui = egg.Model.BillboardGui
							local bar = gui:FindFirstChild("ProgressBar")
							if bar then
								bar.Visible = false
							end
							gui.Price.Text = "Ready to hatch!"
							gui.Price.Visible = true
							if gui.Ready.Visible == false then
								gui.Ready.Visible = true
								local SoundR = script.Ready:Clone()
								SoundR.Parent = egg.Model.PrimaryPart or egg.Model.Handle
								SoundR:Play()
								game.Debris:AddItem(SoundR, 6)
							end
							
                            -- Enable proximity prompt for hatching
                            --if egg.Model.PrimaryPart:FindFirstChild("HatchPrompt") then
                                --local hasLuck = part:GetAttribute("Luck")
                               -- local hasSize = part:GetAttribute("Size")

                               -- local output = {}
                               -- egg.Model.PrimaryPart:FindFirstChild("HatchPrompt").ActionText =
                            --end
                            if not egg.Model.PrimaryPart:FindFirstChild("HatchPrompt") then
                                
								local prompt = Instance.new("ProximityPrompt")
								prompt.Name = "HatchPrompt"
								prompt.ActionText = "Hatch Egg"
								prompt.ObjectText = egg.Rarity .. " Egg"
								prompt.HoldDuration = 1
								prompt.RequiresLineOfSight = false
								prompt.MaxActivationDistance = 12
								prompt.Parent = egg.Model.PrimaryPart
								prompt.Style = "Custom"
								prompt:SetAttribute("Theme", "DefaultGreen")

								prompt.Triggered:Connect(function(player)
									-- call server to hatch pigeon

                                    local Limit = 5
                                    local Multiplier = 1
                                    if player:GetAttribute("TotalExpands") and player:GetAttribute("TotalExpands") > 0 then
                                        Multiplier *= player:GetAttribute("TotalExpands") + 1
                                    end
                                    Limit = Limit * Multiplier
                                    
									if getMyPlot(game.Players.LocalPlayer):FindFirstChild("Pigeons") then
										if #getMyPlot(game.Players.LocalPlayer).Pigeons:GetChildren() >= Limit then
                                            _G.Notification("You need to expand your plot to place more pigeons. (" .. Limit .. "/" .. #getMyPlot(player).Pigeons:GetChildren() .. ")", Color3.new(1, 0, 0))

											return
										end
									end
									Knit.GetService("PigeonService"):RewardPigeon({
										Position = {egg.relativeCFrame:GetComponents()},
										Rarity = egg.Rarity,
										Model = egg.Model,
										EggName = egg.Model.Name,
										LuckBoost = egg.Model:GetAttribute("LuckBoost"),
										SizeBoost = egg.Model:GetAttribute("SizeBoost"),
										Mutation = egg.Mutation,
										ID = egg.ID
									})
									warn(egg.Rarity)
									
									local Achivement = game.ReplicatedStorage.Remotes:WaitForChild("AddAchievement")
									Achivement:FireServer({"Eggs",egg.Rarity},1)
									prompt.Enabled = false
									EggUpdate:FireServer(egg.ID)
									print("Open")
									prompt.Enabled = false
									prompt:Destroy()
									--task.delay(0.75, function()
									--	if egg.Model then
									--		egg.Model:Destroy()
									--	end
									--end)
									LocalEggs[egg.ID] = nil
								end)
							end
						end
					end
				end)
				if e then
					print("Error: "..e)
				end
			end
			task.wait(1)
		end
	end)
end

return EggController
