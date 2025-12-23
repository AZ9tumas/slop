local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService('TextService')

local SOURCE_LOCALE = "en"
local translator = nil

local AnimateUI = {
	Instances = {},
}

local fakeLabel = Instance.new("TextLabel")

local TypingSound = ReplicatedStorage.Sounds.Typing
--[[
local function getTextSize(text: string, fontSize: number, font: Enum.Font, frameSize: Vector2?): Vector2
	if text:find('<font') then
		text = text:gsub('<[^>]+>', '')
	end

	return TextService:GetTextSize(text, fontSize, font, frameSize or Vector2.new(math.huge, math.huge))
end
--]]

function AnimateUI.loadTranslator()
	pcall(function()
		translator = LocalizationService:GetTranslatorForPlayerAsync(Players.LocalPlayer)
	end)
	if not translator then
		pcall(function()
			translator = LocalizationService:GetTranslatorForLocaleAsync(SOURCE_LOCALE)
		end)
	end
end

function AnimateUI.richFilter(text)
	local newText = ""
	local isRichText = false
	for i = 1, string.len(text) do
		local currentCharacter = string.sub(text, i, i)
		if currentCharacter == "<" then
			if isRichText == false then
				isRichText = true
			end
		end
		--
		if isRichText == false then
			newText = newText..currentCharacter
		else
			if currentCharacter == ">" then
				isRichText = false
			end
		end
	end
	return newText
end

function AnimateUI.typeWrite(guiObject, text, delayBetweenChars)
	if guiObject.Text == text then return end -- 23/10 Text already set
	if delayBetweenChars == nil then delayBetweenChars = 0.03 end
	
	local function cancelCurrentTask() -- 23/10
		local currentTask = AnimateUI.Instances[guiObject]
		if currentTask then
			task.cancel(currentTask)
			TypingSound:Stop()
		end
	end
	cancelCurrentTask()
	guiObject.Visible = true
	guiObject.AutoLocalize = false
	--local displayText = UITweening:RichStroke(text)
	local displayText = text
	-- Translate text if possible
	if translator then
		displayText = translator:Translate(guiObject, text)
	end

	-- Replace line break tags so grapheme loop will not miss those characters
	displayText = displayText:gsub("<br%s*/>", "\n")
	displayText:gsub("<[^<>]->", "")

	-- Set translated/modified text on parent
	guiObject.Text = displayText

	local index = 0

	local filteredMessage = AnimateUI.richFilter(displayText)
	local breakText = false
	
	--[[28/12
	coroutine.wrap(function() -- Sound
		for i = 1,string.len(filteredMessage) do
			task.wait(delayBetweenChars)
			--UISounds:Play("Typewriter")
		end
		breakText = true
	end)()
	--]]
	local textThread -- Created so that this can be cancelled
	textThread = task.spawn(function()
		TypingSound:Play()
		
		fakeLabel.Text = displayText
		
		--for first, last in utf8.graphemes(displayText) do
		for i = 1,#filteredMessage do
			if breakText then break end
			index = index + 1
			guiObject.MaxVisibleGraphemes = index
			
			task.wait(delayBetweenChars)
		end
		TypingSound:Stop()
	end)
	AnimateUI.Instances[guiObject] = textThread
end

return AnimateUI