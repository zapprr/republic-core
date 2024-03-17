fx_version 'adamant'
games { 'gta5' }

name 'republic-core'
description 'An all-in-one framework for menu-based FiveM roleplay servers'
author 'Jennifer Adams, Bozza, et al'

local postalFile = 'json/postals_sa.json'
local streetFile = 'json/streets_lc.json'

dependencies {
	"blip_info",
	"bob74_ipl",
	"discord_perms",
	"pma-voice",
	"rp-radio",
}

file(streetFile)
street_lc_file(streetFile)

file(postalFile)
postal_sa_file(postalFile)

-- Prerequisite Files
client_script '@NativeUILua_Reloaded/src/NativeUIReloaded.lua'

shared_scripts {
	-- Configs
	"configs/*-sh.lua",

	-- Code
	"lua/main/*-sh.lua",
	"lua/*-sh.lua",
	"lua/mdt/*-sh.lua",
	"lua/oldphone/*-sh.lua",
	"lua/newphone/*-sh.lua",
}

client_scripts {
	-- Configs
	"configs/*-cl.lua",

	-- Code
	"lua/main/*-cl.lua",
	"lua/*-cl.lua",
	"lua/mdt/*-cl.lua",
	"lua/oldphone/*-cl.lua",
	"lua/newphone/*-cl.lua",
}

server_scripts {
	-- Configs
	"configs/*-sv.lua",

	-- Code
	"lua/main/*-sv.lua",
	"lua/*-sv.lua",
	"lua/mdt/*-sv.lua",
	"lua/oldphone/*-sv.lua",
	"lua/newphone/*-sv.lua",
}

-- These are for the holster sounds

ui_page 'sound/index.html'
file 'sound/*'
