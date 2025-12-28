-- Holds pigeon stats: multipliers, prices, and weight ranges

local Pigeons = {
	-- Common Egg
	["Pigeon"] = {Multiplier = 3.5, Price = 0, Weight = {Min = 1.05, Max = 1.2}},
	["Baker Pigeon"] = {Multiplier = 4.2, Price = 0, Weight = {Min = 1.05, Max = 1.25}},
	["Messenger Pigeon"] = {Multiplier = 5.0, Price = 0, Weight = {Min = 1.1, Max = 1.32}},
	["Fisher Pigeon"] = {Multiplier = 6.0, Price = 0, Weight = {Min = 1.1, Max = 1.35}},

	-- Uncommon Egg
	["Artist Pigeon"] = {Multiplier = 7.3, Price = 0, Weight = {Min = 1.1, Max = 1.32}},
	["Pirate Pigeon"] = {Multiplier = 8.7, Price = 0, Weight = {Min = 1.1, Max = 1.35}},
	["Skater Pigeon"] = {Multiplier = 10.5, Price = 0, Weight = {Min = 1.15, Max = 1.4}},
	["Gardener Pigeon"] = {Multiplier = 12.5, Price = 0, Weight = {Min = 1.1, Max = 1.45}},

	-- Rare Egg
	["Pharaoh Pigeon"] = {Multiplier = 15.0, Price = 0, Weight = {Min = 1.15, Max = 1.4}},
	["Astronaut Pigeon"] = {Multiplier = 18.1, Price = 0, Weight = {Min = 1.15, Max = 1.4}},
	["Ninja Pigeon"] = {Multiplier = 21.7, Price = 0, Weight = {Min = 1.15, Max = 1.4}},
	["Samurai Pigeon"] = {Multiplier = 26.0, Price = 0, Weight = {Min = 1.15, Max = 1.4}, CustomSound = "rbxassetid://7118966167"},

	-- Epic Egg
	["Gladiator Pigeon"] = {Multiplier = 31.2, Price = 0, Weight = {Min = 1.15, Max = 1.55}},
	["Shadow Pigeon"] = {Multiplier = 37.4, Price = 0, Weight = {Min = 1.15, Max = 1.55}, CustomSound = "rbxassetid://6464007319"},
	["Cyberpunk Pigeon"] = {Multiplier = 44.9, Price = 0, Weight = {Min = 1.15, Max = 1.55}, CustomSound = "rbxassetid://78951140328588"},

	-- Beach Egg
	["Surfer Pigeon"] = {Multiplier = 53.9, Price = 0, Weight = {Min = 1.15, Max = 1.55}},
	["Lifeguard Pigeon"] = {Multiplier = 64.7, Price = 0, Weight = {Min = 1.15, Max = 1.6}, CustomSound = "rbxassetid://9125967088"},
	["Seashell Pigeon"] = {Multiplier = 77.7, Price = 0, Weight = {Min = 1.15, Max = 1.75}},

	-- Miner Egg
	["Miner Pigeon"] = {Multiplier = 93.2, Price = 0, Weight = {Min = 1.15, Max = 1.6}},
	["Minecart Pigeon"] = {Multiplier = 111.8, Price = 0, Weight = {Min = 1.2, Max = 1.7}},
	["Crystal Pigeon"] = {Multiplier = 134.2, Price = 0, Weight = {Min = 1.3, Max = 1.85}},

	-- Kingdom Egg
	["Crown Pigeon"] = {Multiplier = 161.0, Price = 0, Weight = {Min = 1.3, Max = 1.75}, CustomSound = "rbxassetid://7995127481"},
	["Knight Pigeon"] = {Multiplier = 193.2, Price = 0, Weight = {Min = 1.3, Max = 1.85}},
	["Priest Pigeon"] = {Multiplier = 231.9, Price = 0, Weight = {Min = 1.3, Max = 1.95}},

	-- Nature Egg
	["Blossom Pigeon"] = {Multiplier = 278.2, Price = 0, Weight = {Min = 1.4, Max = 2.1}},
	["Nature Pigeon"] = {Multiplier = 333.9, Price = 0, Weight = {Min = 1.4, Max = 2.1}},
	["Golem Pigeon"] = {Multiplier = 400.7, Price = 0, Weight = {Min = 1.4, Max = 2.2}},

	-- Candy Egg
	["Chocolate Pigeon"] = {Multiplier = 480.8 * 1.2, Price = 0, Weight = {Min = 1.4, Max = 2.1}},
	["Candycane Pigeon"] = {Multiplier = 577.0 * 1.2, Price = 0, Weight = {Min = 1.4, Max = 2.4}},
	["Cake Pigeon"] = {Multiplier = 692.3 * 1.2, Price = 0, Weight = {Min = 1.4, Max = 2.5}},

	-- Volcano Egg
	["Fire Pigeon"] = {Multiplier = 830.8 * 1.8, Price = 0, Weight = {Min = 1.4, Max = 2.4}, CustomSound = "rbxassetid://4403634269"},
	["Magma Pigeon"] = {Multiplier = 997.0 * 1.8, Price = 0, Weight = {Min = 1.4, Max = 2.4}, CustomSound = "rbxassetid://4403634269"},
	["Volcano Pigeon"] = {Multiplier = 1196.4 * 1.8, Price = 0, Weight = {Min = 1.4, Max = 2.6}, CustomSound = "rbxassetid://4403634269"},

	-- Winter Egg
	["Snow Pigeon"] = {Multiplier = 1435.7 * 2.6, Price = 0, Weight = {Min = 1.8, Max = 2.8}},
	["Elf Pigeon"] = {Multiplier = 1722.8 * 2.6, Price = 0, Weight = {Min = 1.8, Max = 2.8}, CustomSound = "rbxassetid://86881219907776"},
	["Santa Pigeon"] = {Multiplier = 2067.3 * 2.6, Price = 0, Weight = {Min = 1.8, Max = 2.8}, CustomSound = "rbxassetid://8178141232"},

	-- Pumpkin Egg
	["Pumpkin Pigeon"] = {Multiplier = 2480.8 * 3.7, Price = 0, Weight = {Min = 1.8, Max = 2.95}},
	["Ghost Pigeon"] = {Multiplier = 2977.0 * 3.7, Price = 0, Weight = {Min = 1.8, Max = 2.95}},
	["Reaper Pigeon"] = {Multiplier = 3572.4 * 3.7, Price = 0, Weight = {Min = 1.8, Max = 2.95}},

	-- Wealth Egg
	["Rich Pigeon"] = {Multiplier = 4200.8 * 3.9, Price = 0, Weight = {Min = 1.9, Max = 3.1}},
	["Money Pigeon"] = {Multiplier = 6250.0 * 3.9, Price = 0, Weight = {Min = 1.9, Max = 3.1}},
	["Wealthy Pigeon"] = {Multiplier = 9000.4 * 3.9, Price = 0, Weight = {Min = 1.9, Max = 3.1}},

	-- Zombie Egg
	["Zombie Pigeon"] = {Multiplier = 4286.8 * 4.3, Price = 0, Weight = {Min = 2, Max = 3.1}, CustomSound = "rbxassetid://89544586861111"},
	["Skeleton Pigeon"] = {Multiplier = 5144.2 * 4.3, Price = 0, Weight = {Min = 2, Max = 3.1}, CustomSound = "rbxassetid://8923870615"},
	["Frank Pigeon"] = {Multiplier = 6173.0 * 4.3, Price = 0, Weight = {Min = 2, Max = 3.1}, CustomSound = "rbxassetid://574998623"},

	-- Glitched Egg
	["Glitched Pigeon"] = {Multiplier = 7407.6 * 4.7, Price = 0, Weight = {Min = 2.2, Max = 3.4}, CustomSound = "rbxassetid://91393676317056"},
    ["Hacked Pigeon"] = {Multiplier = 8889.2 * 4.7, Price = 0, Weight = {Min = 2.2, Max = 3.4}, CustomSound = "rbxassetid://84287195013022"},
    
    -- Galaxy Egg
    ["Nova Pigeon"] = {Multiplier = 20432.5 * 4.8, RelativeMultiplier = 105, Price = 0, Weight = {Min = 2.3, Max = 3.7}, CustomSound = "rbxassetid://131826433704051"},
    ["Gravity Pigeon"] = {Multiplier = 20432.5 * 4.8, RelativeMultiplier = 120, Price = 0, Weight = {Min = 2.3, Max = 3.7}, CustomSound = "rbxassetid://3609296008"},
    ["Cosmic Pigeon"] = {Multiplier = 20432.5 * 4.8, RelativeMultiplier = 135, Price = 0, Weight = {Min = 2.3, Max = 3.7}, CustomSound = "rbxassetid://125020338799924"},
    ["Voidtrix Pigeon"] = {Multiplier = 20432.5 * 4.8, RelativeMultiplier = 150, Price = 0, Weight = {Min = 2.3, Max = 3.7}, CustomSound = "rbxassetid://9126138070"},
    
	-- Space Egg
	["Earth Pigeon"] = {Multiplier = 10667.0 * 5.1, Price = 0, Weight = {Min = 2.3, Max = 3.7}},
	["Star Pigeon"] = {Multiplier = 12800.4 * 5.1, Price = 0, Weight = {Min = 2.3, Max = 3.7}},
	["Space Pigeon"] = {Multiplier = 20432.5 * 5.1, Price = 0, Weight = {Min = 2.3, Max = 3.7}},

	-- Secret Egg
	["Cyborg Pigeon"] = {Multiplier = 18432.6 * 5.6, Price = 0, Weight = {Min = 2.5, Max = 3.9}, CustomSound = "rbxassetid://9125554166"},
	["Alien Pigeon"] = {Multiplier = 22119.1 * 5.6, Price = 0, Weight = {Min = 2.5, Max = 3.9}, CustomSound = "rbxassetid://73840813063136"},
    ["Triple Pigeon"] = {Multiplier = 26542.9 * 5.6, Price = 0, Weight = {Min = 2.5, Max = 3.9}},
    
    --Creature Egg
    ["Unicorn Pigeon"] = {Multiplier = 22180.6 * 5.8, Price = 0, Weight = {Min = 2.65, Max = 4.2}, CustomSound = "rbxassetid://70724562242201"},
    ["Phoenix Pigeon"] = {Multiplier = 26600.1 * 5.8, Price = 0, Weight = {Min = 2.65, Max = 4.2}, CustomSound = "rbxassetid://491270608"},
    ["Dragon Pigeon"] = {Multiplier = 32000.9 * 5.8, Price = 0, Weight = {Min = 2.65, Max = 4.2}, CustomSound = "rbxassetid://7127123554"},
	
}

--[[
    Relative Multiplier means it takes the highest rate and multiples by the abs value
    For example, with Galaxy Pigeon (assume highest rate without this pigeon was 100) then it will
    have a rate of 290% * 100 = 290.
]]

return Pigeons
