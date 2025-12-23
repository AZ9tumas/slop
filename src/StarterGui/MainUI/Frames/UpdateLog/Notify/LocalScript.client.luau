local ExperienceNotificationService = game:GetService("ExperienceNotificationService")

script.Parent.MouseButton1Click:Connect(function()
	ExperienceNotificationService:PromptOptIn()
end)