local rarities = {
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Beach",
	"Miner",
	"Kingdom",
    "Nature",
    "Candy",
	"Volcano",
	"Winter",
	"Pumpkin",
    "Zombie",
    "Glitched",
	"Space",
	"Secret"
}

return function(registry)
	warn(rarities)
	registry:RegisterType("rarity",registry.Cmdr.Util.MakeEnumType("rarity",rarities))
end
