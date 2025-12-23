local events = {
	"Earthquake",
	"Volcano",
	"Lightning",
	"Spot",
	"Beak Rain",
	"Blackhole",
	"Luck4x",
	"Thunderic",
	"AllEvents"
}

return function(registry)
	registry:RegisterType("events",registry.Cmdr.Util.MakeEnumType("events",events))
end
