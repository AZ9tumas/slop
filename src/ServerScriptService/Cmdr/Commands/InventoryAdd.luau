return {
	Name = "Inventory",
	Aliases = {"IN"},
	Description = "Add a object to your inventory",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "Player Name",
			Description = "Name of the player"
		},
		{
			Type = "gameItem",
			Name = "Item Name",
			Description = "Name of the item you want to add"
		},
		{
			Type = "number",
			Name = "Amount",
			Description = "Amount of the item you want to add"
		},
	}
	
}