fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'LuckyCharmz'
description 'A interesting delivery Job :3'
version '1.0.0'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'config.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'server/main.lua',
}

dependencies {
    'ox_lib',
}