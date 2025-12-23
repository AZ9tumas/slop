-- OfflineCollection.lua
local OfflineCollection = {
	-- default values you can tweak
	Cycle = 125,         -- secs
	MaxOfflineTime = 60 * 60 * 12, -- max
	Scaling = 0.004,          -- cut
}
OfflineCollection.MaxCycles = math.floor(OfflineCollection.MaxOfflineTime / OfflineCollection.Cycle)

-- returns number of full cycles (0..MaxCycles) since lastLeaveTime
function OfflineCollection:GetOfflineCycles(lastLeaveTime)
	if not lastLeaveTime then
		return 0
	end

	local currentTime = os.time()
	local offlineSeconds = currentTime - lastLeaveTime

	-- clamp to maximum allowed
	if offlineSeconds <= 0 then
		return 0
	end
	if offlineSeconds > self.MaxOfflineTime then
		offlineSeconds = self.MaxOfflineTime
	end

	local cycles = math.floor(offlineSeconds / self.Cycle)
	if cycles < 0 then cycles = 0 end
	if cycles > self.MaxCycles then cycles = self.MaxCycles end
	return cycles
end

-- compute total earnings for `cycles` cycles for a pigeon
-- info = pigeon info table (should contain .Multiplier), weight = pigeon.Weight (rolled)
function OfflineCollection:GetEarnings(info, weight, cycles)
	if not info or cycles <= 0 then
		return 0
	end
	local multiplier = info.Multiplier or 1
	local w = (weight or 1)
	-- production per second would be multiplier * weight
	-- production per cycle (Cycle seconds) = multiplier * weight * Cycle
	-- offline award uses Scaling percent of that per cycle
	local perCycle = multiplier * w * self.Cycle * self.Scaling
	return perCycle * cycles
end

return OfflineCollection
