return {
	Name = "GlobalNotification",
	Aliases = {"GB"},
	Description = "Send a global message to all servers in the game",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Message",
			Description = "Choose the message you want to send across all servers"
		}
	}
	
}