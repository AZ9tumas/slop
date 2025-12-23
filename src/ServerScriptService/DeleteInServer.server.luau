game.ReplicatedStorage.Remotes.Delete.OnServerInvoke = function(player,toolName)
	
	local character = player.Character
	local tool = character:FindFirstChild(toolName)
	--if tool then
	--	if tool:FindFirstChild("Handle") then
	--		for i,v in pairs(tool.Handle:GetDescendants()) do
	--			if v:IsA("BasePart") then
	--				v.Transparency = 1
	--			end
	--		end
	--	end
	--end
end