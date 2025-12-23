while wait(7 * 60, 15 * 60) do
    local RandomPile = math.random(1, 8)
    local Pile = game.ReplicatedStorage.Game.EventVFX.Piles[RandomPile]:Clone()
    Pile.Parent = workspace
    game.ReplicatedStorage.Remotes.Notification:FireAllClients("A treasure has been spawned on the map!")
    task.delay(60, function()
        if Pile then
            Pile:Destroy()
        end
    end)
end