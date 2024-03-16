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
	"lua/*-sh.lua",
	"lua/*/*-sh.lua",
}

client_scripts {
	-- Configs
	"configs/*-cl.lua",

	-- Actual Code
	"lua/*-cl.lua",
	"lua/*/*-cl.lua",
}

server_scripts {
	-- Configs
	"configs/*-sv.lua",

	"lua/*-sv.lua",
	"lua/*/*-sv.lua",
}

-- These are for the holster sounds

ui_page 'sound/index.html'
file 'sound/*'