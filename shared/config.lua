Config = {}
Config.Bank = 'Doka & Doka'
Config.debugZone = false
Config.debugDoor = false
Config.defaultPlate = '...  ...'

Config.Garage = {
	Prices = {
		Insurance = 2000,
		Move = 1000,
		Impound	= 5000
	}
}

Config.MaxCredit = 10000

local hour = 3600
local day = hour * 24

Config.time = {
	hour = hour,
	day = day,
	moneywash = day,
	bill = day * 7,
}

Config.Menus = {
	washedMoney = {label = 'Washed money (this property)', value = 'washedMoney'},
	washMoney = {label = 'Wash Money', value = 'washMoney'},
	keyMaster = {label = 'Keymaster', value = 'keyMaster'},
}

Config.PropertyTypes = {
	house = {
		sprite = 40,
		pMenu = {},
		bMenu = {},
		sMenu = {},
	},
	parking = {
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
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
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
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
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
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
		sMenu = {},
	},
	bank = {
		sprite = 207,
		pMenu = {},
		bMenu = {},
		sMenu = {'keyMaster'},
	},
	club = {
		sprite = 121,
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
		sMenu = {},
	},
	industrial = {
		sprite = 473,
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
		sMenu = {},
	},
	scrap = {
		sprite = 527,
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
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
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
		sMenu = {},
	},
	outlaw = {
		sprite = 492,
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
		sMenu = {},
	},
	altruist = {
		sprite = 269,
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
		sMenu = {},
	},
	taxi = {
		sprite = 198,
		pMenu = {'washMoney'},
		bMenu = {'washedMoney','washMoney'},
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
