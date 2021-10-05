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
        actions = nil,
        sMenu = {},
    },
    garage = {
        sprite = 357,
        actions = nil,
        sMenu = {},
    },
    airfield = {
        sprite = 359,
        actions = nil,
        sMenu = {},
    },
    helipad = {
        sprite = 360,
        actions = nil,
        sMenu = {},
    },
    dock = {
        sprite = 356,
        actions = nil,
        sMenu = {},
    },
    shop = {
        sprite = 59,
        actions = nil,
        sMenu = {},
    },
    law = {
        sprite = 60,
        actions = nil,
        sMenu = {},
    },
    prison = {
        sprite = 188,
        actions = nil,
        sMenu = {},
    },
    hospital = {
        sprite = 61,
        actions = nil,
        sMenu = {},
    },
    dealer = {
        sprite = 326,
        actions = nil,
        sMenu = {},
    },
    mechanic = {
        sprite = 446,
        actions = nil,
        sMenu = {},
    },
    bank = {
        sprite = 207,
        actions = nil,
        sMenu = {{label = 'Keymaster', value = 'keymaster'}},
    },
    club = {
        sprite = 121,
        actions = nil,
        sMenu = {},
    },
    industrial = {
        sprite = 473,
        actions = nil,
        sMenu = {},
    },
    scrap = {
        sprite = 527,
        actions = nil,
        sMenu = {},
    },
    courier = {
        sprite = 85,
        actions = nil,
        sMenu = {},
    },
    pier = {
        sprite = 266,
        actions = nil,
        sMenu = {},
    },
    outlaw = {
        sprite = 492,
        actions = nil,
        sMenu = {},
    },
    altruist = {
        sprite = 269,
        actions = nil,
        sMenu = {},
    },
    taxi = {
        sprite = 198,
        actions = nil,
        sMenu = {},
    },
    security = {
        sprite = 67,
        actions = nil,
        sMenu = {},
    },
    military = {
        sprite = 526,
        actions = nil,
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