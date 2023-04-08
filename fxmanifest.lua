fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Luxu#0001 <luxu@luxu.gg>'
description 'Player Avatar by Luxu.gg'
version '1.0.0'

ui_page 'web/index.html'

files { 'web/*', 'web/**/*', }

shared_scripts { '@ox_lib/init.lua', 'config.lua' }
server_scripts { '@mysql-async/lib/MySQL.lua', 'server.lua', 'database/*' }
client_scripts { 'client.lua' }
