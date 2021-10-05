fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author "DokaDoka"
description "DokaDoka's Society"
version "0.2.0"

dependencies {
    'mysql-async',
    -- 'oxmysql',
    'es_extended',
    'dd_menus',
    'PolyZone',
}

shared_scripts { 
    '@es_extended/imports.lua',
    'shared/*.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/*.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/**/*.lua',
}
