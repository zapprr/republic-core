--[[
	Wiwang MDT
	Created by Jennifer Adams for Republic Core
]]

mdtRenderPage = {}
mdtOpen = false

mdtMouseControl = false
cursorX = 0.8
cursorY = 0.8

mdtIncidentNumber = 0
mdtPostalLocation = 0
mdtRosterPage = 1

mdtAttachedCall = 0

mdtNotes = ""
mdtUnitDisplay = ""

mdtColor = {0, 0, 0}

RegisterCommand('mdt', function(source, args, user)
	if player.job == "Law Enforcement" or player.job == "Fire/EMS" or player.job == "Coroner" then

		loadTextDict("desktop_pc")
		loadTextDict("desktop_sar")
		
		for _, item in ipairs(agencies) do
			if string.upper(item.long) == string.upper(player.dept) then
				AddTextEntry("MDT_CALLSIGN", callsign)
				AddTextEntry("MDT_DEPARTMENT", item.long)
				AddTextEntry("MDT_MOTTO", item.motto)

				if tonumber(item.wallpaper[1]) then
					mdtColor = item.wallpaper
				else
					computerWallpaper = item.wallpaper
					loadTextDict(computerWallpaper[1])
				end
			end
		end

		if #args > 0 then
			mdtPageStack = {{tonumber(args[1]), 0}}
			if #args > 1 then
				computerWallpaper = computerWallpapers[tonumber(args[2])]
				loadTextDict(computerWallpaper[1])
			end
		end

		local theme = GetUserSettings("Computer Theme")
		computerTheme = computerThemes[theme]
		computerTaskbar = computerTaskbars[theme]

		mdtRenderPage = table.duplicate(mdtLayout[mdtPageStack[1][1]])

		for _, item in ipairs(mdtRenderPage) do
			if item.txd then
				loadTextDict(item.txd)
			end
		end

		if mdtRenderPage[1].refresh then
			for _, item in ipairs(mdtRenderPage[1].refresh) do
				ExecuteCommand(item)
			end
		end
		mdtOpen = not mdtOpen
	end

end, false)

computerWallpaper = nil
computerWallpapers = {
	{"desktop_sar", "wallpaper_vista"},
	{"desktop_sar", "wallpaper_xl"},
	{"hacking_pc_desktop_0", "hacking_pc_desktop_0"},
	{"hacking_pc_desktop_1", "hacking_pc_desktop_1"},
	{"hacking_pc_desktop_2", "hacking_pc_desktop_2"},
	{"hacking_pc_desktop_3", "hacking_pc_desktop_3"},
	{"hacking_pc_desktop_4", "hacking_pc_desktop_4"},
	{"hacking_pc_desktop_5", "hacking_pc_desktop_5"},
	{"hacking_pc_desktop_6", "hacking_pc_desktop_6"},
}

computerTaskbar = nil
computerTaskbars = {
	{ -- Windows XP style (Facade XL)
		{x = 0.8, y = 0.985, height = 0.03, width = 0.4, txd = "desktop_sar", sprite = "bar_xl"},
		{x = 0.615, y = 0.985, height = 0.03, width = 0.03, txd = "desktop_sar", sprite = "start_vista"},
		{x = 0.97, y = 0.985, height = 0.03, width = 0.06, txd = "desktop_sar", sprite = "end_xl"},

		{text = "CURRENT_TIME", x = 0.98, y = 0.983, size = 0.22, font = 0, label = true, color = {r = 255, g = 255, b = 255}},
		{text = "CURRENT_DATE", x = 0.98, y = 0.997, size = 0.22, font = 0, label = true, color = {r = 255, g = 255, b = 255}},
	},
	{ -- Windows 7 style (Facade 6.9)
		{x = 0.8, y = 0.985, height = 0.03, width = 0.4, color = {r = 80, g = 136, b = 192}},
		{x = 0.8, y = 0.985, height = 0.03, width = 0.4, txd = "desktop_sar", sprite = "bar_vista"},
		{x = 0.615, y = 0.985, height = 0.03, width = 0.03, txd = "desktop_sar", sprite = "start_vista"},

		{text = "CURRENT_TIME", x = 0.98, y = 0.983, size = 0.22, font = 0, label = true, color = {r = 255, g = 255, b = 255}},
		{text = "CURRENT_DATE", x = 0.98, y = 0.997, size = 0.22, font = 0, label = true, color = {r = 255, g = 255, b = 255}},
	},
	{ -- Windows 10 style (Facade One)
		{x = 0.8, y = 0.985, height = 0.03, width = 0.4, color = {r = 0, g = 0, b = 0}},
		{x = 0.615, y = 0.985, height = 0.03, width = 0.03, txd = "desktop_sar", sprite = "start_vista"},

		{text = "CURRENT_TIME", x = 0.98, y = 0.983, size = 0.22, font = 0, label = true, color = {r = 255, g = 255, b = 255}},
		{text = "CURRENT_DATE", x = 0.98, y = 0.997, size = 0.22, font = 0, label = true, color = {r = 255, g = 255, b = 255}},
	},
	{ -- Windows 11 style (Facade One2)
		{x = 0.8, y = 0.985, height = 0.03, width = 0.4, color = {r = 255, g = 255, b = 255}},
		{x = 0.615, y = 0.985, height = 0.03, width = 0.03, txd = "desktop_sar", sprite = "start_vista"},

		{text = "CURRENT_TIME", x = 0.98, y = 0.983, size = 0.22, font = 0, label = true, color = {r = 255, g = 255, b = 255}},
		{text = "CURRENT_DATE", x = 0.98, y = 0.997, size = 0.22, font = 0, label = true, color = {r = 255, g = 255, b = 255}},
	},
}

computerTheme = {header = {r = 80, g = 136, b = 192}, window = {r = 180, g = 180, b = 180}}
computerThemes = {
	{header = {r = 0, g = 80, b = 230}, window = {r = 180, g = 180, b = 180}}, -- Facade XL
	{header = {r = 80, g = 136, b = 192}, window = {r = 220, g = 230, b = 240}}, -- Facade 6.9
	{header = {r = 0, g = 0, b = 0}, window = {r = 30, g = 30, b = 40}}, -- Facade One
	{header = {r = 240, g = 240, b = 240}, window = {r = 255, g = 255, b = 255}}, -- Facade One2
}	

mdtLayout = {
	{ -- Page 1 - Home screen
		{
			title = "Wiwang MDT - Homepage", 
			txd = "desktop_sar", 
			sprite = "wiwang",
			window = {x = 0.4, y = 0.37, color = {r = 140, g = 140, b = 140}}, 
			refresh = {"mdt_get_attached_call"}
		},



		{text = "MDT_DEPARTMENT", x = 0.61, y = 0.65, size = 0.5, wrap = 1.0, font = 4, label = true},
		{text = "MDT_MOTTO", x = 0.9, y = 0.66, size = 0.35, wrap = 0.0, font = 1, label = true},

		{x = 0.95, y = 0.655, width = 0.08, height = 0.03, accent = {r = 20, g = 20, b = 20}},
		{text = "CURRENT_TIME", x = 0.985, y = 0.655, size = 0.38, wrap = 0.0, font = 4, label = true},
		{text = "MDT_CALLSIGN", x = 0.915, y = 0.655, size = 0.4, wrap = 1.0, font = 4, label = true},

		{x = 0.68, y = 0.7, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 177, g = 78, b = 0}, enterFunction = {"busy"}},
		{text = "BUSY", x = 0.68, y = 0.7, size = 0.4, color = {r = 200, g = 200, b = 200}},

		{x = 0.74, y = 0.7, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 169, g = 0, b = 18}, enterFunction = {"unavailable"}},
		{text = "UNAVAILABLE", x = 0.74, y = 0.7, size = 0.4, color = {r = 200, g = 200, b = 200}},

		{x = 0.8, y = 0.7, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 33, g = 145, b = 134}, enterFunction = {"clear"}},
		{text = "CLEAR", x = 0.8, y = 0.7, size = 0.4, color = {r = 200, g = 200, b = 200}},

		{x = 0.86, y = 0.7, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 36, g = 78, b = 156}, enterFunction = {"enroute", "mdt_set_state Assigned"}},
		{text = "ENROUTE", x = 0.86, y = 0.7, size = 0.4, color = {r = 200, g = 200, b = 200}},

		{department = "Law Enforcement", x = 0.92, y = 0.7, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 36, g = 156, b = 62}, enterFunction = {"c6", "mdt_set_state On Scene"}},
		{department = "Law Enforcement", text = "CODE SIX", x = 0.92, y = 0.7, size = 0.4, color = {r = 200, g = 200, b = 200}},

		{department = "Fire/EMS", x = 0.92, y = 0.7, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 36, g = 156, b = 62}, enterFunction = {"onscene", "mdt_set_state On Scene"}},
		{department = "Fire/EMS", text = "ON SCENE", x = 0.92, y = 0.7, size = 0.4, color = {r = 200, g = 200, b = 200}},

		{department = "Coroner", x = 0.92, y = 0.7, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 36, g = 156, b = 62}, enterFunction = {"onscene", "mdt_set_state On Scene"}},
		{department = "Coroner", text = "ON SCENE", x = 0.92, y = 0.7, size = 0.4, color = {r = 200, g = 200, b = 200}},

		{x = 0.65, y = 0.75, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_open_page 2"}},
		{text = "VIEW CALLS", x = 0.65, y = 0.75, size = 0.4},

		{department = "Law Enforcement", x = 0.65, y = 0.79, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_open_page 3"}},
		{department = "Fire/EMS", x = 0.65, y = 0.79, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_open_page 3"}},
		{department = "Coroner", x = 0.65, y = 0.79, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_open_page 3"}},
		{text = "ACTIVE UNITS", x = 0.65, y = 0.79, size = 0.4},

		{department = "Law Enforcement", x = 0.65, y = 0.83, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_run"}},
		{department = "Law Enforcement", text = "CPDB LOOKUP", x = 0.65, y = 0.83, size = 0.4},

		{department = "Fire/EMS", x = 0.65, y = 0.83, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_open_page 6"}},
		{department = "Fire/EMS", text = "FIRE RECORDS", x = 0.65, y = 0.83, size = 0.4},

		{department = "Coroner", x = 0.65, y = 0.83, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_open_page 6"}},
		{department = "Coroner", text = "CORONER RECORDS", x = 0.65, y = 0.83, size = 0.4},

		{department = "Law Enforcement", index = 10, x = 0.65, y = 0.87, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_open_page 6"}},
		{department = "Law Enforcement", text = "POLICE RECORDS", x = 0.65, y = 0.87, size = 0.4},

		{text = "REQUEST", x = 0.61, y = 0.95, size = 0.4, wrap = 1.0},

		{x = 0.71, y = 0.95, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_request_backup Requesting LEO"}},
		{department = "Law Enforcement", text = "BACKUP", x = 0.71, y = 0.95, size = 0.4},
		{department = "Fire/EMS", text = "LEO", x = 0.71, y = 0.95, size = 0.4},
		{department = "Coroner", text = "LEO", x = 0.71, y = 0.95, size = 0.4},

		{x = 0.77, y = 0.95, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_request_backup Requesting Fire/EMS"}},
		{text = "FIRE/EMS", x = 0.77, y = 0.95, size = 0.4},

		{x = 0.83, y = 0.95, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_request_backup Animal Control"}},
		{text = "ANIMAL CONT", x = 0.83, y = 0.95, size = 0.4},

		{x = 0.89, y = 0.95, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_request_backup Coroner"}},
		{text = "CORONER", x = 0.89, y = 0.95, size = 0.4},

		{x = 0.95, y = 0.95, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_request_backup Tow Truck"}},
		{text = "TOW", x = 0.95, y = 0.95, size = 0.4},

		{x = 0.84, y = 0.78, width = 0.29, height = 0.09, color = {r = 20, g = 20, b = 20}},
		{text = "MDT_CALL_INFO", x = 0.735, y = 0.75, size = 0.36, wrap = 0.975, font = 4, label = true},
		{text = "INFO", x = 0.7, y = 0.75, size = 0.38, wrap = 1.0},

		{x = 0.84, y = 0.875, width = 0.29, height = 0.08, color = {r = 20, g = 20, b = 20}},
		{text = "NOTES", x = 0.7, y = 0.85, size = 0.38, wrap = 1.0},
		{text = "MDT_CALL_NOTES", x = 0.735, y = 0.85, size = 0.36, wrap = 0.975, font = 4, label = true},

	},
	{ -- Page 2 - Displaying all calls
		{
			title = "Wiwang MDT - Calls", 
			txd = "desktop_sar", 
			sprite = "wiwang",
			window = {x = 0.4, y = 0.37, color = {r = 140, g = 140, b = 140}}, 
			refresh = {"mdt_get_latest_call", "mdt_mark_read"}
		},



		{x = 0.635, y = 0.64, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 36, g = 78, b = 156}, enterFunction = {"mdt_set_gps", "mdt_attach_to_call ENROUTE", "mdt_set_state Assigned"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{text = "SELF ASSIGN", x = 0.635, y = 0.64, size = 0.4},

		{department = "Law Enforcement", x = 0.635, y = 0.68, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 36, g = 156, b = 62}, enterFunction = {"mdt_attach_to_call CODE SIX", "mdt_set_state On Scene"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{department = "Law Enforcement", text = "CODE SIX", x = 0.635, y = 0.68, size = 0.4},

		{department = "Fire/EMS", x = 0.635, y = 0.68, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 36, g = 156, b = 62}, enterFunction = {"mdt_attach_to_call ON SCENE", "mdt_set_state On Scene"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{department = "Fire/EMS", text = "ON SCENE", x = 0.635, y = 0.68, size = 0.4},

		{department = "Coroner", x = 0.635, y = 0.68, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 36, g = 156, b = 62}, enterFunction = {"mdt_attach_to_call ON SCENE", "mdt_set_state On Scene"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{department = "Coroner", text = "ON SCENE", x = 0.635, y = 0.68, size = 0.4},

		{x = 0.635, y = 0.72, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, accent = {r = 33, g = 145, b = 134}, enterFunction = {"mdt_set_state Resolved", "clear"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{text = "RESOLVED", x = 0.635, y = 0.72, size = 0.4},

		{x = 0.635, y = 0.76, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_set_gps"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{text = "SET GPS", x = 0.635, y = 0.76, size = 0.4},

		{x = 0.635, y = 0.8, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_edit_notes"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{text = "EDIT NOTES", x = 0.635, y = 0.8, size = 0.4},

		{x = 0.635, y = 0.84, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_request_backup Created Incident"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{text = "CREATE CALL", x = 0.635, y = 0.84, size = 0.4},

		{x = 0.635, y = 0.88, width = 0.05, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_call_lookup"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{text = "SEARCH BY ID", x = 0.635, y = 0.88, size = 0.4},

		{department = "Law Enforcement", x = 0.635, y = 0.94, width = 0.05, height = 0.05, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_request_backup Crime Broadcast"}, leftFunction = "mdt_get_next_call", rightFunction = "mdt_get_previous_call"},
		{department = "Law Enforcement", text = "CRIME~n~BROADCAST", x = 0.635, y = 0.93, size = 0.4},

		{x = 0.73, y = 0.645, width = 0.12, height = 0.03, color = {r = 20, g = 20, b = 20}},
		{text = "MDT_CALL_TYPE", x = 0.71, y = 0.645, size = 0.38, wrap = 1.0, font = 4, label = true},
		{text = "TYPE", x = 0.675, y = 0.645, size = 0.38, wrap = 1.0},

		{x = 0.85, y = 0.645, width = 0.08, height = 0.03, color = {r = 20, g = 20, b = 20}},
		{text = "MDT_CALL_PR", x = 0.815, y = 0.645, size = 0.38, wrap = 1.0, font = 4, label = true},

		{x = 0.965, y = 0.645, width = 0.05, height = 0.03, color = {r = 20, g = 20, b = 20}},
		{text = "MDT_CALL_NUMBER", x = 0.945, y = 0.645, size = 0.38, wrap = 1.0, font = 4, label = true},

		{x = 0.755, y = 0.685, width = 0.17, height = 0.03, color = {r = 20, g = 20, b = 20}},
		{text = "MDT_CALL_ADDRESS", x = 0.71, y = 0.685, size = 0.38, wrap = 1.0, font = 4, label = true},
		{text = "ADDRESS", x = 0.675, y = 0.685, size = 0.38, wrap = 1.0},

		{x = 0.92, y = 0.685, width = 0.11, height = 0.03, color = {r = 20, g = 20, b = 20}},
		{text = "MDT_CALL_STATE", x = 0.905, y = 0.685, size = 0.38, wrap = 1.0, font = 4, label = true},
		{text = "STATE", x = 0.87, y = 0.685, size = 0.38, wrap = 1.0},

		{x = 0.83, y = 0.77, width = 0.32, height = 0.09, color = {r = 20, g = 20, b = 20}},
		{text = "MDT_CALL_INFO", x = 0.71, y = 0.74, size = 0.36, wrap = 0.99, font = 4, label = true},
		{text = "INFO", x = 0.675, y = 0.74, size = 0.38, wrap = 1.0},

		{x = 0.83, y = 0.865, width = 0.32, height = 0.08, color = {r = 20, g = 20, b = 20}},
		{text = "NOTES", x = 0.675, y = 0.84, size = 0.38, wrap = 1.0},
		{text = "MDT_CALL_NOTES", x = 0.71, y = 0.84, size = 0.36, wrap = 0.99, font = 4, label = true},

		{x = 0.83, y = 0.94, width = 0.32, height = 0.05, color = {r = 20, g = 20, b = 20}},

		{text = "MDT_CALL_ATTACHED", x = 0.71, y = 0.93, size = 0.38, wrap = 0.99, font = 4, label = true},
		{text = "ATTACHED", x = 0.675, y = 0.93, size = 0.38, wrap = 0.99},
	},
	{ -- Page 3 - Unit Roster
		{
			title = "Wiwang MDT - Active Units", 
			txd = "desktop_sar", 
			sprite = "wiwang",
			window = {x = 0.4, y = 0.37, color = {r = 140, g = 140, b = 140}}, 
			refresh = {"mdt_refresh_roster"}
		},



		{x = 0.66, y = 0.66, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_set_unit_display Law Enforcement", "mdt_refresh_roster"}, leftFunction = "mdt_decrement_roster_page", rightFunction = "mdt_increment_roster_page"},
		{text = "LEO UNITS", x = 0.66, y = 0.66, size = 0.4},

		{x = 0.66, y = 0.70, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_set_unit_display Fire/EMS", "mdt_refresh_roster"}, leftFunction = "mdt_decrement_roster_page", rightFunction = "mdt_increment_roster_page"},
		{text = "FD/EMS UNITS", x = 0.66, y = 0.70, size = 0.4},

		{x = 0.66, y = 0.74, width = 0.07, height = 0.03, color = {r = 0, g = 0, b = 0}, enterFunction = {"mdt_set_unit_display Coroner", "mdt_refresh_roster"}, leftFunction = "mdt_decrement_roster_page", rightFunction = "mdt_increment_roster_page"},
		{text = "MISC UNITS", x = 0.66, y = 0.74, size = 0.4},

		{text = "MDT_CALLSIGN_LIST", x = 0.72, y = 0.64, size = 0.38, wrap = 1.0, font = 4, label = true},
		{text = "MDT_NAME_LIST", x = 0.8, y = 0.64, size = 0.38, wrap = 1.0, font = 4, label = true},
		{text = "MDT_STATUS_LIST", x = 0.97, y = 0.64, size = 0.38, wrap = 0.1, font = 4, label = true},
	},
	{ -- Page 4 - Facade Homescreen Test
		{refresh = {}},

		{x = 0.63, y = 0.64, width = 0.03, height = 0.05, txd = "hacking_pc", sprite = "network", enterFunction = {"mdt_open_page 1"}},
		{text = "Old MDT", x = 0.63, y = 0.68, size = 0.25, font = 13, color = {r = 255, g = 255, b = 255}},
		
		{x = 0.63, y = 0.72, width = 0.03, height = 0.05, txd = "desktop_sar", sprite = "wiwang", enterFunction = {"mdt_open_page 5"}},
		{text = "Wiwang MDT", x = 0.63, y = 0.76, size = 0.25, font = 13, color = {r = 255, g = 255, b = 255}},

		{x = 0.63, y = 0.8, width = 0.03, height = 0.05, txd = "hacking_pc", sprite = "harddrive", enterFunction = {"mdt_open_page 6"}},
		{text = "USB Storage~n~Device", x = 0.63, y = 0.84, size = 0.25, font = 13, color = {r = 255, g = 255, b = 255}},
	},

	{ -- Page 5 - New MDT Home Screen
		{
			title = "Wiwang MDT - Development Mode", 
			txd = "desktop_sar", 
			sprite = "wiwang",
			window = {x = 0.4, y = 0.37}, 
			refresh = {}
		},



		{x = 0.625, y = 0.65, width = 0.05, height = 0.05, accent = {r = 177, g = 78, b = 0}, enterFunction = {"busy"}},
		{text = "Busy", x = 0.605, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{text = "F1", x = 0.605, y = 0.64, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{x = 0.675, y = 0.65, width = 0.05, height = 0.05, accent = {r = 169, g = 0, b = 18}, enterFunction = {"unavailable"}},
		{text = "Unavailable", x = 0.655, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{text = "F2", x = 0.655, y = 0.64, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{x = 0.725, y = 0.65, width = 0.05, height = 0.05, accent = {r = 33, g = 145, b = 134}, enterFunction = {"clear"}},
		{text = "Clear", x = 0.705, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{text = "F3", x = 0.705, y = 0.64, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{x = 0.775, y = 0.65, width = 0.05, height = 0.05, accent = {r = 36, g = 78, b = 156}, enterFunction = {"enroute"}},
		{text = "Enroute", x = 0.755, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{text = "F4", x = 0.755, y = 0.64, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{department = "Law Enforcement", x = 0.825, y = 0.65, width = 0.05, height = 0.05, accent = {r = 36, g = 156, b = 62}, enterFunction = {"codesix"}},
		{department = "Law Enforcement", text = "Code Six", x = 0.805, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{department = "Fire/EMS", x = 0.825, y = 0.65, width = 0.05, height = 0.05, accent = {r = 36, g = 156, b = 62}, enterFunction = {"onscene"}},
		{department = "Fire/EMS", text = "On Scene", x = 0.805, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{department = "Coroner", x = 0.825, y = 0.65, width = 0.05, height = 0.05, accent = {r = 36, g = 156, b = 62}, enterFunction = {"onscene"}},
		{department = "Coroner", text = "On Scene", x = 0.805, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{text = "F5", x = 0.805, y = 0.64, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{x = 0.875, y = 0.65, width = 0.05, height = 0.05, accent = {r = 150, g = 150, b = 150}, enterFunction = {"mdt_open_page 6"}},
		{text = "TBD 1", x = 0.855, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{text = "F6", x = 0.855, y = 0.64, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{x = 0.925, y = 0.65, width = 0.05, height = 0.05, accent = {r = 150, g = 150, b = 150}, enterFunction = {"mdt_open_page 6"}},
		{text = "TBD 2", x = 0.905, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{text = "F7", x = 0.905, y = 0.64, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{x = 0.975, y = 0.65, width = 0.05, height = 0.05, accent = {r = 150, g = 150, b = 150}, enterFunction = {"mdt_open_page 6"}},
		{text = "TBD 3", x = 0.955, y = 0.66, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
		{text = "F8", x = 0.955, y = 0.64, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{x = 0.64, y = 0.945, width = 0.08, height = 0.04, accent = {r = 150, g = 150, b = 150}, enterFunction = {"mdt_open_page 6"}},
		{text = "NAME~n~LOOKUP", x = 0.605, y = 0.94, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{x = 0.72, y = 0.945, width = 0.08, height = 0.04, accent = {r = 150, g = 150, b = 150}, enterFunction = {"mdt_open_page 6"}},
		{text = "PLATE~n~LOOKUP", x = 0.685, y = 0.94, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},

		{x = 0.8, y = 0.945, width = 0.08, height = 0.04, accent = {r = 150, g = 150, b = 150}, enterFunction = {"mdt_open_page 6"}},
		{text = "FIREARM~n~LOOKUP", x = 0.765, y = 0.94, size = 0.3, font = 13, wrap = 1.0, color = {r = 0, g = 0, b = 0}},
	},

	{ -- Coming Soon Popup
		{title = "Coming Soon", window = {x = 0.12, y = 0.12}, refresh = {}},

		{x = 0.75, y = 0.76, size = 0.3, text = "This feature hasn\'t been implemented yet.", font = 13, wrap = 0.85, color = {r = 0, g = 0, b = 0}},

		{x = 0.8, y = 0.82, width = 0.05, height = 0.03, enterFunction = {"mdt_close_page"}},
		{text = "Okay", x = 0.8, y = 0.82, size = 0.3, font = 13, color = {r = 0, g = 0, b = 0}},
	},
}

Citizen.CreateThread(function()
	for _, superitem in ipairs(mdtLayout) do
		counter = 0
		for i, item in ipairs(superitem) do
			if item.enterFunction then
				item.index = counter
				counter = counter + 1
			end
		end
	end

	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(0, 19) and mdtOpen then
			mdtMouseControl = not mdtMouseControl
		end
	end
end)

mdtPageStack = {{1, 0}}


function DrawMdt()
	-- Arrow Keys
	DisableControlAction(0, 27, true)
	DisableControlAction(0, 172, true)
	DisableControlAction(0, 173, true)
	DisableControlAction(0, 174, true)
	DisableControlAction(0, 175, true)
	DisableControlAction(0, 176, true)
	DisableControlAction(0, 177, true)

	-- Mouse Attack Keys
	DisableControlAction(0, 18, true)
	DisableControlAction(0, 24, true)
	DisableControlAction(0, 69, true)
	DisableControlAction(0, 92, true)
	DisableControlAction(0, 106, true)
	DisableControlAction(0, 122, true)

	SetScriptGfxDrawOrder(3)
	if computerWallpaper then
		DrawSprite(computerWallpaper[1], computerWallpaper[2], 0.8 + safezoneSize - 0.5, 0.8 + safezoneSize - 0.5, 0.4, 0.4, 0.0, 255, 255, 255, 255)
	else
		DrawRect(0.8 + safezoneSize - 0.5, 0.8 + safezoneSize - 0.5, 0.4, 0.4, mdtColor[1], mdtColor[2], mdtColor[3], 255)
	end

	SetScriptGfxDrawOrder(4)

	if mdtRenderPage[1].window then
		if mdtRenderPage[1].window.x < 0.4 or mdtRenderPage[1].window.y < 0.37 then
			local mdtTempRender = mdtLayout[mdtPageStack[2][1]]

			if computerTheme and mdtTempRender[1].window then
				local window = mdtTempRender[1].window

				if window.color then
					DrawRect(0.8 + safezoneSize - 0.5, 0.785 + safezoneSize - 0.5, window.x, window.y, window.color.r, window.color.g, window.color.b, 255)
				else
					DrawRect(0.8 + safezoneSize - 0.5, 0.785 + safezoneSize - 0.5, window.x, window.y, computerTheme.window.r, computerTheme.window.g, computerTheme.window.b, 255)
				end

				if mdtTempRender[1].title then
					DrawRect(0.8 + safezoneSize - 0.5, 0.795 + safezoneSize - 0.5 - (window.y/2), window.x, 0.02, computerTheme.header.r, computerTheme.header.g, computerTheme.header.b, 255)

					if mdtTempRender[1].sprite then
						DrawSprite(mdtTempRender[1].txd, mdtTempRender[1].sprite, 0.808 + safezoneSize - 0.5 - window.x/2, 0.795 + safezoneSize - 0.5 - (window.y/2), 0.01, 0.018, 0.0, 255, 255, 255, 255)
					end

					WriteText(0.815 - window.x/2, 0.785 - window.y/2, 0.25, mdtTempRender[1].title, 13, 0, 1.0, false, true, false, 255, 255, 255, 255)
					WriteText(0.795 + window.x/2, 0.785 - window.y/2, 0.25, "-  X", 0, 0, 0.0, false, true, false, 255, 255, 255, 255)
				end

				DrawRect(0.8 + safezoneSize - 0.5, 0.785 + safezoneSize - 0.5, window.x, window.y, 0, 0, 0, 20)
				
			end

			for _, item in ipairs(mdtTempRender) do
				RenderComputerItem(item, false)
			end
		end
	end

	SetScriptGfxDrawOrder(5)
	if computerTheme and mdtRenderPage[1].window then
		local window = mdtRenderPage[1].window
		if window.color then
			DrawRect(0.8 + safezoneSize - 0.5, 0.785 + safezoneSize - 0.5, window.x, window.y, window.color.r, window.color.g, window.color.b, 255)
		else
			DrawRect(0.8 + safezoneSize - 0.5, 0.785 + safezoneSize - 0.5, window.x, window.y, computerTheme.window.r, computerTheme.window.g, computerTheme.window.b, 255)
		end

		if mdtRenderPage[1].title then
			DrawRect(0.8 + safezoneSize - 0.5, 0.795 + safezoneSize - 0.5 - (window.y/2), window.x, 0.02, computerTheme.header.r, computerTheme.header.g, computerTheme.header.b, 255)

			if mdtRenderPage[1].sprite then
				DrawSprite(mdtRenderPage[1].txd, mdtRenderPage[1].sprite, 0.808 + safezoneSize - 0.5 - window.x/2, 0.795 + safezoneSize - 0.5 - (window.y/2), 0.01, 0.018, 0.0, 255, 255, 255, 255)
			end

			WriteText(0.815 - window.x/2, 0.785 - window.y/2, 0.25, mdtRenderPage[1].title, 13, 0, 1.0, false, true, false, 255, 255, 255, 255)
			WriteText(0.795 + window.x/2, 0.785 - window.y/2, 0.25, "-  X", 0, 0, 0.0, false, true, false, 255, 255, 255, 255)

		end
	end

	for _, item in ipairs(mdtRenderPage) do
		RenderComputerItem(item, true)
	end

	if computerTaskbar then
		for _, item in ipairs(computerTaskbar) do
			RenderComputerItem(item, false)
		end
	end

	SetScriptGfxDrawOrder(4)

	if mdtMouseControl then

		DisableControlAction(0, 1)
		DisableControlAction(0, 2)
				
		local mouseX = GetDisabledControlNormal(0, 1) / 5
		local mouseY = GetDisabledControlNormal(0, 2) / 5
		cursorX = cursorX + mouseX
		cursorY = cursorY + mouseY
		if cursorX > safezoneSize + 0.5 then
			cursorX = safezoneSize + 0.5
		elseif cursorX < 0.1 + safezoneSize then
			cursorX = safezoneSize + 0.1
		end

		if cursorY > safezoneSize + 0.5 then
			cursorY = safezoneSize + 0.5
		elseif cursorY < 0.1 + safezoneSize then
			cursorY = safezoneSize + 0.1
		end

		
		SetScriptGfxDrawOrder(6)
		DrawSprite("desktop_pc", "arrow", cursorX + 0.005, cursorY + 0.01, 0.01, 0.02, 0.0, 255, 255, 255, 255)
		SetScriptGfxDrawOrder(4)
	end

	ProcessComputerInput(mdtRenderPage)

	if IsDisabledControlJustPressed(0, 177) and UpdateOnscreenKeyboard() ~= 0 then -- Backspace
		if #mdtPageStack == 1 then
			mdtOpen = false
		else
			table.remove(mdtPageStack, 1)
			mdtRenderPage = table.duplicate(mdtLayout[mdtPageStack[1][1]])

			if mdtRenderPage[1].refresh then
				for _, item in ipairs(mdtRenderPage[1].refresh) do
					ExecuteCommand(item)
				end
			end
		end
	end
end

function ProcessComputerInput(page)

	if mdtMouseControl then
		local mouseFound = false
		for _, item in ipairs(page) do
			if item.index and (not item.department or (item.department == player.job)) then
				if cursorX < item.x + safezoneSize - 0.5 + (item.width/2) and cursorX > item.x + safezoneSize - 0.5 - (item.width/2) and cursorY < item.y + safezoneSize - 0.5 + (item.height/2) and cursorY > item.y + safezoneSize - 0.5 - (item.height/2) then
					mdtPageStack[1][2] = item.index
					mouseFound = true
				end
			end
		end
		if not mouseFound then
			mdtPageStack[1][2] = -1
		end
	elseif mdtPageStack[1][2] == -1 then
		mdtPageStack[1][2] = -1
	end


	for _, item in ipairs(page) do
		if item.index == mdtPageStack[1][2] and UpdateOnscreenKeyboard() ~= 0 and (not item.department or (item.department == player.job)) then
			if IsDisabledControlJustPressed(0,176) and item.enterFunction then
				for _, x in ipairs(item.enterFunction) do
					ExecuteCommand(x)
				end
			elseif IsDisabledControlJustPressed(0,172) then
				if item.upFunction then
					ExecuteCommand(item.upFunction)
				else
					SetMdtIndex("UP")
				end
				break
			elseif IsDisabledControlJustPressed(0,173) then
				if item.downFunction then
					ExecuteCommand(item.downFunction)
				else
					SetMdtIndex("DOWN")
				end
				break
			elseif IsDisabledControlJustPressed(0,174) then
				if item.leftFunction then
					ExecuteCommand(item.leftFunction)
				else
					SetMdtIndex("LEFT")
				end
				break
			elseif IsDisabledControlJustPressed(0,175) then
				if item.rightFunction then
					ExecuteCommand(item.rightFunction)
				else
					SetMdtIndex("RIGHT")
				end
				break
			end
		end
	end

end

function RenderComputerItem(item, inputs)
	if (not item.department or (item.department == player.job)) and item.x and item.y then

		local color = computerTheme.window

		if item.index then
			if item.sprite then -- Button is an icon of some sort
				DrawSprite(item.txd, item.sprite, item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width, item.height, 0.0, 255, 255, 255, 255)
				if inputs and mdtPageStack[1][2] == item.index then
					DrawRect(item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width, item.height, 255, 255, 255, 50)
				end
			else
			
				if item.color then
					color = item.color
				end

				if item.accent then -- Item has an accent color
					DrawRect(item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width, item.height, item.accent.r, item.accent.g, item.accent.b, 255)
				else
					if color.r+color.g+color.b > 400 then
						DrawRect(item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width, item.height, color.r - 60, color.g - 60, color.b - 60, 255)
					else
						DrawRect(item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width, item.height, color.r + 60, color.g + 60, color.b + 60, 255)
					end
				end

				if inputs and mdtPageStack[1][2] == item.index then
					if color.r+color.g+color.b > 400 then
						DrawRect(item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width - 0.003, item.height - 0.004, color.r - 40, color.g - 40, color.b - 40, 255)
					else
						DrawRect(item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width - 0.003, item.height - 0.004, color.r + 40, color.g + 40, color.b + 40, 255)
					end
				else
					DrawRect(item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width - 0.003, item.height - 0.004, color.r, color.g, color.b, 255)
				end
			end
		elseif item.text then
			if (item.text == player.status and mdtPageStack[1][1] == 1) or not item.color then
				WriteText(item.x, item.y - 0.014, item.size, item.text, item.font or 4, 0, item.wrap or nil, item.label or false, true, false, 255, 255, 255, 255)
			else
				WriteText(item.x, item.y - 0.014, item.size, item.text, item.font or 4, 0, item.wrap or nil, item.label or false, true, false, item.color.r, item.color.g, item.color.b, 255)
			end
		elseif item.sprite then
			DrawSprite(item.txd, item.sprite, item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width, item.height, 0.0, 255, 255, 255, 255)
		elseif item.color then
			DrawRect(item.x + safezoneSize - 0.5, item.y + safezoneSize - 0.5, item.width, item.height, item.color.r, item.color.g, item.color.b, 255)
		end
	end

end

function SetMdtIndex(direction)

	if not mdtMouseControl then

		local closest = 100.0
		local newIndex = nil
		x, y = 0, 0
		for _, item in ipairs(mdtRenderPage) do
			if mdtPageStack[1][2] == item.index then
				x = item.x
				y = item.y
			end
		end
		
		for _, item in ipairs(mdtRenderPage) do
			if item.index and (item.index ~= mdtPageStack[1][2]) then
				if (direction == "DOWN" and item.y > y) or (direction == "UP" and item.y < y) or (direction == "LEFT" and item.x < x) or (direction == "RIGHT" and item.x > x) then
					local distance = Vdist2(x, y, 0.0, item.x, item.y, 0.0)
					if distance < closest and ((item.department == player.job) or not item.department) then
						closest = distance
						newIndex = item.index
					end
				end
			end
		end

		if newIndex then
			mdtPageStack[1][2] = newIndex
		end
	end
end

RegisterCommand("mdt_set_index", function(source, args, rawCommand)
	for _, item in ipairs(mdtRenderPage) do
		if item.index == tonumber(args[1]) and ((item.department == player.job) or not item.department) then
			mdtPageStack[1][2] = tonumber(args[1])
		end
	end
end)

RegisterCommand("mdt_open_page", function(source, args, rawCommand)
	for _, item in ipairs(mdtLayout[tonumber(args[1])]) do
		if item.txd then
			loadTextDict(item.txd)
		end
	end

	table.insert(mdtPageStack, 1, {tonumber(args[1]), 0})
	mdtRenderPage = table.duplicate(mdtLayout[mdtPageStack[1][1]])

	if mdtRenderPage[1].refresh then
		for _, item in ipairs(mdtRenderPage[1].refresh) do
			ExecuteCommand(item)
		end
	end
end)

RegisterCommand("mdt_close_page", function(source, args, rawCommand)
	table.remove(mdtPageStack, 1)
	mdtRenderPage = table.duplicate(mdtLayout[mdtPageStack[1][1]])

	if mdtRenderPage[1].refresh then
		for _, item in ipairs(mdtRenderPage[1].refresh) do
			ExecuteCommand(item)
		end
	end


end)


RegisterCommand("mdt_get_latest_call", function(source, args, rawCommand)
	TriggerServerEvent("mdt:GetEmergencyCall", player.incident)
end)

RegisterCommand("mdt_get_attached_call", function(source, args, rawCommand)
	if player.incident ~= 0 then
		TriggerServerEvent("mdt:GetEmergencyCall", player.incident)
	else
		AddTextEntry("MDT_CALL_INFO", "")
		AddTextEntry("MDT_CALL_NOTES", "")
		
	end
end)

RegisterCommand("mdt_get_previous_call", function(source, args, rawCommand)
	mdtIncidentNumber = mdtIncidentNumber - 1
	TriggerServerEvent("mdt:GetEmergencyCall", mdtIncidentNumber)
end)

RegisterCommand("mdt_get_next_call", function(source, args, rawCommand)
	mdtIncidentNumber = mdtIncidentNumber + 1
	TriggerServerEvent("mdt:GetEmergencyCall", mdtIncidentNumber)
end)

RegisterCommand("mdt_call_lookup", function(source, args, rawCommand)
	N_0x3ed1438c1f5c6612(2)
	DisplayOnscreenKeyboard(0, "FMMC_SMS4", "", "", "", "", "", 300)
	repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
	if UpdateOnscreenKeyboard() == 1 then
		local message = GetOnscreenKeyboardResult()

		if tonumber(message) then
			local lookup = tonumber(message)
				
			if lookup > 10000 then
				TriggerServerEvent("mdt:GetEmergencyCall", lookup)
			end
		end
		
	elseif UpdateOnscreenKeyboard() == 2 then
		ShowInfo("Message Cancelled", 5000)
	end



end)


RegisterCommand("mdt_set_gps", function(source, args, rawCommand)
	local n = string.upper(mdtPostalInformation)
	local fp = nil
	for _, p in ipairs(postals) do
		if string.upper(p.code) == n then
			fp = p
		end
	end

   	if fp then
		SetNewWaypoint(fp.x, fp.y)
		ShowInfo("~HUD_COLOUR_WAYPOINTLIGHT~Drawing a route to ".. fp.code .. ".")
	else
		ShowInfo("~HUD_COLOUR_WAYPOINTLIGHT~Unable to locate call origin.")
	end
end)

RegisterCommand("mdt_mark_read", function(source, args, rawCommand)
	mdtUnread = nil
end)

RegisterCommand("mdt_run", function(source, args, rawCommand)
	N_0x3ed1438c1f5c6612(2)
	DisplayOnscreenKeyboard(0, "FMMC_SMS4", "", "", "", "", "", 300)
	repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
	if UpdateOnscreenKeyboard() == 1 then
		local message = GetOnscreenKeyboardResult()
		ExecuteCommand("run " .. message)
	elseif UpdateOnscreenKeyboard() == 2 then
		ShowInfo("Message Cancelled", 5000)
	end
end)

RegisterCommand("mdt_set_state", function(source, args, rawCommand)
	if table.concat(args, " ") == "Resolved" then
		TriggerServerEvent("mdt:SetCallState", mdtIncidentNumber, table.concat(args, " "))
	else
		TriggerServerEvent("mdt:SetCallState", player.incident, table.concat(args, " "))
	end
end)

RegisterCommand("mdt_attach_to_call", function(source, args, rawCommand)
	newStatus = table.concat(args, " ")
	if newStatus == "BUSY" or newStatus == "UNAVAILABLE" or newStatus == "CLEAR" then
		TriggerServerEvent("mdt:SetStatus", player.callsign, newStatus, 0)
	else
		TriggerServerEvent("mdt:SetStatus", player.callsign, newStatus, mdtIncidentNumber)
	end
end)

RegisterCommand("mdt_set_unit_display", function(source, args, rawCommand)
	mdtUnitDisplay = table.concat(args, " ")
end)

RegisterCommand("mdt_increment_roster_page", function(source, args, rawCommand)
	mdtRosterPage = mdtRosterPage + 1
	ExecuteCommand("mdt_refresh_roster")
end)


RegisterCommand("mdt_decrement_roster_page", function(source, args, rawCommand)
	if mdtRosterPage > 1 then
		mdtRosterPage = mdtRosterPage - 1
		ExecuteCommand("mdt_refresh_roster")
	end
end)

RegisterCommand("mdt_refresh_roster", function(source, args, rawCommand)
	mdtRenderPage = table.duplicate(mdtLayout[mdtPageStack[1][1]])
	
	if mdtUnitDisplay == "" then
		mdtUnitDisplay = player.job
	end

	local unitDisplay = {}
	for _, player in ipairs(onlinePlayers) do
		if player.job == mdtUnitDisplay and player.nick then
			print(player.nick)
			local unitname = string.sub(player.nick, 1, 1) .. ". " .. string.match(player.nick, '[^ ]+$') .. " ["..player.id.."]"
			addToTable = true
			for _, item in ipairs(unitDisplay) do
				if item.callsign == player.callsign then
					addToTable = false
					item.name = item.name .. ", " .. unitname
				end
			end
			if addToTable then
				table.insert(unitDisplay, {name = unitname, status = player.status, callsign = player.callsign})
			end
		end
	end

	for i = 1, 10 do
		if unitDisplay[i+(mdtRosterPage*10)-10] then
			table.insert(mdtRenderPage, {temporary = true, x = 0.84, y = 0.65 + (0.03 * i), width = 0.27, height = 0.03, color = {r = 20, g = 20, b = 20}})
			table.insert(mdtRenderPage, {temporary = true, text = unitDisplay[i+(mdtRosterPage*10)-10].callsign, x = 0.72, y = 0.65 + (0.03 * i), size = 0.38, wrap = 1.0})
			table.insert(mdtRenderPage, {temporary = true, text = unitDisplay[i+(mdtRosterPage*10)-10].name, x = 0.76, y = 0.65 + (0.03 * i), size = 0.38, wrap = 1.0})
			table.insert(mdtRenderPage, {temporary = true, text = unitDisplay[i+(mdtRosterPage*10)-10].status, x = 0.9, y = 0.65 + (0.03 * i), size = 0.38, wrap = 1.0})
		else
			table.insert(mdtRenderPage, {temporary = true, x = 0.84, y = 0.65 + (0.03 * i), width = 0.27, height = 0.03, color = {r = 0, g = 0, b = 0}})
		end
	end
	table.insert(mdtRenderPage, {temporary = true, text = mdtUnitDisplay .. " Units", x = 0.72, y = 0.65, size = 0.4, wrap = 1.0})
	table.insert(mdtRenderPage, {temporary = true, text = "Page " .. mdtRosterPage, x = 0.975, y = 0.65, size = 0.4, wrap = 0.1})
end)

RegisterCommand("mdt_edit_notes", function(source, args, rawCommand)
	N_0x3ed1438c1f5c6612(2)
	DisplayOnscreenKeyboard(0, "FMMC_SMS4", "", mdtNotes, "", "", "", 300)
	repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
	if UpdateOnscreenKeyboard() == 1 then
		local message = GetOnscreenKeyboardResult()
		TriggerServerEvent("mdt:SetNotes", mdtIncidentNumber, string.upper(message))
	elseif UpdateOnscreenKeyboard() == 2 then
		ShowInfo("Message Cancelled", 5000)
	end
end)

RegisterCommand("mdt_request_backup", function(source, args, rawCommand)
	N_0x3ed1438c1f5c6612(2)
	DisplayOnscreenKeyboard(0, "FMMC_SMS4", "", "", "", "", "", 300)
	repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
	if UpdateOnscreenKeyboard() == 1 then
		local message = GetOnscreenKeyboardResult()
		local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

		TriggerServerEvent("relaySpecialContact", table.concat(args, " "), message, GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z)), x, y, z, player.callsign, GetPlayerServerId(PlayerId()), "CHAR_DEFAULT")
	elseif UpdateOnscreenKeyboard() == 2 then
		ShowInfo("Message Cancelled", 5000)
	end
end)

function AttachedUnitList(incident)
	local units = {}
	local unitStr = ""

	if incident > 0 then
		for _, item in ipairs(onlinePlayers) do
			if item.incident == incident then

				found = false

				for _, unit in ipairs(units) do
					if unit == item.callsign then
						found = true
					end
				end
	
				if not found then
					table.insert(units, item.callsign)

					if unitStr ~= "" then
						unitStr = unitStr ..  ", "
					end
					unitStr = unitStr .. item.callsign
				end
			end
		end
		return unitStr
	end
	return ""
end

function SetMdtStatus(newStatus)
	if newStatus == "BUSY" or newStatus == "UNAVAILABLE" or newStatus == "CLEAR" then
		TriggerServerEvent("mdt:SetStatus", player.callsign, newStatus, 0)
	else
		TriggerServerEvent("mdt:SetStatus", player.callsign, newStatus, player.incident)
	end
end

RegisterNetEvent("mdt:setSpecificCallInformation")
AddEventHandler("mdt:setSpecificCallInformation", function(incidentNumber, state, notes)
	if incidentNumber == mdtIncidentNumber then
		if notes then
			AddTextEntry("MDT_CALL_NOTES", notes)
			mdtNotes = notes
		else
			AddTextEntry("MDT_CALL_STATE", state)

			AddTextEntry("MDT_CALL_ATTACHED", AttachedUnitList(mdtIncidentNumber))	
		end
	end
end)

RegisterNetEvent("mdt:setCallInformation")
AddEventHandler("mdt:setCallInformation", function(call)
	if call then
		AddTextEntry("MDT_CALL_INFO", call.message)
		AddTextEntry("MDT_CALL_TYPE", call.type)
		AddTextEntry("MDT_CALL_ADDRESS", call.postal .. " " .. call.address)
		AddTextEntry("MDT_CALL_PR", "PR   " .. call.playerName)
		AddTextEntry("MDT_CALL_NUMBER", "ID   " .. call.incidentNumber)
		AddTextEntry("MDT_CALL_NOTES", call.notes)

		AddTextEntry("MDT_CALL_STATE", call.state)
		AddTextEntry("MDT_CALL_ATTACHED", AttachedUnitList(call.incidentNumber))

		mdtNotes = call.notes
		mdtPostalInformation = call.postal
		mdtIncidentNumber = call.incidentNumber

	else
		AddTextEntry("MDT_CALL_INFO", "")
		AddTextEntry("MDT_CALL_TYPE", "No Calls Found")
		AddTextEntry("MDT_CALL_ADDRESS", "")
		AddTextEntry("MDT_CALL_PR", "")
		AddTextEntry("MDT_CALL_NUMBER", "")
		AddTextEntry("MDT_CALL_NOTES", "")

		AddTextEntry("MDT_CALL_STATE", "")
		AddTextEntry("MDT_CALL_ATTACHED", "")

		mdtNotes = ""
		mdtPostalInformation = 0
		mdtIncidentNumber = 0
	end
end)

-- Quick Commands

RegisterCommand("busy", function(source, args, rawCommand)
	SetMdtStatus("BUSY")
end)
RegisterCommand("bsy", function(source, args, rawCommand)
	SetMdtStatus("BUSY")
end)

RegisterCommand("unavailable", function(source, args, rawCommand)
	SetMdtStatus("UNAVAILABLE")
end)
RegisterCommand("ua", function(source, args, rawCommand)
	SetMdtStatus("UNAVAILABLE")
end)

RegisterCommand("clear", function(source, args, rawCommand)
	SetMdtStatus("CLEAR")
end)
RegisterCommand("cl", function(source, args, rawCommand)
	SetMdtStatus("CLEAR")
end)

RegisterCommand("enroute", function(source, args, rawCommand)
	SetMdtStatus("ENROUTE")
end)
RegisterCommand("er", function(source, args, rawCommand)
	SetMdtStatus("ENROUTE")
end)

RegisterCommand("codesix", function(source, args, rawCommand)
	SetMdtStatus("CODE SIX")
end)

RegisterCommand("c6", function(source, args, rawCommand)
	SetMdtStatus("CODE SIX")
end)
RegisterCommand("code6", function(source, args, rawCommand)
	SetMdtStatus("CODE SIX")
end)

RegisterCommand("onscene", function(source, args, rawCommand)
	SetMdtStatus("ON SCENE")
end)