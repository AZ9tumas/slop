-- Holds pigeon stats: multipliers, prices, and weight ranges

local Pigeons = {
    -- Common Egg
    ["Pigeon"] = {Multiplier = 3.5, Price = 0, Weight = {Min = 1.05, Max = 1.2}},
    ["Baker Pigeon"] = {Multiplier = 3.7, Price = 0, Weight = {Min = 1.05, Max = 1.25}},
    ["Messenger Pigeon"] = {Multiplier = 3.9, Price = 0, Weight = {Min = 1.1, Max = 1.32}},
    ["Fisher Pigeon"] = {Multiplier = 4.1, Price = 0, Weight = {Min = 1.1, Max = 1.35}},

    -- Uncommon Egg
    ["Artist Pigeon"] = {Multiplier = 3.95, Price = 0, Weight = {Min = 1.1, Max = 1.32}},
    ["Pirate Pigeon"] = {Multiplier = 4.2, Price = 0, Weight = {Min = 1.1, Max = 1.35}},
    ["Skater Pigeon"] = {Multiplier = 4.5, Price = 0, Weight = {Min = 1.15, Max = 1.4}},
    ["Gardener Pigeon"] = {Multiplier = 4.8, Price = 0, Weight = {Min = 1.1, Max = 1.45}},

    -- Rare Egg
    ["Pharaoh Pigeon"] = {Multiplier = 4.6, Price = 0, Weight = {Min = 1.15, Max = 1.4}},
    ["Astronaut Pigeon"] = {Multiplier = 5, Price = 0, Weight = {Min = 1.15, Max = 1.4}},
    ["Ninja Pigeon"] = {Multiplier = 5.8, Price = 0, Weight = {Min = 1.15, Max = 1.4}},
    ["Samurai Pigeon"] = {Multiplier = 6.5, Price = 0, Weight = {Min = 1.15, Max = 1.4}},

    -- Epic Egg
    ["Gladiator Pigeon"] = {Multiplier = 6.3, Price = 0, Weight = {Min = 1.15, Max = 1.55}},
    ["Shadow Pigeon"] = {Multiplier = 7.2, Price = 0, Weight = {Min = 1.15, Max = 1.55}},
    ["Cyberpunk Pigeon"] = {Multiplier = 8, Price = 0, Weight = {Min = 1.15, Max = 1.55}},

    -- Beach Egg
    ["Surfer Pigeon"] = {Multiplier = 8.5, Price = 0, Weight = {Min = 1.15, Max = 1.55}},
    ["Lifeguard Pigeon"] = {Multiplier = 10.5, Price = 0, Weight = {Min = 1.15, Max = 1.6}},
    ["Seashell Pigeon"] = {Multiplier = 15, Price = 0, Weight = {Min = 1.15, Max = 1.75}},

    -- Miner Egg
    ["Miner Pigeon"] = {Multiplier = 10, Price = 0, Weight = {Min = 1.15, Max = 1.6}},
    ["Minecart Pigeon"] = {Multiplier = 17.5, Price = 0, Weight = {Min = 1.2, Max = 1.7}},
    ["Crystal Pigeon"] = {Multiplier = 29.5, Price = 0, Weight = {Min = 1.3, Max = 1.85}},

    -- Kingdom Egg
    ["Crown Pigeon"] = {Multiplier = 30, Price = 0, Weight = {Min = 1.3, Max = 1.75}},
    ["Knight Pigeon"] = {Multiplier = 45.5, Price = 0, Weight = {Min = 1.3, Max = 1.85}},
    ["Priest Pigeon"] = {Multiplier = 50.5, Price = 0, Weight = {Min = 1.3, Max = 1.95}},

    -- Nature Egg
    ["Blossom Pigeon"] = {Multiplier = 35.6, Price = 0, Weight = {Min = 1.4, Max = 2.1}},
    ["Nature Pigeon"] = {Multiplier = 65.6, Price = 0, Weight = {Min = 1.4, Max = 2.1}},
    ["Golem Pigeon"] =  {Multiplier = 90.6, Price = 0, Weight = {Min = 1.4, Max = 2.2}},

    -- Candy Egg
    ["Chocolate Pigeon"] = {Multiplier = 75.6, Price = 0, Weight = {Min = 1.4, Max = 2.1}},
    ["Candycane Pigeon"] = {Multiplier = 89.6, Price = 0, Weight = {Min = 1.4, Max = 2.4}},
    ["Cake Pigeon"] = {Multiplier = 135.6, Price = 0, Weight = {Min = 1.4, Max = 2.5}},

    -- Volcano Egg
    ["Fire Pigeon"] = {Multiplier = 95.6, Price = 0, Weight = {Min = 1.4, Max = 2.4}},
    ["Magma Pigeon"] = {Multiplier = 130.6, Price = 0, Weight = {Min = 1.4, Max = 2.4}},
    ["Volcano Pigeon"] = {Multiplier = 200.6, Price = 0, Weight = {Min = 1.4, Max = 2.6}},

    -- Winter Egg
    ["Snow Pigeon"] = {Multiplier = 150.6, Price = 0, Weight = {Min = 1.4, Max = 2.5}},
    ["Elf Pigeon"] = {Multiplier = 260.6, Price = 0, Weight = {Min = 1.4, Max = 2.5}},
    ["Santa Pigeon"] = {Multiplier = 390.6, Price = 0, Weight = {Min = 1.4, Max = 2.5}},

    -- Pumpkin Egg
    ["Pumpkin Pigeon"] = {Multiplier = 350.6, Price = 0, Weight = {Min = 1.4, Max = 2.5}},
    ["Ghost Pigeon"] = {Multiplier = 550.6, Price = 0, Weight = {Min = 1.4, Max = 2.5}},
    ["Reaper Pigeon"] = {Multiplier = 800.6, Price = 0, Weight = {Min = 1.4, Max = 2.5}},

    -- Zombie Egg
    ["Zombie Pigeon"] = {Multiplier = 700.6, Price = 0, Weight = {Min = 1.4, Max = 2.55}},
    ["Skeleton Pigeon"] = {Multiplier = 1000.6, Price = 0, Weight = {Min = 1.4, Max = 2.8}},
    ["Frank Pigeon"] = {Multiplier = 3000.6, Price = 0, Weight = {Min = 1.4, Max = 2.8}},

    -- Glitched Egg
    ["Glitched Pigeon"] = {Multiplier = 1550.6, Price = 0, Weight = {Min = 1.4, Max = 2.8}},
    ["Hacked Pigeon"] = {Multiplier = 3800.6, Price = 0, Weight = {Min = 1.4, Max = 2.8}},

    -- Space Egg
    ["Earth Pigeon"] = {Multiplier = 3000.6, Price = 0, Weight = {Min = 1.4, Max = 2.8}},
    ["Star Pigeon"] = {Multiplier = 4200.6, Price = 0, Weight = {Min = 1.4, Max = 2.8}},
    ["Space Pigeon"] = {Multiplier = 5500.6, Price = 0, Weight = {Min = 1.4, Max = 2.9}},

    -- Secret Egg
    ["Cyborg Pigeon"] = {Multiplier = 4500.6, Price = 0, Weight = {Min = 1.4, Max = 2.8}},
    ["Alien Pigeon"] = {Multiplier = 5600.6, Price = 0, Weight = {Min = 1.4, Max = 2.8}},
    ["Triple Pigeon"] = {Multiplier = 8000.6, Price = 0, Weight = {Min = 1.4, Max = 2.8}},
}

return Pigeons
