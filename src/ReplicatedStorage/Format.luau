local ReplicatedStorage = game:GetService("ReplicatedStorage")

local formatNumber = require(ReplicatedStorage.Modules.FormatNumber.Main)
local formatterUnder10k
local formatterOver10k
local formatFullNumber
local priceFormatA

local abreviations = formatNumber.Notation.compactWithSuffixThousands({ -- Up to 36 digits
    "K", "M", "B", "T", "Q", "QQ", "Sx", "Sp", "Oc", "No", "Dc", 
    "UDc", "DDc", "TDc", "Qa", "QQa", "Sx", "Sp", "Oc", "No", "Vg", 
    "UVg", "DVg", "TVg", "Qg", "QQg", "Sg", "Sp", "Og", "Ng", "Tg", 
    "Qn", "QQn", "Sn", "Sp", "On", "Nn", "Ct", "Uct",
})

formatterUnder10k = formatNumber.NumberFormatter.with()--:Notation(abreviations)
:Precision(formatNumber.Precision.minMaxFraction(0,0))

formatterOver10k = formatNumber.NumberFormatter.with():Notation(abreviations)
:Precision(formatNumber.Precision.minMaxFraction(0,2))

priceFormatA = formatNumber.NumberFormatter.with()--:Notation(abreviations)
:Precision(formatNumber.Precision.minMaxFraction(0,0))

formatFullNumber = formatNumber.NumberFormatter.with()--:Notation(abreviations)
:Precision(formatNumber.Precision.minMaxFraction(0,999))

local Format = {}

function Format:GetFullAmount(amount)
	return formatFullNumber:Format(amount)
end

function Format:GetProductDisplayAmount(amount)
	return formatterOver10k:Format(amount) 
end

function Format:GetDisplayAmount(amount)
    amount = tonumber(amount)
	if amount < 10000 then
		return formatterUnder10k:Format(amount)
	else
		return formatterOver10k:Format(amount)
	end
end

function Format:GetButtonPrice(amount)
	amount = tonumber(amount)
	if amount < 1000 then
		return formatterUnder10k:Format(amount)
	else
		return formatterOver10k:Format(amount)
	end
end

function Format:GetMoneyStr(amount)
	amount = tonumber(amount)
	if amount < 1000 then
		return formatterUnder10k:Format(amount)
	else
		return formatterOver10k:Format(amount)
	end
end


function Format:GetPriceDisplayAmount(amount)
	return priceFormatA:Format(amount)
end

return Format