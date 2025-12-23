--// Services
local rp = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Lighting  = game:GetService('Lighting')

--// modules
local CameraShaker = require(script.Module.CameraShaker)


local module = {}
--
--local camera = game.Workspace.CurrentCamera

module.Darkness = function(Data)
	local camera =workspace.Camera or Data.camera 
	local tim = Data.tim or 1
	local oldClockTim = Lighting.ClockTime
	
	Lighting.ClockTime = 0
	
	local effect = script.Effects["-0.05"]:Clone()
	effect.Parent = camera
	effect.Enabled = true


	game.Debris:AddItem(effect, tim)
	task.delay(tim, function()
		Lighting.ClockTime = oldClockTim
	end)
	
end


module.Flash = function(data)
	local camera =workspace.Camera or data.camera 
	local tim = data.tim or 1
	local request = data.request
	
	if request and script.Effects:FindFirstChild(request)  then
		local effect = script.Effects[request]:Clone()
		effect.Parent = camera
		effect.Enabled = true
		
		
		game.Debris:AddItem(effect, tim)
	else
		warn( request, 'does not exist in effects folder!')
	end
	
	
end

module.Insert_Blur = function(data)
	local bool = data.bool
	local name = data.name or "Blur"
	
	if bool == true then
		if not workspace.Camera:FindFirstChild(name) then
			local blur = script.Effects["Blur"]:Clone()
			blur.Name = name
			blur.Parent = workspace.Camera
		end
	else
		if workspace.Camera:FindFirstChild(name) then
			local blur = workspace.Camera:FindFirstChild(name)
			blur:Destroy()
		end
	end
	
end

module.Blur = function(data)
	local camera = workspace.Camera or data.camera 
	local tim1,tim2 = data.tim1 or .5, data.tim2 
	local EasingStyleDirc = data.EasingStyleDirc or Enum.EasingDirection.Out
	local EasingStyleDirc2 = data.EasingStyleDirc or EasingStyleDirc
	local EasingStyle = data.EasingStyle or Enum.EasingStyle.Sine
	local EasingStyle2 = data.EasingStyle2 or EasingStyle
	local size = data.size or 7
	local wai_till_normalFov = data.wai_till_normalFov or tim1
	
	coroutine.wrap(function()
		local blur = script.Effects["Blur"]:Clone()
		blur.Parent = camera
		blur.Size = 0
		
		-- tween
		TS:Create(blur,TweenInfo.new(
			tim1,
			EasingStyle,EasingStyleDirc,
			0,
			false,
			0),
			{Size = size}):Play()
		
		task.wait(wai_till_normalFov)

		TS:Create(blur,TweenInfo.new(
			tim2 or tim1, 
			EasingStyle2,EasingStyleDirc,
			0,
			false,
			0),
			{Size = 0}):Play()
		
		game.Debris:AddItem(blur,tim2 or tim1)
	end)()
end


module.shake = function( data)
	local camera = workspace.Camera or data.camera 
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
		camera.CFrame = camera.CFrame * shakeCFrame
	end)
	
	
	local shake = data.shake or "Bump"
	camShake:Start()
	camShake:Shake(CameraShaker.Presets[shake])
end

module.Fov = function(data)
	coroutine.wrap(function()
		local camera = workspace.Camera or data.camera 
		local start = data.start 
		local retern = data.retern 
		local tim1,tim2 = data.tim1 or .5, data.tim2 
		local EasingStyleDirc = data.EasingStyleDirc or Enum.EasingDirection.Out
		local EasingStyleDirc2 = data.EasingStyleDirc or EasingStyleDirc
		local EasingStyle = data.EasingStyle or Enum.EasingStyle.Sine
		local EasingStyle2 = data.EasingStyle2 or EasingStyle
		local Fov = data.Fov or 70
		local wai_till_normalFov = data.wai_till_normalFov or tim1
		
		-- tween
		if start  then
			TS:Create(camera,TweenInfo.new(
				tim1,
				EasingStyle,EasingStyleDirc,
				0,
				false,
				0),
				{FieldOfView = Fov}):Play()
		end
		
		if retern  then
			task.wait(wai_till_normalFov)

			TS:Create(camera,TweenInfo.new(
				tim2 or tim1, 
				EasingStyle2,EasingStyleDirc,
				0,
				false,
				0),{FieldOfView = 70}):Play()
		end
	end)()
end



function module.Clasic_tween(part, data)
	local Textcolr = data.Textcolr or nil
	local size = data.size or nil
	local tim = data.tim or .3
	local pos = data.pos or nil
	local trans = data.trans or nil
	local cf = data.cf or nil
	local colr = data.colr or nil
	local EasingStyle = data.EasingStyle 
	local EasingDirection = data.EasingDirection 
	local redo = data.redo or false

	if size ~= nil then
		local startSize = data.startSize or part.Size
		part.Size = startSize

		local sizeTim = data.sizeTim 
		local sizeDel = data.sizeDel 

		local Info = TweenInfo.new(
			sizeTim or tim,
			EasingStyle or Enum.EasingStyle.Linear,
			EasingDirection or Enum.EasingDirection.Out,
			0,
			redo,
			sizeDel or 0
		)
		local new = {}
		new.Size = size
		local twee = TS:Create(part, Info, new)
		twee:Play()
		twee:Destroy()
	end

	if trans ~= nil then
		local startTrans = data.startTrans or part.Transparency
		part.Transparency = startTrans

		local transTim = data.transTim 
		local transDel = data.transDel 

		local Info = TweenInfo.new(
			transTim or tim ,
			EasingStyle or Enum.EasingStyle.Linear,
			EasingDirection or Enum.EasingDirection.Out,
			0,
			redo,
			transDel or 0
		)
		local new = {}
		new.Transparency = trans
		local twee = TS:Create(part, Info, new)
		twee:Play()
		twee:Destroy()
	end

	if cf ~= nil then
		local cfTim = data.cfTim 
		local cfDel = data.cfDel 

		local Info = TweenInfo.new(
			cfTim or tim,
			EasingStyle or Enum.EasingStyle.Linear,
			EasingDirection or Enum.EasingDirection.Out,
			0,
			redo,
			cfDel or 0
		)
		local new = {}
		new.CFrame = cf
		local twee = TS:Create(part, Info, new)
		twee:Play()
		twee:Destroy()
	end

	-- pos
	if pos ~= nil then
		local posTim = data.posTim 
		local posDely = data.posDely 

		local Info = TweenInfo.new(
			posTim or tim,
			EasingStyle or Enum.EasingStyle.Linear,
			EasingDirection or Enum.EasingDirection.Out,
			0,
			redo,
			posDely or 0
		)
		local new = {}
		new.Position = pos
		local twee = TS:Create(part, Info, new)
		twee:Play()
		twee:Destroy()
	end

	-- colr
	if colr ~= nil then
		local colrTim = data.colrTim 
		local colrDel = data.colrDel 
		local startColr = data.startColr or part.BrickColor

		part.Color = startColr.Color
		local Info = TweenInfo.new(
			colrTim or tim,
			EasingStyle or Enum.EasingStyle.Linear,
			EasingDirection or Enum.EasingDirection.Out,
			0,
			redo,
			colrDel or 0
		)
		local new = {}
		new.Color = colr.Color
		local twee = TS:Create(part, Info, new)
		twee:Play()
		twee:Destroy()
	end

	-- Textcolr
	if Textcolr ~= nil then
		--Textcolr = Textcolr.Color
		local TextcolrTim = data.TextcolrTim 
		local TextcolrDel = data.TextcolrDel 
		local startTextcolr = data.startTextcolr or part.TextColor3

		part.TextColor3 = startTextcolr
		local Info = TweenInfo.new(
			TextcolrTim or tim,
			EasingStyle or Enum.EasingStyle.Linear,
			EasingDirection or Enum.EasingDirection.Out,
			0,
			redo,
			TextcolrDel or 0
		)
		local new = {}
		new.TextColor3 = Textcolr.Color
		local twee = TS:Create(part, Info, new)
		twee:Play()
		twee:Destroy()
	end
end

return module
