-- Beaks.lua
local Beaks = {
	Base = 0.66, -- base beaks per second for all pigeons
}

-- Calculates Beaks/sec for a pigeon
-- pigeonWeight = the rolled/stored weight for this pigeon
-- pigeonInfo   = the info table for this pigeon (from PigeonInfo)
--[[function Beaks:GetBeaksPerSecond(pigeonWeight, pigeonInfo)
	if not pigeonInfo or not pigeonInfo.Weight then
		return 1
	end

	-- Clamp weight within its defined range
	local weight = math.clamp(pigeonWeight, pigeonInfo.Weight.Min, pigeonInfo.Weight.Max)

	local weightRange = pigeonInfo.Weight.Max - pigeonInfo.Weight.Min
	local normalisedWeight = (weight - pigeonInfo.Weight.Min) / (weightRange > 0 and weightRange or 1)

	-- Formula: base * multiplier * (1 + normalisedWeight)
	local beaksPerSecond = self.Base * (pigeonInfo.Multiplier or 1) * (1 + normalisedWeight * 1.1)
	return beaksPerSecond
end]]

function Beaks:GetBeaksPerSecond(pigeonWeight, pigeonInfo, referenceRate)
	if not pigeonInfo or not pigeonInfo.Weight then
		return 1
	end

    if pigeonInfo.RelativeMultiplier then
		local ans = (referenceRate or 0) * (pigeonInfo.RelativeMultiplier / 100)
		print(ans)
        return ans
    end

	local minW = pigeonInfo.Weight.Min
	local maxW = pigeonInfo.Weight.Max
	local mult = pigeonInfo.Multiplier or 1
	local base = self.Base or 1

	-- Clamp within range but store overflow separately
	local weight = math.clamp(pigeonWeight, minW, maxW)
	local weightRange = maxW - minW
	local normalisedWeight = (weight - minW) / (weightRange > 0 and weightRange or 1)

	-- Base curve (same as your old one)
	local weightFactor = 1 + normalisedWeight * 1.1

	-- Add small boost if pigeon is heavier than max
	if pigeonWeight > maxW then
		local overflow = (pigeonWeight - maxW) / maxW
		weightFactor = weightFactor + overflow * 0.3 -- gentle post-max boost
	end

	local beaksPerSecond = base * mult * weightFactor
	return beaksPerSecond
end



return Beaks
