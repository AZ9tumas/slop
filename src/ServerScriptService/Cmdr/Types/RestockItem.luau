local restockItems = {
	"Slap",
	"Speed Coil",
	"Volcanic Spray",
	"Shock Spray",
	"Luck Spray",
	"Size Spray"
}

return function(registry)
	registry:RegisterType("restockItems",registry.Cmdr.Util.MakeEnumType("RestockItems",restockItems))
end
