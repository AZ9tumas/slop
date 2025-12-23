local QuestData = {
	[1] = {
		Name = 'Get Started!',
		Title = 'Get Started! [<font color="#FFFF64">1</font>]',
		ToDo = {
			"Hatch 3 Common Eggs"
		},
		Rewards = 'Rewards: <font color="#FFFF64">$100</font>',
		Needed = {
			["Eggs"] = {
				["Common"] = 3
			}
		},
		Reward = {
			["Beaks"] = 100	
		},
	},
	[2] = {
		Name = 'Collecting!',
		Title = 'Collecting! [<font color="#FFFF64">2</font>]',
		ToDo = {
			"Collect 1200 Beaks"
		},
		Rewards = 'Rewards: <font color="#FFFF64">$300</font>',
		Needed = {
			["Beaks"] = 1200
		},
		Reward = {
			["Beaks"] = 300	
		},
	},
	[3] = {
		Name = 'New Egg!',
		Title = 'New Egg! [<font color="#FFFF64">3</font>]',
		ToDo = {
			"Hatch 2 Uncommon Egg"
		},
		Rewards = 'Rewards: <font color="#FFFF64">$350</font>',
		Needed = {
			["Eggs"] = {
				["Uncommon"] = 2
			}
		},
		Reward = {
			["Beaks"] = 350	
		},
	},
	[4] = {
		Name = 'First Sell!',
		Title = 'First Sell! [<font color="#FFFF64">4</font>]',
		ToDo = {
			"Sell Any Pigeon at the Sell Stand",
		},
		Rewards = 'Rewards: <font color="#FFFF64">$250</font>',
		Needed = {
			["Sell"] = {
				["Pigeon"] = 1
			},
		},
		Reward = {
			["Beaks"] = 250	
		},
	},
	[5] = {
		Name = 'Journey Started!',
		Title = 'Journey Started! [<font color="#FFFF64">5</font>]',
		ToDo = {
			"Hatch 3 Rare Eggs",
			'Hatch "Skater Pigeon" In Uncommon Egg',
		},
		Rewards = 'Rewards: <font color="#FFFF64">$800</font>',
		Needed = {
			["Eggs"] = {
				["Rare"] = 3
			},
			["Pigeon"] = {
				["Skater"] = 1
			}
		},
		Reward = {
			["Beaks"] = 800	
		},
	},
	[6] = {
		Name = 'Getting Better!',
		Title = 'Getting Better! [<font color="#FFFF64">6</font>]',
		ToDo = {
			"Hatch 2 Epic Eggs",
			'Buy "Speed Coil" In the gear shop',
		},
		Rewards = 'Rewards: <font color="#FFFF64">$2500</font>',
		Needed = {
			["Eggs"] = {
				["Epic"] = 2
			},
			["Speed Coil"] = 1
		},
		Reward = {
			["Beaks"] = 2500	
		},
	},
	[7] = {
		Name = 'Sell Epic Egg!',
		Title = 'Sell Epic Egg! [<font color="#FFFF64">7</font>]',
		ToDo = {
			'Sell an "Epic Egg" at the sell stand',
		},
		Rewards = 'Rewards: <font color="#00FFFF">Rare Egg (2x)</font>',
		Needed = {
			["Sell"] = {
				["Epic"] = 1
			}
		},
		Reward = {
			["Eggs"] = {
				["Rare"] = 2
			}
		},
	},
	[8] = {
		Name = 'Better Eggs!',
		Title = 'Better Egg! [<font color="#FFFF64">8</font>]',
		ToDo = {
			'Hatch 1 Beach Egg',
		},
		Rewards = 'Rewards: <font color="#FFFF64">$7000</font>',
		Needed = {
			["Eggs"] = {
				["Beach"] = 1
			},
		},
		Reward = {
			["Beaks"] = 7000	
		},
	},
	[9] = {
		Name = 'Collect 30k Beaks!',
		Title = 'Collect 30k! [<font color="#FFFF64">9</font>]',
		ToDo = {
			"Collect 30,000 Beaks!",
		},
		Rewards = 'Rewards: <font color="#FFF8C6">Beach Egg </font><font color="#FFFF64">, $3500</font>',
		Needed = {
			["Beaks"] = 30000
		},
		Reward = {
			["Beaks"] = 3500,
			["Eggs"] = {
				["Beach"] = 1
			}	
		},
	},
	[10] = {
		Name = 'First Mutation!',
		Title = 'First Mutation! [<font color="#FFFF64">10</font>]',
		ToDo = {
			"Get any mutation on any pigeon",
		},
		Rewards = 'Rewards: <font color="#545454">Miner Egg</font><font color="#FFFF64">, $5000</font>',
		Needed = {
			["TotalMutations"] = 1
		},
		Reward = {
			["Beaks"] = 5000,
			["Eggs"] = {
				["Miner"] = 1
			}	
		},
	},
	[11] = {
		Name = 'First Miner Egg!',
		Title = 'Miner Egg! [<font color="#FFFF64">11</font>]',
		ToDo = {
			"Buy 1 Miner Egg",
		},
		Rewards = 'Rewards: <font color="#00FF66">Luck Spray</font>',
		Needed = {
			["Buy"] = {
				["Miner"] = 1
			}
		},
		Reward = {
			["Beaks"] = 10000,
			["Tool"] = {
				["Luck Spray"] = 1
			}	
		},
	},
	[12] = {
		Name = 'First Golden!',
		Title = 'First Golden! [<font color="#FFFF64">12</font>]',
		ToDo = {
			'Get any egg with the "Golden" Mutation!',
		},
		Rewards = 'Rewards: <font color="#FFC233">Size Spray</font><font color="#00FF66">, Luck Spray</font>',
		Needed = {
			["GoldenMutation"] = 1
		},
		Reward = {
			["Tool"] = {
				["Luck Spray"] = 1,
				["Size Spray"] = 1,
			}	
		},
	},
	[13] = {
		Name = 'First Spray!',
		Title = 'First Spray! [<font color="#FFFF64">13</font>]',
		ToDo = {
			"Use any kind of Spray one time",
		},
		Rewards = 'Rewards: <font color="#545454">Miner Egg</font><font color="#FFFF64">, $5000</font>',
		Needed = {
			["Spray"] = 1
		},
		Reward = {
			["Beaks"] = 5000,
			["Eggs"] = {
				["Miner"] = 1
			}	
		},
	},
	[14] = {
		Name = 'First 75K!',
		Title = 'First 75K! [<font color="#FFFF64">14</font>]',
		ToDo = {
			"Collect 75,000 Beaks"
		},
		Rewards = 'Rewards: <font color="#FFC233">Size Spray</font><font color="#00FF66">, Luck Spray</font>',
		Needed = {
			["Beaks"] = 75000
		},
		Reward = {
			["Tool"] = {
				["Size Spray"] = 1,
				["Luck Spray"] = 1
			}	
		},
	},
	[15] = {
		Name = 'Big Progress!',
		Title = 'Big Progress! [<font color="#FFFF64">15</font>]',
		ToDo = {
			"Buy 1 Kingdom Egg",
		},
		Rewards = 'Rewards: <font color="#FF5733">Volcanic Spray</font><font color="#FFFF64">, $10,000</font>',
		Needed = {
			["Buy"] = {
				["Kingdom"] = 1
			}
		},
		Reward = {
			["Beaks"] = 10000,
			["Tool"] = {
				["Volcanic Spray"] = 1
			}	
		},
	},
	[16] = {
		Name = 'Discover The Old! ',
		Title = 'Discover The Old! [<font color="#FFFF64">16</font>]',
		ToDo = {
			'Hatch "Samurai Pigeon" in Rare Egg',
			'Hatch "Cyberpunk Pigeon" in Epic Egg',
		},
		Rewards = 'Rewards: <font color="#00FFFF">Shock Spray</font><font color="#00FF66">, Luck Spray (2x)</font>',
		Needed = {
			["Pigeon"] = {
				["Samurai"] = 1,
				["Cyberpunk"] = 1,
			}
		},
		Reward = {
			["Tool"] = {
				["Luck Spray"] = 2,
				["Shock Spray"] = 1,
			}	
		},
	},
	[17] = {
		Name = 'First Rainbow!',
		Title = 'First <font color="#FF0000">R</font><font color="#FF7F00">a</font><font color="#FFFF00">i</font><font color="#00FF00">n</font><font color="#0000FF">b</font><font color="#4B0082">o</font><font color="#8B00FF">w</font>! [<font color="#FFFF64">17</font>]',
		ToDo = {
			'Get any egg with the "Rainbow" Mutation!',
		},
		Rewards = 'Rewards: <font color="#FFC233">Size Spray</font><font color="#00FF66">, Luck Spray</font>',
		Needed = {
			["RainbowMutation"] = 1
		},
		Reward = {
			["Tool"] = {
				["Luck Spray"] = 1,
				["Size Spray"] = 1,
			}	
		},
	},
	[18] = {
		Name = 'Nature Egg!',
		Title = 'Nature Egg! [<font color="#FFFF64">18</font>]',
		ToDo = {
			"Hatch 1 Nature Egg",
		},
		Rewards = 'Rewards: <font color="#FFFF64">Kingdom Egg, $50,000</font>',
		Needed = {
			["Eggs"] = {
				["Nature"] = 1
			}
		},
		Reward = {
			["Beaks"] = 50000,
			["Eggs"] = {
				["Kingdom"] = 1
			}	
		},
	},
	[19] = {
		Name = 'Keep Selling!',
		Title = 'Keep Selling! [<font color="#FFFF64">19</font>]',
		ToDo = {
			'Sell a "Minecart Pigeon" from the Miner Egg',
		},
		Rewards = 'Rewards: <font color="#FFC233">Size Spray</font><font color="#FFFF64">, $30,000</font>',
		Needed = {
			["Sell"] = {
				["Minecart"] = 1
			}
		},
		Reward = {
			["Beaks"] = 30000,
			["Tool"] = {
				["Size Spray"] = 1
			}	
		},
	},
	[20] = {
		Name = 'Sell Miner Egg!',
		Title = 'Sell Miner Egg! [<font color="#FFFF64">20</font>]',
		ToDo = {
			'Sell a "Miner Egg" at the sell stand',
		},
		Rewards = 'Rewards: <font color="#FFC233">Size Spray</font><font color="#00FF66">, Luck Spray</font>',
		Needed = {
			["Sell"] = {
				["Miner"] = 1
			}
		},
		Reward = {
			["Tool"] = {
				["Size Spray"] = 1,
				["Luck Spray"] = 1
			}	
		},
	},
	[21] = {
		Name = 'Sell Master!',
		Title = 'Sell Master! [<font color="#FFFF64">21</font>]',
		ToDo = {
			"Sell '25' Pigeons in total!",
		},
		Rewards = 'Rewards: <font color="#FFFF64">Kingdom Egg</font>',
		Needed = {
			["Sell"] = {
				["Pigeon"] = 25
			},
		},
		Reward = {
			["Eggs"] = {
				["Kingdom"] = 1
			}
		},
	},
	[22] = {
		Name = 'Target The Best!',
		Title = 'Target The Best! [<font color="#FFFF64">22</font>]',
		ToDo = {
			'Hatch "Seashell Pigeon" in Beach Egg',
			'Hatch "Crystal Pigeon" in Miner Egg',
		},
		Rewards =  'Rewards: <font color="#00FFFF">Shock Spray</font><font color="#FFC233">, Size Spray</font>',
		Needed = {
			["Pigeon"] = {
				["Seashell"] = 1,
				["Crystal"] = 1,
			}
		},
		Reward = {
			["Tool"] = {
				["Size Spray"] = 1,
				["Shock Spray"] = 1,
			}	
		},
	},
	[23] = {
		Name = 'Mutation',
		Title = '<font color="#FF4500">Mutation</font> <font color="#00FFFF">Master!</font> [<font color="#FFFF64">23</font>]',
		ToDo = {
			"Get 3 Mutations on a pigeon",
		},
		Rewards = 'Rewards: <font color="#FFC233">Size Spray (2x)</font><font color="#FFFF64">, $65,000</font>',
		Needed = {
			["TotalMutations"] = 3
		},
		Reward = {
			["Beaks"] = 65000,
			["Tool"] = {
				["Size Spray"] = 2,
			}	
		},
	},
	[24] = {
		Name = 'Candy Eggs!',
		Title = 'Candy Eggs! [<font color="#FFFF64">24</font>]',
		ToDo = {
			"Hatch 2 Candy Eggs!",
		},
		Rewards = 'Rewards: <font color="#FF5733">Volcano Egg</font><font color="#FFFF64">, $25,000</font>',
		Needed = {
			["Eggs"] = {
				["Candy"] = 2
			}
		},
		Reward = {
			["Beaks"] = 25000,
			["Eggs"] = {
				["Volcano"] = 1
			}	
		},
	},
	[25] = {
		Name = 'Volcano Egg!',
		Title = 'Volcano Egg! [<font color="#FFFF64">25</font>]',
		ToDo = {
			"Hatch 1 Volcano Egg",
		},
		Rewards = 'Rewards: <font color="#228B22">Nature Egg</font><font color="#FFFF64">, $50,000</font>',
		Needed = {
			["Eggs"] = {
				["Volcano"] = 1
			}
		},
		Reward = {
			["Beaks"] = 50000,
			["Eggs"] = {
				["Nature"] = 1
			}	
		},
	},
	[26] = {
		Name = 'Winter Egg!',
		Title = 'Winter Egg! [<font color="#FFFF64">26</font>]',
		ToDo = {
			"Hatch 1 Winter Egg",
		},
		Rewards = 'Rewards: <font color="#FF5733">Volcano Egg</font><font color="#FFFF64">, $50,000</font>',
		Needed = {
			["Eggs"] = {
				["Winter"] = 1
			}
		},
		Reward = {
			["Beaks"] = 50000,
			["Eggs"] = {
				["Volcano"] = 1
			}	
		},
	},
	[27] = {
		Name = 'Pumpkin Egg!',
		Title = 'Pumpkin Egg! [<font color="#FFFF64">27</font>]',
		ToDo = {
			"Hatch 1 Pumpkin Egg",
		},
		Rewards = 'Rewards: <font color="#FF5733">Volcano Egg</font><font color="#FFFF64">, $50,000</font>',
		Needed = {
			["Eggs"] = {
				["Pumpkin"] = 1
			}
		},
		Reward = {
			["Beaks"] = 50000,
			["Eggs"] = {
				["Volcano"] = 1
			}	
		},
	},
	[28] = {
		Name = 'Volcano Pigeon!',
		Title = 'Volcano Pigeon! [<font color="#FFFF64">28</font>]',
		ToDo = {
			'Hatch "Volcano Pigeon" in Volcano Egg',
		},
		Rewards = 'Rewards: <font color="#E0FFFF">Winter Egg</font><font color="#FFC233">, Size Spray (2x)</font>',
		Needed = {
			["Pigeon"] = {
				["Volcano"] = 1,
			}
		},
		Reward = {
			["Tool"] = {
				["Size Spray"] = 2,
			},
			["Eggs"] = {
				["Winter"] = 1
			}	
		},
	},
	[29] = {
		Name = 'Pumpkin Eggs!',
		Title = 'Pumpkin Eggs! [<font color="#FFFF64">29</font>]',
		ToDo = {
			"Hatch 2 Pumpkin Eggs",
		},
		Rewards = 'Rewards: <font color="#2c7309">Zombie Egg</font><font color="#FFFF64">, $500,000</font>',
		Needed = {
			["Eggs"] = {
				["Pumpkin"] = 2
			}
		},
		Reward = {
			["Beaks"] = 500000,
			["Eggs"] = {
				["Zombie"] = 1
			}	
		},
	},
	[30] = {
		Name = 'Winter Master!',
		Title = 'Winter Master! [<font color="#FFFF64">30</font>]',
		ToDo = {
			"Hatch 3 Winter Eggs",
		},
		Rewards = 'Rewards: <font color="#2c7309">Zombie Egg</font><font color="#FFFF64">, $850,000</font>',
		Needed = {
			["Eggs"] = {
				["Winter"] = 3
			}
		},
		Reward = {
			["Beaks"] = 850000,
			["Eggs"] = {
				["Zombie"] = 1
			}	
		},
	},
	[31] = {
		Name = 'Zombified!',
		Title = 'Zombified! [<font color="#FFFF64">31</font>]',
		ToDo = {
			"Hatch 2 Zombie Eggs",
		},
		Rewards = 'Rewards: <font color="#00c43e">Glitched Egg</font>',
		Needed = {
			["Eggs"] = {
				["Zombie"] = 2
			}
		},
		Reward = {
			["Eggs"] = {
				["Glitched"] = 1
			}	
		},
    },

}

return QuestData
