Config = {}

Config.debugZone = true

Config.Garage = {
	Prices = {
		Insurance = 2000,
		Move = 1000,
		Impound	= 5000
	}
}

-- bank(partial)
-- law
-- hospital
-- scrap

Config.PropertyTypes = {
	house = {
		sprite = 40,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	garage = {
		sprite = 357,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	airfield = {
		sprite = 359,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	helipad = {
		sprite = 360,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	dock = {
		sprite = 356,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	shop = {
		sprite = 59,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	law = {
		sprite = 60,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	prison = {
		sprite = 188,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	hospital = {
		sprite = 61,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	dealer = {
		sprite = 326,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	mechanic = {
		sprite = 446,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	bank = {
		sprite = 207,
		pMenu = {},
		bMenu = {},
		sMenu = {{label = 'Keymaster', value = 'keymaster'}},
	},
	club = {
		sprite = 121,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	industrial = {
		sprite = 473,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	scrap = {
		sprite = 527,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	courier = {
		sprite = 85,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	pier = {
		sprite = 266,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	outlaw = {
		sprite = 492,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	altruist = {
		sprite = 269,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	taxi = {
		sprite = 198,
		pMenu = {{label = 'Wash money', value = 'washmoney'}},
		bMenu = {{label = 'Washed money', value = 'washedmoney'},{label = 'Wash money', value = 'washmoney'}},
		sMenu = {},
	},
	security = {
		sprite = 67,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	military = {
		sprite = 526,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	}
}

Config.Zones = {
	garage = {
		message = 'Press ~INPUT_PICKUP~ to access this garage'
	},
	boss = {
		message = 'Press ~INPUT_PICKUP~ to open the boss menu'
	},
	property = {
		message = 'Press ~INPUT_PICKUP~ to open the property menu'
	},
	uniform = {
		message = 'Press ~INPUT_PICKUP~ to open the uniform menu'
	},
	teleport = {
		message = 'Press ~INPUT_PICKUP~ to open the teleport menu'
	},
}