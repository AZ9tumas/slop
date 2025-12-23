return {
	Name = "RestockItem",
	Aliases = {"RI"},
	Description = "Restock an item in the gear shop",
	Group = "Admin",
	Args = {
		{
			Type = "restockItems",
			Name = "Item Name",
			Description = "Name of the Item you want to restock"
		}
	}
	
}