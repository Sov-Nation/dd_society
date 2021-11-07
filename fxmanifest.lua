fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author "DokaDoka"
description "DokaDoka's Society"
version "0.3.1"

dependencies {
	'es_extended',
	'dd_menus',
	'PolyZone',
}

shared_scripts {
	'@es_extended/imports.lua',
	'shared/*.lua',
}

server_scripts {
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

ui_page 'html/index.html'

files {
	'data/**/*.lua',
	'html/index.html',
	'html/css/style.css',
	'html/js/script.js'
}
