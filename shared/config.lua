Config = {}
Config.Bank = 'doka&doka'
Config.BankName = 'Doka & Doka'
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
