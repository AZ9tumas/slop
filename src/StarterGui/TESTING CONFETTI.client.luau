local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ParticleBorder = require(ReplicatedStorage:WaitForChild("ParticleBorder"))

wait(3)
print('ok now')
local confettiFolder = ReplicatedStorage.Particles.Confetti

ParticleBorder.createFromTop(
	confettiFolder,
	3,    -- seconds of emission
	1.3   -- screen coverage multiplier
)
