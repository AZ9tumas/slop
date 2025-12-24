local EggEvolutionInfo = {}

EggEvolutionInfo.Path = {
	"Common Egg",
	"Uncommon Egg",
	"Rare Egg",
	"Epic Egg",
	"Beach Egg",
	"Miner Egg",
	"Kingdom Egg",
	"Nature Egg",
	"Candy Egg",
	"Volcano Egg",
	"Winter Egg",
	"Pumpkin Egg",
	"Wealth Egg",
	"Zombie Egg",
	"Glitched Egg",
	"Space Egg",
	"Secret Egg",
	"Gravity Egg",
}

EggEvolutionInfo.Evolutions = {

	["Common Egg"] = {
		Enabled = true,
		To = "Uncommon Egg",
		OnFail = "Common Egg",

		Time = 5,
		SuccessChance = 0.95,
		Cost = 100,

		ProtectionProductId = nil,
		SkipProductId = 200001,
	},

	["Uncommon Egg"] = {
		Enabled = true,
		To = "Rare Egg",
		OnFail = "Common Egg",

		Time = 15,
		SuccessChance = 0.090,
		Cost = 300,

		ProtectionProductId = 3487625216,
		SkipProductId = 200102,
	},

	["Rare Egg"] = {
		Enabled = true,
		To = "Epic Egg",
		OnFail = "Uncommon Egg",

		Time = 45,
		SuccessChance = 0.85,
		Cost = 900,

		ProtectionProductId = 3487625467,
		SkipProductId = 200202,
	},

	["Epic Egg"] = {
		Enabled = true,
		To = "Beach Egg",
		OnFail = "Rare Egg",

		Time = 120,
		SuccessChance = 0.80,
		Cost = 2500,

		ProtectionProductId = 3487626814,
		SkipProductId = 200302,
	},

	["Beach Egg"] = {
		Enabled = true,
		To = "Miner Egg",
		OnFail = "Epic Egg",

		Time = 300,
		SuccessChance = 0.75,
		Cost = 8000,

		ProtectionProductId = 3487626990,
		SkipProductId = 200402,
	},

	["Miner Egg"] = {
		Enabled = true,
		To = "Kingdom Egg",
		OnFail = "Beach Egg",

		Time = 900,
		SuccessChance = 0.70,
		Cost = 20000,

		ProtectionProductId = 3487627166,
		SkipProductId = 200502,
	},

	["Kingdom Egg"] = {
		Enabled = true,
		To = "Nature Egg",
		OnFail = "Miner Egg",

		Time = 1800,
		SuccessChance = 0.65,
		Cost = 50000,

		ProtectionProductId = 3487627392,
		SkipProductId = 200602,
	},

	["Nature Egg"] = {
		Enabled = true,
		To = "Candy Egg",
		OnFail = "Kingdom Egg",

		Time = 3600,
		SuccessChance = 0.60,
		Cost = 120000,

		ProtectionProductId = 3487627566,
		SkipProductId = 200702,
	},

	["Candy Egg"] = {
		Enabled = true,
		To = "Volcano Egg",
		OnFail = "Nature Egg",

		Time = 7200,
		SuccessChance = 0.55,
		Cost = 300000,

		ProtectionProductId = 3487627846,
		SkipProductId = 200802,
	},

	["Volcano Egg"] = {
		Enabled = true,
		To = "Winter Egg",
		OnFail = "Candy Egg",

		Time = 14400,
		SuccessChance = 0.50,
		Cost = 750000,

		ProtectionProductId = 3487628051,
		SkipProductId = 200902,
	},

	["Winter Egg"] = {
		Enabled = true,
		To = "Pumpkin Egg",
		OnFail = "Volcano Egg",

		Time = 21600,
		SuccessChance = 0.45,
		Cost = 1500000,

		ProtectionProductId = 3487628201,
		SkipProductId = 201002,
	},

	["Pumpkin Egg"] = {
		Enabled = true,
		To = "Wealth Egg",
		OnFail = "Winter Egg",

		Time = 28800,
		SuccessChance = 0.40,
		Cost = 5000000,

		ProtectionProductId = 3487628367,
		SkipProductId = 201102,
	},

	["Wealth Egg"] = {
		Enabled = true,
		To = "Zombie Egg",
		OnFail = "Pumpkin Egg",

		Time = 36000,
		SuccessChance = 0.35,
		Cost = 20000000,

		ProtectionProductId = 201201,
		SkipProductId = 201202,
	},

	["Zombie Egg"] = {
		Enabled = true,
		To = "Glitched Egg",
		OnFail = "Wealth Egg",

		Time = 43200,
		SuccessChance = 0.30,
		Cost = 50000000,

		ProtectionProductId = 3487628558,
		SkipProductId = 201302,
	},

	["Glitched Egg"] = {
		Enabled = true,
		To = "Space Egg",
		OnFail = "Zombie Egg",

		Time = 54000,
		SuccessChance = 0.30,
		Cost = 150000000,

		ProtectionProductId = 3487628825,
		SkipProductId = 201402,
	},

	["Space Egg"] = {
		Enabled = false,
		To = "Secret Egg",
		OnFail = "Glitched Egg",

		Time = 72000,
		SuccessChance = 0.30,
		Cost = 500000000,

		ProtectionProductId = 201501,
		SkipProductId = 201502,
	},

	["Secret Egg"] = {
		Enabled = false,          -- 🔒 disabled by default
		To = "Gravity Egg",
		OnFail = "Space Egg",

		Time = 86400,
		SuccessChance = 0.25,
		Cost = 1000000000,

		ProtectionProductId = 201601,
		SkipProductId = 201602,
	},

	["Gravity Egg"] = {
		Enabled = false,          -- 🔒 terminal / event-only
		To = nil,
		OnFail = "Secret Egg",

		Time = 0,
		SuccessChance = 1,
		Cost = 0,

		ProtectionProductId = nil,
		SkipProductId = nil,
	},
}


function EggEvolutionInfo.GetEvolutionDetails(currentEggName)
	if not currentEggName then warn("Invalid egg.") end
	local data = EggEvolutionInfo.Evolutions[currentEggName]

	if not data or not data.Enabled or not data.To then
		return nil
	end

	return {
		CurrentEgg = currentEggName,
		NextEgg = data.To,
		FailEgg = data.OnFail,

		Cost = data.Cost,
		Time = data.Time,

		SuccessChance = data.SuccessChance,
		FailChance = 1 - data.SuccessChance,

		ProtectionProductId = data.ProtectionProductId,
		SkipProductId = data.SkipProductId
	}
end

function EggEvolutionInfo.Evolve(currentEggName)
	local details = EggEvolutionInfo.GetEvolutionDetails(currentEggName)

	if not details then
		warn("Cannot evolve egg:", currentEggName)
		return currentEggName, false
	end

	local roll = math.random() -- [0, 1)

	if roll <= details.SuccessChance then
		return details.NextEgg, true
	else
		return details.FailEgg, false
	end
end

return EggEvolutionInfo