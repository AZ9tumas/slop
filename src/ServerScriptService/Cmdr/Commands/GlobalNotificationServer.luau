local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")

return function(context, message: string)
	MessagingService:PublishAsync("GlobalMessage", message)
	return "Message sent globally successfully"
end
