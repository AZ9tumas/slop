local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DISTANCE_FROM_CAMERA = 1.3
local X_PARTICLES = 6
local Y_PARTICLES = 4

local currentCamera = workspace.CurrentCamera

local function getDividedSegment(size: number, totalSegments: number, segment: number)
	return -size/2 + (size / (totalSegments - 1)) * (segment - 1)
end

local ParticleBorder = {}

-- Utility: manual cleanup container
local function createCleanup()
	local cleanup = {
		connections = {},
		instances = {},
		destroyed = false,
	}

	function cleanup:TrackInstance(inst)
		table.insert(self.instances, inst)
	end

	function cleanup:TrackConnection(conn)
		table.insert(self.connections, conn)
	end

	function cleanup:Destroy()
		if self.destroyed then return end
		self.destroyed = true

		for _, conn in ipairs(self.connections) do
			if conn.Connected then
				conn:Disconnect()
			end
		end

		for _, inst in ipairs(self.instances) do
			if inst and inst.Parent then
				inst:Destroy()
			end
		end
	end

	return cleanup
end

function ParticleBorder.create(particleFolder: Folder, duration: number, overlaySizeMultiplier: number)
	local cleanup = createCleanup()

	local overlay = Instance.new("Part")
	overlay.Name = "ParticleBorder"
	overlay.Transparency = 1
	overlay.CanCollide = false
	overlay.CanTouch = false
	overlay.CanQuery = false
	overlay.CastShadow = false
	overlay.Parent = currentCamera
	cleanup:TrackInstance(overlay)

	local particleFolderChildren = particleFolder:GetChildren()
	local particles = {}
	local attachments = {}

	for _ = 1, X_PARTICLES*2 + (Y_PARTICLES-2)*2 do
		local attachment = Instance.new("Attachment")

		for _, emitter in ipairs(particleFolderChildren) do
			if emitter:IsA("ParticleEmitter") then
				local clone = emitter:Clone()
				clone.Enabled = true
				clone.LockedToPart = true
				clone.Parent = attachment
				table.insert(particles, clone)
			end
		end

		attachment.Parent = overlay
		table.insert(attachments, attachment)
	end

	overlaySizeMultiplier = overlaySizeMultiplier or 1
	local overlayHeight = 1.5
	local increase = overlayHeight * (overlaySizeMultiplier - 1)

	local function updateOverlay()
		if cleanup.destroyed then return end

		local viewportSize = currentCamera.ViewportSize
		local overlaySize = Vector3.new(
			overlayHeight * (viewportSize.X / viewportSize.Y) + increase,
			overlayHeight + increase,
			0.2
		)

		overlay.Size = overlaySize
		overlay.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -DISTANCE_FROM_CAMERA)

		local idx = 0

		for i = 1, X_PARTICLES do
			idx += 1
			attachments[idx].CFrame =
				CFrame.lookAt(Vector3.new(getDividedSegment(overlaySize.X, X_PARTICLES, i), overlaySize.Y/2, 0), Vector3.zero)
		end

		for i = 1, X_PARTICLES do
			idx += 1
			attachments[idx].CFrame =
				CFrame.lookAt(Vector3.new(getDividedSegment(overlaySize.X, X_PARTICLES, i), -overlaySize.Y/2, 0), Vector3.zero)
		end

		for i = 2, Y_PARTICLES-1 do
			idx += 1
			attachments[idx].CFrame =
				CFrame.lookAt(Vector3.new(overlaySize.X/2, getDividedSegment(overlaySize.Y, Y_PARTICLES, i), 0), Vector3.zero)
		end

		for i = 2, Y_PARTICLES-1 do
			idx += 1
			attachments[idx].CFrame =
				CFrame.lookAt(Vector3.new(-overlaySize.X/2, getDividedSegment(overlaySize.Y, Y_PARTICLES, i), 0), Vector3.zero)
		end
	end

	updateOverlay()
	cleanup:TrackConnection(RunService.RenderStepped:Connect(updateOverlay))

	-- Compute max lifetime
	local highestLifetime = 0
	for _, emitter in ipairs(particleFolderChildren) do
		if emitter:IsA("ParticleEmitter") then
			highestLifetime = math.max(highestLifetime, emitter.Lifetime.Max)
		end
	end

	duration = duration or 1
	task.delay(duration, function()
		if cleanup.destroyed then return end

		for _, p in ipairs(particles) do
			p.Enabled = false
		end

		task.wait(highestLifetime)
		cleanup:Destroy()
	end)

	return cleanup
end

function ParticleBorder.createFromTop(particleFolder: Folder, duration: number, overlaySizeMultiplier: number)
	local cleanup = createCleanup()

	local overlay = Instance.new("Part")
	overlay.Name = "ParticleBorder"
	overlay.Transparency = 1
	overlay.CanCollide = false
	overlay.CanTouch = false
	overlay.CanQuery = false
	overlay.CastShadow = false
	overlay.Parent = currentCamera
	cleanup:TrackInstance(overlay)

	local particleFolderChildren = particleFolder:GetChildren()
	local particles = {}
	local attachments = {}

	for _ = 1, X_PARTICLES do
		local attachment = Instance.new("Attachment")

		for _, emitter in ipairs(particleFolderChildren) do
			if emitter:IsA("ParticleEmitter") then
				local clone = emitter:Clone()
				clone.Enabled = true
				clone.LockedToPart = true
				clone.Parent = attachment
				table.insert(particles, clone)
			end
		end

		attachment.Parent = overlay
		table.insert(attachments, attachment)
	end

	overlaySizeMultiplier = overlaySizeMultiplier or 1
	local overlayHeight = 1.5
	local increase = overlayHeight * (overlaySizeMultiplier - 1)

	local function updateOverlay()
		if cleanup.destroyed then return end

		local viewportSize = currentCamera.ViewportSize
		local overlaySize = Vector3.new(
			overlayHeight * (viewportSize.X / viewportSize.Y) + increase,
			overlayHeight + increase,
			0.2
		)

		overlay.Size = overlaySize
		overlay.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -DISTANCE_FROM_CAMERA)

		for i = 1, X_PARTICLES do
			attachments[i].CFrame =
				CFrame.lookAt(
					Vector3.new(getDividedSegment(overlaySize.X, X_PARTICLES, i), overlaySize.Y / 2, 0),
					Vector3.zero
				)
		end
	end

	updateOverlay()
	cleanup:TrackConnection(RunService.RenderStepped:Connect(updateOverlay))

	-- lifetime handling
	local highestLifetime = 0
	for _, emitter in ipairs(particleFolderChildren) do
		if emitter:IsA("ParticleEmitter") then
			highestLifetime = math.max(highestLifetime, emitter.Lifetime.Max)
		end
	end

	duration = duration or 1
	task.delay(duration, function()
		if cleanup.destroyed then return end

		for _, p in ipairs(particles) do
			p.Enabled = false
		end

		task.wait(highestLifetime)
		cleanup:Destroy()
	end)

	return cleanup
end


return ParticleBorder
