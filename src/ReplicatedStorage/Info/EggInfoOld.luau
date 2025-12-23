local Egg = {
	["Common Egg"] = {
		DisplayName = "Common Egg",
		Rarity = "Common",
		Cost = 100,
		HoldDuration = 0.55,
		Pigeons = {
			{ Name = "Pigeon", Weight = 2.6, Chance = 40 },
			{ Name = "Baker Pigeon", Weight = 2.6, Chance = 30 },
			{ Name = "Messenger Pigeon", Weight = 2.7, Chance = 20 },
			{ Name = "Fisher Pigeon", Weight = 2.9, Chance = 10 },
		},
		HatchTime = 10,
	},

	["Uncommon Egg"] = {
		DisplayName = "Uncommon Egg",
		Rarity = "Uncommon",
		Cost = 450,
		HoldDuration = 0.55,
		Pigeons = {
			{ Name = "Artist Pigeon", Weight = 2.55, Chance = 45 },
			{ Name = "Pirate Pigeon", Weight = 2.7, Chance = 30 },
			{ Name = "Skater Pigeon", Weight = 2.8, Chance = 18 },
			{ Name = "Gardener Pigeon", Weight = 3, Chance = 7 },
		},
		HatchTime = 15,
	},

	["Rare Egg"] = {
		DisplayName = "Rare Egg",
		Rarity = "Rare",
		Cost = 975,
		HoldDuration = 0.55,
		Pigeons = {
			{ Name = "Pharaoh Pigeon", Weight = 2.7, Chance = 45 },
			{ Name = "Astronaut Pigeon", Weight = 2.9, Chance = 40 },
			{ Name = "Ninja Pigeon", Weight = 3, Chance = 10 },
			{ Name = "Samurai Pigeon", Weight = 3.1, Chance = 5 },
		},
		HatchTime = 25,
	},

	["Epic Egg"] = {
		DisplayName = "Epic Egg",
		Rarity = "Epic",
		Cost = 4250,
		HoldDuration = 0.55,
		Pigeons = {
			{ Name = "Gladiator Pigeon", Weight = 3.1, Chance = 50 },
			{ Name = "Shadow Pigeon", Weight = 3.3, Chance = 35 },
			{ Name = "Cyberpunk Pigeon", Weight = 3.5, Chance = 15 },
		},
		HatchTime = 75,
	},

	["Beach Egg"] = {
		DisplayName = "Beach Egg",
		Rarity = "Beach",
		Cost = 14500,
		HoldDuration = 0.55,
		Pigeons = {
			{ Name = "Surfer Pigeon", Weight = 3.1, Chance = 50 },
			{ Name = "Lifeguard Pigeon", Weight = 3.3, Chance = 40 },
			{ Name = "Seashell Pigeon", Weight = 3.7, Chance = 10 },
		},
		HatchTime = 125,
	},

	["Miner Egg"] = {
		DisplayName = "Miner Egg",
		Rarity = "Miner",
		Cost = 28000,
		HoldDuration = 0.55,
		HatchSound = "rbxassetid://9125869495",
		HatchVFX = game.ReplicatedStorage.Game.HatchVFX.Rocks,
		Pigeons = {
			{ Name = "Miner Pigeon", Weight = 3.2, Chance = 50 },
			{ Name = "Minecart Pigeon", Weight = 3.4, Chance = 40 },
			{ Name = "Crystal Pigeon", Weight = 3.9, Chance = 10 },
		},
		HatchTime = 210,
	},

	["Kingdom Egg"] = {
		DisplayName = "Kingdom Egg",
		Rarity = "Kingdom",
		Cost = 50000,
		HoldDuration = 0.6,
		HatchSound = "rbxassetid://2789429097",
		Pigeons = {
			{ Name = "Crown Pigeon", Weight = 2.7, Chance = 55 },
			{ Name = "Knight Pigeon", Weight = 2.9, Chance = 40 },
			{ Name = "Priest Pigeon", Weight = 3.4, Chance = 5 },
		},
		HatchTime = 450,
	},

	["Nature Egg"] = {
		DisplayName = "Nature Egg",
		Rarity = "Nature",
		Cost = 90000,
		HoldDuration = 1,
		HatchSound = "rbxassetid://105277634319381",
		HatchVFX = game.ReplicatedStorage.Game.HatchVFX.Leaves,
		Pigeons = {
			{ Name = "Blossom Pigeon", Weight = 2.7, Chance = 50 },
			{ Name = "Nature Pigeon", Weight = 3.0, Chance = 40 },
			{ Name = "Golem Pigeon", Weight = 3.8, Chance = 10 },
		},
		HatchTime = 1500,
	},

	["Candy Egg"] = {
		DisplayName = "Candy Egg",
		Rarity = "Candy",
		Cost = 185000,
		HoldDuration = 1.5,
		Pigeons = {
			{ Name = "Chocolate Pigeon", Weight = 2.8, Chance = 50 },
			{ Name = "Candycane Pigeon", Weight = 3.1, Chance = 40 },
			{ Name = "Cake Pigeon", Weight = 3.5, Chance = 10 },
		},
		HatchTime = 1750,
	},

	["Volcano Egg"] = {
		DisplayName = "Volcano Egg",
		Rarity = "Volcano",
		Cost = 372500,
		HoldDuration = 1.5,
		Pigeons = {
			{ Name = "Fire Pigeon", Weight = 3.0, Chance = 50 },
			{ Name = "Magma Pigeon", Weight = 3.4, Chance = 42 },
			{ Name = "Volcano Pigeon", Weight = 3.6, Chance = 8 },
		},
		HatchTime = 2850,
	},

	["Winter Egg"] = {
		DisplayName = "Winter Egg",
		Rarity = "Winter",
		Cost = 920000,
		HoldDuration = 2,
		Pigeons = {
			{ Name = "Snow Pigeon", Weight = 3.1, Chance = 50 },
			{ Name = "Elf Pigeon", Weight = 3.5, Chance = 45 },
			{ Name = "Santa Pigeon", Weight = 3.8, Chance = 5 },
		},
		HatchTime = 4500,
	},

	["Pumpkin Egg"] = {
		DisplayName = "Pumpkin Egg",
		Rarity = "Pumpkin",
		Cost = 1750000,
		HoldDuration = 2,
		Pigeons = {
			{ Name = "Pumpkin Pigeon", Weight = 3.2, Chance = 55 },
			{ Name = "Ghost Pigeon", Weight = 3.6, Chance = 40 },
			{ Name = "Reaper Pigeon", Weight = 3.9, Chance = 5 },
		},
		HatchTime = 6500,
	},

	["Zombie Egg"] = {
		DisplayName = "Zombie Egg",
		Rarity = "Zombie",
		Cost = 3850000,
		HoldDuration = 2.5,
		HatchSound = "rbxassetid://135076986499326",
		HatchVFX = game.ReplicatedStorage.Game.HatchVFX.Bones,
		Pigeons = {
			{ Name = "Zombie Pigeon", Weight = 5.1, Chance = 60 },
			{ Name = "Skeleton Pigeon", Weight = 6.8, Chance = 30 },
			{ Name = "Frank Pigeon", Weight = 8.0, Chance = 10 },
		},
		HatchTime = 18000,
	},

	["Glitched Egg"] = {
		DisplayName = "Glitched Egg",
		Rarity = "Glitched",
		Cost = 7000000,
		HoldDuration = 2.5,
		Pigeons = {
			{ Name = "Glitched Pigeon", Weight = 5.2, Chance = 60 },
			{ Name = "Hacked Pigeon", Weight = 7.1, Chance = 40 },
		},
		HatchTime = 19000,
	},

	["Space Egg"] = {
		DisplayName = "Space Egg",
		Rarity = "Space",
		Cost = 13500000,
		HoldDuration = 2.5,
		Pigeons = {
			{ Name = "Earth Pigeon", Weight = 5.4, Chance = 53 },
			{ Name = "Star Pigeon", Weight = 7.0, Chance = 40 },
			{ Name = "Space Pigeon", Weight = 9.6, Chance = 7 },
		},
		HatchTime = 20000,
	},

	["Secret Egg"] = {
		DisplayName = "Secret Egg",
		Rarity = "Secret",
		Cost = 28500000,
		HoldDuration = 3,
		Pigeons = {
			{ Name = "Cyborg Pigeon", Weight = 14.4, Chance = 50 },
			{ Name = "Alien Pigeon", Weight = 20.0, Chance = 40 },
			{ Name = "Triple Pigeon", Weight = 24.8, Chance = 10 },
		},
		HatchTime = 28800,
	},
}

return Egg
