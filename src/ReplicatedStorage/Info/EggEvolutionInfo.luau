local Egg = {
	["Common Egg"] = {
		DisplayName = "Common Egg",
		Rarity = "Common",
		Cost = 100,
		HoldDuration = 0.55,
		Pigeons = {
			{ Name = "Pigeon", Weight = 2.6, Chance = 35 },
			{ Name = "Baker Pigeon", Weight = 2.6, Chance = 30 },
			{ Name = "Messenger Pigeon", Weight = 2.7, Chance = 25 },
			{ Name = "Fisher Pigeon", Weight = 2.9, Chance = 10 },
		},
		HatchTime = 10,
	},

	["Uncommon Egg"] = {
		DisplayName = "Uncommon Egg",
		Rarity = "Uncommon",
		Cost = 500,
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
		Cost = 1000,
		HoldDuration = 0.55,
		Pigeons = {
			{ Name = "Pharaoh Pigeon", Weight = 2.7, Chance = 40 },
			{ Name = "Astronaut Pigeon", Weight = 2.9, Chance = 30 },
			{ Name = "Ninja Pigeon", Weight = 3, Chance = 20 },
			{ Name = "Samurai Pigeon", Weight = 3.1, Chance = 10 },
		},
		HatchTime = 25,
	},

	["Epic Egg"] = {
		DisplayName = "Epic Egg",
		Rarity = "Epic",
		Cost = 5800,
		HoldDuration = 0.55,
		Pigeons = {
			{ Name = "Gladiator Pigeon", Weight = 3.1, Chance = 50 },
			{ Name = "Shadow Pigeon", Weight = 3.3, Chance = 35 },
			{ Name = "Cyberpunk Pigeon", Weight = 3.5, Chance = 15 },
		},
		HatchTime = 50,
	},

	["Beach Egg"] = {
		DisplayName = "Beach Egg",
		Rarity = "Beach",
		Cost = 16000,
		HoldDuration = 0.55,
		Pigeons = {
			{ Name = "Surfer Pigeon", Weight = 3.1, Chance = 50 },
			{ Name = "Lifeguard Pigeon", Weight = 3.3, Chance = 40 },
			{ Name = "Seashell Pigeon", Weight = 3.7, Chance = 10 },
		},
		HatchTime = 75,
	},

	["Miner Egg"] = {
		DisplayName = "Miner Egg",
		Rarity = "Miner",
		Cost = 45000,
		HoldDuration = 0.65,
		HatchSound = "rbxassetid://9125869495",
		HatchVFX = game.ReplicatedStorage.Game.HatchVFX.Rocks,
		Pigeons = {
			{ Name = "Miner Pigeon", Weight = 3.2, Chance = 50 },
			{ Name = "Minecart Pigeon", Weight = 3.4, Chance = 40 },
			{ Name = "Crystal Pigeon", Weight = 3.9, Chance = 10 },
		},
		HatchTime = 250,
	},

	["Kingdom Egg"] = {
		DisplayName = "Kingdom Egg",
		Rarity = "Kingdom",
		Cost = 100000,
		HoldDuration = 0.6,
		HatchSound = "rbxassetid://2789429097",
		SpawnSound = "rbxassetid://94191035780888",
		Pigeons = {
			{ Name = "Crown Pigeon", Weight = 3.2 * 1.1, Chance = 55 },
			{ Name = "Knight Pigeon", Weight = 3.4 * 1.1, Chance = 40 },
			{ Name = "Priest Pigeon", Weight = 3.9 * 1.1, Chance = 5 },
		},
		HatchTime = 500,
	},

	["Nature Egg"] = {
		DisplayName = "Nature Egg",
		Rarity = "Nature",
		Cost = 275000,
		HoldDuration = 1,
		HatchSound = "rbxassetid://105277634319381",
		SpawnSound = "rbxassetid://122520192691431",
		HatchVFX = game.ReplicatedStorage.Game.HatchVFX.Leaves,
		Pigeons = {
			{ Name = "Blossom Pigeon", Weight = 3.2 * 1.2, Chance = 50 },
			{ Name = "Nature Pigeon", Weight = 3.4 * 1.2, Chance = 40 },
			{ Name = "Golem Pigeon", Weight = 4.1 * 1.15, Chance = 10 },
		},
		HatchTime = 1500,
	},

	["Candy Egg"] = {
		DisplayName = "Candy Egg",
		Rarity = "Candy",
		Cost = 525000,
		HoldDuration = 1.5,
		SpawnSound = "rbxassetid://108012763425202",
		Pigeons = {
			{ Name = "Chocolate Pigeon", Weight = 3.2 * 1.3, Chance = 50 },
			{ Name = "Candycane Pigeon", Weight = 3.4 * 1.3, Chance = 40 },
			{ Name = "Cake Pigeon", Weight = 4.2 * 1.2, Chance = 10 },
		},
		HatchTime = 1750,
	},

	["Volcano Egg"] = {
		DisplayName = "Volcano Egg",
		Rarity = "Volcano",
		Cost = 1385000,
		HoldDuration = 1.5,
		SpawnSound = "rbxassetid://136573872074259",
		Pigeons = {
			{ Name = "Fire Pigeon", Weight = 3.5 * 1.3, Chance = 50 },
			{ Name = "Magma Pigeon", Weight = 3.7 * 1.3, Chance = 42 },
			{ Name = "Volcano Pigeon", Weight = 4.3 * 1.25, Chance = 8 },
		},
		HatchTime = 3600,
	},

	["Winter Egg"] = {
		DisplayName = "Winter Egg",
		Rarity = "Winter",
		Cost = 3580000,
		HoldDuration = 2,
		SpawnSound = "rbxassetid://137381545951901",
		Pigeons = {
			{ Name = "Snow Pigeon", Weight = 3.5 * 1.3, Chance = 50 },
			{ Name = "Elf Pigeon", Weight = 3.75 * 1.4, Chance = 45 },
			{ Name = "Santa Pigeon", Weight = 4.4 * 1.3, Chance = 5 },
		},
		HatchTime = 4500,
	},

	["Pumpkin Egg"] = {
		DisplayName = "Pumpkin Egg",
		Rarity = "Pumpkin",
		Cost = 25580000,
		HoldDuration = 2,
		SpawnSound = "rbxassetid://135427058683314",
		Pigeons = {
			{ Name = "Pumpkin Pigeon", Weight = 3.4 * 1.25, Chance = 50 },
			{ Name = "Ghost Pigeon", Weight = 3.9 * 1.35, Chance = 40 },
			{ Name = "Reaper Pigeon", Weight = 4.6 * 1.35, Chance = 10 },
		},
		HatchTime = 6500,
	},

	["Wealth Egg"] = {
		DisplayName = "Wealth Egg",
		Rarity = "Wealth",
		Cost = 0,
		HoldDuration = 2,
		Pigeons = {
			{ Name = "Rich Pigeon", Weight = 4.2 * 1.25, Chance = 50 },
			{ Name = "Money Pigeon", Weight = 5.5 * 1.35, Chance = 42 },
			{ Name = "Wealthy Pigeon", Weight = 8.2 * 1.35, Chance = 8 },
		},
		HatchTime = 10800,
	},

	["Zombie Egg"] = {
		DisplayName = "Zombie Egg",
		Rarity = "Zombie",
		Cost = 125500000,
		HoldDuration = 2.5,
		HatchSound = "rbxassetid://135076986499326",
		HatchVFX = game.ReplicatedStorage.Game.HatchVFX.Bones,
		SpawnSound = "rbxassetid://100951219085114",
		Pigeons = {
			{ Name = "Zombie Pigeon", Weight = 5.1 * 1.2, Chance = 60 },
			{ Name = "Skeleton Pigeon", Weight = 6.8* 1.2, Chance = 30 },
			{ Name = "Frank Pigeon", Weight = 8.0* 1.2, Chance = 10 },
		},
		HatchTime = 18000,
	},

	["Glitched Egg"] = {
		DisplayName = "Glitched Egg",
		Rarity = "Glitched",
		Cost = 870000000,
		HoldDuration = 2.5,
		SpawnSound = "rbxassetid://136395162227348",
		Pigeons = {
			{ Name = "Glitched Pigeon", Weight = 5.5* 1.2, Chance = 60 },
			{ Name = "Hacked Pigeon", Weight = 7.5* 1.2, Chance = 40 },
		},
		HatchTime = 19000,
    },
    ["Galaxy Egg"] = {
        DisplayName = "Galaxy Egg",
        Rarity = "Galaxy",
        Cost = 0,
        HoldDuration = 4,
        SpawnSound = "",
        Pigeons = {
            { Name = "Nova Pigeon", Weight = 14.3, Chance = 50 },
            { Name = "Gravity Pigeon", Weight = 19.0, Chance = 30 },
            { Name = "Cosmic Pigeon", Weight = 24.5, Chance = 15 },
            { Name = "Voidtrix Pigeon", Weight = 25.5, Chance = 5 },
        },
        HatchTime = 10000,
    },
	["Space Egg"] = {
		DisplayName = "Space Egg",
		Rarity = "Space",
		Cost = 4750000000,
		HoldDuration = 2.5,
		SpawnSound = "rbxassetid://108085825910426",
		Pigeons = {
			{ Name = "Earth Pigeon", Weight = 5.4* 1.15, Chance = 50 },
			{ Name = "Star Pigeon", Weight = 7.0* 1.15, Chance = 43 },
			{ Name = "Space Pigeon", Weight = 9.6* 1.15, Chance = 7 },
		},
		HatchTime = 19000,
	},

	["Secret Egg"] = {
		DisplayName = "Secret Egg",
		Rarity = "Secret",
		Cost = 19250000000,
		HoldDuration = 3.5,
		SpawnSound = "rbxassetid://129833815349802",
		Pigeons = {
			{ Name = "Cyborg Pigeon", Weight = 14.4, Chance = 50 },
			{ Name = "Alien Pigeon", Weight = 20.0, Chance = 40 },
			{ Name = "Triple Pigeon", Weight = 24.8, Chance = 10 },
		},
		HatchTime = 23800,
	},
    ["Creature Egg"] = {
        DisplayName = "Creature Egg",
        Rarity = "Creature",
        Cost = 100000000000,
        HoldDuration = 4,
        SpawnSound = "rbxassetid://133315066890208",
        Pigeons = {
            { Name = "Unicorn Pigeon", Weight = 15.4, Chance = 50 },
            { Name = "Phoenix Pigeon", Weight = 23.5, Chance = 40 },
            { Name = "Dragon Pigeon", Weight = 28.9, Chance = 10 },
        },
        HatchTime = 28800,
    },
	
}

return Egg
