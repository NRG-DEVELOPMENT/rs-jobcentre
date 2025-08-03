fx_version 'cerulean'
game 'gta5'

author 'NRG Development'
description 'Advanced Job Centre for FiveM servers'
version '1.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png',
}

lua54 'yes'