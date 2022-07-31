-- Made by @Tomić#9076

fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author "devTomic (tomiichx)"
description "Territory System for Gangs"

version 'Tomić Development | v1.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  'shared.lua'
}

client_scripts {
  'client.lua'
}

server_scripts { 
  '@oxmysql/lib/MySQL.lua',
  'server.lua',
}

dependencies {
	'qb-core'
}

--[[
████████╗░█████╗░███╗░░░███╗██╗░█████╗░
╚══██╔══╝██╔══██╗████╗░████║██║██╔══██╗
░░░██║░░░██║░░██║██╔████╔██║██║██║░░╚═╝
░░░██║░░░██║░░██║██║╚██╔╝██║██║██║░░██╗
░░░██║░░░╚█████╔╝██║░╚═╝░██║██║╚█████╔╝
░░░╚═╝░░░░╚════╝░╚═╝░░░░░╚═╝╚═╝░╚════╝░
]]
