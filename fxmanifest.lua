fx_version 'cerulean'
game 'gta5'

description 'Bed Spawns & Basic Needs'
version '1.0.1'

shared_scripts {
	'@qb-core/shared/locale.lua',
	'locales/en.lua',
	'locales/*.lua',
	'config.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'client/load-unload.lua',
	'client/hospital.lua',
	'client/main.lua',
	'client/visn_bridge.lua'
}

server_scripts {
	'server/main.lua',
}

dependencies {
	'ox_lib',
	'ox_target',
	'ox_inventory',
	"lng-base",
	'qbx-management',
}

lua54 'yes'
