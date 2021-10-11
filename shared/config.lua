Config = {}

Config.debugZone = false

Config.Garage = {
	Prices = {
		Insurance = 2000,
		Move = 1000,
		Impound	= 5000
	}
}

Config.Menus = {
	washedmoney = {label = 'Washed money (this property)', value = 'washedmoney'},
	washmoney = {label = 'Wash money', value = 'washmoney'},
	keymaster = {label = 'Keymaster', value = 'keymaster'},
}

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
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
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
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
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
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
		sMenu = {},
	},
	bank = {
		sprite = 207,
		pMenu = {},
		bMenu = {},
		sMenu = {'keymaster'},
	},
	club = {
		sprite = 121,
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
		sMenu = {},
	},
	industrial = {
		sprite = 473,
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
		sMenu = {},
	},
	scrap = {
		sprite = 527,
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
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
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
		sMenu = {},
	},
	outlaw = {
		sprite = 492,
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
		sMenu = {},
	},
	altruist = {
		sprite = 269,
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
		sMenu = {},
	},
	taxi = {
		sprite = 198,
		pMenu = {'washmoney'},
		bMenu = {'washedmoney','washmoney'},
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