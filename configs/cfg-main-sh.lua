-- use this to enable trains or something
-- only metro trains are enabled by default since they don't bug out compared to freight trains (as tested on OneSync)
trainsEnabled = true

ServerName = "My Server" -- This is used for the server name across various locations
ServerId = "myserver" -- This is used for KVP Data storage, so one server's settings won't interfere with another's.

CheckIfPlayerInDiscord = false -- Enabling this will prevent the player from joining the server if they can't be found in the Discord Server defined in discord_perms.


-- Text Entries are what's used in UI elements to show text to the player - this is editable as needed.
textEntries = {
	{"FMMC_ADTITLE", "Advertisement Title (MAX 25 characters)"},
	{"FMMC_ADDESC", "Advertisement (MAX 200 characters)"},
	{"FMMC_HANDLE", "Set your Bleeter handle for this character (MAX 20 characters)"},
	{"FMMC_BLEET", "Send Bleet (MAX 180 characters)"},

	{"INFO_HANDSUP", "~INPUT_DUCK~ Toggle kneeling~n~~INPUT_CHARACTER_WHEEL~ Toggle hands on head"},
	{"INFO_HOLSTER", "~INPUT_CHARACTER_WHEEL~ Raise/Lower Hand~n~~INPUT_AIM~ Draw Weapon"},

	{"INFO_SESSIONRP", "~g~You are now in the ~h~roleplay session."},
	{"INFO_SESSIONFR", "~g~You are now in the ~h~freeroam session."},
	{"INFO_SESSIONPR", "~g~You are now in your ~h~private session."},


	{"AOP_VOTESUB", "~BLIP_INFO_ICON~  ~b~Your vote has been submitted!"},
	{"AOP_VOTETIE", "~BLIP_INFO_ICON~  ~b~A tiebreaker vote has started. Press ~INPUT_FRONTEND_SOCIAL_CLUB~ to vote."},
	{"AOP_VOTEBEGIN", "~BLIP_INFO_ICON~  ~b~An AOP Vote has started. Press ~INPUT_FRONTEND_SOCIAL_CLUB~ to vote."},
	{"AOP_VOTEMEMBER", "~BLIP_INFO_ICON~  ~b~An AOP Vote has started, but only server members can vote."},

	{"RESTRICT_WEAPON", "~r~To prevent abuse, automatic and Heavy weapons are restricted to server members only"},
	{"RESTRICT_VEHICLE", "~r~To prevent abuse, this vehicle can only be driven by server members"},
	{"RESTRICT_PLATE", "~r~To prevent abuse, custom licence plates are restricted to server members only"},
}

-- This is used for adding custom icons to be used with Bleeter/advertising on the phone.

customIcon = {
	-- Generic
	{name = "Mors Mutual", handle = "@MorsMutual", icon = "CHAR_MP_MORS_MUTUAL"},
	{name = "Taxi Driver", icon = "CHAR_FLOYD"},
	
	{name = "Los Santos Transit", handle="@LSTransit", icon = "CHAR_LSTRANSIT"},

	-- Law Enforcement
	{name = "Los Santos Police Department", handle = "@LosSantosPolice", icon = "web_lossantospolicedept"},
	{name = "Drug Observation Agency", handle = "@DOAHQ", icon = "web_nationalofficeofsecurityenforcement"},

	-- Taxis
	{name = "Downtown Cab Co", handle = "@DowntownCabCo", icon = "CHAR_TAXI"},

	-- Private Security
	{name = "Merryweather Security", handle = "@MerryweatherSecurity", icon = "CHAR_MP_MERRYWEATHER"},
	{name = "SecuroServ", handle = "@SecuroServ", icon = "char_gangapp"},
	

	-- Businesses
	{name = "Ammunation", handle = "@Ammunation", icon = "CHAR_AMMUNATION"},
	{name = "Bugstars", handle = "@Bugstars", icon = "CHAR_BUGSTARS"},
	{name = "iFruit", handle = "@iFruit", icon = "CHAR_IFRUIT"},
	{name = "Otto\'s Autos", handle = "@OttosAutos", icon = "CHAR_OTTOSAUTOS"},
	{name = "Roger\'s Salvage & Scrap", handle = "@RogersSAS", icon = "WEB_ROGERS"},
	
	-- Supermarkets
	{name = "24/7 Supermarket", handle = "@247", icon = "WEB_247"},
	{name = "Limited Gasoline", handle = "@LTD", icon = "WEB_LTD"},

	{name = "Lost MC", handle = "@LostMotorcycleClub", icon = "dia_lost"},
	{name = "Love Fist", handle = "@LoveFist", icon = "dia_lovefist"},

	-- Fast Food
	{name = "Cluckin\' Bell", handle = "@CluckinBell", icon = "web_cluckinbell"},
	{name = "Sprunk", handle = "@Sprunk", icon = "web_sprunk"},

	-- Cell Providers
	{name = "Whiz Wireless", handle = "@WhizWireless", icon = "web_whizwireless"},
	{name = "Bittersweet", handle = "@Bittersweet", icon = "web_bittersweetcellphone"},

	-- Tourist Board
	{name = "Alamo Sea Tourist Board", handle = "@AlamoSeaTouristBoard", icon = "web_alamoseatouristboard"},
	{name = "LS Tourist Info", handle = "@LSTouristInfo", icon = "char_ls_tourist_board"},
	{name = "Star Tours", handle = "@StarTours", icon = "dia_tour"},

	-- Bars
	{name = "Bahama Mamas West", handle = "@BahamaMamas", icon = "web_bahamamamaswest"},
	{name = "Vanilla Unicorn", handle = "@VanillaUnicorn", icon = "char_mp_stripclub_pr"},

	-- Vehicle Manufacturers
	{name = "Benefactor", handle = "@Benefactor", icon = "web_benefactor"},

	-- Banks
	{name = "Fleeca Bank", handle = "@FleecaBank", icon = "CHAR_BANK_FLEECA"},
	{name = "Maze Bank", handle = "@MazeBank", icon = "CHAR_BANK_MAZE"},
	{name = "Bank of Liberty", handle = "@BankOfLiberty", icon = "CHAR_BANK_BOL"},
	{name = "Lombank", handle = "@Lombank", icon = "web_lombank"},

	{name = "Facade", handle = "@Facade", icon = "web_facadecomputers"},
	{name = "Fruit", handle = "@Fruit", icon = "web_fruit"},

	{name = "Epsilon", handle = "@EpsilonProgram", icon = "CHAR_EPSILON"},

	-- Garages
	{name = "Los Santos Customs", handle = "@LosSantosCustoms", icon = "CHAR_LS_CUSTOMS"},
	{name = "Premium Deluxe Motorsport", handle = "@PremiumDeluxe", icon = "web_premiumdeluxemotorsport"},
	{name = "Benny\'s Original Motor Works", handle = "@BennysOriginal", icon = "char_carsite3"},

	{name = "The Diamond Resort & Casino", handle = "@DiamondResortCasino", icon = "char_casino"},
	{name = "Lifeinvader", handle = "@Lifeinvader", icon = "char_lifeinvader"},

}

-- So, I never really finished the bus system. However, you're able to define bus lines here, and it'll let you both view them while at a bus stop, and allow bus drivers to route themselves to it.
-- Feel free to expand on it/somehow integrate it with better bus scripts

BusStops = {
	{name = "Dashound Terminal 1", operator = "Dashound Lines", x = 452.19, y = -647.71, z = 28.46},
	{name = "Dashound Terminal 2", operator = "Dashound Lines", x = 452.87, y = -640.44, z = 28.5},
	{name = "Dashound Terminal 3", operator = "Dashound Lines", x = 453.53, y = -633.03, z = 28.5},
	{name = "Dashound Terminal 4", operator = "Dashound Lines", x = 454.22, y = -625.94, z = 28.46},
	{name = "Dashound Terminal 5", operator = "Dashound Lines", x = 454.79, y = -618.72, z = 28.46},

	-- Downtown Los Santos
	{name = "Alesandro Southbound", operator = "Los Santos Transit", x = 304.22, y = -765.3, z = 29.31},
	{name = "San Andreas Plaza Westbound", operator = "Los Santos Transit", x = 115.89, y = -781.74, z = 31.4},
	{name = "Peaceful Street Northbound", operator = "Los Santos Transit", x = -267.83, y = -823.93, z = 31.84},
	{name = "Peaceful Street Southbound", operator = "Los Santos Transit", x = -247.9, y = -713.52, z = 33.55},

	{name = "Schlongberg Sachs Southbound", operator = "Los Santos Transit", x = -176.43, y = -818.17, z = 31.57},

	{name = "Mile High Club Westbound", operator = "Los Santos Transit", x = -183.89, y = -1127.46, z = 23.03},
	{name = "8156 Vespucci", operator = "Los Santos Transit", x = -250.22, y = -887.00, z = 30.62},

	{name = "Mission Row Eastbound", operator = "Los Santos Transit", x = 355.74, y = -1067.25, z = 29.57},
	{name = "Sinner Street", operator = "Los Santos Transit", x = 413.23, y = -781.61, z = 29.3},

	-- Little Seoul
	{name = "Midway Eastbound", operator = "Los Santos Transit", x = -558.26, y =-848.98, z = 27.57},
	{name = "Kayton Group Westbound", operator = "Los Santos Transit", x = -712.52, y = -824.34, z = 23.55},
	{name = "Ginger Street Northbound", operator = "Los Santos Transit", x = -737.86, y = -751.19, z = 26.82},
	{name = "Valdez Eastbound", operator = "Los Santos Transit", x = -691.78, y = -670.65, z = 30.87},
	{name = "Little Seoul LST Eastbound", operator = "Los Santos Transit", x = -505.06, y = -671.1, z = 33.1},

	-- Strawberry
	{name = "Strawberry LST", operator = "Los Santos Transit", x = 258.56, y = -1191.73, z = 29.46},
	{name = "Forum Drive Southbound", operator = "Los Santos Transit", x = -110.42, y = -1685.89, z = 29.31},

	{name = "Strawberry Northbound", operator = "Los Santos Transit", x = -110.42, y = -1685.89, z = 29.31},

	-- Vespucci
	{name = "Goma Street Southbound", operator = "Los Santos Transit", x = -1170.93, y = -1473.5, z = 4.38},

	-- Maze Bank
	{name = "Maze Bank Arena Stop 1", operator = "Los Santos Transit", x = -130.54, y = -1970.48, z = 22.81},
	{name = "Maze Bank Arena Stop 2", operator = "Los Santos Transit", x = -130.1, y = -1976.36, z = 22.81},
	{name = "Maze Bank Arena Stop 3", operator = "Los Santos Transit", x = -129.81, y = -1989.92, z = 22.81},
	{name = "Maze Bank Arena Stop 4", operator = "Los Santos Transit", x = -129.63, y = -1988.97, z = 22.81},


	-- La Mesa
	{name = "Popular Street Northbound", operator = "Los Santos Transit", x = 788.42, y = -776.53, z = 26.42},
	{name = "Popular Street Southbound", operator = "Los Santos Transit", x = 768.1, y = -941.94, z = 25.71},
	{name = "Olympic Underpass Northbound", operator = "Los Santos Transit", x = 810.06, y = -1352.11, z = 26.33},
	{name = "Olympic Underpass Southbound", operator = "Los Santos Transit", x = 785.39, y = -1369.22, z = 26.61},

	-- East Los Santos
	{name = "Industry Gardens Southbound", operator = "Los Santos Transit", x = 822.41, y = -1638.59, z = 30.39},
	{name = "Cypress Flats Eastbound", operator = "Los Santos Transit", x = 868.88, y = -1769.5, z = 29.99},
	{name = "Cypress Flats Westbound", operator = "Los Santos Transit", x = 932.64, y = -1749.47, z = 31.15},

	{name = "Murrietta Heights", operator = "Los Santos Transit", x = 1311.56, y = -1642.84, z = 52.07}, -- Unpropped
	{name = "Labor Place", operator = "Los Santos Transit", x = 1319.37, y = -1779.44, z = 54.07}, -- Unpropped

	-- Paleto Bay
	{name = "Great Ocean Highway Southbound", operator = "Blaine County Transit", x = -219.03, y = 6174.81, z = 31.27},
	{name = "Great Ocean Highway Northbound", operator = "Blaine County Transit", x = -147.63, y = 6211.41, z = 31.29},
	{name = "Paleto Blvd", operator = "Blaine County Transit", x = -329.61, y = 6190.37, z = 31.38},

	-- Casino
	{name = "Casino Stand 1", operator = "Los Santos Transit", x = 934.44, y = 151.68, z = 80.83},

	-- Majestic County
	{name = "E Harmony Westbound", operator = "Dashound Lines", x = 1059.0, y = 2698.32, z = 39.09},
	{name = "E Harmony Eastbound", operator = "Dashound Lines", x = 1102.47, y = 2677.8, z = 38.59},

	{name = "W Harmony Eastbound", operator = "Dashound Lines", x = 561.6, y = 2676.6, z = 42.12},
	{name = "W Harmony Westbound", operator = "Dashound Lines", x = 573.57, y = 2701.64, z = 41.88},

	{name = "Sandy Shores Westbound", operator = "Dashound Lines", x = 1842.2, y = 3604.59, z = 34.85},
	{name = "Sandy Shores Eastbound", operator = "Dashound Lines", x = 1848.24, y = 3584.6, z = 34.95},

	{name = "Grapeseed Northbound", operator = "Dashound Lines", x = 1681.55, y = 4848.27, z = 42.12},
	{name = "Grapeseed Southbound", operator = "Dashound Lines", x = 1660.76, y = 4835.47, z = 42.02},
}

BusRoutes = {
	{name = "201", color = 6, stops = {"Sinner Street", "Alesandro Southbound", "San Andreas Plaza Westbound", "Schlongberg Sachs Southbound", "Kayton Group Westbound", "Goma Street Southbound", "Midway Eastbound", "8156 Vespucci", "Mission Row Eastbound"}},
	{name = "556", color = 6, stops = {"Popular Street Southbound", "Olympic Underpass Southbound", "Industry Gardens Southbound", "Cypress Flats Westbound", "Murrietta Heights", "Labor Place", "Cypress Flats Westbound", "Olympic Underpass Northbound", "Popular Street Northbound", "Casino Stand 1"}},
	{name = "303", color = 14, stops = {"Maze Bank Arena Stop 1", "Strawberry Northbound", "Strawberry LST", "Mission Row Eastbound", "Sinner Street", "Alesandro Southbound", "San Andreas Plaza Westbound", "Schlongberg Sachs Southbound", "8156 Vespucci", "Strawberry LST", "Forum Drive Southbound"}},
}
-- These are all the agencies as used in the in-game CAD/MDT
-- You'll need to configure some of these yourselves. The "short" is what's used with the /onduty command.

agencies = {
{type = "Law Enforcement", short = "LSPD", long = "Los Santos Police Department", motto = "Obey and Survive", 
equipment = {
	{weapon = "WEAPON_COMBATPISTOL", components = {"COMPONENT_AT_PI_FLSH"}}, 
	{weapon = "WEAPON_STUNGUN", tint = 1},
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_NIGHTSTICK"},

	{weapon = "WEAPON_CARBINERIFLE_MK2", rack = "rifle", components = {"COMPONENT_AT_AR_FLSH", "COMPONENT_AT_SIGHTS", "COMPONENT_AT_AR_AFGRIP_02"}},
	{weapon = "WEAPON_PUMPSHOTGUN", rack = "shotgun"},
},
wallpaper = {"hacking_pc_desktop_3", "hacking_pc_desktop_3"}},


-- Los Santos Sheriff's Office

{type = "Law Enforcement", short = "LSSD", long = "Los Santos County Sheriff's Department", motto = "A Tradition of Suppression", 
equipment = {
	{weapon = "WEAPON_COMBATPISTOL", components = {"COMPONENT_AT_PI_FLSH"}}, 
	{weapon = "WEAPON_STUNGUN", tint = 2},
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_NIGHTSTICK"},

	{weapon = "WEAPON_CARBINERIFLE_MK2", rack = "rifle", components = {"COMPONENT_AT_AR_FLSH", "COMPONENT_AT_SIGHTS", "COMPONENT_AT_AR_AFGRIP_02"}},
	{weapon = "WEAPON_PUMPSHOTGUN", rack = "shotgun"},
},
wallpaper = {40, 70, 50}},

-- Blaine County Sheriff's Office

{type = "Law Enforcement", short = "BCSO", long = "Blaine County Sheriff's Office", motto = "", 
equipment = {
	{weapon = "WEAPON_COMBATPISTOL", components = {"COMPONENT_AT_PI_FLSH", "COMPONENT_AT_PI_SAFETYPISTOL_RDS"}}, 
	{weapon = "WEAPON_STUNGUN", tint = 2},
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_NIGHTSTICK", tint = 7},

	{weapon = "WEAPON_CARBINERIFLE_MK2", rack = "rifle", components = {"COMPONENT_AT_AR_FLSH", "COMPONENT_AT_SCOPE_MACRO_MK2", "COMPONENT_AT_AR_SUPP_02"}},
	{weapon = "WEAPON_PUMPSHOTGUN", rack = "shotgun"},
},
wallpaper = {40, 70, 50}},


{type = "Fire/EMS", short = "LSFD", long = "Los Santos Fire Department", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_FIREEXTINGUISHER"},
	{weapon = "WEAPON_FLARE"},
	{weapon = "WEAPON_SLEDGEHAMMER"},
	{weapon = "WEAPON_PIKEPOLE"},
	{weapon = "WEAPON_HYDRANTWRENCH"},
	{weapon = "WEAPON_FIREAXE"},
	{weapon = "WEAPON_HALLIGAN"},
	{weapon = "WEAPON_MEDBAG"},
},
wallpaper = {"hacking_pc_desktop_3", "hacking_pc_desktop_3"}},

{type = "Fire/EMS", short = "LSCoFD", long = "Los Santos County Fire Department", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_FIREEXTINGUISHER"},
	{weapon = "WEAPON_FLARE"},
	{weapon = "WEAPON_SLEDGEHAMMER"},
	{weapon = "WEAPON_PIKEPOLE"},
	{weapon = "WEAPON_HYDRANTWRENCH"},
	{weapon = "WEAPON_FIREAXE"},
	{weapon = "WEAPON_HALLIGAN"},
	{weapon = "WEAPON_MEDBAG"},
},
wallpaper = {100, 20, 20}},

{type = "Fire/EMS", short = "BCFD", long = "Blaine County Fire Department", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_FIREEXTINGUISHER"},
	{weapon = "WEAPON_FLARE"},
	{weapon = "WEAPON_SLEDGEHAMMER"},
	{weapon = "WEAPON_PIKEPOLE"},
	{weapon = "WEAPON_HYDRANTWRENCH"},
	{weapon = "WEAPON_FIREAXE"},
	{weapon = "WEAPON_HALLIGAN"},
	{weapon = "WEAPON_MEDBAG"},
},
wallpaper = {130, 130, 50}},

{type = "Fire/EMS", short = "MRSA", long = "Medical Response San Andreas", motto = "",
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_MEDBAG"},
},
wallpaper = {80, 80, 200}},


-------------------------------------------------------------------------------
-- Private Security Companies

{type = "Private Security", short = "G6", long = "Gruppe Sechs", motto = "Putting U in Secure", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_VFCOMBATPISTOL"}, 
	{weapon = "WEAPON_NIGHTSTICK"},
},
wallpaper = {50, 110, 50}},

{type = "Private Security", short = "MW", long = "Merryweather Security", motto = "Your security is our concern", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_VFCOMBATPISTOL"}, 
	{weapon = "WEAPON_NIGHTSTICK"},
},
wallpaper = {60, 60, 130}},

{type = "Private Security", short = "SECURO", long = "SecuroServ", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
	{weapon = "WEAPON_NIGHTSTICK"},
},
wallpaper = {200, 200, 200}},

-------------------------------------------------------------------------------
-- Coroner & Medical Examiner
-- I can't remember if I actually implemented these or not.

{type = "Coroner", short = "LSCC", long = "Los Santos County Coroner", motto = "Serving Communities With Scientific Fact", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
},
wallpaper = {80, 80, 200}},

{type = "Coroner", short = "BCME", long = "Blaine County Medical Examiner", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
},
wallpaper = {80, 80, 200}},


-------------------------------------------------------------------------------
-- Tow Trucks

{type = "Tow Truck", short = "CHC", long = "Casey\'s Highway Clearance", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "MMI", long = "Mors Mutual Insurance", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "OPG", long = "Los Santos OPG", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "RUSSO", long = "Russo\'s Towing & Recovery", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "RS", long = "Roger\'s Salvage & Scrap", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "PEGASUS", long = "Pegasus", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "AUTOEXOTIC", long = "Auto Exotic Fixing Station", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "BEEKERS", long = "Beeker\'s Garage & Parts", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "DIEGOS", long = "Diego\'s Garage", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "LM", long = "Legendary Motorsport", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "SUPERAUTOS", long = "Southern San Andreas Super Autos", motto = "meeting your vehicular needs", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "AL", long = "Al\'s Auto Repair", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Tow Truck", short = "AUTOCARE", long = "Autocare Professional Repair & Service", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

-------------------------------------------------------------------------------
-- Animal Control

{type = "Animal Control", short = "BCAC", long = "Blaine County Animal Control", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Animal Control", short = "LSCAC", long = "Los Santos County Animal Control", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},


-------------------------------------------------------------------------------
-- Public Works

{type = "Public Works", short = "ST", long = "SanTrans", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Public Works", short = "LSCWP", long = "Los Santos Department of Water and Power", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Public Works", short = "LSDT", long = "Los Santos Department of Transportation", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Public Works", short = "LSDGP", long = "Los Santos Department of Green Power", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Public Works", short = "LSDW", long = "Los Santos Department of Wind Power", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Public Works", short = "LSDWP", long = "Los Santos City Water & Power", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Public Works", short = "LSDS", long = "Los Santos Department of Sanitation", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Public Works", short = "HOBO", long = "Household Order Bin Operations Inc.", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

-- Transit
{type = "Public Works", short = "LST", long = "Los Santos Transit", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Public Works", short = "GL", long = "GoLoco", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

{type = "Public Works", short = "DASHOUND", long = "Dashound", motto = "", 
equipment = {
	{weapon = "WEAPON_FLASHLIGHT"},
}},

}

-- This was never implemented, was planning on doing some sort of NativeUI menu that'd let people use a register as a clerk.
RegisterPrices = {
	{"24/7 Supermarket", {
		{name = "Meteorite", category = "Snacks", price = 1.0},
		{name = "Ego Chaser", category = "Snacks", price = 1.0},
		{name = "Zebrabar", category = "Snacks", price = 1.0},
		{name = "EarthQuakes", category = "Snacks", price = 1.0},
		{name = "Release Gum", category = "Snacks", price = 1.5},
		{name = "Phat Chips", category = "Snacks", price = 2.0},
	}},
}

initialAOPs = {
	"Mirror Park",
	"Paleto Bay",
	"Del Perro",
	"Davis",
	"Sandy Shores",
	"Grapeseed",
	"Strawberry",
	"Downtown Los Santos",
	"Downtown Vinewood",
	"Rockford Hills",
	"Little Seoul",
	"Vespucci"
}

-- This lists props that are made indestructible
indestructibleProps = {
	"prop_traffic_01a",
	"prop_traffic_01b",
	"prop_traffic_01d",
	"prop_traffic_02a",
	"prop_traffic_02b",
	"prop_traffic_03a",
	"prop_traffic_03b",
	"prop_fire_hydrant_1",
	"prop_fire_hydrant_01",
	"prop_fire_hydrant_2",
	"prop_fire_hydrant_02",

	"prop_streetlight_01",
	"prop_streetlight_01b",
	"prop_streetlight_02",
	"prop_streetlight_03",
	"prop_streetlight_03b",
	"prop_streetlight_03c",
	"prop_streetlight_03d",
	"prop_streetlight_03e",
	"prop_streetlight_04",
	"prop_streetlight_05",
	"prop_streetlight_05_b",
	"prop_streetlight_06",
	"prop_streetlight_07a",
	"prop_streetlight_07b",
	"prop_streetlight_08",
	"prop_streetlight_09",
	"prop_streetlight_10",
	"prop_streetlight_11a",
	"prop_streetlight_11b",
	"prop_streetlight_11c",
	"prop_streetlight_12a",
	"prop_streetlight_12b",
	"prop_streetlight_14a",
	"prop_streetlight_15a",
	"prop_streetlight_16a",
	
	"prop_bench_09",
	"prop_phonebox_04",
	
	"prop_ind_light_02a",
	"prop_ind_light_02b",
	"prop_ind_light_02c",
	"prop_ind_light_03a",
	"prop_ind_light_03b",
	"prop_ind_light_03c"
}

-- Also never implemented, the idea was that your speedometer would turn orange above a certain speed. I was planning on including X/Y modifiers so roads could change speed.
-- It's a bit of a complicated idea, but if anyone wants to run with it that'd be awesome.
SpeedLimits = {
	{road = "Paleto Blvd", speed = 35},

	{road = "Route 68", speed = 60, east = {{speed = 50, x = 1570.0}}},

	{},


}
