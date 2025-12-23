while task.wait() do
	game.ReplicatedStorage.CurrentTime.Value = os.time()
end