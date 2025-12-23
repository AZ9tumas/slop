-- SERVICES
local ts = game:GetService("TweenService")


-- FUNCTIONS

local function replace(str,remove,place)
	if string.find(str,remove) then
		local split = string.split(str,remove)
		return split[1]..place..split[2]
	end
end

function format(str)
	for match in str:gmatch("{(.-)}") do

		local symbols = {}
		local startfrom = 1

		while match:find("[.]", startfrom) do
			local spos = match:find("[.]", startfrom)
			local epos = match:find("[.]", spos+1)
			if not epos then epos = match:find("[:]", spos+1)
				if not epos then epos = match:find("}", spos+1)
				end end

			if not epos then break
			else epos -= 1 end

			table.insert(symbols, {symbol=".", spos=spos, epos=epos, key=string.sub(match,spos+1,epos)})
			startfrom = epos+1
		end

		if #symbols > 0 then
			table.sort(symbols, function(a, b) return a.spos < b.spos end)

			local first = symbols[1]
			table.insert(symbols, {symbol="start", spos=1, epos=first.spos-1, key=string.sub(match,1,first.spos-1)})
			table.sort(symbols, function(a, b) return a.spos < b.spos end)
		else
			table.insert(symbols, {symbol="start", spos=1, epos=#match, key=match})
		end


		local val
		for i,v in pairs(symbols) do
			if v.symbol == "start" then
				local function c(s,t) if v.key == s then val = t end end
				c("game",game)
				c("workspace",workspace)
			elseif v.symbol == "." then 
				val = val[v.key]
			end
		end

		local sp = string.split(str,"{"..match.."}")
		if type(val) ~= "string" then val = tostring(val) end
		str = sp[1]..val..sp[2]

	end
	return str
end

local function psound(sound,stoptime)
	spawn(function()
		local s = sound:Clone()
		s.Parent = game:GetService("SoundService")
		s:Play()
		if tonumber(stoptime) then
			wait(stoptime-0.02)
			s:Destroy()
		else
			s.Ended:Wait()
			s:Destroy()
		end
	end)
end

local function RGBToHex(s)
	local function c(a) return math.clamp(a,0,255) end
	return string.format("#%02X%02X%02X", c(s[1]), c(s[2]), c(s[3]))
end

local function synctrans(t,labelarg,stcolor,mes)
	local rc = 0
	repeat 
		rc += 0.005 wait(0.005)
		labelarg.Text = '<stroke thickness="3" transparency="'..labelarg.TextTransparency..'" color="'..tostring(stcolor)..'">'..mes..'</stroke>'
	until rc > t
end


-- MODULE

local module = {}
module.Pop = {}

module.TransitionIn = {Fade = "Fade", Drop = "Drop", Typewriter = "Typewriter"}
module.TransitionOut = {Fade = "Fade", Shrink = "Shrink", Erase = "Erase"}


local mainTransIn,mainTransOut
local setTransCon

function module:SetDefaultTransition(TransitionIn, TransitionOut)

	if (not game.Players.LocalPlayer) then

		script.SetDefaultTransition:FireAllClients(TransitionIn,TransitionOut)
		if setTransCon then setTransCon:Disconnect() end

		setTransCon = game.Players.PlayerAdded:Connect(function(plr)
			script.SetDefaultTransition:FireClient(plr,TransitionIn,TransitionOut)
		end)

	end

	if module.TransitionIn[TransitionIn] then mainTransIn = TransitionIn
	else warn("Couldn't set default transition in: "..TransitionIn) end

	if module.TransitionOut[TransitionOut] then mainTransOut = TransitionOut
	else warn("Couldn't set default transition out: "..TransitionOut) end

end


function module.Pop.SelectedPlayers(Players,Message:string,Color:Color3,Duration:number,Transition:any,Properties:any)
	for _, plr:Player in pairs(Players) do
		script.PopUpEvent:FireClient(plr,Message,Color,Duration,Transition,Properties)
	end
end

function module.Pop.ExceptPlayers(Players,Message:string,Color:Color3,Duration:number,Transition:any,Properties:any)
	for i,plr in pairs(game.Players:GetChildren()) do
		if (not table.find(Players,plr)) then
			script.PopUpEvent:FireClient(plr,Message,Color,Duration,Transition,Properties)
		end
	end
end

function module.Pop.SelectedTeam(Team:Team,Message:string,Color:Color3,Duration:number,Transition:any,Properties:any)
	if Team then
		for i,plr in pairs(game.Players:GetChildren()) do
			if plr.Team == Team then
				script.PopUpEvent:FireClient(plr,Message,Color,Duration,Transition,Properties)
			end
		end
	else
		warn('Team not found!')
	end
end

function module.Pop.ExceptTeam(Team:Team,Message:string,Color:Color3,Duration:number,Transition:any,Properties:any)
	if Team then
		for i,plr in pairs(game.Players:GetChildren()) do
			if plr.Team ~= Team then
				script.PopUpEvent:FireClient(plr,Message,Color,Duration,Transition,Properties)
			end
		end
	else
		warn('Team not found!')
	end
end

function module.Pop.Everyone(Message:string,Color:Color3,Duration:number,Transition:any,Properties:any)
	script.PopUpEvent:FireAllClients(Message,Color,Duration,Transition,Properties)
end
local currentPersistentPopup

function module.Pop.Local(Message:string,Color:Color3,Duration:number,Transition:any,Properties:any)

	coroutine.wrap(function()

		local notvalid = 'A PopUp Function argument is not valid.'

		if type(Message) ~= "string" then return warn(notvalid) end
		if type(Color) ~= "userdata" then return warn(notvalid) end
		if type(Duration) ~= "number" then return warn(notvalid) end
		if type(Properties) ~= "table" and Properties then return warn(notvalid) end
		if Transition and type(Transition) ~= "table" then
			return warn('"Transition" needs to be a table including transition in and out types.')
		end

		local transin = (Transition and Transition[1]) or mainTransIn
		local transout = (Transition and Transition[2]) or mainTransOut

		if type(transin) ~= "string" then return warn('Transition in type not found.') end
		if type(transout) ~= "string" then return warn('Transition out type not found.') end


		local plr = game.Players.LocalPlayer

		local runloc = string.match(debug.traceback(),"%S+%s+%S+%s+%S+%s+(.+)")
		if not plr then return warn('"'..runloc..'" This function is a Client-Side function!') end

		local pgui = plr.PlayerGui:FindFirstChild("PopUpGui")
		if not pgui then warn('Gui not found. Rename gui as "PopUpGui" and place it in "StarterGui".') return end	

		local p = pgui.PopUps

		local def = pgui.Defaults
		local maxcount = def:GetAttribute("1_MaxPopUps")
		local reverse = def:GetAttribute("0_ReverseDirection")

		local child = p:GetChildren()
		local count = #child - 3

		Message = format(Message)

		local brs,findbr = {},0
		local function br()
			local spos,epos = string.find(Message,"<br/>",findbr+1)
			if epos then
				findbr = epos
				table.insert(brs,{startp=spos,endp=epos})
				br()
			else
				return
			end
		end	br()

		table.sort(brs, function(a, b) return a.startp < b.endp end)

		local frame = p.cloneframe:Clone()
		currentPersistentPopup = frame
		frame.Name = "Sort_"..tick()
		if maxcount == 0 then
			frame.Parent = p
		else
			if count < maxcount then
				frame.Parent = p
			else
				frame.Parent = p.waitlist
				wait(.05)
				frame.Changed:Wait()
			end
		end

		frame.Locate.Enabled = true

		local label = frame.TextLabel

		local stenabled = def:GetAttribute("S_EnableStroke")
		local sthick = def:GetAttribute("S_StrokeThickness")
		local stcolor = {Color.R*160-80, Color.G*160-80, Color.B*160-80}

		local grad,gcolor,nosound = nil,nil,true
		if Properties then
			for i,prop in pairs(Properties) do

				if i == "Font" then
					if type(prop) ~= "userdata" then return warn('Use Enum.Font to specify "Font"') end
					label.Font = prop

				elseif i == "StrokeColor" then 
					if type(prop) ~= "userdata" then return warn('Use Color3 to specify "StrokeColor"') end
					stcolor = {prop.R*255,prop.G*255,prop.B*255}

				elseif i == "Gradient" then 
					if type(prop) ~= "table" then return warn('"Gradient" needs to be a table including "Color" and "Rotation"') end
					if not prop.Color or not prop.Rotation then return warn('Specify "Color" and "Rotation" when using "Gradient"') end
					if type(prop.Color) ~= "userdata" then return warn('Use Color3 to specify "Color"') end
					if type(prop.Rotation) ~= "number" then return warn('Use number to specify "Rotation"') end
					grad = Instance.new("UIGradient",label)
					grad.Color, grad.Rotation = prop.Color, prop.Rotation

				elseif i == "Sound" then
					if type(prop) ~= "userdata" then return warn('"Sound" needs to be a sound. Not id or another thing.') end
					psound(prop,nil) nosound = false
				end

			end	
		end
		if def:GetAttribute("G_UseGradientByDefault") and (not Properties or (not Properties["Gradient"])) then
			grad = Instance.new("UIGradient",label)
			grad.Color, grad.Rotation = def:GetAttribute("G_GradientColor"), def:GetAttribute("G_GradientRotation")
		end
		
		if grad then gcolor = grad.Color end

		local rawtext = string.gsub(Message, "<br/>", " ")

		stcolor = RGBToHex(stcolor)
		label.TextColor3 = Color

		frame.Size = frame.Size+UDim2.new(0,0,#brs*(label.LineHeight),0)

		frame.TransIn.Value = transin

		local function creategrad(lines)
			if grad then
				if lines >= 1 then
					local keys = {}
					for _, keypoint in ipairs(gcolor.Keypoints) do
						table.insert(keys, {
							Time = keypoint.Time,
							Color = keypoint.Value
						})
					end
					table.sort(keys, function(a, b) return a.Time < b.Time end)

					local newkeys = {}
					for i=1, lines do
						local tchange = (i-1)/lines
						for l,v in pairs(keys) do
							local midtime
							if v.Time < 0.5 then midtime = 0.001
							elseif v.Time > 0.5 then midtime = -0.001
							elseif v.Time == 0.5 then midtime = 0 end

							table.insert(newkeys, {
								Time = (v.Time/lines)+tchange+midtime,
								Value = 	v.Color				
							})					
						end
					end	

					table.sort(newkeys, function(a, b) return a.Time < b.Time end)
					table.remove(newkeys,1) table.remove(newkeys,#newkeys)
					table.insert(newkeys,{Time=0, Value=keys[1].Color})
					table.insert(newkeys,{Time=1, Value=keys[#keys].Color})
					table.sort(newkeys, function(a, b) return a.Time < b.Time end)

					local newpoints = {}
					for i,v in pairs(newkeys) do
						table.insert(newpoints, ColorSequenceKeypoint.new(v.Time,v.Value))
					end
					local success, newseq = pcall(function()
						return ColorSequence.new(newpoints)
					end)
					if success then grad.Color = newseq
					else grad.Color = gcolor end
				end
			end
		end


		if def:GetAttribute("P_PlaySound") and nosound then
			local playid = def:GetAttribute("P_SoundId")
			if playid ~= 0 then
				coroutine.wrap(function()
					local playsound = Instance.new("Sound",game.SoundService)
					playsound.Volume = def:GetAttribute("P_SoundVolume")
					playsound.SoundId = "rbxassetid://"..playid
					playsound:Play()
					playsound.Ended:Wait()
					playsound:Remove()
				end)()
			end
		end


		if transin == "Fade" then
			label.TextTransparency = 1
			label.Position = UDim2.new(0.5,0,0.3,0)

			local info = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
			local newpos = UDim2.new(0.5, 0, 0, 0)

			if stenabled then
				label.Text = '<stroke thickness="'..sthick..'" transparency="1" color="'..tostring(stcolor)..'">'..Message..'</stroke>'
				coroutine.wrap(function() synctrans(info.Time,label,stcolor,Message) end)()	
			else
				label.Text = Message
			end

			local fadein = ts:Create(label, info, {TextTransparency = 0, Position = newpos})		

			fadein:Play()


		elseif transin == "Drop" then
			if stenabled then
				label.Text = '<stroke thickness="'..sthick..'" color="'..tostring(stcolor)..'">'..Message..'</stroke>'
			else
				label.Text = Message
			end
			label.Size = UDim2.new(1.5,0,1.5,0)
			label.Position = UDim2.new(0.5,0,-0.25,0)

			local info = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
			local info2 = TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.In)

			local newpos = UDim2.new(0.5, 0, 0, 0)

			local fadein = ts:Create(label, info, {Size = UDim2.new(1,0,1,0), Position = UDim2.new(0.5,0,0,0)})		

			fadein:Play()


		elseif transin == "Typewriter" then
			label.Text = ""
			local lenmp = 0.75+(5/(#Message-#brs*5))
			local brscopy = table.clone(brs)

			local write,lines = "",1
			coroutine.wrap(function()
				local function w(new)
					local function c(p) for i,p2 in pairs(p) do if new == p2 then return true else return false end end end
					local waitt
					if c({" "}) then waitt = 0.05*lenmp
					elseif c({","}) then waitt = 0.28*lenmp
					elseif c({";",":"}) then waitt = 0.32*lenmp
					elseif c({".","!"}) then waitt = 0.5*lenmp
					elseif c({"?"}) then waitt = 0.6*lenmp
					elseif tonumber(new) then waitt = 0.05*lenmp
					else waitt = 0.07*lenmp end
					wait(waitt) return waitt
				end
				for i=1, #Message do
					local newadded = string.sub(Message,i,i)

					local waitt = 0
					if #brscopy > 0 then
						if i == brscopy[1].startp then
							write = write.."<br/>"
							lines += 1

							creategrad(lines)

						elseif i > brscopy[1].startp and i < brscopy[1].endp then
						elseif i == brscopy[1].endp then table.remove(brscopy,1)
						else 
							write = write..newadded
							if stenabled then
								label.Text = '<stroke thickness="'..sthick..'" color="'..tostring(stcolor)..'">'..write..'</stroke>'
							else
								label.Text = write
							end
							waitt = w(newadded)
							psound(pgui.TypewriterSound,nil)
						end
					else
						write = write..newadded
						if stenabled then
							label.Text = '<stroke thickness="'..sthick..'" color="'..tostring(stcolor)..'">'..write..'</stroke>'
						else
							label.Text = write
						end
						waitt = w(newadded)
						psound(pgui.TypewriterSound,nil)
					end	
				end	
			end)()
		end


		if transout == "Fade" then
			local info = TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
			local fadeout = ts:Create(label, info, {TextTransparency = 1})

			wait(Duration-(info.Time))
			fadeout:Play()
			if stenabled then coroutine.wrap(function() synctrans(info.Time,label,stcolor,Message) end)() end


			wait(info.Time)


		elseif transout == "Shrink" then
			local info = TweenInfo.new(.25,Enum.EasingStyle.Sine,Enum.EasingDirection.In)
			local shrink = ts:Create(label, info, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0), Rotation=math.random(-10,10)})		

			wait(Duration-0.23)
			shrink:Play()
			wait(.23)


		elseif transout == "Erase" then

			wait(Duration-(#Message-(#brs*5))*0.02)

			local lines = #brs+1
			local function eraseAnimation(str)
				local len = string.len(str)
				local tagLen = string.len("<br/>")
				local subStr = string.sub(str, 1, len - 1)
				local tagSubStr = string.sub(str, 1, len - tagLen)

				if string.sub(str, len - tagLen + 1, len) == "<br/>" then
					lines-=1
					Message = tagSubStr
					creategrad(lines)
				else
					Message = subStr
				end

				if stenabled then
					label.Text = '<stroke thickness="'..sthick..'" color="'..tostring(stcolor)..'">'..Message..'</stroke>'
				else
					label.Text = Message
				end

				if len > 0 then
					wait(0.02)
					eraseAnimation(Message)
				end
			end

			eraseAnimation(Message)


		end

		frame:Remove()	

	end)()

end

-- Store reference to the current persistent popup

function module.Pop.LocalPersistent(Message:string, Color:Color3, Transition:any, Properties:any)
	coroutine.wrap(function()
		if type(Message) ~= "string" then return warn("Message must be a string.") end
		if Properties and type(Properties) ~= "table" then return warn("Properties must be a table.") end

		local plr = game.Players.LocalPlayer
		if not plr then return warn("This function is client-side only!") end

		local pgui = plr.PlayerGui:FindFirstChild("PopUpGui")
		if not pgui then return warn('Gui not found. Rename gui as "PopUpGui" and place it in "StarterGui".') end
		local p = pgui.PopUps
		local def = pgui.Defaults
		local stenabled = def:GetAttribute("S_EnableStroke")
		local sthick = def:GetAttribute("S_StrokeThickness")

		-- Remove previous persistent popup
		if currentPersistentPopup and currentPersistentPopup.Parent then
			local fadeOut = ts:Create(currentPersistentPopup.TextLabel, TweenInfo.new(0.25), {TextTransparency = 1})
			fadeOut:Play()
			wait(0.25)
			currentPersistentPopup:Destroy()
		end

		-- Clone new popup frame
		local frame = p.cloneframe:Clone()
		frame.Name = "Persistent_" .. tick()
		frame.Parent = p
		local label = frame.TextLabel
		label.TextColor3 = Color

		-- Apply transitions, gradients, sounds, etc. (same as Local)
		-- Example: FadeIn
		local transin = (Transition and Transition[1]) or mainTransIn
		local transout = (Transition and Transition[2]) or mainTransOut

		if transin == "Fade" then
			label.TextTransparency = 1
			local fadein = ts:Create(label, TweenInfo.new(0.2), {TextTransparency = 0})
			fadein:Play()
		elseif transin == "Drop" then
			label.Position = UDim2.new(0.5,0,-0.25,0)
			label.Size = UDim2.new(1.5,0,1.5,0)
			ts:Create(label, TweenInfo.new(0.2), {Size=UDim2.new(1,0,1,0), Position=UDim2.new(0.5,0,0,0)}):Play()
		elseif transin == "Typewriter" then
			label.Text = ""
			for i = 1, #Message do
				label.Text = string.sub(Message,1,i)
				wait(0.02)
			end
		end

		-- Apply properties (gradients, sounds, etc.)
		if Properties then
			if Properties.Gradient then
				local grad = Instance.new("UIGradient", label)
				grad.Color = Properties.Gradient.Color
				grad.Rotation = Properties.Gradient.Rotation
			end
			if Properties.Sound then
				psound(Properties.Sound)
			end
		end

		-- Store reference for replacement
		currentPersistentPopup = frame

		-- Note: No automatic removal (linger forever)
		-- To remove, call module.Pop.LocalClear()
	end)()
end

-- Clear lingering popup
function module.Pop.LocalClear(FadeOutTime:number)
	if currentPersistentPopup and currentPersistentPopup.Parent then
		FadeOutTime = FadeOutTime or 0.25
		local fadeOut = ts:Create(currentPersistentPopup.TextLabel, TweenInfo.new(FadeOutTime), {TextTransparency = 1})
		fadeOut:Play()
		fadeOut.Completed:Wait()
		currentPersistentPopup:Destroy()
		currentPersistentPopup = nil
	end
end

return module