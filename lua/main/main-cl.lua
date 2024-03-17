--- Republic Core client.lua

-- Variables

serverMap = "San Andreas"

-- Player information storage
informationObtained = false
player = {}

ped = nil
pedHealth = nil

clientMinute = 0
clientHour = 0

-- Format:
--[[
	id = -1, -- Player ID
	name = nil, -- The name (usually Steam name)
	member = false, -- If the player is a member
	staff = false, -- If the player is staff
	session = 0, -- The session the player is in
	nick = nil, -- The player character name
	job = "Civilian", -- Player's current job category (i.e. "Law Enforcement")
	dept = "Unemployed", -- Player's current sub-job category (i.e. "LSPD")
	callsign = nil, -- Player callsign (where applicable)
	status = "UNAVAILABLE", -- Player status (where applicable)
	incident = 0, -- Player Incident Number (where applicable)
]]

-- These are used for tracking what "job" the player currently has.
jobA = "Civilian"
jobB = "Unemployed"
callsign = ""

-- What weapons the player has access to via /rack
rack = {}

-- Server info storage

-- For the AOP Vote Script
aopVote = false
voted = true
aoplist = {}

whitelist = false

-- Visual stuff
drawAdjust = 1

_menuPool = NativeUI.CreatePool()

-- For AOP Voting Menus
aopMenu = NativeUI.CreateMenu("AOP Vote", "", 0, 0, "nativeui_headers", "header_misc")
_menuPool:Add(aopMenu)

-- Settings Menu
settingsMenu = NativeUI.CreateMenu("Settings", "", 0, 0, "nativeui_headers", "header_settings")
_menuPool:Add(settingsMenu)

-- Session Change Menu
sessionMenu = NativeUI.CreateMenu("Session Selector", "", 0, 0, "nativeui_headers", "header_session")
_menuPool:Add(sessionMenu)

-- Starting Jobs Menu
jobMenu = NativeUI.CreateMenu("Jobs", "", 0, 0, "nativeui_headers", "header_misc")
_menuPool:Add(jobMenu)

-- Phone Booth Menu
phoneBoothMenu = NativeUI.CreateMenu("Phone Booth", "")
_menuPool:Add(phoneBoothMenu)

-- Vehicle Spawner Menu
vehicleMenu = NativeUI.CreateMenu("Vehicle Spawner", "", 0, 0, "nativeui_headers", "header_misc")
_menuPool:Add(vehicleMenu)

playerReportQueue = {}
dispatchTextQueue = {}

leoUnitCount = 0
leoUnitsAvailable = 0
fireUnitCount = 0
fireUnitsAvailable = 0

currentTime = ""

weaponTaken = false

-- If the player's weapon is holstered
local holstered = true

local draggedBy = -1
local drag = false
local wasDragged = false
draggedPlayerId = -1

hideAllUI = false

waypointAddress = ""

vehicleDoorControls = nil
sundayDrive = false

showFlavorText = false

mdtUnread = false

showid = false

justPaused = false

walkingBackwards = 0

showWarning = false

settingsTemplate =
{
	{categoryName = "Player Location Display", description = "Settings for UI components, such as the player location display", components = {
		{name = "PLD Theme", description = "Select a Player Location Display theme", options = {"Millennium", "Rapid", "Centered", "Rockstar", "Millennium Flipped", "Rapid Flipped", "Hidden"}, default = 1},
		{name = "PLD Color", description = "Select a Player Location Display color scheme", options = {"Blue", "Red", "Yellow", "Green", "Purple", "White"}, default = 1},
		{name = "Show Time", description = "Show a clock next to the minimap", options = "checkbox", default = true},
		{name = "Always Show AOP", description = "Toggle between always showing the AOP, or showing the AOP only when outside of it.", options = "checkbox", default = true},
		{name = "Hide PLD when minimap is hidden", description = "When the minimap is hidden, automatically switch to the Hidden option until the minimap is reenabled.", options = "checkbox", default = false},
		{name = "Use Intercardinal Directions", description = "Have the PLD show intercardinal directions such as NW, SW, SE, NE, etc.", options = "checkbox", default = true},
	}},

	{categoryName = "Vehicle Settings", description = "Settings which affect vehicle behaviour", components = {
		{name = "Sunday Driver", description = "Enables a slower acceleration curve, as well as stop-without-reversing.", options = "checkbox", default = false},
		--{name = "Vehicle UI Theme", description = "Select a Vehicle User Interface theme", options = {"Digital Inline"}, default = 1},
		--{name = "Use Metric System", description = "Use kilometers per hour instead of miles per hour", options = "checkbox", default = false},
	}},

	{categoryName = "Weapons Settings", description = "Settings that affect how weapons work", components = {
		{name = "Show Weapon on Back", description = "Show unequipped weapons on your back when not using them.", options = "checkbox", default = true},
		{name = "Switch to First Person while aiming", description = "When aiming your weapon, automatically switch to first person as long as you are aiming.", options = "checkbox", default = false},
		{name = "Accidental Attack Prevention", description = "Prevents attacking while unarmed, unless you are aiming, or using the secondary attack.", options = "checkbox", default = true},
	}},

	{categoryName = "Chat Settings", description = "Settings that allow you to customise chat functionality", components = {
		{name = "Show Join/Leave Messages", description = "Show messages when players join/leave the server", options = "checkbox", default = true},
	}},

	{categoryName = "In-Game Phone & Computer", description = "Settings related to the in-game phone", components = {
		{name = "Phone Model", description = "Which type of phone you would like to use", options = {"iFruit", "Facade", "Drone", "PDA", "Celltowa"}, default = 1},
		{name = "Computer Theme", description = "Theme used for the in-game MDT system", options = {"Facade XL", "Facade 6.9", "Facade One"}, default = 1},
	}},

	{categoryName = "Map Settings", description = "Settings that affect the in-game pause map", components = {
		{name = "Map Style", description = "The style used by the pause menu map.", options = {"Eyefind Maps", "Satellite"}, default = 1},
		{name = "Show Business Blips", description = "Show blips for all privately owned businesses", options = "checkbox", default = true, onChange = "RefreshBlips"},
		{name = "Show Public Space Blips", description = "Show blips for public spaces, such as parks and plazas", options = "checkbox", default = true, onChange = "RefreshBlips"},
		{name = "Show Government Blips", description = "Show blips for government buildings such as police and fire stations", options = "checkbox", default = true, onChange = "RefreshBlips"},
		{name = "Show Transport Blips", description = "Show blips for public transport, such as railway stations and airports", options = "checkbox", default = true, onChange = "RefreshBlips"},
	}},

	{categoryName = "Miscellaneous Settings", description = "Other settings not covered above", components = {
		{name = "Use Custom Plates", description = "Use custom plate textures. Requires game restart to take effect.", options = "checkbox", default = true},
		{name = "Aspect Ratio", description = "[Experimental] Support for ultrawide monitors", options = {"Standard", "32:9", "21:9"}, default = 1},
	}},
}
userSettings = {}

local attached_weapons = {}

local check = false

keepHandOnHolster = false
stopHolsterAnimation = false

-- UI elements
address = {
	area = "",
	region = "",
	street = "",
	cross = "",
	postal = 3036,
}

alwaysShowAOP = true
currentAOP = "Please wait..."
aopTime = 0
inAOP = false
currSpeed = 0
prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
warningLight = false
click = false

nearbyBlips = {}

hudColors = {
	"HUD_COLOUR_PURE_WHITE",
	"HUD_COLOUR_WHITE",
	"HUD_COLOUR_BLACK",
	"HUD_COLOUR_GREY",
	"HUD_COLOUR_GREYLIGHT",
	"HUD_COLOUR_GREYDARK",
	"HUD_COLOUR_RED",
	"HUD_COLOUR_REDLIGHT",
	"HUD_COLOUR_REDDARK",
	"HUD_COLOUR_BLUE",
	"HUD_COLOUR_BLUELIGHT",
	"HUD_COLOUR_BLUEDARK",
	"HUD_COLOUR_YELLOW",
	"HUD_COLOUR_YELLOWLIGHT",
	"HUD_COLOUR_YELLOWDARK",
	"HUD_COLOUR_ORANGE",
	"HUD_COLOUR_ORANGELIGHT",
	"HUD_COLOUR_ORANGEDARK",
	"HUD_COLOUR_GREEN",
	"HUD_COLOUR_GREENLIGHT",
	"HUD_COLOUR_GREENDARK",
	"HUD_COLOUR_PURPLE",
	"HUD_COLOUR_PURPLELIGHT",
	"HUD_COLOUR_PURPLEDARK",
	"HUD_COLOUR_PINK"
}

phoneBooths = {"prop_phonebox_01a", "prop_phonebox_01b", "prop_phonebox_01c", "prop_phonebox_02", "prop_phonebox_03", "prop_phonebox_04", "prop_phonebox_05a", }
nearPhoneBooth = false

nearStop = false
routeList = {}
routeListCreeper = 1
firstStop = nil

vehicle = {}
lastVehicle = {}


fBrakeForce = 1.0

speedLimiter = false
speedLimitInt = 0

selfDriving = false

mapOffset = 0.0
relX1 = 0
safezoneSize = 0
direction = "N"
directionsInter = { [0] = 'N', [45] = 'NW', [90] = 'W', [135] = 'SW', [180] = 'S', [225] = 'SE', [270] = 'E', [315] = 'NE', [360] = 'N',}
directionsCard = { [0] = 'N', [90] = 'W', [180] = 'S', [270] = 'E', [360] = 'N',}

-- Jail Script Variables
jailTime = 0
hospitalTime = 0
coronerTime = 0

seatbeltOn = false
requireSeatbelt = false

vehicleExitControl = 0

isPlayerCuffed = false
cuffMpPedVariation = 0

showPlayerlist = false
playerlistPage = 1
onlinePlayers = {}

privateMap = "San Andreas"
transferVehicle = true

devmode = false

RegisterCommand('dev', function(source, args, user)
	devmode = not devmode
	ShowInfo("Developer Mode Toggled")

	if devmode then

		local charName = GetPlayerNick(PlayerId())
		--local characterInfo = GetExternalKvpString("vMenu", "mp_ped_"..charName)
		--[[if characterInfo then
			AddTextEntry("DEV_CHARINFO", characterInfo)
			print(characterInfo)
		else
			AddTextEntry("DEV_CHARINFO", "Unable to find vMenu character")
		end]]

		while devmode do
		        Citizen.Wait(0)

			local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
			local interiorId = GetInteriorFromEntity(PlayerPedId())
			local portalCount = GetInteriorPortalCount(interiorId)
			local area = GetAreaFromCoords(x, y)

			WriteText(1.0, 0.04, 0.4, (GetNameOfZone(x, y, z)), 4, 1, 0.7, false, true, false, 255, 255, 255, 255)

			WriteText(1.0, 0.06, 0.4, area, 4, 1, 0.7, false, true, false, 255, 255, 255, 255)

			WriteText(1.0, 0.08, 0.4, "INTERIOR ID: " .. interiorId, 4, 1, 0.7, false, true, false, 255, 255, 255, 255)
			WriteText(1.0, 0.1, 0.4, "PORTAL COUNT: " .. portalCount, 4, 1, 0.7, false, true, false, 255, 255, 255, 255)

			AddTextEntry("DEV_PLAYERINFO", json.encode(player))
			WriteText(1.0, 0.14, 0.4, "DEV_PLAYERINFO", 4, 1, 0.7, true, true, false, 255, 255, 255, 255)

			AddTextEntry("DEV_VEHICLEINFO", json.encode(vehicle))
			WriteText(1.0, 0.26, 0.4, "DEV_VEHICLEINFO", 4, 1, 0.7, true, true, false, 255, 255, 255, 255)

			WriteText(1.0, 0.24, 0.4, "DEV_CONTROLS", 4, 1, 0.7, true, true, false, 255, 255, 255, 255)
		end
	end

	--SetMinimapOverlayDisplay(0, 0.5, 0.5, 50, 50, 100)

	--[[SetMinimapComponentPosition('minimap', 'R', 'B', -0.0045, 0.012, 0.150, 0.218888)

	SetMinimapComponentPosition('minimap_mask', 'R', 'B', 0.020, 0.052, 0.111, 0.199)

	SetMinimapComponentPosition('minimap_blur', 'R', 'B', -0.03, 0.042, 0.266, 0.277)

	if devmode then

		local minimap = RequestScaleformMovie("minimap")
		while devmode do
		        Wait(0)
		        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
		        ScaleformMovieMethodAddParamInt(3)
		        EndScaleformMovieMethod()
		end
	end]]


end, false)

-- FUNCTIONS

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}
  
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
      
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
      
        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
      
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function loadAnimDict( dict )
	local timeout = 0
	while not (HasAnimDictLoaded(dict) or (timeout >= 20)) do
		RequestAnimDict(dict, true)
		timeout = timeout + 1
		Citizen.Wait(50)
	end
	if timeout >= 20 then
		print("^rUnable To Load Animation Dictionary " .. dict)
	else
		print("Loaded Animation Dictionary " .. dict)
	end
end

function loadTextDict( dict)
	local timeout = 0
	while not (HasStreamedTextureDictLoaded(dict) or (timeout >= 20)) do
		RequestStreamedTextureDict(dict, true)
		timeout = timeout + 1
		Citizen.Wait(50)
	end
	if timeout >= 20 then
		print("^rUnable To Load Texture Dictionary " .. dict)
	else
		print("Loaded Texture Dictionary " .. dict)
	end
end

function ShowInfo(text)
	if not hideAllUI then
		AddTextEntry("SHOWINFO_LABEL", text)
		BeginTextCommandDisplayHelp("SHOWINFO_LABEL")
		EndTextCommandDisplayHelp(0, false, false, -1)
	end
end

function ShowInfoLabel(text)
	if not hideAllUI then
		BeginTextCommandDisplayHelp(text)
		EndTextCommandDisplayHelp(0, false, false, -1)
	end
end

function ShowNotification(text)
	if not hideAllUI then
		SetNotificationTextEntry("STRING")
		AddTextComponentSubstringPlayerName(text)
		DrawNotification(true, true)
	end
end

function LoadCustomPlates()
	loadTextDict("plates")
	print("Loading Custom Plate Textures")

	RemoveReplaceTexture("vehshare", "plate01")
	AddReplaceTexture("vehshare", "plate01", "plates", "plate01")
	RemoveReplaceTexture("vehshare", "plate01_n")
	AddReplaceTexture("vehshare", "plate01_n", "plates", "plate01_n")
	RemoveReplaceTexture("vehshare", "plate02")
	AddReplaceTexture("vehshare", "plate02", "plates", "plate02")
	RemoveReplaceTexture("vehshare", "plate02_n")
	AddReplaceTexture("vehshare", "plate02_n", "plates", "plate02_n")
	RemoveReplaceTexture("vehshare", "plate03")
	AddReplaceTexture("vehshare", "plate03", "plates", "plate03")
	RemoveReplaceTexture("vehshare", "plate03_n")
	AddReplaceTexture("vehshare", "plate03_n", "plates", "plate03_n")
	RemoveReplaceTexture("vehshare", "plate04")
	AddReplaceTexture("vehshare", "plate04", "plates", "plate04")
	RemoveReplaceTexture("vehshare", "plate04_n")
	AddReplaceTexture("vehshare", "plate04_n", "plates", "plate04_n")
	RemoveReplaceTexture("vehshare", "plate05")
	AddReplaceTexture("vehshare", "plate05", "plates", "plate05")
	RemoveReplaceTexture("vehshare", "plate05_n")
	AddReplaceTexture("vehshare", "plate05_n", "plates", "plate05_n")
	RemoveReplaceTexture("vehshare", "yankton_plate")
	AddReplaceTexture("vehshare", "yankton_plate", "plates", "yankton_plate")
	RemoveReplaceTexture("vehshare", "yankton_plate_n")
	AddReplaceTexture("vehshare", "yankton_plate_n", "plates", "yankton_plate_n")
	RemoveReplaceTexture("vehshare", "vehicle_generic_plate_font")
	AddReplaceTexture("vehshare", "vehicle_generic_plate_font", "plates", "vehicle_generic_plate_font")
	RemoveReplaceTexture("vehshare", "vehicle_generic_plate_font_n")
	AddReplaceTexture("vehshare", "vehicle_generic_plate_font_n", "plates", "vehicle_generic_plate_font_n")
end

function LoadCayoPlates()
	loadTextDict("plates")
	print("Loading Cayo Perico Plate Textures")

	RemoveReplaceTexture("vehshare", "plate01")
	AddReplaceTexture("vehshare", "plate01", "plates", "cayo_plate")
	RemoveReplaceTexture("vehshare", "plate01_n")
	AddReplaceTexture("vehshare", "plate01_n", "plates", "cayo_plate_n")

	RemoveReplaceTexture("vehshare", "plate04")
	AddReplaceTexture("vehshare", "plate04", "plates", "cayo_plate2")
	RemoveReplaceTexture("vehshare", "plate04_n")
	AddReplaceTexture("vehshare", "plate04_n", "plates", "cayo_plate2_n")

	RemoveReplaceTexture("vehshare", "yankton_plate")
	AddReplaceTexture("vehshare", "yankton_plate", "plates", "cayo_plate3")
	RemoveReplaceTexture("vehshare", "yankton_plate_n")
	AddReplaceTexture("vehshare", "yankton_plate_n", "plates", "cayo_plate3_n")

	RemoveReplaceTexture("vehshare", "plate05")
	AddReplaceTexture("vehshare", "plate05", "plates", "cayo_plate4")
	RemoveReplaceTexture("vehshare", "plate05_n")
	AddReplaceTexture("vehshare", "plate05_n", "plates", "cayo_plate4_n")

	RemoveReplaceTexture("vehshare", "plate03")
	AddReplaceTexture("vehshare", "plate03", "plates", "vice_plate")
	RemoveReplaceTexture("vehshare", "plate03_n")
	AddReplaceTexture("vehshare", "plate03_n", "plates", "vice_plate_n")
end

function ResetPlates()
	RemoveReplaceTexture("vehshare", "plate01")
	RemoveReplaceTexture("vehshare", "plate01_n")
	RemoveReplaceTexture("vehshare", "plate02")
	RemoveReplaceTexture("vehshare", "plate02_n")
	RemoveReplaceTexture("vehshare", "plate03")
	RemoveReplaceTexture("vehshare", "plate03_n")
	RemoveReplaceTexture("vehshare", "plate04")
	RemoveReplaceTexture("vehshare", "plate04_n")
	RemoveReplaceTexture("vehshare", "plate05")
	RemoveReplaceTexture("vehshare", "plate05_n")
	RemoveReplaceTexture("vehshare", "yankton_plate")
	RemoveReplaceTexture("vehshare", "yankton_plate_n")
	RemoveReplaceTexture("vehshare", "vehicle_generic_plate_font")
	RemoveReplaceTexture("vehshare", "vehicle_generic_plate_font_n")
end


function AddCheckbox(menu, position, aop)
	table.insert(aoplist, position, {aop, NativeUI.CreateCheckboxItem(aop, false, aop), false})
	menu:AddItem(aoplist[position][2])
	menu.OnCheckboxChange = function(sender, item, checked_)
		for i in pairs(aoplist) do
			if item == aoplist[i][2] then
				if aoplist[i][3] == false then
					aoplist[i][3] = true
				else
					aoplist[i][3] = false
				end
			end
		end
	end
end

function AddConfirm(menu)
	local newitem = NativeUI.CreateItem("Submit", "Confirm that these are the AOPs you would be okay with.")
	newitem:SetRightBadge(BadgeStyle.Tick)
	menu:AddItem(newitem)
	menu.OnItemSelect = function(sender, item, index)
		if item == newitem then
			voted = true
			aopMenu:Visible(not aopMenu:Visible())
			for i in ipairs(aoplist) do
				if aoplist[i][3] == true then
					TriggerServerEvent("SendAOPVote", aoplist[i][1])
					Citizen.Wait(100)
				end
			end
		ShowInfoLabel("AOP_VOTESUB")
		end
	end
	menu.OnIndexChange = function(sender, index)
		if sender.Items[index] == newitem then
			newitem:SetLeftBadge(BadgeStyle.None)
		end
	end
end

function GetUserSettings(name)
	for _, item in ipairs(userSettings) do
		if item[1] == name then
			return item[2]
		end
	end
end

function SetUserSettings(name, newValue)
	for _, item in ipairs(userSettings) do
		if item[1] == name then
			item[2] = newValue
			SetResourceKvp(ServerId .. "-CORE:SETTINGS", json.encode(userSettings))
			print("Settings File Successfully Updated")
		end
	end
end

function CreateSettings(menu)
	for i, item in ipairs(settingsTemplate) do
		item.menu = _menuPool:AddSubMenu(menu, item.categoryName, item.description, "nativeui_headers", "settings_header")
		for j, subitem in ipairs(item.components) do
			if subitem.options == "checkbox" then
				subitem.menu = NativeUI.CreateCheckboxItem(subitem.name, GetUserSettings(subitem.name), subitem.description)
				item.menu.SubMenu:AddItem(subitem.menu)
			else
				subitem.menu = NativeUI.CreateListItem(subitem.name, subitem.options, GetUserSettings(subitem.name), subitem.description)
				item.menu.SubMenu:AddItem(subitem.menu)
			end
		end
	end

	for i, settingItem in ipairs(settingsTemplate) do
		settingItem.menu.SubMenu.OnListChange = function(sender, item, index)
			for j, item2 in ipairs(settingItem.components) do
				if item2.menu == item then
					SetUserSettings(item2.name, index)
					if item2.onChange then
						TriggerEvent(item2.onChange)
					end
				end
			end
		end
		settingItem.menu.SubMenu.OnCheckboxChange = function(sender, item, checked_)
			for j, item2 in ipairs(settingItem.components) do
				if item2.menu == item then
					SetUserSettings(item2.name, not GetUserSettings(item2.name))
					if item2.onChange then
						TriggerEvent(item2.onChange)
					end
				end
			end
		end
	end
end

function CreatePhoneBoothMenu(menu)
	phoneBoothList = {}

	for _, item in ipairs(contacts) do
		table.insert(phoneBoothList, {name = item.nick, item = NativeUI.CreateItem(item.name, "Call " .. item.name), id = item.name})
	end

	for i, player in ipairs(onlinePlayers) do
		if player.job ~= "Fire/EMS" and player.job ~= "Law Enforcement" and player.dept ~= "Civilian" and player.dept ~= "Unemployed" then
			local found = false
			for _, item in ipairs(phoneBoothList) do
				if player.dept == item.name then
					found = true
				end
			end
			if not found then
				table.insert(phoneBoothList, {name = player.nick, item = NativeUI.CreateItem(player.dept, "Call " .. player.dept), id = player.dept})
			end
		end
	end		

	for _, item in ipairs(onlinePlayers) do
		if item.nick then
			table.insert(phoneBoothList, {name = item.nick, item = NativeUI.CreateItem(item.nick, "Call " .. item.nick), id = item.id})
		end
	end

	for _, item in ipairs(phoneBoothList) do
		menu:AddItem(item.item)
	end

	menu.OnItemSelect = function(sender, item, index)
		for _, entry in ipairs(phoneBoothList) do
			if item == entry.item then
				phoneBoothMenu:Visible(not phoneBoothMenu:Visible())

				if tonumber(entry.id) then
					if callId == 0 then
						TriggerEvent("PhoneBoothCall", entry.id)
					end
				else
					TriggerEvent("PhoneBoothCallStatic", entry.id)
				end
			end
		end
	end
end

function CreateVehicleMenu(menu)
	
	local vehicles = GetAllVehicleModels()

	classSpawn = _menuPool:AddSubMenu(menu, "Spawn by Class", "Spawn Vehicles By Class", "nativeui_headers", "header_misc")
	manufacturerSpawn = _menuPool:AddSubMenu(menu, "Spawn by Manufacturer", "Spawn Vehicles By Class", "nativeui_headers", "header_misc")

	local classes = {}
	local manufacturers = {}

	for _, item in ipairs(vehicles) do

		local vclass = GetLabelText("VEH_CLASS_" .. tostring(GetVehicleClassFromName(item)))
		local vmanufacturer = nil
		if not (GetMakeNameFromVehicleModel(item) == "" or GetMakeNameFromVehicleModel(item) == "NULL") then
			vmanufacturer = GetLabelText(GetMakeNameFromVehicleModel(item))
		end

		local vname = GetLabelText(GetDisplayNameFromVehicleModel(item))

		local vehicle = {spawn = item, manufacturer = vmanufacturer, name = vname}

		if vmanufacturer == nil then
			vmanufacturer = "Uncategorised"
		end

		local found = false
		for _, class in ipairs(classes) do
			if class.name == vclass then
				table.insert(class.vehicles, vehicle)
				found = true
			end
		end
		if not found then
			table.insert(classes, {name = vclass, vehicles = {vehicle}})
		end

		local found = false
		for _, manufacturer in ipairs(manufacturers) do
			if manufacturer.name == vmanufacturer then
				table.insert(manufacturer.vehicles, vehicle)
				found = true
			end
		end
		if not found then
			table.insert(manufacturers, {name = vmanufacturer, vehicles = {vehicle}})
		end
	end

	table.sort(manufacturers, function(a, b) return a.name < b.name end)
	table.sort(classes, function(a, b) return a.name < b.name end)

	for _, item in ipairs(manufacturers) do

		table.sort(item.vehicles, function(a, b) return a.name < b.name end)

		item.menu = _menuPool:AddSubMenu(manufacturerSpawn.SubMenu, item.name)
		for _, subitem in ipairs(item.vehicles) do
			subitem.item = NativeUI.CreateItem(subitem.name, subitem.spawn)
			item.menu.SubMenu:AddItem(subitem.item)
		end
	end

	for _, item in ipairs(classes) do

		table.sort(item.vehicles, function(a, b) return a.name < b.name end)

		item.menu = _menuPool:AddSubMenu(classSpawn.SubMenu, item.name)
		for _, subitem in ipairs(item.vehicles) do
			subitem.item = NativeUI.CreateItem(subitem.name, subitem.spawn)
			item.menu.SubMenu:AddItem(subitem.item)
		end
	end
end


Citizen.CreateThread(function()
	SetMillisecondsPerGameMinute(8000)
end)

RegisterNetEvent('CoreTimeSync')
AddEventHandler('CoreTimeSync', function(serverMinute, serverHour)
	if player.session then
		if not (player.session > 5) then
			NetworkOverrideClockTime(serverHour, serverMinute, 0)
		end
	end
		
end)

RegisterNetEvent('PhoneBoothCallStatic')
AddEventHandler('PhoneBoothCallStatic', function(id)

	loadAnimDict("cellphone@")
	TaskPlayAnim(GetPlayerPed(-1), "cellphone@",  "cellphone_call_listen_base", 200.0, 200.0, -1, 18, 0, false, false, false)

	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

    	local prop = CreateObject(GetHashKey("vw_prop_casino_phone_01b_handle"), x, y, z + 0.2, true, true, true)
    	AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, -0.03, -0.03, 90.0, 0.0, 140.0, true, true, false, true, 1, true)

	N_0x3ed1438c1f5c6612(2)
	DisplayOnscreenKeyboard(0, "FMMC_SMS4", "", "", "", "", "", 500)
	repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
		if UpdateOnscreenKeyboard() == 1 then
			local message = GetOnscreenKeyboardResult()
			local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(PlayerId()), true))
			local location = GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z))

			math.randomseed(GetGameTimer())
			local phoneNumber = "(555) 404-" .. math.random(1000, 9999)

			TriggerServerEvent('relaySpecialContact', id, message, location, x, y, z, phoneNumber, GetPlayerServerId(PlayerId()), "CHAR_DEFAULT")
		elseif UpdateOnscreenKeyboard() == 2 then
			Notification("Message Cancelled", 5000)
		end

	DeleteEntity(prop)
	ClearPedTasks(PlayerPedId())
	
end)

RegisterNetEvent('PhoneBoothCall')
AddEventHandler('PhoneBoothCall', function(id)
	callId = tonumber(id)
	otherCaller = tonumber(id)

	exports["pma-voice"]:addPlayerToCall(callId + 30)

	PlayPedRingtone("Dial_and_Remote_Ring", GetPlayerPed(-1), 1)

	loadAnimDict("cellphone@")
	TaskPlayAnim(GetPlayerPed(-1), "cellphone@",  "cellphone_call_listen_base", 200.0, 200.0, -1, 18, 0, false, false, false)

	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

    	local prop = CreateObject(GetHashKey("vw_prop_casino_phone_01b_handle"), x, y, z + 0.2, true, true, true)
    	AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, -0.03, -0.03, 90.0, 0.0, 140.0, true, true, false, true, 1, true)

	TriggerServerEvent("phone_server:callRequest", callId, true)

	while callId ~= 0 do
		Citizen.Wait(0)
		if IsControlJustReleased(3, 177) or otherCaller == 0 or not nearPhoneBooth then -- CANCEL / CLOSE PHONE
			if otherCaller ~= 0 then
				TriggerServerEvent('phone_server:callEnd', otherCaller)
			end

			DeleteEntity(prop)
			ClearPedTasks(PlayerPedId())

			exports["pma-voice"]:removePlayerFromCall()
			callId = 0
			otherCaller = 0
		end
	end
end)


RegisterNetEvent('RefreshBlips')
AddEventHandler('RefreshBlips', function()
	SetBlips()
end)

RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function(spawn)
	if GetResourceKvpFloat(ServerId .. "-CORE:PLAYER_Z") > 0.0 then
		local x = GetResourceKvpFloat(ServerId .. "-CORE:PLAYER_X")
		local y = GetResourceKvpFloat(ServerId .. "-CORE:PLAYER_Y")
		local z = GetResourceKvpFloat(ServerId .. "-CORE:PLAYER_Z")
		SetEntityCoords(GetPlayerPed(-1), x, y, z, false, false, false, true)
		print("Putting you back where you last was")
	else
		print("Couldn\'t find a location to place you")
	end
end)

function CreateJobMenu(menu)

	--[[local newCharacter = menu:AddItem(NativeUI.CreateItem("Create New Character", "Creates a new character and sets as current character."))
	
	local editCharacter = _menuPool:AddSubMenu(menu, "Edit Current Character")
	for i, item in ipairs(characterMenuTemplate) do
		if item.components then
			item.menu = _menuPool:AddSubMenu(editCharacter.SubMenu, item.categoryName)
			for j, subitem in ipairs(item.components) do
				subitem.menu = NativeUI.CreateListItem(subitem.name, subitem.options, GetCharacterInformation(subitem.name), subitem.description)
				item.menu.SubMenu:AddItem(subitem.menu)
			end

		else
			if item.options == "text" then
				item.menu = NativeUI.CreateItem(item.name, item.description)
				editCharacter.SubMenu:AddItem(item.menu)
				item.menu:RightLabel(GetCharacterInformation(item.name))
				print(GetCharacterInformation(item.name))
			elseif item.options == "checkbox" then

			else
				item.menu = NativeUI.CreateListItem(item.name, item.options, GetCharacterInformation(item.name), item.description)
				editCharacter.SubMenu:AddItem(item.menu)
			end
		end
	end]]
end

function CreateSessionMenu(menu)
	local roleplaySession = NativeUI.CreateItem("Roleplay Session", "This session exists for roleplay purposes.")
	menu:AddItem(roleplaySession)
	local freeroamSession = NativeUI.CreateItem("Freeroam Session", "This session exists to allow for non-roleplay activities.")
	menu:AddItem(freeroamSession)
	local personalSession = NativeUI.CreateItem("Personal Session", "This session is for personal experimenting. No other players can access this session.")
	menu:AddItem(personalSession)
	--local transferVehicleItem = NativeUI.CreateCheckboxItem("Transfer Vehicle", true, "Transfer your current vehicle between roleplay sessions.")
	--menu:AddItem(transferVehicleItem)

	local personalSessionSettings = _menuPool:AddSubMenu(menu, "~c~Personal Session Settings")

	local personalSessionMap = NativeUI.CreateListItem("Set Map", {"San Andreas", "North Yankton", "Cayo Perico"}, 1, "Load maps such as North Yankton or Cayo Perico.")
	personalSessionSettings.SubMenu:AddItem(personalSessionMap)

	local personalSessionTime = NativeUI.CreateListItem("Set Time", {"1:00", "2:00", "3:00", "4:00", "5:00", "6:00", "7:00", "8:00", "9:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "0:00"}, 1, "Set the current time for your private session.")
	personalSessionSettings.SubMenu:AddItem(personalSessionTime)

	local personalSessionPopulation = NativeUI.CreateCheckboxItem("Toggle AI", true, "Toggle if AI vehicles and pedestrians can exist in the session.")
	personalSessionSettings.SubMenu:AddItem(personalSessionPopulation)

	menu.OnCheckboxChange = function(sender, item, checked_)
		if item == transferVehicleItem then
			transferVehicle = not transferVehicle
		end
	end

	menu.OnItemSelect = function(sender, item, index)
		if item == roleplaySession then
			if GetPlayerNick(PlayerId()) then
				TriggerServerEvent("changeSession", 1)
				player.session = 1
				AddTextEntry("SESSION_STRING", "")
				ShowInfoLabel("INFO_SESSIONRP")
				SetMaps(false)
			end
		elseif item == freeroamSession then
			TriggerServerEvent("changeSession", 2)
			player.session = 2
			AddTextEntry("SESSION_STRING", "You are currently in the Freeroam Session")
			ShowInfoLabel("INFO_SESSIONFR")
			SetMaps(false)
		elseif item == personalSession then
			TriggerServerEvent("changeSession", -1)
			player.session = GetPlayerServerId(PlayerId()) + 5
			AddTextEntry("SESSION_STRING", "You are currently in a Private Session")
			ShowInfoLabel("INFO_SESSIONPR")
			SetMaps(true)
		end
		sessionMenu:Visible(not sessionMenu:Visible())
	end

	personalSessionSettings.SubMenu.OnListSelect = function(sender, item, index)
		if item == personalSessionMap then
			if index == 1 then
				privateMap = "San Andreas"
			elseif index == 2 then
				privateMap = "North Yankton"
			elseif index == 3 then
				privateMap = "Cayo Perico"
			end
			if player.session > 5 then
				SetMaps(true)
				print("Private Session Map Updated to " .. privateMap)
			end
		elseif item == personalSessionTime then
			if player.session > 5 then
				if index < 24 then
					NetworkOverrideClockTime(index, 0, 0)
				else
					NetworkOverrideClockTime(0, 0, 0)
				end
			end
		end
	end

	personalSessionSettings.SubMenu.OnCheckboxChange = function(sender, item, checked_)
		if item == personalSessionPopulation then
			TriggerServerEvent("setSessionPopulation", checked_)
		end
	end
end

function SetMaps(priv)
	if currentAOP == privateMap then
		print("Private session map is the same as AOP - nothing needs to be loaded/unloaded")
	else
		TriggerEvent("RefreshBlips")
		NorthYankton(false)
		CayoPerico(false)

		if privateMap == "North Yankton" then
			NorthYankton(priv)
		elseif privateMap == "Cayo Perico" then
			CayoPerico(priv)
		end
		if currentAOP == "North Yankton" then
			NorthYankton(not priv)
		elseif currentAOP == "Cayo Perico" then
			CayoPerico(not priv)
		end
	end
end

function GetPlayerNick(sourceId)
	for _, player in ipairs(onlinePlayers) do
		if tonumber(player.id) == GetPlayerServerId(sourceId) then
			return player.nick
		end
	end
end

function GetBleeterHandle()
	if GetPlayerNick(PlayerId()) then
		local nick = GetPlayerNick(PlayerId())
		return GetResourceKvpString("KGV:PHONE:HANDLE:" .. nick)
	else
		return nil
	end
end


RegisterNetEvent('hideAllUI', hidden)
AddEventHandler('hideAllUI', function(hidden)
	hideAllUI = hidden
end)

RegisterNetEvent('AnnounceScriptRestart')
AddEventHandler('AnnounceScriptRestart', function()
	print("The core script has just been restarted. Issues and bugs are to be expected.")
end)

RegisterNetEvent('clientSetWhitelist', onoff)
AddEventHandler('clientSetWhitelist', function(onoff)
	whitelist = onoff
	if onoff then
		ShowInfo("Whitelist is now enabled")
	else
		ShowInfo("Whitelist is now disabled")
	end
end)

RegisterNetEvent('reportSubmittedAll')
AddEventHandler('reportSubmittedAll', function(reportedName, reportedId, reporteeName, reporteeId, reportText, reportId)
	if player.staff then
		table.insert(playerReportQueue, {reportedName = reportedName, reportedId = reportedId, reporteeName = reporteeName, reporteeId = reporteeId, reportText = reportText, reportId = reportId, reportStatus = "Unclaimed"})
	end
end)

RegisterCommand("rs", function(source, args, rawCommand)
	if player.staff and #playerReportQueue > 0 then
		TriggerServerEvent("markReportAsHandled", table.concat(args, " "), playerReportQueue[1].reportId)
	end
end)

RegisterCommand("rd", function(source, args, rawCommand)
	if player.staff and #playerReportQueue > 0 then
		table.remove(playerReportQueue, 1)
	end
end)

RegisterCommand("rr", function(source, args, rawCommand)
	if player.staff and #playerReportQueue > 0 then
		TriggerServerEvent("sendReportReply", table.concat(args, " "), playerReportQueue[1].reporteeId)
	end
end)

RegisterNetEvent('updateReportState', newStatus, id)
AddEventHandler('updateReportState', function(newStatus, id)
	for _, item in ipairs(playerReportQueue) do
		if item.reportId == id then
			item.reportStatus = newStatus
		end
	end
end)


RegisterNetEvent('syncFlavorText')
AddEventHandler('syncFlavorText', function(flavorText)
	found = false
	playerLocation = vector3(table.unpack(GetEntityCoords(PlayerPedId())))

	for _, item in ipairs(flavorText) do
		if #(playerLocation - item.coords) < 2.0 then
			AddTextEntry("FLAVORTEXT", item.text)
			showFlavorText = true
			found = true
		end
	end
	
	if not found then
		showFlavorText = false
	end
end)

RegisterNetEvent('syncPlayerList')
AddEventHandler('syncPlayerList', function(players)
	onlinePlayers = players

	for _, item in ipairs(players) do
		if tonumber(item.id) == GetPlayerServerId(PlayerId()) then

			player = item

			if jobA ~= item.job then -- Server script has just been restarted, re-syncing stuff
				jobA = item.job
				jobB = item.dept
				callsign = item.callsign
			end
		end
	end

	table.sort(onlinePlayers, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
end)

RegisterNetEvent('syncUnitCounts')
AddEventHandler('syncUnitCounts', function(unitCounts)
	leoUnitCount = unitCounts[1][2]
	leoUnitsAvailable = unitCounts[1][3]
	fireUnitCount = unitCounts[2][2]
	fireUnitsAvailable = unitCounts[2][3]

end)

function GetNearestVehicle()
	local pos = GetEntityCoords(PlayerPedId())
	local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)

	local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
	local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
	return vehicleHandle
end

RegisterNetEvent("getDragged")
AddEventHandler("getDragged", function(source, giv)
	draggedBy = source
	drag = not drag
	if giv then
		TaskEnterVehicle(ped, GetNearestVehicle(), 3000, 1, 1.0, 1, 0)
	end
end)

RegisterNetEvent('BeginAOPVote', aopstoadd, tiebreaker)
AddEventHandler('BeginAOPVote', function(aopstoadd, tiebreaker)
	aopVote = true
	if player.member then
		PlaySoundFrontend(-1,"CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET",1)
		if tiebreaker then
			ShowInfoLabel("AOP_VOTETIE")
		else
			ShowInfoLabel("AOP_VOTEBEGIN")
		end

		voted = false
		aoplist = {}

		aopMenu = NativeUI.CreateMenu("AOP Vote", "", 0, 0, "nativeui_headers", "header_misc")
		_menuPool:Add(aopMenu)

		for i in ipairs(aopstoadd) do
			AddCheckbox(aopMenu, i, aopstoadd[i])
		end

		AddConfirm(aopMenu)
		_menuPool:RefreshIndex()

		local aopCountdown = 120
		if tiebreaker then
			aopCountdown = 60
		end

		while aopCountdown > 1 and aopVote do
			AddTextEntry("AOP_STRING", "Area of Play: Vote in Progress - " .. aopCountdown .. " seconds remaining")
			aopCountdown = aopCountdown - 1
			Citizen.Wait(1000)
		end
	else
		ShowInfoLabel("AOP_VOTEMEMBER")
	end
end)

RegisterNetEvent('EndAOPVote')
AddEventHandler('EndAOPVote', function()
	voted = true
	aopVote = false
end)

function getClosestPlayer()
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
	local _, _, _, _, ped = GetShapeTestResult(rayHandle)

	for id = 0, 255 do
		if NetworkIsPlayerActive(id) then
			if GetPlayerPed(id) == ped then
				return(GetPlayerServerId(id))

			end
		end
	end
end

-- x: The X position of the text
-- y: The Y position of the text
-- text: The text to be displayed
-- label: Is the text a label?
-- size: The size/scale of the text
-- font: 4 or 6
-- edge: 2 or 1
-- r, g, b: RGB values
-- a: Alpha value

function WriteText(x, y, size, text, font, edge, wrap, label, safezone, phone, r, g, b, a)
	if not phone then
		x = x/drawAdjust + 1.0/drawAdjust - 1.0
		if wrap then
			wrap = wrap/drawAdjust + 1.0/drawAdjust - 1.0
		end
	end

	if safezone and x < 0.5 then
		x = x - safezoneSize + 0.5
		if wrap then
			wrap = wrap - safezoneSize + 0.5
		end
	elseif safezone and x > 0.5 then
		x = x + safezoneSize - 0.5
		if wrap then
			wrap = wrap + safezoneSize - 0.5
		end
	end
	if safezone and y < 0.5 then
		y = y - safezoneSize + 0.5
	elseif safezone and y > 0.5 then
		y = y + safezoneSize - 0.5
	end

	SetTextFont(font)
	if phone and devmode then
		SetTextScale(size * 2, size)
	else
		SetTextScale(size, size)
	end
	SetTextColour(r, g, b, a)

	if edge == 1 then
		SetTextOutline()
	elseif edge > 0 then
		SetTextDropshadow(edge, 0, 0, 0, 255)
	end
	
	if not wrap then
		SetTextJustification(0)
		SetTextWrap(0.5 - safezoneSize, 0.5 + safezoneSize)
	elseif wrap < x then
		SetTextJustification(2)
		SetTextWrap(wrap, x)
	elseif wrap > x then
		SetTextJustification(1)
		SetTextWrap(x, wrap)
	end

	if label then
		BeginTextCommandDisplayText(text)
	else
		BeginTextCommandDisplayText("STRING")
		AddTextComponentString(text)
	end
	EndTextCommandDisplayText(x, y)

	BeginTextCommandLineCount(text)
	return EndTextCommandLineCount(x, y)
end

-- x: X position on the screen
-- y: Y position on the screen
-- size: How big it should be
-- text: Message to be displayed
-- Font: 4 or 6
-- Edge: 2 or 1
-- Align: 0 centre, 1 left, 2 right
function drawTxt(x, y, size, text, font, edge, align, r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(size, size)
	SetTextColour(r, g, b, a)

	if edge ~= 0 then
		SetTextDropShadow(0, 0, 0, 0, 255)
		SetTextEdge(edge, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
	end

	SetTextJustification(align)
	--SetScriptGfxDrawBehindPausemenu(true)
	if align == 1 then
		SetTextWrap(x/drawAdjust + 1.0/drawAdjust - 1, 0.5 + safezoneSize)
	elseif align == 2 then
		SetTextWrap(0.5 - safezoneSize, x/drawAdjust + 1.0/drawAdjust - 1)
	end
	BeginTextCommandDisplayText("STRING")
	AddTextComponentString(text)
	EndTextCommandDisplayText(x/drawAdjust + 1.0/drawAdjust - 1, y)
end

function drawTxtLabel(x, y, size, text, font, edge, align, r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(size, size)
	SetTextColour(r, g, b, a)
	if edge ~= 0 then
		SetTextDropShadow(0, 0, 0, 0, 255)
		SetTextEdge(edge, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
	end

	SetTextJustification(align)
	if align == 1 then
		SetTextWrap(x/drawAdjust + 1.0/drawAdjust - 1, 0.5 + safezoneSize)
	elseif align == 2 then
		SetTextWrap(0.5 - safezoneSize, x/drawAdjust + 1.0/drawAdjust - 1)
	end
	BeginTextCommandDisplayText(text)
	EndTextCommandDisplayText(x/drawAdjust + 1.0/drawAdjust - 1, y)
end

function drawTxtPhone(x, y, size, text, font, edge, align, r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(size, size * yRenderMultiplier)
	SetTextColour(r, g, b, a)

	if edge ~= 0 then
		SetTextDropShadow(0, 0, 0, 0, 255)
		SetTextEdge(edge, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
	end

	SetTextJustification(align)
	--SetScriptGfxDrawBehindPausemenu(true)
	if align == 1 then
		SetTextWrap(x, 0.5 + safezoneSize)
	elseif align == 2 then
		SetTextWrap(0.5 - safezoneSize, x)
	end
	BeginTextCommandDisplayText("STRING")
	AddTextComponentString(text)
	EndTextCommandDisplayText(x, y)
end

function drawTxtBleet(x, y, size, text, font, edge, align, r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(size/2, size)
	SetTextColour(r, g, b, a)

	if edge ~= 0 then
		SetTextDropShadow(0, 0, 0, 0, 255)
		SetTextEdge(edge, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
	end

	SetTextJustification(align)
	--SetScriptGfxDrawBehindPausemenu(true)
	if align == 1 then
		SetTextWrap(x, 0.5 + safezoneSize)
	elseif align == 2 then
		SetTextWrap(0.5 - safezoneSize, x)
	end
	BeginTextCommandDisplayText(text)
	EndTextCommandDisplayText(x, y)

	BeginTextCommandLineCount(text)
	return(EndTextCommandLineCount(x, y))
end

function drawTxt3D(x,y,z, text, r,g,b, scale2)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov * scale2

    if onScreen then
        SetTextScale(0.0*scale, 0.85*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end


 function CheckWeapon(ped)
	for i = 1, #holsterWeapons do
		if GetHashKey(holsterWeapons[i]) == GetSelectedPedWeapon(ped) then
			return true
		end
	end
	return false
end

-- NETWORK EVENTS

function NorthYankton(enable)
	SetMinimapInPrologue(enable)
	exports['bob74_ipl']:EnableIpl({"prologue01", "prologue01c", "prologue01d", "prologue01e", "prologue01f", "prologue01g","prologue01h", "prologue01i", "prologue01j", "prologue01k", "prologue01z", "NorthYanktonBetterTrees", "prologue02", "prologue03", "prologue03b", "prologue04", "prologue04b", "prologue05", "prologue05b", "prologue06", "prologue06b", "prologue06_int", "prologuerd", "prologuerdb ", "prologue_DistantLights", "prologue_LODLights", "prologue_m2_door"}, enable)
end

function CayoPerico(enable)
	SetToggleMinimapHeistIsland(enable)
	SetAiGlobalPathNodesType(enable)
	if enable then
		SetDeepOceanScaler(0.0)
		LoadCayoPlates()
		SetDefaultVehicleNumberPlateTextPattern(-1, 'AAA 1111')
		SetDefaultVehicleNumberPlateTextPattern(1, 'AAA 1111')
		SetDefaultVehicleNumberPlateTextPattern(2, 'AAA 1111')
		SetDefaultVehicleNumberPlateTextPattern(4, 'AAA 1111')
		SetDefaultVehicleNumberPlateTextPattern(5, 'AAA 1111')
	else
		ResetDeepOceanScaler()

		if GetUserSettings("Use Custom Plates") then
			LoadCustomPlates()
		else
			ResetPlates()
		end
		SetDefaultVehicleNumberPlateTextPattern(-1, '11AAA111')
		SetDefaultVehicleNumberPlateTextPattern(1, ' AAA111 ')
		SetDefaultVehicleNumberPlateTextPattern(2, ' 111AAA ')
		SetDefaultVehicleNumberPlateTextPattern(4, '^11111111')
		SetDefaultVehicleNumberPlateTextPattern(5, '111 BAAA')
	end

	exports['bob74_ipl']:EnableIpl({"h4_islandairstrip", "h4_islandairstrip_props", "h4_islandx_mansion", "h4_islandx_mansion_props", "h4_islandx_props", "h4_islandxdock", "h4_islandxdock_props", "h4_islandxdock_props_2", "h4_islandxtower", "h4_islandx_maindock", "h4_islandx_maindock_props", "h4_islandx_maindock_props_2", "h4_IslandX_Mansion_Vault", "h4_islandairstrip_propsb", "h4_beach", "h4_beach_props", "h4_beach_bar_props", "h4_islandx_barrack_props", "h4_islandx_checkpoint", "h4_islandx_checkpoint_props", "h4_islandx_Mansion_Office", "h4_islandx_Mansion_LockUp_01", "h4_islandx_Mansion_LockUp_02", "h4_islandx_Mansion_LockUp_03", "h4_islandairstrip_hangar_props", "h4_IslandX_Mansion_B", "h4_islandairstrip_doorsclosed", "h4_Underwater_Gate_Closed", "h4_mansion_gate_closed", "h4_aa_guns", "h4_IslandX_Mansion_GuardFence", "h4_IslandX_Mansion_Entrance_Fence", "h4_IslandX_Mansion_B_Side_Fence", "h4_IslandX_Mansion_Lights", "h4_islandxcanal_props", "h4_beach_props_party", "h4_islandX_Terrain_props_06_a", "h4_islandX_Terrain_props_06_b", "h4_islandX_Terrain_props_06_c", "h4_islandX_Terrain_props_05_a", "h4_islandX_Terrain_props_05_b", "h4_islandX_Terrain_props_05_c", "h4_islandX_Terrain_props_05_d", "h4_islandX_Terrain_props_05_e", "h4_islandX_Terrain_props_05_f", "H4_islandx_terrain_01", "H4_islandx_terrain_02", "H4_islandx_terrain_03", "H4_islandx_terrain_04", "H4_islandx_terrain_05", "H4_islandx_terrain_06", "h4_ne_ipl_00", "h4_ne_ipl_01", "h4_ne_ipl_02", "h4_ne_ipl_03", "h4_ne_ipl_04", "h4_ne_ipl_05", "h4_ne_ipl_06", "h4_ne_ipl_07", "h4_ne_ipl_08", "h4_ne_ipl_09", "h4_nw_ipl_00", "h4_nw_ipl_01", "h4_nw_ipl_02", "h4_nw_ipl_03", "h4_nw_ipl_04", "h4_nw_ipl_05", "h4_nw_ipl_06", "h4_nw_ipl_07", "h4_nw_ipl_08", "h4_nw_ipl_09", "h4_se_ipl_00", "h4_se_ipl_01", "h4_se_ipl_02", "h4_se_ipl_03", "h4_se_ipl_04", "h4_se_ipl_05", "h4_se_ipl_06", "h4_se_ipl_07", "h4_se_ipl_08", "h4_se_ipl_09", "h4_sw_ipl_00", "h4_sw_ipl_01", "h4_sw_ipl_02", "h4_sw_ipl_03", "h4_sw_ipl_04", "h4_sw_ipl_05", "h4_sw_ipl_06", "h4_sw_ipl_07", "h4_sw_ipl_08", "h4_sw_ipl_09", "h4_islandx_mansion", "h4_islandxtower_veg", "h4_islandx_sea_mines", "h4_islandx", "h4_islandx_barrack_hatch", "h4_islandxdock_water_hatch", "h4_beach_party"}, enable)

	SetZoneEnabled(GetZoneFromNameId("PrLog"), false) -- REMOVES SNOW FROM Cayo]]

end

RegisterNetEvent('updateAOP')
AddEventHandler('updateAOP', function(message, newTime)
	aopTime = newTime
	if message == "North Yankton" then
		NorthYankton(true)
	elseif currentAOP == "North Yankton" then
		NorthYankton(false)
	end

	if message == "Cayo Perico" then
		CayoPerico(true)
	elseif currentAOP == "Cayo Perico" then
		CayoPerico(false)
	end

	currentAOP = message

	AddTextEntry("AOP_STRING", "Area of Play: " .. currentAOP)
	ShowInfo("~BLIP_INFO_ICON~  ~b~AOP has been changed to "..message)
	PlaySoundFrontend(-1,"CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET",1)
	Citizen.Wait(5000)
	ShowInfo("~BLIP_INFO_ICON~ ~b~Please finish your current roleplay and move there.")

	SetBlips()
end)

RegisterNetEvent('updateAlert')
AddEventHandler('updateAlert', function(message)
	AddTextEntry("ALERT_STRING", message)
	PlaySoundFrontend(-1,"CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET",1)
end)


RegisterNetEvent('connectionMessage', message)
AddEventHandler('connectionMessage', function(message)
	if GetUserSettings("Show Join/Leave Messages") then
		TriggerEvent('chat:addMessage', {color = {180,180,180}, args = {message}})
	end
end)

RegisterNetEvent('sendProximityMessageMe')
AddEventHandler('sendProximityMessageMe', function(id, message)

	local myId = PlayerId()
	local pid = GetPlayerFromServerId(id)
	if message and pid ~= -1 then
		if (pid == myId) or (GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myId)), GetEntityCoords(GetPlayerPed(pid)), true) < 29.999) then
			TriggerEvent('chat:addMessage', {args = {"^3" .. message}})
		end
	end
end)


RegisterNetEvent('ActionMessage')
AddEventHandler('ActionMessage', function(message, id, localAction)
	if GetPlayerNick(PlayerId()) then

		if string.find(message, GetPlayerNick(PlayerId())) and GetPlayerFromServerId(id) ~= PlayerId() then
		-- Targeted Me
			TriggerEvent('chat:addMessage', {args = {"~b~" .. message}})
			PlaySoundFrontend(-1,"CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET",1)

		-- Local Me
	
		elseif localAction  then
			if ((GetPlayerFromServerId(id) == PlayerId()) or (GetPlayerFromServerId(id) ~= -1 and GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(PlayerId())), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(id))), true) < 29.999)) then
				TriggerEvent('chat:addMessage', {args = {"^3" .. message}})
			end
		-- Global Me
		else
			TriggerEvent('chat:addMessage', {args = {"^2" .. message}})

		end
	end
end)


RegisterNetEvent('reportSubmitted')
AddEventHandler('reportSubmitted', function(message)
	AddTextEntry("REPORT_INFO", "~b~" .. message)
	SetTextComponentFormat("REPORT_INFO")
	DisplayHelpTextFromStringLabel(0, 0, 0, -1)
end)

RegisterNetEvent('showWarning')
AddEventHandler('showWarning', function(message, type)
if player.session > 0 then
	AddTextEntry("SERVER_WARNING", message)
	showWarning = false
	
	Citizen.Wait(100)

	showWarning = true

	while showWarning do
		Citizen.Wait(0)

		DrawRect(0.8 + safezoneSize - 0.5, 0.1 - safezoneSize + 0.5, 0.4, 0.2, 0, 0, 0, 200)
		if type == 1 then
			DrawRect(0.8 + safezoneSize - 0.5, 0.2 - safezoneSize + 0.5, 0.4, 0.005, 46, 121, 189, 255)
			WriteText(0.61, 0.01, 0.4, "Server Advisory Issued", 0, 0, 1.0, false, true, false, 255, 255, 255, 255)
		else
			DrawRect(0.8 + safezoneSize - 0.5, 0.2 - safezoneSize + 0.5, 0.4, 0.005, 200, 20, 20, 255)
			WriteText(0.61, 0.01, 0.5, "Server Warning Issued", 0, 0, 1.0, false, true, false, 255, 255, 255, 255)
		end

		WriteText(0.61, 0.05, 0.4, "SERVER_WARNING", 0, 0, 1.0, true, true, false, 255, 255, 255, 255)

		WriteText(0.61, 0.16, 0.3, "To confirm that you have read this, type /dismiss", 0, 0, 1.0, false, true, false, 255, 255, 255, 255)
	end
	end
end)

RegisterCommand("dismiss", function(source, args, rawCommand)
	showWarning = false
end)

RegisterCommand("showid", function(source, args, rawCommand)
	showid = not showid
	if showid then
		loadTextDict("licences")

    		local handle = RegisterPedheadshotTransparent(PlayerPedId())
    		while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
        		Wait(0)
    		end
    		local txd = GetPedheadshotTxdString(handle)

		UnregisterPedheadshot(handle)

		while showid do
			Citizen.Wait(0)
			DrawSprite("licences", "driver_san_andreas", 0.35+safezoneSize, 0.35+safezoneSize, 0.3, 0.3, 0.0, 255, 255, 255, 255)

			DrawRect(0.25 + safezoneSize, 0.38 + safezoneSize, 0.08, 0.16, 27, 33, 108, 255)
			DrawSprite(txd, txd, 0.25 + safezoneSize, 0.38 + safezoneSize, 0.08, 0.16, 0.0, 255, 255, 255, 255)

			DrawRect(0.45 + safezoneSize, 0.35 + safezoneSize, 0.05, 0.1, 27, 33, 108, 100)
			DrawSprite(txd, txd, 0.45 + safezoneSize, 0.35 + safezoneSize, 0.05, 0.1, 0.0, 255, 255, 255, 100)

			WriteText(0.8, 0.78, 0.3, "103403243", 13, 0, 1.0, false, true, false, 27, 33, 108, 255)
			WriteText(0.8, 0.81, 0.3, "JENNIFER ADAMS", 13, 0, 1.0, false, true, false, 27, 33, 108, 255)

			WriteText(0.8, 0.83, 0.3, "11042 FORUM DR, LS", 13, 0, 1.0, false, true, false, 27, 33, 108, 255)

			WriteText(0.8, 0.87, 0.3, "SEX: F", 13, 0, 1.0, false, true, false, 27, 33, 108, 255)
			WriteText(0.8, 0.89, 0.3, "HT: 5-11", 13, 0, 1.0, false, true, false, 27, 33, 108, 255)

			WriteText(0.85, 0.87, 0.3, "HAIR: BRN", 13, 0, 1.0, false, true, false, 27, 33, 108, 255)
			WriteText(0.85, 0.89, 0.3, "WT: 170", 13, 0, 1.0, false, true, false, 27, 33, 108, 255)

			WriteText(0.8, 0.92, 0.3, "PTFC: 08 01 30 53 10", 13, 0, 1.0, false, true, false, 27, 33, 108, 255)

			WriteText(0.81, 0.94, 0.5, "J ADAMS", 15, 0, 1.0, false, true, false, 27, 33, 108, 255)

			WriteText(0.83, 0.97, 0.25, "VALID FROM 23/03/22", 13, 0, 1.0, false, true, false, 0, 0, 0, 255)

			WriteText(0.94, 0.96, 0.3, "EYES BRN", 13, 0, 1.0, false, true, false, 200, 50, 50, 255)
		end
	end
end)


RegisterNetEvent('getCuffed')
AddEventHandler('getCuffed', function()
	

	if isPlayerCuffed then
		isPlayerCuffed = false
		ClearPedTasks(ped)
		SetEnableHandcuffs(ped, false)
		UncuffPed(ped)

		SendNuiMessage([[{"t":"PLAY_SOUND","d":{"sound":3}}]])

		if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") or GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
			SetPedComponentVariation(ped, 7, cuffMpPedVariation, 0, 0)
		end
	else
		
		loadAnimDict("anim@arrest_crooks")

		isPlayerCuffed = true
		SetPedDropsWeapon(ped)
		SetEnableHandcuffs(ped, true)

		SendNuiMessage([[{"t":"PLAY_SOUND","d":{"sound":2}}]])
		
		if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
			cuffMpPedVariation = GetPedDrawableVariation(ped, 7)
			SetPedComponentVariation(ped, 7, 41, 0, 0)
		elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
			cuffMpPedVariation = GetPedDrawableVariation(ped, 7)
			SetPedComponentVariation(ped, 7, 25, 0, 0)
		end
		
		while isPlayerCuffed do
			DisableControlAction(0, 59, true)
			DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
			DisableControlAction(0, 92, true) -- INPUT_VEH_PASSENGER_ATTACK
			DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
			DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
			DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
			DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
			DisableControlAction(0, 257, true) -- INPUT_ATTACK2
			DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
			DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
			DisableControlAction(0, 24, true) -- INPUT_ATTACK
			DisableControlAction(0, 25, true) -- INPUT_AIM

			if IsPedSprinting(ped) then
				Citizen.Wait(500)
				if IsPedSprinting(ped) then
					SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
				end
			end
			Citizen.Wait(0)
		end
	end
end)

RegisterNetEvent("jailPlayer")
AddEventHandler("jailPlayer", function(time)
	SetEntityCoords(ped, 1691.169, 2565.421, 45.565)
	jailTime = time
	if isPlayerCuffed then
		TriggerEvent('getCuffed')
	end
end)

RegisterNetEvent("unjailPlayer")
AddEventHandler("unjailPlayer", function()
	SetEntityCoords(ped, 1855.807, 2601.949, 45.323)
	jailTime = 0
end)

RegisterNetEvent("coronerPlayer")
AddEventHandler("coronerPlayer", function(time)
	SetEntityCoords(ped, 1691.169, 2565.421, 45.565)
	coronerTime = time

	if isPlayerCuffed then
		TriggerEvent('getCuffed')
	end
end)

RegisterNetEvent("uncoronerPlayer")
AddEventHandler("uncoronerPlayer", function()
	SetEntityCoords(ped, 1855.807, 2601.949, 45.323)
	coronerTime = 0
end)

RegisterNetEvent("hospitalPlayer")
AddEventHandler("hospitalPlayer", function(time)
	SetEntityCoords(ped, 315.9, -584.7, 43.28)
	hospitalTime = time
end)

RegisterNetEvent("unhospitalPlayer")
AddEventHandler("unhospitalPlayer", function()
	SetEntityCoords(ped, 298.5, -584.7, 43.26)
	hospitalTime = 0

	if isPlayerCuffed then
		TriggerEvent('getCuffed')
	end
end)

RegisterNetEvent('callSpecialContact', type, message, address, postal, playerName, playerID, incidentNumber, status)
AddEventHandler('callSpecialContact', function(type, message, address, postal, playerName, playerID, incidentNumber, status)
	if jobA == "Law Enforcement" or jobA == "Fire/EMS" or jobA == "Coroner" then

		if mdtUnread ~= "Panic Button" then

			if type == "Panic Button" then
				mdtUnread = type
				PlaySoundFrontend(-1, "Beep_Green", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
				Citizen.Wait(1200)
				PlaySoundFrontend(-1, "Beep_Green", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
				Citizen.Wait(1200)
				PlaySoundFrontend(-1, "Beep_Green", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)


			elseif type == "Crime Broadcast" or type == "Created Incident" then
				mdtUnread = type
				PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
				Citizen.Wait(600)
				PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)

			elseif type == "911 Emergency" or type == "311 Non-Emergency" or type == "Requesting " .. jobA then
				mdtUnread = type
				PlaySoundFrontend(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", 0)
			end
		end
	end
end)

RegisterNetEvent('callResponseSpecialContact', icon, name, message)
AddEventHandler('callResponseSpecialContact', function(icon, name, message)
		SetNotificationTextEntry("STRING")
		AddTextComponentString(message)
		SetNotificationMessage(icon, name, true, 2, playerName, "Response to Call")
		PlaySoundFrontend(-1, "Phone_Generic_Key_01", "HUD_MINIGAME_SOUNDSET", 0)
end)

RegisterNetEvent('setInitialInformation', whitelistOn, aop, aopT, alert, serverHour, serverMinute)
AddEventHandler('setInitialInformation', function(whitelistOn, aop, aopT, alert, serverHour, serverMinute)

	informationObtained = true

	whitelist = whitelistOn
	currentAOP = aop
	aopTime = aopT

	if currentAOP == "North Yankton" then
		NorthYankton(true)
	elseif currentAOP == "Cayo Perico" then
		CayoPerico(true)
	end

	NetworkOverrideClockTime(serverHour, serverMinute, 0)

	AddTextEntry("AOP_STRING", "Area of Play: " .. currentAOP)
	AddTextEntry("ALERT_STRING", alert)

end)

mapDictionaryList = {

{"minimap_sea_0_0", "minimap_sat_0_0"},
{"minimap_sea_0_1", "minimap_sat_0_1"},
{"minimap_sea_1_0", "minimap_sat_1_0"},
{"minimap_sea_1_1", "minimap_sat_1_1"},
{"minimap_sea_2_0", "minimap_sat_2_0"},
{"minimap_sea_2_1", "minimap_sat_2_1"},

}


-- Initialising
Citizen.CreateThread(function()

	print("Core Script is Starting...")

	if IsDlcPresent(`tuner`) then
		print("Running Tuner Update!")
	else
		print("Not running Tuner Update")
	end

	print("Creating text entries...")
	for _, item in ipairs(textEntries) do
		AddTextEntry(item[1], item[2])
	end

	print("Setting initalisation requests...")
	-- Set custom plate formats
	-- Yellow on Black
	SetDefaultVehicleNumberPlateTextPattern(1, ' AAA111 ')
	-- Yellow on Blue
	SetDefaultVehicleNumberPlateTextPattern(2, ' 111AAA ')
	-- Exempt
	SetDefaultVehicleNumberPlateTextPattern(4, '^11111111')
	-- Yankton
	SetDefaultVehicleNumberPlateTextPattern(5, '111 BAAA')

	SetWeaponsNoAutoreload(true)
	SetWeaponsNoAutoswap(true)

	-- Tries to stop emergency services from spawning
	for i = 1, 15 do
		EnableDispatchService(i, false)
	end

	for _, item in ipairs(blacklistedVehicles) do
		SetVehicleModelIsSuppressed(GetHashKey(item), true)
	end
	SetVehicleModelIsSuppressed(GetHashKey("ambulance"), true)

	if GetResourceState("LibertyV") == "started" then
		serverMap = "Liberty City"
	end
	print("Map Loaded: " .. serverMap)

	print("Configuring map zoom data...")
	ResetMapZoomDataLevel(0)
	ResetMapZoomDataLevel(1)
	ResetMapZoomDataLevel(2)
	ResetMapZoomDataLevel(3)
	ResetMapZoomDataLevel(4)
	ResetMapZoomDataLevel(5)
	ResetMapZoomDataLevel(6)
	ResetMapZoomDataLevel(7)
	ResetMapZoomDataLevel(8)

	SetMapZoomDataLevel(0, 2.73, 0.9, 0.08, 0.0, 0.0)
	SetMapZoomDataLevel(1, 2.8, 0.9, 0.08, 0.0, 0.0)
	SetMapZoomDataLevel(2, 8.0, 0.9, 0.08, 0.0, 0.0)
	SetMapZoomDataLevel(3, 11.0, 0.9, 0.08, 0.0, 0.0)
	SetMapZoomDataLevel(4, 50.0, 0.9, 0.08, 0.0, 0.0)

	-- Tries to stop these peds from spawning
	SetPedModelIsSuppressed(GetHashKey("s_f_y_scrubs_01"), true)
	SetPedModelIsSuppressed(GetHashKey("s_m_y_hwaycop_01"), true)
	SetPedModelIsSuppressed(GetHashKey("s_m_y_sheriff_01"), true)
	SetPedModelIsSuppressed(GetHashKey("s_m_y_cop_01"), true)
	SetPedModelIsSuppressed(GetHashKey("s_f_y_sheriff_01"), true)
	SetPedModelIsSuppressed(GetHashKey("s_f_y_ranger_01"), true)
	SetPedModelIsSuppressed(GetHashKey("s_f_y_cop_01"), true)
	SetPedModelIsSuppressed(GetHashKey("s_m_y_ranger_01"), true)
	SetPedModelIsSuppressed(GetHashKey("s_m_m_doctor_01"), true)
	SetPedModelIsSuppressed(GetHashKey("a_c_shepherd"), true)

	print("Getting save data...")

	savedUserSettings = json.decode(GetResourceKvpString(ServerId .. "-CORE:SETTINGS")) or {}

	for _, nonitem in ipairs(settingsTemplate) do
		for _, item in ipairs(nonitem.components) do
			table.insert(userSettings, {item.name, item.default})
			print(item.name)
		end
	end

	print(#savedUserSettings)
	print(#userSettings)

	for _, item in ipairs(userSettings) do
		for _, item2 in ipairs(savedUserSettings) do
			if item[1] == item2[1] then
				item[2] = item2[2]
			end
		end
	end

	SetResourceKvp(ServerId .. "-CORE:SETTINGS", json.encode(userSettings), -1)

	print("Please mind the gap while the doors are closing...")
	-- Stops train doors from being forced open while ppl are inside (hopefully)
	SetTrainsForceDoorsOpen(false)


	--[[if GetResourceKvpString(ServerId .. "-CORE:SETTINGS") then
		local tempUserSettings = json.decode(GetResourceKvpString(ServerId .. "-CORE:SETTINGS"))

		if tempUserSettings.pldTheme then
			tempUserSettings = userSettings
		end

		for _, item in ipairs(userSettings) do
			found = false
			for _, item2 in ipairs(tempUserSettings) do
				if item[1] == item2[1] then
					found = true
				end
			end

			if not found then
				table.insert(tempUserSettings, item)
			end
		end
		if #tempUserSettings ~= #userSettings then
			print("User settings do not match template - resetting")
			tempUserSettings = userSettings
		else
			print("Settings successfully found and set")
			userSettings = tempUserSettings
		end
	end
	SetResourceKvp(ServerId .. "-CORE:SETTINGS", json.encode(userSettings), -1)]]


	characterHandle = StartFindKvp(ServerId .. "-CORE:CHARACTER:")
	if characterHandle ~= -1 then
		local key
		repeat
			key = FindKvp(characterHandle)
			if key then
				print(key)
			end
		until not key
		EndFindKvp(kvpHandle)
	end

	print("Configuring menus...")
	CreateSettings(settingsMenu)
	CreateSessionMenu(sessionMenu)
	CreateJobMenu(jobMenu)
	CreateVehicleMenu(vehicleMenu)
	CreatePropMenu(propMenu)

	_menuPool:RefreshIndex()

	print("Loading animations...")
	-- Holster script
	-- Animations are reloaded when called as well
	-- loadAnimDict("reaction@intimidation@cop@unarmed")
	loadAnimDict("anim@holster_walk")
	loadAnimDict("anim@holster_hold_there")
	loadAnimDict("rcmjosh4")

	-- Hands up
	loadAnimDict("missminuteman_1ig_2")
	loadAnimDict("random@arrests@busted")
	loadAnimDict("random@arrests")

	-- Wheelchair
	loadAnimDict("missfinale_c2leadinoutfin_c_int")

	-- Cuffs
	loadAnimDict("anim@arrest_crooks")
	
	print("Loading texture dictionaries...")
	loadTextDict("vehicleui")
	if serverMap == "San Andreas" then
		loadTextDict("mapimages")
	end
	
	print("Getting Discord permissions...")
	while not informationObtained do
		TriggerServerEvent("getInitialInformation")
		Citizen.Wait(math.random(1000, 3000))
	end

	print("Setting up chat suggestions...")

	--TriggerEvent('chat:addSuggestion', '/character', 'Open the character menu.') -- Incomplete.
	--TriggerEvent('chat:addSuggestion', '/prop', 'Open the prop menu.') -- NEEDS TO BE FIXED!
	TriggerEvent('chat:addSuggestion', '/dismiss', 'Dismiss a server warning or advisory.')
	TriggerEvent('chat:addSuggestion', '/showid', 'Show your ID.')
	TriggerEvent('chat:addSuggestion', '/playerlist', 'Hide/show the player list.')
	TriggerEvent('chat:addSuggestion', '/hu', 'Raise/lower your hands.')
	TriggerEvent('chat:addSuggestion', '/hh', 'Place your hand on your holster.')
	TriggerEvent('chat:addSuggestion', '/engine', 'Toggle vehicle engine on or off.')
	TriggerEvent('chat:addSuggestion', '/seatbelt', 'Put your seatbelt on.')
	TriggerEvent('chat:addSuggestion', '/settings', 'Open the settings menu.')
	--TriggerEvent('chat:addSuggestion', '/vehicle', 'Open the vehicle spawning menu.') -- Incomplete.
	TriggerEvent('chat:addSuggestion', '/session', 'Open the session menu.')
	--TriggerEvent('chat:addSuggestion', '/jobmenu', 'Open the job menu.') -- Incomplete.
	TriggerEvent('chat:addSuggestion', '/onduty', 'Go on duty as an approved agency/company.', {{ name="department", help="Which department you're going on duty as."}, { name="callsign/identifier", help="Enter your callsign/station number here."}})
	TriggerEvent('chat:addSuggestion', '/offduty', 'Go off duty.')
	TriggerEvent('chat:addSuggestion', '/p', 'Activate Panic Button')
	TriggerEvent('chat:addSuggestion', '/jail', 'Jail a user.', {{ name="id", help="User ID."}, { name="time", help="How long they should be jailed for in seconds."}, {name="report", help="Optional reason for jailing"}})
	TriggerEvent('chat:addSuggestion', '/unjail', 'Unjail a user.', {{ name="id", help="User ID."}, {name="report", help="Optional reason for unjailing"}})
	TriggerEvent('chat:addSuggestion', '/hospital', 'Send a user to the hospital.', {{ name="id", help="User ID."}, { name="time", help="How long they should be in the hospital for in seconds."}})
	TriggerEvent('chat:addSuggestion', '/unhospital', 'Release a user from the hospital.', {{ name="id", help="User ID."}, {name="report", help="Optional reason for releasing"}})
	TriggerEvent('chat:addSuggestion', '/coroner', 'Send a user to the mortuary.', {{ name="id", help="User ID."}, { name="time", help="How long they should be in the coroner for in seconds."}})
	TriggerEvent('chat:addSuggestion', '/uncoroner', 'Release a user from the mortuary.', {{ name="id", help="User ID."}, {name="report", help="Optional reason for releasing"}})
	--TriggerEvent('chat:addSuggestion', '/job', 'Set your job.', {{ name="job", help="The job you wish to set."}}) -- NEED MORE DOCUMENTATION
	TriggerEvent('chat:addSuggestion', '/postal', 'Draw a GPS route to a specified postal.', {{ name="postal", help="The 3 or 4 digit postal code you want to be routed to."}})
	TriggerEvent('chat:addSuggestion', '/trunk', 'Open the trunk of your car.')
	TriggerEvent('chat:addSuggestion', '/hood', 'Open the hood of your car.')
	--TriggerEvent('chat:addSuggestion', '/bus' -- Incomplete.
	TriggerEvent('chat:addSuggestion', '/xmit', 'Send a message to Dispatch.', {{ name="message", help="The message you wish to send."}})
	TriggerEvent('chat:addSuggestion', '/window', 'Roll your windows up or down.', {{ name="window", help="Either put 1, 2, 3, 4, front, rear, or all."}, { name="state", help="up/down"}})
	TriggerEvent('chat:addSuggestion', '/door', 'Open the door of your car.', {{ name="door", help="Either put 1, 2, 3, 4, front, rear, or all."}})
	TriggerEvent('chat:addSuggestion', '/cuff ', 'Cuff/uncuff a player.', {{ name="id", help="The ID of the person you are cuffing/uncuffing."}})
	TriggerEvent('chat:addSuggestion', '/drag', 'Drag/undrag a player.', {{ name="id", help="The ID of the person you are dragging/undragging."}})
	TriggerEvent('chat:addSuggestion', '/rack', 'Rack a weapon that you have previously unracked.')
	TriggerEvent('chat:addSuggestion', '/unrack', 'Take a weapon from the weapon rack.', {{ name="weapon", help="What weapon you wish to unrack. 1 for Rifle, 2 for Shotgun, 3 for Beanbag Shotgun, 4 for 40mm Less-Lethal Launcher."}})
	TriggerEvent('chat:addSuggestion', '/drop', 'Drop your current weapon on the ground.')
	TriggerEvent('chat:addSuggestion', '/firingmode', 'Cycle through your weapon\'s firing modes.')
	TriggerEvent('chat:addSuggestion', '/dev', 'Staff Only: Toggle developer mode.')

	TriggerEvent('chat:addSuggestion', '/deleteentity', 'Delete an entity.', {{ name="id", help="The ID of the entity you wish to delete."}})
	TriggerEvent('chat:addSuggestion', '/char', 'Set an in-character name.', {{ name="character name", help="Your character's name. Please ensure the name is realistic and reasonable."}})
	TriggerEvent('chat:addSuggestion', '/msg', 'Send a private chat message to another player.', {{ name="id", help="The ID of the person you are messaging."}, { name="message", help="The message you wish to send."}})
	TriggerEvent('chat:addSuggestion', '/gme', 'Indicate that your character is doing something to all players.', {{ name="message", help="The message you wish to send."}})
	TriggerEvent('chat:addSuggestion', '/me', 'Indicate that your character is doing something to nearby players.', {{ name="message", help="The message you wish to send."}})
	TriggerEvent('chat:addSuggestion', '/do', 'Describe something or answer role-play questions for nearby players.', {{ name="message", help="The message you wish to send."}})
	TriggerEvent('chat:addSuggestion', '/gdo', 'Describe something or answer role-play questions for all players.', {{ name="message", help="The message you wish to send."}})
	TriggerEvent('chat:addSuggestion', '/action', 'Describe something or answer role-play questions for nearby players.', {{ name="message", help="The message you wish to send."}})
	TriggerEvent('chat:addSuggestion', '/gaction', 'Describe something or answer role-play questions for all players.', {{ name="message", help="The message you wish to send."}})
	TriggerEvent('chat:addSuggestion', '/run', 'Run a plate/name.', {{ name="name/plate", help="What you're running (examples include \"12ABC345\", \"John Doe\", \"The plate on the Red Stanier\", etc)."}})
	TriggerEvent('chat:addSuggestion', '/search', 'Search something.', {{ name="name", help="What you're searching (examples include \"12ABC345\", \"John Doe\", \"The plate on the Red Stanier\", etc)."}})
	TriggerEvent('chat:addSuggestion', '/report', 'Quickly report another player to staff.', {{ name="id", help="The ID of the person you are reporting."}, { name="report", help="Your report."}})

	TriggerEvent('chat:addSuggestion', '/mdt', 'Open/close the Mobile Data Terminal.')
	TriggerEvent('chat:addSuggestion', '/busy', 'MDT: Set your status to busy.')
	TriggerEvent('chat:addSuggestion', '/bsy', 'MDT: Set your status to busy.')
	TriggerEvent('chat:addSuggestion', '/unavailable', 'MDT: Set your status to unavailable.')
	TriggerEvent('chat:addSuggestion', '/ua', 'MDT: Set your status to unavailable.')
	TriggerEvent('chat:addSuggestion', '/clear', 'MDT: Clear your status.')
	TriggerEvent('chat:addSuggestion', '/cl', 'MDT: Clear your status.')
	TriggerEvent('chat:addSuggestion', '/enroute', 'MDT: Set your status to enroute.')
	TriggerEvent('chat:addSuggestion', '/er', 'MDT: Set your status to enroute.')
	TriggerEvent('chat:addSuggestion', '/codesix', 'MDT: Set your status to at-scene.')
	TriggerEvent('chat:addSuggestion', '/c6', 'MDT: Set your status to at-scene.')
	TriggerEvent('chat:addSuggestion', '/code6', 'MDT: Set your status to at-scene.')
	TriggerEvent('chat:addSuggestion', '/onscene', 'MDT: Set your status to at-scene.')

	TriggerEvent('chat:addSuggestion', '/copypasta', ':thonk:')

	if player.staff then
		TriggerEvent('chat:addSuggestion', '/rs', 'Mark a player report as handled.')
		TriggerEvent('chat:addSuggestion', '/rr', 'Reply to a player report.')
		TriggerEvent('chat:addSuggestion', '/rd', 'Dismiss a player report.', {{ name="id", help="The ID of the report you wish to dismiss."}})
		TriggerEvent('chat:addSuggestion', '/smsg', 'Send a private chat message to another player as a staff member.', {{ name="id", help="The ID of the person you are messaging."}, { name="message", help="The message you wish to send."}})
		TriggerEvent('chat:addSuggestion', '/aop', 'Set the current Area of Play.', {{ name="aop", help="The Area of Play you wish to set."}})
		TriggerEvent('chat:addSuggestion', '/alert', 'Create an alert.', {{ name="alert", help="The alert you wish to send."}})
		TriggerEvent('chat:addSuggestion', '/aopvote', 'Start an AOP Vote.', {{ name="aop", help="The potential Areas of Play you wish to set, seperated by |."}})
		TriggerEvent('chat:addSuggestion', '/warn', 'Warn a player.', {{ name="id", help="The ID of the person you are warning."}, { name="warning", help="The warning you wish to send."}})
		TriggerEvent('chat:addSuggestion', '/advise', 'Advise a player.', {{ name="id", help="The ID of the person you are advising."}, { name="advice", help="The advice you wish to send."}})
		TriggerEvent('chat:addSuggestion', '/kick', 'Kick a player from the server.', {{ name="id", help="The ID of the person you are kicking."}, { name="reason", help="The reason you are kicking them."}})
		TriggerEvent('chat:addSuggestion', '/tempban', 'Temporarily ban a player from the server.', {{ name="id", help="The ID of the person you are banning."}, { name="time", help="The time you are banning them for."}, { name="reason", help="The reason you are banning them."}})
		TriggerEvent('chat:addSuggestion', '/ban', 'Permanently ban a player from the server.', {{ name="id", help="The ID of the person you are banning."}, { name="reason", help="The reason you are banning them."}})
		TriggerEvent('chat:addSuggestion', '/unban', 'Unban a player from the server.', {{ name="id", help="The ID of the person you are unbanning."}})
		TriggerEvent('chat:addSuggestion', '/staff', 'Send a message in chat labelled with the staff tag.', {{ name="message", help="The message you wish to send."}})
		TriggerEvent('chat:addSuggestion', '/wl', 'Toggle the members-only whitelist.')
		TriggerEvent('chat:addSuggestion', '/time', 'Change the time.', {{ name="hour", help="The hour you wish to set."}, { name="minute", help="The minute you wish to set."}})
	end

	print("Ensuring key mapping...")
	RegisterKeyMapping("playerlist", "Player List", "keyboard", "I")
	RegisterKeyMapping("hu", "Hands Up", "keyboard", "U")
	RegisterKeyMapping("hh", "Ready Quickdraw", "keyboard", "X")
	RegisterKeyMapping("engine", "Engine", "keyboard", "G")
	RegisterKeyMapping("seatbelt", "Seatbelt", "keyboard", "K")
	RegisterKeyMapping("mdt", "Mobile Data Terminal", "keyboard", "O")
	RegisterKeyMapping("trunk", "Trunk", "keyboard", "")
	RegisterKeyMapping('firingmode', 'Select Fire', 'keyboard', '')

	if player.staff then
		RegisterKeyMapping("rd", "Dismiss player report (staff only)", "keyboard", "")
	end

	print("Configuring custom plates (if enabled)")
	
	if GetUserSettings("Use Custom Plates") and currentAOP ~= "Cayo Perico" and serverMap == "San Andreas" then

		LoadCustomPlates()
	end

	print("Grabbing The Dog...")



	print("Creating blips...")

	SetBlips()

	print("republic_core initialised!")
end)

function GetCurrentLocation()
	if player.session then
		if player.session > 5 then
			return privateMap
		else
			if currentAOP == "North Yankton" or currentAOP == "Cayo Perico" then
				return currentAOP
			end
		end
	end
	return serverMap
end

function SetBlips()
	print(GetCurrentLocation())
	blipCount = 0

	for i, item in pairs(blips) do
		if not item.location then
			item.location = "San Andreas"
		end

		if GetCurrentLocation() == item.location and GetUserSettings("Show " .. item.category .. " Blips") then
			if not DoesBlipExist(item.blip) then
				CreateBlip(item)
				blipCount = blipCount + 1
			end
		else
			RemoveBlip(item.blip)
		end
		Citizen.Wait(0)
	end
	print(blipCount)

end

function CreateBlip(item)
	item.blip = AddBlipForCoord(item.x, item.y, 10.0)
	SetBlipSprite(item.blip, item.id)
	SetBlipAsShortRange(item.blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(item.type)
	EndTextCommandSetBlipName(item.blip)

	if item.image then
		exports['blip_info']:SetBlipInfoImage(item.blip, "mapimages", item.image)
	end
	exports['blip_info']:SetBlipInfoTitle(item.blip, nil, true)
	exports['blip_info']:AddBlipInfoHeader(item.blip, item.name)
	if item.closed then
		exports['blip_info']:AddBlipInfoText(item.blip, item.type, "~r~Closed")
	else
		exports['blip_info']:AddBlipInfoText(item.blip, item.type, "~g~Open")
	end
	local blipAddress = GetNearestPostal(item.x, item.y, 10.0)
	exports['blip_info']:AddBlipInfoText(item.blip, "Postal", blipAddress)

	if item.website then
		exports['blip_info']:AddBlipInfoText(item.blip, "Website", item.website)
	end
	if item.bleeter then
		exports['blip_info']:AddBlipInfoText(item.blip, "Bleeter", item.bleeter)
	end
	if item.phone then
		exports['blip_info']:AddBlipInfoText(item.blip, "Phone Number", item.phone)
	end

	if item.description then
		exports['blip_info']:AddBlipInfoText(item.blip, item.description)
	end
end

-- CODE LOOPS

-- Every 200ms
Citizen.CreateThread(function()
	while true do
		if ped ~= GetPlayerPed(-1) then
			print("Player Ped Changed")
			ped = GetPlayerPed(-1)

			SetPedMinGroundTimeForStungun(ped, 10000)

			ResetPlayerStamina(PlayerId())
			SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)

      			for name, attached_object in pairs(attached_weapons) do
            			DeleteObject(attached_object.handle)
            			attached_weapons[name] = nil
      			end
      			for wep_name, wep_hash in pairs(weaponOnBackSettings.compatable_weapon_hashes) do
          			if HasPedGotWeapon(ped, wep_hash, false) and GetUserSettings("Show Weapon on Back") then
              				if not attached_weapons[wep_name] then
                  				AttachWeapon(wep_name, wep_hash, weaponOnBackSettings.back_bone, weaponOnBackSettings.x, weaponOnBackSettings.y, weaponOnBackSettings.z, weaponOnBackSettings.x_rotation, weaponOnBackSettings.y_rotation, weaponOnBackSettings.z_rotation, isMeleeWeapon(wep_name))
              				end
          			end
     	 		end
		end

		if pedHealth then
			if GetEntityHealth(ped) > pedHealth then
				TriggerServerEvent("ServerLog", "[Heal] " .. GetPlayerName(PlayerId()) .. " has healed themselves")
			end
		end
		pedHealth = GetEntityHealth(ped)


		if not player.member then
			for _, item in ipairs(memberOnlyWeapons) do
				if HasPedGotWeapon(ped, GetHashKey(item), false) then
					RemoveWeaponFromPed(ped, GetHashKey(item))
					ShowInfoLabel("MEMBER_RESTRICT")
				end
			end
		end

		checkMap = IsMinimapRendering()
		if checkMap then
			if IsBigmapActive() then
				mapOffset = 0.23
			else
				mapOffset = 0.15
			end
		else
			mapOffset = 0.0
		end

		if vehicleExitControl > 5 and not IsEntityDead(ped) and vehicle.vehicle then
			SetVehicleEngineOn(vehicle.vehicle, true, true, false)
			TaskLeaveVehicle(ped, vehicle.vehicle, 256)
		end

		if vehicle.vehicle ~= GetVehiclePedIsIn(ped,false) and GetVehiclePedIsIn(ped,false) ~= 0 then -- Ped is in a new vehicle
			vehicle.speed = 0.0
			vehicle.fuel = 0.0
			vehicle.vehicle = GetVehiclePedIsIn(ped,false)
			vehicle.driver = (ped == GetPedInVehicleSeat(vehicle.vehicle, -1))

			vehicle.class = GetVehicleClass(vehicle.vehicle)
			if vehicle.class == 8 or vehicle.class == 13 or IsThisModelABike(GetEntityModel(vehicle.vehicle)) or IsThisModelAQuadbike(GetEntityModel(vehicle.vehicle)) then
				vehicle.bike = true
			else
				vehicle.bike = false
			end

			vehicle.aircraft = (vehicle.class == 15 or vehicle.class == 16)
			
			fBrakeForce = GetVehicleHandlingFloat(vehicle.vehicle, 'CHandlingData', 'fBrakeForce')
			sundayDrive = GetUserSettings("Sunday Driver")
			if sundayDrive then
				print("Sunday Driver enabled!")
			end

			speedLimiter = false

			if GetEntityModel(vehicle.vehicle) == GetHashKey("wheelchair") then
				loadAnimDict("missfinale_c2leadinoutfin_c_int")
				print("Wheelchair Animation Now Playing")
				TaskPlayAnim(GetPlayerPed(-1), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 50, 0, false, false, false)
			end

			if vehicle.bike or vehicle.aircraft or vehicle.class == 21 then
				requireSeatbelt = false
			else
				requireSeatbelt = true
			end

			SetVehicleCanDeformWheels(vehicle.vehicle, true)
			SetVehicleWheelsCanBreak(vehicle.vehicle, true)
		elseif GetVehiclePedIsIn(ped,false) == 0 then
			lastVehicle = vehicle
			vehicle = {}
			requireSeatbelt = false
		end

		if vehicle.driver then
			if vehicle.hp then
				if GetVehicleEngineHealth(vehicle.vehicle) > vehicle.hp then
					TriggerServerEvent("ServerLog", "[Vehicle] " .. GetPlayerName(PlayerId()) .. " repaired their vehicle")
				end
			end

			if not GetVehicleTyresCanBurst(vehicle.vehicle) and (not player.member or devmode) then
				SetVehicleTyresCanBurst(vehicle.vehicle, true)
			end
			if (not player.member) then
				SetVehicleNitroEnabled(vehicle.vehicle, false)
			end

			vehicle.hp = GetVehicleEngineHealth(vehicle.vehicle) 
			vehicle.speed = GetEntitySpeed(vehicle.vehicle, false) * 2.236936
			if IsVehicleStopped(vehicle.vehicle) then
				vehicle.speed = 0
			end
			vehicle.fuel = GetVehicleFuelLevel(vehicle.vehicle)
			_, vehicle.lights, vehicle.highbeam = GetVehicleLightsState(vehicle.vehicle)
		else
			if not (GetPedParachuteState(ped) == 2) then
				playerModel = GetEntityModel(ped)
				--if GetHashKey("mp_m_freemode_01") == playerModel or GetHashKey("mp_f_freemode_01") == playerModel then
				if HolsterConfig.Peds[playerModel] then
   					if CheckWeapon(ped) then
				  		if holstered then
							if not (stopHolsterAnimation or IsPedInAnyVehicle(ped, true)) then
								loadAnimDict("rcmjosh4")
								TaskPlayAnim(ped, "rcmjosh4", "josh_leadout_cop2", 8.0, 2.0, - 1, 48, 10, 0, 0, 0 )
								Citizen.Wait(600)
								ClearPedTasks(ped)
							end
							holstered = false
						end
					else
						if not holstered then
							Citizen.Wait(500)
							ClearPedTasks(ped)
							holstered = true
						end
					end
				end
			end
		end

		

      		for wep_name, wep_hash in pairs(weaponOnBackSettings.compatable_weapon_hashes) do
          		if HasPedGotWeapon(ped, wep_hash, false) and GetUserSettings("Show Weapon on Back") then
              			if not attached_weapons[wep_name] then
                  			AttachWeapon(wep_name, wep_hash, weaponOnBackSettings.back_bone, weaponOnBackSettings.x, weaponOnBackSettings.y, weaponOnBackSettings.z, weaponOnBackSettings.x_rotation, weaponOnBackSettings.y_rotation, weaponOnBackSettings.z_rotation, isMeleeWeapon(wep_name))
              			end
          		end
     	 	end

      		for name, attached_object in pairs(attached_weapons) do
          		if GetSelectedPedWeapon(ped) ==  attached_object.hash or not HasPedGotWeapon(ped, attached_object.hash, false) or not GetUserSettings("Show Weapon on Back") then -- equipped or not in weapon wheel
            			DeleteObject(attached_object.handle)
            			attached_weapons[name] = nil
          		end
      		end

		-- Bus Route Code
		if firstStop then
			if GetDistanceBetweenCoords(GetEntityCoords(ped), firstStop.x, firstStop.y, firstStop.z, false) < 20.0 then
				if found == false then
					found = true
					DrawBusRoute(item.stops, item.color)
				end
			else
				found = false
			end
		end

		Citizen.Wait(200)
	end
end)

-- Every 500ms
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		click = not click
	end
end)

-- Every 5000ms
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if #routeList > 0 then
			routeListCreeper = routeListCreeper + 1
			if routeListCreeper > #routeList then
				routeListCreeper = 1
			end

			if #routeList > 1 then
				DrawBusRoute(routeList[routeListCreeper].stops, routeList[routeListCreeper].color)
			end
		end

		local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

		local safe, coords = GetSafeCoordForPed(x, y, z, true, 16)
		local x, y, z = table.unpack(coords)

		if safe then
			SetResourceKvpFloat(ServerId .. "-CORE:PLAYER_X", x)
			SetResourceKvpFloat(ServerId .. "-CORE:PLAYER_Y", y)
			SetResourceKvpFloat(ServerId .. "-CORE:PLAYER_Z", z)
		end
	end
end)

-- Every 1000ms
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		currentTime = GetCurrentTime()
		AddTextEntry("CURRENT_TIME", currentTime)

		aopTime = aopTime + 1

		if coronerTime > 0 then
			if coronerTime > 1200 then
				coronerTime = 1200
			end

			if #(vector3(table.unpack(GetEntityCoords(PlayerPedId()))) - vector3(263.1, -1353.1, 24.5) ) > 16 then
				SetEntityCoords(ped, 263.1, -1353.1, 24.5)
			end

			RemoveAllPedWeapons(ped, true)

			coronerTime = coronerTime - 1

			if coronerTime == 0 or coronerTime < 0 then
				SetEntityCoords(ped, 240.4, -1379.9, 33.8)
			end

		elseif hospitalTime > 0 then
			if hospitalTime > 1200 then
				hospitalTime = 1200
			end
			
			if #(vector3(table.unpack(GetEntityCoords(PlayerPedId()))) - vector3(328.2, -596.1, 43.28) ) > 30 then
				SetEntityCoords(ped, 315.9, -584.7, 43.28)
			end

			RemoveAllPedWeapons(ped, true)

			hospitalTime = hospitalTime - 1

			if hospitalTime == 0 or hospitalTime < 0 then
				SetEntityCoords(ped, 298.5, -584.7, 43.26)
				if isPlayerCuffed then
					TriggerEvent('getCuffed')
				end
			end

		elseif jailTime > 0 then
			if jailTime > 1200 then
				jailTime = 1200
			end
			
			-- Keeping prisoner in the prison
			if GetNameOfZone(table.unpack(GetEntityCoords(PlayerPedId()))) ~= "JAIL" then
				SetEntityCoords(ped, 1691.169, 2565.421, 45.565)
			end

			RemoveAllPedWeapons(ped, true)

			jailTime = jailTime - 1

			if jailTime == 0 or jailTime < 0 then
				SetEntityCoords(ped, 1855.807, 2601.949, 45.323)
			end
		end
	end
end)

regions = {
	{"Little Seoul", "Los Santos"},
	{"Downtown Los Santos", "Los Santos"},
	{"Vespucci", "Los Santos"},
	{"Strawberry", "Los Santos"},
	{"La Mesa", "Los Santos"},
	{"Mirror Park", "Los Santos"},
	{"Downtown Vinewood", "Los Santos"},
	{"Vinewood Hills", "Los Santos"},
	{"Richman", "Los Santos"},
	{"La Puerta", "Los Santos"},
	{"Los Santos International Airport", "Los Santos"},
	{"Port of Los Santos", "Los Santos"},

	{"Grand Senora Desert", "Majestic County"},
	{"Redwood Lights Track", "Majestic County"},
	{"Sandy Shores", "Majestic County"},
	{"Grapeseed", "Majestic County"},
	{"Harmony", "Majestic County"},
	{"Bolingbroke Penitentiary", "Majestic County"},
	{"San Chianski", "Majestic County"},
	{"Alamo Sea", "Majestic County"}, 

	{"Chiliad State Wilderness", "Blaine County"},
	{"Paleto Bay", "Blaine County"},
	{"Mount Josiah", "Blaine County"},
	{"Fort Zancudo", "Blaine County"},
	{"Zancudo River", "Blaine County"},
	{"Stab City", "Blaine County"},

	{"Chumash", "Los Santos County"},
	{"Banham Canyon", "Los Santos County"},
	{"Davis", "Los Santos County"},

	{"Del Perro", "Los Santos County"},

	{"Burton", "Los Santos County"},
	{"Rockford Hills", "Los Santos County"},
	{"Morningwood", "Rockford Hills"},
	{"Richards Majestic", "Rockford Hills"},

	{"East Los Santos", "Los Santos County"},
	{"Tataviam Mountains", "Los Santos County"},
	{"Palomino Highlands", "Los Santos County"},
	{"Tataviam Valley", "Los Santos County"},

	{"Ludendorff", "North Yankton"},
	{"Lakota County", "North Yankton"},

	{"Marina Beach", "Blaine County"},
	--{"Marina Beach", "Roxwood County"},

	{"Paraíso Norte", "Cayo Perico"},
	{"Paraíso del Sur", "Cayo Perico"},

	{"Pacific Ocean", "San Andreas"},

	{"Liberty City", "Liberty City"},
}

function GetAddress(x, y, z)
	if serverMap == "San Andreas" then
		local street, cross = GetStreetNameAtCoord(x, y, z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
		street = GetStreetNameFromHashKey(street)
		cross = GetStreetNameFromHashKey(cross) or ""
		if street == "" then
			street = "Unnamed Road"
		elseif street == "Cavalry Blvd" and GetCurrentLocation() ~= "North Yankton" then
			street = "Buccaneer Way"
		end

		postal = GetNearestPostal(x, y, z)

		if street == "Cavalry Blvd" then
			if x < 3400.0 then
				area = "Ludendorff"
			else
				area = "Lakota County"
			end
		elseif GetLabelText(GetNameOfZone(x, y, z)) == "Pacific Ocean" and y > 6399.85 and y < 7700.0 and x > -1200.0 and x < 0.0 then
			area = "Marina Beach"
		elseif GetLabelText(GetNameOfZone(x, y, z)) == "Cayo Perico" then
			if GetCurrentLocation() == "Cayo Perico" then
				if y > -4950.0 then
					area = "Paraíso Norte"
				else
					area = "Paraíso del Sur"
				end
			else
				area = "Pacific Ocean"
			end
		else
			area = GetLabelText(GetNameOfZone(x, y, z))
		end

		region = "San Andreas"
		for _, item in ipairs(regions) do
			if item[1] == area then
				region = item[2]
			end
		end

		address = {postal = postal, street = street, cross = cross, area = area, region = region}

		return address
	elseif serverMap == "Liberty City" then

		street = GetNearestStreetLC(x, y, z)
		cross = ""
		postal = GetNearestPostal(x, y, z)
		area = "Liberty City"
		region = "State of Liberty"

		address = {postal = postal, street = street, cross = cross, area = area, region = region}

		return address
	end
end

Citizen.CreateThread(function()
	while not player.session do
		Citizen.Wait(100)
	end

	AddTextEntry("SPAWN_A", "Since you've just joined, we've seperated you from the rest of the server until you:")
	AddTextEntry("SPAWN_B", "Change your ~b~character model~s~ using vMenu or any other trainer.")
	AddTextEntry("SPAWN_C", "Set your ~b~character\'s name~s~ with the command \"/char\"")
	AddTextEntry("SPAWN_D", "Once you've done these steps, you will be allowed to interact with the rest of the server.")

	while player.session == 0 do
		
         	SetCanAttackFriendly(GetPlayerPed(-1), false, false)
            	NetworkSetFriendlyFireOption(false)	

		if not showPlayerlist then

			DrawRect(0.8 + safezoneSize - 0.5, 0.1 - safezoneSize + 0.5, 0.4, 0.2, 0, 0, 0, 200)

			DrawRect(0.8 + safezoneSize - 0.5, 0.2 - safezoneSize + 0.5, 0.4, 0.005, 46, 121, 189, 255)
			WriteText(0.61, 0.01, 0.5, "Welcome to " .. ServerName, 0, 0, 1.0, false, true, false, 255, 255, 255, 255)

			WriteText(0.61, 0.05, 0.3, "SPAWN_A", 0, 0, 1.0, true, true, false, 255, 255, 255, 255)

			WriteText(0.62, 0.09, 0.35, "SPAWN_B", 0, 0, 1.0, true, true, false, 255, 255, 255, 255)
			WriteText(0.62, 0.12, 0.35, "SPAWN_C", 0, 0, 1.0, true, true, false, 255, 255, 255, 255)

			WriteText(0.61, 0.16, 0.3, "SPAWN_D", 0, 0, 1.0, true, true, false, 255, 255, 255, 255)



			if not (GetEntityModel(ped) == GetHashKey("a_m_y_hipster_01")) then
				DrawRect(0.78 + safezoneSize - 0.5, 0.105 - safezoneSize + 0.5, 0.32, 0.003, 255, 255, 255, 255)
			elseif player.nick then
				DrawRect(0.754 + safezoneSize - 0.5, 0.135 - safezoneSize + 0.5, 0.265, 0.003, 255, 255, 255, 255)
			end
		end

		if not (GetEntityModel(ped) == GetHashKey("a_m_y_hipster_01")) and player.nick then
			TriggerServerEvent("changeSession", 1)
			player.session = 1
			SetCanAttackFriendly(GetPlayerPed(-1), true, false)
			NetworkSetFriendlyFireOption(true)
			Citizen.Wait(1000)
			AddTextEntry("SESSION_STRING", "")
			ShowInfoLabel("INFO_SESSIONRP")
			Citizen.Wait(5000)
			TriggerServerEvent("GetAdvertsOnSpawn")
		end

		Citizen.Wait(0)
	end
end)

AddEventHandler('gameEventTriggered', function (name, args)
	if devmode then
		print('game event ' .. name .. ' (' .. json.encode(args) .. ')')
		print(GetPlayerPed(-1))
		print(args[2])
	end
	if name == "CEventNetworkEntityDamange" and tonumber(args[2]) == GetPlayerPed(-1) then
		if devmode then
			ShowInfo("Player took damage")
		end
	end
end)


function DrawBusRoute(route, color)
	StartGpsMultiRoute(color, false, true)

	for _, item in ipairs(BusStops) do
		if item.name == route[#route] then
			AddPointToGpsMultiRoute(item.x, item.y, item.z)
		end
	end

	for i=1,2 do
		for _, item in ipairs(route) do
			for _, item2 in ipairs(BusStops) do
				if item2.name == item then
					AddPointToGpsMultiRoute(item2.x, item2.y, item2.z)
				end
			end
		end
	end

	for _, item in ipairs(BusStops) do
		if item.name == route[1] then
			AddPointToGpsMultiRoute(item.x, item.y, item.z)
		end
	end

	ClearGpsMultiRoute()
	SetGpsMultiRouteRender(true)
end

-- Every 500ms
Citizen.CreateThread(function()
	while true do
		safezoneSize = (GetSafeZoneSize()/2)
		if GetUserSettings("Aspect Ratio") == 2 then
			drawAdjust = 2
		elseif GetUserSettings("Aspect Ratio") == 3 then
			drawAdjust = 1.3125
		else
			drawAdjust = 1
		end

		local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

		local directions = nil
		local modifier = 45.0
		if GetUserSettings("Use Intercardinal Directions") then
			directions = directionsInter
			modifier = 22.5
		else
			directions = directionsCard
			modifier = 45.0
		end

		for k,v in pairs(directions)do
			direction = GetEntityHeading(PlayerPedId())
			if(math.abs(direction - k) < 45.0)then
				direction = v
				AddTextEntry("PLD_COMPASS", "| ~w~".. direction .. "~s~ |")
				break
			end
		end

		if direction == 'N' then
			relX1 = -0.015
		elseif direction == 'NE' then 
			relX1 = -0.0
		elseif direction == 'E' then 
			relX1 = -0.017
		elseif direction == 'SE' then 
			relX1 = -0.0
		elseif direction == 'S' then
			relX1 = -0.015
		elseif direction == 'SW' then
			relX1 = -0.0
		elseif direction == 'W' then 
			relX1 = -0.012
		elseif direction == 'NW' then
			relX1 = 0.005
		end

		address = GetAddress(x, y, z)

		if address.cross ~= "" then
			AddTextEntry("PLD_ADDRESS_1", "~w~" .. address.postal ..  " " .. address.street .. "/~s~" .. address.cross)
		else
			AddTextEntry("PLD_ADDRESS_1", "~w~" .. address.postal ..  " ~s~" .. address.street)
		end

		AddTextEntry("PLD_ADDRESS_2", address.area .. ", " .. address.region)

		if jailTime > 0 then
			AddTextEntry("PLD_ADDRESS_2", jailTime .. " seconds of jail time remaining")
		elseif coronerTime > 0 then
			AddTextEntry("PLD_ADDRESS_2", coronerTime .. " seconds of death time remaining")
		elseif hospitalTime > 0 then
			AddTextEntry("PLD_ADDRESS_2", hospitalTime .. " seconds of hospital time remaining")
		end

		if IsWaypointActive() then
			x2, y2, z2 = table.unpack(GetBlipInfoIdCoord(GetFirstBlipInfoId(8)))

			if serverMap == "San Andreas" then
				waypointAddress = GetNearestPostal(x2, y2, z2) .. " " .. GetStreetNameFromHashKey(GetStreetNameAtCoord(x2, y2, 0.0, Citizen.ResultAsInteger(), Citizen.ResultAsInteger()))
			else
				waypointAddress = GetNearestStreetLC(x2, y2, z2)
			end
		else
			waypointAddress = ""
		end

		if currentAOP == serverMap then
			if not inAOP then
				inAOP = true
				ShowInfo("You are now in the AOP")
			end
		elseif address.cross == "" and not (string.find(currentAOP, address.area) or string.find(currentAOP, address.region) or string.find(currentAOP, address.street)) then
			if inAOP then
				inAOP = false
				ShowInfo("You are no longer in the AOP")
			end
		elseif not (string.find(currentAOP, address.area) or string.find(currentAOP, address.region) or string.find(currentAOP, address.street) or string.find(currentAOP, address.cross)) then
			if inAOP then
				inAOP = false
				ShowInfo("You are no longer in the AOP")
			end
		else
			if not inAOP then
				inAOP = true
				ShowInfo("You are now in the AOP")
			end
		end

		if speedLimiter then
			SetVehicleMaxSpeed(vehicle.vehicle, (speedLimitInt) - 0.3)
			if IsVehicleSirenOn(vehicle.vehicle) then
				enableLimiter()
			end
		end

		if vehicle.vehicle and vehicle.driver then
			--Engine Warning Light
			if (vehicle.hp >= 0) and (vehicle.hp < 800) then
				warningLight = true
			else
				warningLight = false
			end
		
			CheckPlateValidity(vehicle.vehicle)
		end

		local transportBlips = GetUserSettings("Show Transport Blips")
		local stopFound = false

		for _, stop in ipairs(BusStops) do
			stopDistance = GetDistanceBetweenCoords(GetEntityCoords(ped), stop.x, stop.y, stop.z, true)
			
			if devmode then
				if not stop.blip then
					stop.blip = AddBlipForCoord(stop.x, stop.y, stop.z)
					SetBlipSprite(stop.blip, 266)
					SetBlipDisplay(stop.blip, 8)
					SetBlipAsShortRange(stop.blip, true)
				else
					SetBlipDisplay(stop.blip, 8)
				end
			elseif stopDistance < 250.0 and transportBlips then
				if not stop.blip then
					stop.blip = AddBlipForCoord(stop.x, stop.y, stop.z)
					SetBlipSprite(stop.blip, 266)
					SetBlipDisplay(stop.blip, 5)
					SetBlipAsShortRange(stop.blip, true)
				end
			else
				if stop.blip then
					RemoveBlip(stop.blip)
					stop.blip = nil
				end
			end

			if stopDistance < 2.0 then
				stopFound = true

				if not nearStop then
					nearStop = true

					local transitInfo = ""

					for _, item in ipairs(BusRoutes) do
						for _, item2 in ipairs(item.stops) do
							if stop.name == item2 then
								DrawBusRoute(item.stops, item.color)

								table.insert(routeList, item)
								if transitInfo ~= "" then
									transitInfo = transitInfo .. "~s~, "
								end

								transitInfo = transitInfo .. "~" .. hudColors[item.color + 1] .. "~" .. item.name
								
							end
						end
					end

					if transitInfo == "" then
						transitInfo = "N/A"
					end

					AddTextEntry("TRANSIT_INFO", stop.operator .. "~n~Stop Name: " .. stop.name .. "~n~~n~Routes: " .. transitInfo)
				end
			end
		end


		if not stopFound and nearStop then
			nearStop = false
			routeList = {}
			print("Clearing Route")
			ClearGpsMultiRoute()
		end

		for veh in EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle) do
			for _, blacklisted in ipairs(blacklistedVehicles) do
				if IsVehicleModel(veh, GetHashKey(blacklisted)) and player.session then
					if player.session < 5 then
						SetEntityAsMissionEntity(veh, true, true)
						Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh) )
					end
				end
			end
			if IsThisModelATrain(GetEntityModel(veh)) and devmode then
				print("Train " .. veh .. ": Node " .. GetTrainCurrentTrackNode(veh) .. ", carriage at index 1 is " .. GetTrainCarriage(veh, 1))
			end
		end

		local found = false

		for _, item in ipairs(phoneBooths) do
			if GetClosestObjectOfType(GetEntityCoords(ped), 1.0, GetHashKey(item), false, false, false) > 0 then
				nearPhoneBooth = true
				found = true
			end
		end
		if not found then
			nearPhoneBooth = false
		end

		Citizen.Wait(500)
	end
end)

function CheckPlateValidity(veh)

	local plate = GetVehicleNumberPlateText(veh)
	local type = GetVehicleNumberPlateTextIndex(veh)

	if plate ~= nil then
		if string.match(plate, "1%d%d%d%d%d%d%d") or string.match(plate, "%d%d%a%a%a%d%d%d") or string.match(plate, "%d%d%d% B%a%a%a") or string.match(plate, "%a%a%a% %d%d%d%d") or string.match(plate, "% %a%a%a%d%d%d% ") or string.match(plate, "% %d%d%d%a%a%a% ") then
			if GetCurrentLocation() == "San Andreas" or GetCurrentLocation() == "North Yankton" then
				if type == 4 and not string.match(plate, "1%d%d%d%d%d%d%d") then
					SetPlateRandom(veh, 2)
				elseif type == 5 and not string.match(plate, "%d%d%d% B%a%a%a") then
					SetPlateRandom(veh, 3)
				elseif type == 1 and not string.match(plate, "% %a%a%a%d%d%d% ") then
					SetPlateRandom(veh, 5)
				elseif type == 2 and not string.match(plate, "% %d%d%d%a%a%a% ") then
					SetPlateRandom(veh, 6)
				elseif type ~= 1 and type ~= 2 and type ~= 4 and type ~= 5 and not string.match(plate, "%d%d%a%a%a%d%d%d") then
					SetPlateRandom(veh, 1)
				end
			elseif GetCurrentLocation() == "Cayo Perico" then
				if not string.match(plate, "%a%a%a %d%d%d%d") then
					SetPlateRandom(veh, 4)
				end
			end
		elseif plate == "46EEK572" or plate == " FIVE M " or plate == " MENYOO " then
			SetVehicleNumberPlateTextIndex(veh, 0)
			SetPlateRandom(veh, 1)
		elseif not player.member or devmode then
			SetVehicleNumberPlateTextIndex(veh, 0)
			SetPlateRandom(veh, 1)
			ShowInfoLabel("RESTRICT_PLATE")
		end
	end
end


function SetPlateRandom(veh, type)
	math.randomseed(GetGameTimer())
	local plateString = ""

	if type == 1 then
		-- San Andreas
		for i = 1, 2 do
			plateString = plateString .. tostring(math.random(0,9))
		end
		for i = 1, 3 do
			plateString = plateString .. string.char(math.random(65,90))
		end
		for i = 1, 3 do
			plateString = plateString .. tostring(math.random(0,9))
		end
	elseif type == 2 then
		-- Exempt
		plateString = "1"
		for i = 1, 7 do
			plateString = plateString .. tostring(math.random(0,9))
		end
	elseif type == 3 then
		-- North Yankton
		for i = 1, 3 do
			plateString = plateString .. tostring(math.random(0,9))
		end

		plateString = plateString .. " B"
		for i = 1, 3 do
			plateString = plateString .. string.char(math.random(65,90))
		end
	elseif type == 4 then
		-- Cayo Perico
		for i = 1, 3 do
			plateString = plateString .. string.char(math.random(65,90))
		end
		plateString = plateString .. " "
		for i = 1, 4 do
			plateString = plateString .. tostring(math.random(0,9))
		end
	elseif type == 5 then
		-- Yellow on black
		plateString = " "
		for i = 1, 3 do
			plateString = plateString .. string.char(math.random(65,90))
		end
		for i = 1, 3 do
			plateString = plateString .. tostring(math.random(0,9))
		end
		plateString = plateString .. " "
	elseif type == 6 then
		-- Yellow on blue
		plateString = " "
		for i = 1, 3 do
			plateString = plateString .. tostring(math.random(0,9))
		end
		for i = 1, 3 do
			plateString = plateString .. string.char(math.random(65,90))
		end
		plateString = plateString .. " "
	else
		-- Something's gone wrong, reset plate
		plateString = "46EEK572"
	end
	SetVehicleNumberPlateText(veh, plateString)
end


Citizen.CreateThread(function()
	local indestructiblePropsHash = {}
	for _, item in ipairs(indestructibleProps) do
		indestructiblePropsHash[GetHashKey(item)] = true
	end

	while true do
		Citizen.Wait(2000)
		for obj in EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject) do
			if indestructiblePropsHash[GetEntityModel(obj)] then
				FreezeEntityPosition(obj, true)
			end
		end
	end
end)


function AttachWeapon(attachModel,modelHash,boneNumber,x,y,z,xR,yR,zR, isMelee)
	local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumber)
	RequestModel(attachModel)
	while not HasModelLoaded(attachModel) do
		Wait(100)
	end

  attached_weapons[attachModel] = {
    hash = modelHash,
    handle = CreateObject(GetHashKey(attachModel), 1.0, 1.0, 1.0, true, true, false)
  }

  if isMelee then x = 0.11 y = -0.14 z = 0.0 xR = -75.0 yR = 185.0 zR = 92.0 end -- reposition for melee items
  if attachModel == "prop_ld_jerrycan_01" then x = x + 0.3 end
	AttachEntityToEntity(attached_weapons[attachModel].handle, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
end

function isMeleeWeapon(wep_name)
    if wep_name == "prop_golf_iron_01" then
        return true
    elseif wep_name == "w_me_bat" then
        return true
    elseif wep_name == "prop_ld_jerrycan_01" then
      return true
    else
        return false
    end
end

function GetCurrentTime()
	local minutes = GetClockMinutes()
	if minutes < 10 then
		minutes = ("0" .. minutes)
	end
	return (GetClockHours() .. ":" .. minutes)
end

pldColors = {
	{r = 46, g = 121, b = 189}, -- Republic Blue
	{r = 182, g = 27, b = 30}, -- Red
	{r = 255, g = 200, b = 60}, -- Yellow
	{r = 20, g = 160, b = 50}, -- Green
	{r = 150, g = 120, b = 200}, -- Purple
	{r = 255, g = 255, b = 255}, -- White
}

pldSettingsNew = {
	{ -- Millennium
		{label = "PLD_ADDRESS_1", x = 0.065, y = 0.94, size = 0.6, wrap = 1.0, opacity = 255, color = false, minimap = true, compass = true},
		{label = "PLD_ADDRESS_2", x = 0.065, y = 0.97, size = 0.5, wrap = 1.0, opacity = 255, color = false, minimap = true, compass = true},
		{label = "AOP_STRING", x = 0.065, y = 0.915, size = 0.45, wrap = 1.0, opacity = 255, color = false, minimap = true, compass = true},
		{label = "ALERT_STRING", x = 0.065, y = 0.89, size = 0.45, wrap = 1.0, opacity = 255, color = true, minimap = true, compass = true},
		{label = "PLD_COMPASS", x = 0.0, y = 0.932, size = 1.25, wrap = 1.0, opacity = 255, color = true, minimap = true},
		{label = "CURRENT_TIME", x = 0.0, y = 0.915, size = 0.45, wrap = 1.0, opacity = 255, color = false, minimap = true},
	},
	{ -- Rapid
		{label = "PLD_ADDRESS_1", x = 0.05, y = 0.955, size = 0.4, wrap = 1.0, opacity = 150, brightness = 220, color = true, minimap = true, compass = true},
		{label = "PLD_ADDRESS_2", x = 0.05, y = 0.977, size = 0.35, wrap = 1.0, opacity = 150, brightness = 220, color = false, minimap = true, compass = true},
		{label = "AOP_STRING", x = 0.05, y = 0.93, size = 0.35, wrap = 1.0, opacity = 150, brightness = 220, color = false, minimap = true, compass = true},
		{label = "ALERT_STRING", x = 0.05, y = 0.91, size = 0.35, wrap = 1.0, opacity = 150, brightness = 220, color = true, minimap = true, compass = true},
		{label = "PLD_COMPASS", x = 0.0, y = 0.95, size = 0.9, wrap = 1.0, opacity = 150, brightness = 220, color = true, minimap = true},
		{label = "CURRENT_TIME", x = 0.0, y = 0.93, size = 0.35, wrap = 1.0, opacity = 150, brightness = 220, color = false, minimap = true},
	},

	{ -- Centered
		{showCenterCompass = true},
		{label = "PLD_ADDRESS_1", x = 0.5, y = 0.0, size = 0.5, wrap = nil, opacity = 255, color = true},
		{label = "PLD_ADDRESS_2", x = 0.5, y = 0.03, size = 0.5, wrap = nil, opacity = 255, color = false},
		{label = "AOP_STRING", x = 0.5, y = 0.975, size = 0.4, wrap = nil, opacity = 255, color = false},
		{label = "ALERT_STRING", x = 0.5, y = 0.95, size = 0.4, wrap = nil, opacity = 255, color = true},
	},

	{ -- Rockstar
		{label = "PLD_ADDRESS_1", x = 1.0, y = 0.93, size = 0.6, wrap = 0.0, opacity = 255, color = false, font = 1, outline = 10},
		{label = "PLD_ADDRESS_2", x = 1.0, y = 0.96, size = 0.5, wrap = 0.0, opacity = 255, color = false, font = 1, outline = 10},
		{label = "ALERT_STRING", x = 1.0, y = 0.04, size = 0.5, wrap = 0.0, opacity = 255, color = true, font = 1, outline = 10},
		{label = "AOP_STRING", x = 1.0, y = 0.01, size = 0.5, wrap = 0.0, opacity = 255, color = false, font = 1, outline = 10},
	},
	
	{ -- Millennium Mirrored
		{label = "PLD_ADDRESS_1", x = 0.935, y = 0.94, size = 0.6, wrap = 0.0, opacity = 255, color = false, compass = true},
		{label = "PLD_ADDRESS_2", x = 0.935, y = 0.97, size = 0.5, wrap = 0.0, opacity = 255, color = false, compass = true},
		{label = "AOP_STRING", x = 0.935, y = 0.915, size = 0.45, wrap = 0.0, opacity = 255, color = false, compass = true},
		{label = "ALERT_STRING", x = 0.935, y = 0.89, size = 0.45, wrap = 0.0, opacity = 255, color = true, compass = true},
		{label = "PLD_COMPASS", x = 1.0, y = 0.932, size = 1.25, wrap = 0.0, opacity = 255, color = true},
		{label = "CURRENT_TIME", x = 1.0, y = 0.915, size = 0.45, wrap = 0.0, opacity = 255, color = false},
	},

	{ -- Rapid Mirrored
		{label = "PLD_ADDRESS_1", x = 0.95, y = 0.955, size = 0.4, wrap = 0.0, opacity = 150, brightness = 220, color = false, compass = true},
		{label = "PLD_ADDRESS_2", x = 0.95, y = 0.977, size = 0.35, wrap = 0.0, opacity = 150, brightness = 220, color = false, compass = true},
		{label = "AOP_STRING", x = 0.95, y = 0.93, size = 0.35, wrap = 0.0, opacity = 150, brightness = 220, color = false, compass = true},
		{label = "ALERT_STRING", x = 0.95, y = 0.91, size = 0.35, wrap = 0.0, opacity = 150, brightness = 220, color = true, compass = true},
		{label = "PLD_COMPASS", x = 1.0, y = 0.95, size = 0.9, wrap = 0.0, opacity = 150, brightness = 220, color = true},
		{label = "CURRENT_TIME", x = 1.0, y = 0.93, size = 0.35, wrap = 0.0, opacity = 150, brightness = 220, color = false},
	},

	{ -- Disabled
		{label = "ALERT_STRING", x = 0.0, y = 0.94, size = 0.4, wrap = 1.0, opacity = 150, color = true, minimap = true},
		{label = "AOP_STRING", x = 0.0, y = 0.97, size = 0.4, wrap = 1.0, opacity = 150, color = false, minimap = true},
	},


}


function drawPld()
	local pldType = GetUserSettings("PLD Theme")
	local pldColor = pldColors[GetUserSettings("PLD Color")]
	local pldAOP = GetUserSettings("Always Show AOP")

	if (GetUserSettings("Hide PLD when minimap is hidden") and not checkMap) then
		pldType = 7

	end

	for _, item in ipairs(pldSettingsNew[pldType]) do
		if item.showCenterCompass then
			drawPldCenterCompass()
		else
			local alignX = ((item.minimap and mapOffset) or 0) + (item.compass and relX1 or 0)

			if item.x > 0.5 then
				alignX = -alignX
			end

			local r, g, b = nil, nil, nil
			if item.color then
				r, g, b = pldColor.r, pldColor.g, pldColor.b
			elseif item.brightness then
				r, g, b = item.brightness, item.brightness, item.brightness
			else
				r, g, b = 255, 255, 255
			end

			-- Hacky workaround to make the AOP indicator/alert "smart"
			
			if (item.label == "AOP_STRING" and player.session > 1) then
				WriteText(item.x + alignX, item.y, item.size, "SESSION_STRING", item.font or 6, item.outline or 1, item.wrap, true, true, false, r, g, b, item.opacity)
			elseif (item.label == "AOP_STRING" and not (pldAOP or not inAOP or aopVote)) then -- Don't show AOP
				r, g, b = pldColor.r, pldColor.g, pldColor.b
				WriteText(item.x + alignX, item.y, item.size, "ALERT_STRING", item.font or 6, item.outline or 1, item.wrap, true, true, false, r, g, b, item.opacity)
			elseif not (item.label == "ALERT_STRING" and not (pldAOP or not inAOP or aopVote)) then
				WriteText(item.x + alignX, item.y, item.size, item.label, item.font or 6, item.outline or 1, item.wrap, true, true, false, r, g, b, item.opacity)
			end
		end
	end
end

function drawPldCenterCompass()
		local pxDegree = 0.25 / 180
		local playerHeadingDegrees = 0

		local camRot = Citizen.InvokeNative( 0x837765A25378F0BB, 0, Citizen.ResultAsVector() )
		playerHeadingDegrees = 270.0 - ((camRot.z + 360.0) % 360.0)
		
		local tickDegree = playerHeadingDegrees - 180 / 2
		local tickDegreeRemainder = 9.0 - (tickDegree % 9.0)
		local tickPosition = 0.25 + tickDegreeRemainder * pxDegree
		
			tickDegree = tickDegree + tickDegreeRemainder
		
			while tickPosition < 0.75 do
				if (tickDegree % 90.0) == 0 then
					-- Draw cardinal
					DrawRect( tickPosition, 0.57-safezoneSize, 0.001, 0.012, 255, 255, 255, 255)
				
					drawTxt(tickPosition, 0.57-safezoneSize + 0.015, 0.45, degreesToIntercardinalDirection( tickDegree ), 6, 1, 0, 255, 255, 255, 255)
				elseif (tickDegree % 45.0) == 0 then
					DrawRect( tickPosition, 0.57-safezoneSize, 0.001, 0.006, 255, 255, 255, 255)
					drawTxt(tickPosition, 0.57-safezoneSize + 0.015, 0.3, degreesToIntercardinalDirection( tickDegree ), 6, 1, 0, 255, 255, 255, 255)
				else
					-- Draw tick
					DrawRect( tickPosition, 0.57-safezoneSize, 0.001, 0.003, 255, 255, 255, 255)
				end
			
				-- Advance to the next tick
				tickDegree = tickDegree + 9.0
				tickPosition = tickPosition + pxDegree * 9.0
			end
end


function degreesToIntercardinalDirection( dgr )
	dgr = dgr % 360.0
	
	if (dgr >= 0.0 and dgr < 22.5) or dgr >= 337.5 then
		return "N "
	elseif dgr >= 22.5 and dgr < 67.5 then
		return "NE"
	elseif dgr >= 67.5 and dgr < 112.5 then
		return "E"
	elseif dgr >= 112.5 and dgr < 157.5 then
		return "SE"
	elseif dgr >= 157.5 and dgr < 202.5 then
		return "S"
	elseif dgr >= 202.5 and dgr < 247.5 then
		return "SW"
	elseif dgr >= 247.5 and dgr < 292.5 then
		return "W"
	elseif dgr >= 292.5 and dgr < 337.5 then
		return "NW"
	end
end

function drawVehicleUI()
	if vehicle.aircraft then
		DrawRect(0.467-safezoneSize + mapOffset, 0.467+safezoneSize, 0.046, 0.03,0,0,0,150)
		drawTxt(0.444-safezoneSize + mapOffset, 0.445+safezoneSize, 0.64, "~w~" .. math.ceil(vehicle.speed), 4, 2, 1, 255, 255, 255, 255)
		drawTxt(0.469-safezoneSize + mapOffset, 0.457+safezoneSize, 0.4,  "~w~ mph", 4, 2, 1, 255, 255, 255, 255)

		DrawRect(0.467-safezoneSize, 0.432+safezoneSize, 0.046, 0.03, 0, 0, 0, 150)
		drawTxt(0.444-safezoneSize, 0.415+safezoneSize, 0.5, "~w~" .. (math.floor(GetEntityHeightAboveGround(vehicle.vehicle) * 3.28)), 4, 2, 1, 255, 255, 255, 255)
		drawTxt(0.475-safezoneSize, 0.420+safezoneSize, 0.4,  "~w~ ft", 4, 2, 1, 255, 255, 255, 255)
	elseif vehicle.class ~= 13 and vehicle.vehicle then

		DrawRect(0.467-safezoneSize + mapOffset, 0.467+safezoneSize, 0.046, 0.03,0,0,0,150)
		drawTxt(0.444-safezoneSize + mapOffset, 0.445+safezoneSize, 0.64, "~w~" .. math.ceil(vehicle.speed), 4, 2, 1, 255, 255, 255, 255)
		drawTxt(0.469-safezoneSize + mapOffset, 0.457+safezoneSize, 0.4,  "~w~ mph", 4, 2, 1, 255, 255, 255, 255)

		if vehicle.fuel then
			DrawRect(0.467-safezoneSize + mapOffset, 0.432+safezoneSize, 0.046, 0.03, 0, 0, 0, 150)
			drawTxt(0.444-safezoneSize + mapOffset, 0.415+safezoneSize, 0.5, "~w~" .. math.ceil(vehicle.fuel) .. "%", 4, 2, 1, 255, 255, 255, 255)
			drawTxt(0.471-safezoneSize + mapOffset,  0.420+safezoneSize, 0.4, "~w~ fuel", 4, 2, 1, 255, 255, 255, 255)


			if vehicle.fuel < 20.0 or IsVehicleEngineStarting(vehicle.vehicle) then
				DrawSprite("vehicleui", "fuel", 0.548-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 255, 180, 0, 255) -- Orange
			else
				DrawSprite("vehicleui", "fuel", 0.548-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
			end
		end
			
		if warningLight or IsVehicleEngineStarting(vehicle.vehicle) then
			DrawSprite("vehicleui", "engine", 0.53-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 255, 180, 0, 255) -- Orange
		else
			DrawSprite("vehicleui", "engine", 0.53-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
		end


		if vehicle.bike then

			if speedLimiter or IsVehicleEngineStarting(vehicle.vehicle) then
				DrawSprite("vehicleui", "limit", 0.512-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 80, 180, 80, 255) -- Green
			else
				DrawSprite("vehicleui", "limit", 0.512-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
			end
		else
			if (not seatbeltOn and requireSeatbelt) or IsVehicleEngineStarting(vehicle.vehicle) then
				DrawSprite("vehicleui", "seatbelt", 0.512-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 230, 0, 0, 200) -- Red
			else
				DrawSprite("vehicleui", "seatbelt", 0.512-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
			end

			if speedLimiter or IsVehicleEngineStarting(vehicle.vehicle) then
				DrawSprite("vehicleui", "limit", 0.512-safezoneSize, 0.438+safezoneSize, 0.016, 0.027, 0.0, 80, 180, 80, 255) -- Green
			else
				DrawSprite("vehicleui", "limit", 0.512-safezoneSize, 0.438+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
			end

			if GetVehicleDoorAngleRatio(vehicle.vehicle, 5) > 0 or IsVehicleEngineStarting(vehicle.vehicle) then
				DrawSprite("vehicleui", "trunk", 0.53-safezoneSize, 0.438+safezoneSize, 0.016, 0.027, 0.0, 80, 180, 80, 255) -- Green
			else
				DrawSprite("vehicleui", "trunk", 0.53-safezoneSize, 0.438+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
			end

			if GetVehicleDoorAngleRatio(vehicle.vehicle, 4) > 0 or IsVehicleEngineStarting(vehicle.vehicle) then
				DrawSprite("vehicleui", "hood", 0.548-safezoneSize, 0.438+safezoneSize, 0.016, 0.027, 0.0, 80, 180, 80, 255) -- Green
			else
				DrawSprite("vehicleui", "hood", 0.548-safezoneSize, 0.438+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
			end
		end



		if vehicle.highbeam ~= 0 or IsVehicleEngineStarting(vehicle.vehicle) then
			DrawSprite("vehicleui", "highbeam", 0.53-safezoneSize, 0.340+safezoneSize, 0.016, 0.027, 0.0, 100, 100, 255, 200) -- Blue
		else
			DrawSprite("vehicleui", "highbeam", 0.53-safezoneSize, 0.340+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
		end

		if vehicle.lights ~= 0 or vehicle.highbeam ~= 0 or IsVehicleEngineStarting(vehicle.vehicle) then
			DrawSprite("vehicleui", "headlights", 0.512-safezoneSize, 0.340+safezoneSize, 0.016, 0.027, 0.0, 80, 180, 80, 255) -- Green
		else
			DrawSprite("vehicleui", "headlights", 0.512-safezoneSize, 0.340+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
		end

		if ((GetVehicleIndicatorLights(vehicle.vehicle) == 1 or GetVehicleIndicatorLights(vehicle.vehicle) == 3) and click) or IsVehicleEngineStarting(vehicle.vehicle) then
			DrawSprite("vehicleui", "turnleft", 0.46-safezoneSize + mapOffset, 0.340+safezoneSize, 0.016, 0.027, 0.0, 80, 180, 80, 255) -- Green
		else
			DrawSprite("vehicleui", "turnleft", 0.46-safezoneSize + mapOffset, 0.340+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
		end

		if ((GetVehicleIndicatorLights(vehicle.vehicle) == 2 or GetVehicleIndicatorLights(vehicle.vehicle) == 3) and click) or IsVehicleEngineStarting(vehicle.vehicle) then
			DrawSprite("vehicleui", "turnright", 0.478-safezoneSize + mapOffset, 0.340+safezoneSize, 0.016, 0.027, 0.0, 80, 180, 80, 255) -- Green
		else
			DrawSprite("vehicleui", "turnright", 0.478-safezoneSize + mapOffset, 0.340+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
		end
	end
end





function RenderPlayerlist()

	HideHudAndRadarThisFrame()
	--[[
		Player List
	]]

	DrawRect(0.3475 - safezoneSize + 0.5, 0.15 - safezoneSize + 0.5, 0.695, 0.3, 0, 0, 0, 200)

	-- Calculations for player stuffs
	local listRow = 1
	local listColumn = 1

	onlinePlayersPage = {}
	for i=1, 24 do
		table.insert(onlinePlayersPage, onlinePlayers[i+(playerlistPage*24) - 24])
	end

	WriteText(0.01 - safezoneSize + 0.5, 0.01 - safezoneSize + 0.5, 0.3, #onlinePlayers .. " Online Players", 0, 0, 1.0, false, false, false, 255, 255, 255, 255)

	-- Removed for now, may readd
	--DrawSprite("playerlist_icon", "playerlist_icon", 0.4475 -safezoneSize + 0.5, 0.15 - safezoneSize + 0.5, 0.4, 0.3, 0.0, 150, 150, 150, 50)

	for _, item in ipairs(onlinePlayersPage) do
		local opacity = 255
		if tonumber(item.id) ~= GetPlayerServerId(PlayerId()) and item.session ~= player.session then
			opacity = 180
		end

		offsetX = listColumn * 0.115 - safezoneSize + 0.5
		offsetY = listRow * 0.06 - safezoneSize + 0.5 - 0.01

		DrawRect(-0.055 + offsetX, 0.02 + offsetY, 0.11,0.05,0,0,0,255)


		-- Information
		local r, g, b = 255, 255, 255

		if tonumber(item.id) == GetPlayerServerId(PlayerId()) then
			r, g, b = 255, 229, 0
		elseif item.member then
			r, g, b = 46, 121, 189
		end

		DrawRect(-0.055 + offsetX, 0.0425 + offsetY, 0.11,0.0025, r, g, b, 255)

		-- Player ID
		WriteText(-0.105 + offsetX, -0.002 + offsetY, 0.3, item.id, 0, 0, 1.0, false, false, false, 255, 255, 255, opacity)

		-- Player Name
		if string.len(item.name) > 17 then
			WriteText(-0.085 + offsetX, -0.002 + offsetY, 0.25, item.name, 0, 0, 1.0, false, false, false, 255, 255, 255, opacity)
		elseif string.len(item.name) > 12 then
			WriteText(-0.085 + offsetX, -0.002 + offsetY, 0.28, item.name, 0, 0, 1.0, false, false, false, 255, 255, 255, opacity)
		else
			WriteText(-0.085 + offsetX, -0.002 + offsetY, 0.3, item.name, 0, 0, 1.0, false, false, false, 255, 255, 255, opacity)
		end

		-- Player Nick
		local NickString = "Error Obtaining Name"

		if item.session == 0 then
			NickString = "Spawn Session"
		elseif item.session == 2 then
			NickString = "Freeroam Session"
		elseif item.session > 5 then
			NickString = "Private Session"
		elseif item.nick then
			NickString = item.nick
			if item.nick == "John Bingle" then
				NickString = "???"
			end
		end

		WriteText(-0.085 + offsetX, 0.018 + offsetY, 0.25, NickString, 0, 0, 1.0, false, false, false, 150, 150, 150, opacity)

		if listColumn == 6 then
			listColumn = 1
			listRow = listRow + 1
		else
			listColumn = listColumn + 1
		end

	end

	if #onlinePlayers > 24 then
		WriteText(0.35 - safezoneSize + 0.5, 0.01 - safezoneSize + 0.5, 0.3, "Page " .. playerlistPage .. " of " .. math.ceil(#onlinePlayers/24), 0, 0, nil, false, false, false, 255, 255, 255, 255)
	end


	--[[
		Server Information
	]]

	DrawRect(0.85, 0.045 - safezoneSize + 0.5, 0.3 + (2 * (safezoneSize - 0.5)), 0.09, 0, 0, 0, 200)

	-- Area of Play
	WriteText(0.71 - safezoneSize + 0.5, 0.01 - safezoneSize + 0.5, 0.3, "AOP_STRING", 0, 0, 0.99 + safezoneSize - 0.5, true, false, false, 255, 255, 255, 255)

	-- Time Since Last AOP Change
	WriteText(0.71 - safezoneSize + 0.5, 0.05 - safezoneSize + 0.5, 0.3, math.floor(aopTime / 60) .. " minutes since last AOP change", 0, 0, 0.99 + safezoneSize - 0.5, false, false, false, 255, 255, 255, 255)

	-- In-game Time
	WriteText(0.99 + safezoneSize - 0.5, 0.05 - safezoneSize + 0.5, 0.3, "CURRENT_TIME", 0, 0, 0.0, true, false, false, 255, 255, 255, 255)


	--[[
		Server Information Part 2
	]]

	DrawRect(0.85, 0.2 - safezoneSize + 0.5, 0.3 + (2 * (safezoneSize - 0.5)), 0.2, 0, 0, 0, 200)

	WriteText(0.71 - safezoneSize + 0.5, 0.11 - safezoneSize + 0.5, 0.3, "Server Status", 0, 0, 0.99 + safezoneSize - 0.5, false, false, false, 255, 255, 255, 255)
	if whitelist then
		WriteText(0.71 - safezoneSize + 0.5, 0.14 - safezoneSize + 0.5, 0.3, "~g~Server Members Only", 0, 0, 0.99 + safezoneSize - 0.5, false, false, false, 255, 255, 255, 255)	
	elseif leoUnitsAvailable == 0 and fireUnitsAvailable == 0 then
		WriteText(0.71 - safezoneSize + 0.5, 0.14 - safezoneSize + 0.5, 0.3, "~r~No Emergency Services Available", 0, 0, 0.99 + safezoneSize - 0.5, false, false, false, 255, 255, 255, 255)	
	else
		WriteText(0.71 - safezoneSize + 0.5, 0.14 - safezoneSize + 0.5, 0.3, "~b~All Players Allowed", 0, 0, 0.99 + safezoneSize - 0.5, false, false, false, 255, 255, 255, 255)	
	end
	WriteText(0.71 - safezoneSize + 0.5, 0.17 - safezoneSize + 0.5, 0.3, "ALERT_STRING", 0, 0, 0.99 + safezoneSize - 0.5, true, false, false, 46, 121, 189, 255)


	WriteText(0.71 - safezoneSize + 0.5, 0.24 - safezoneSize + 0.5, 0.3, "LEO Units~n~Fire/EMS Units", 0, 0, 0.99 + safezoneSize - 0.5, false, false, false, 255, 255, 255, 255)
	WriteText(0.99 + safezoneSize - 0.5, 0.24 - safezoneSize + 0.5, 0.3, leoUnitCount .. " on-duty / " .. leoUnitsAvailable .. " available~n~"..fireUnitCount .. " on-duty / "..fireUnitsAvailable.." available", 0, 0, 0.0, false, false, false, 255, 255, 255, 255)

end

function RenderNamesAboveHead()
	x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))

	-- Player names above head
        for id = 0, 255 do 
		if NetworkIsPlayerActive(id) then
			x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
			if GetPlayerFromServerId(GetPlayerServerId(id)) ~= GetPlayerIndex() then
				local playerPed = GetPlayerPed(id)
				local nick = GetPlayerNick(id)
				if nick == "John Bingle" then
					nick = "???"
				end

				if IsPedInAnyVehicle(playerPed, false) then
					local found = false
					for i=-1, 2 do
						if GetPedInVehicleSeat(GetVehiclePedIsIn(playerPed, -1), i) == playerPed then
							drawTxt3D(x2, y2, z2+2.0+(0.5*i), GetPlayerServerId(id), 255,255,255, 1.2)
							if nick then
								drawTxt3D(x2, y2, z2+1.8+(0.5*i), nick, 255,255,255, 0.8)
							end
							found = true
						end
					end
					if not found then
						drawTxt3D(x2, y2, z2+1.5, GetPlayerServerId(id), 255,255,255, 1.2)
						if nick then
							drawTxt3D(x2, y2, z2+1.3, nick, 255,255,255, 0.8)
						end
					end
				else
					drawTxt3D(x2, y2, z2+1.5, GetPlayerServerId(id), 255,255,255, 1.2)
					if nick then
						drawTxt3D(x2, y2, z2+1.3, nick, 255,255,255, 0.8)
					end
				end
			end
		end
        end
end




function enableLimiter()
	if speedLimiter == false and GetEntitySpeed(vehicle.vehicle, false) > 0 and not IsVehicleSirenOn(vehicle.vehicle) then
		speedLimitInt = math.ceil((GetEntitySpeed(vehicle.vehicle, false) * 2.236936)/5) * 5/2.236936
		SetVehicleMaxSpeed(vehicle.vehicle, (speedLimitInt) - 0.3)
		ShowInfo("Limiter Enabled ".. math.ceil(speedLimitInt * 2.236936) .. " mph")
		speedLimiter = true
	else
		SetVehicleMaxSpeed(vehicle.vehicle, -1)
		speedLimiter = false
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		--missmic2ig_11 - mic_2_ig_11_intro_goon & mic_2_ig_11_intro_p_one
	end
end)

-- Every 0ms
Citizen.CreateThread(function()
	while not player.session do
		Citizen.Wait(100)
	end

	while true do
		Citizen.Wait(0)

		if IsPauseMenuActive() then
			if justPaused == false then
				justPaused = true
				if GetUserSettings("Map Style") == 2 then
					for _, item in ipairs(mapDictionaryList) do
						loadTextDict(item[2])
					end
				end

				for _, item in ipairs(mapDictionaryList) do
					if GetUserSettings("Map Style") == 2 then
						AddReplaceTexture(item[1], item[1], item[2], item[1])
					else
						RemoveReplaceTexture(item[1], item[1])
					end
				end
			end

			if waypointAddress ~= "" then
				SetScriptGfxDrawOrder(7)
				SetScriptGfxDrawBehindPausemenu(true)
				drawTxt(0.505-safezoneSize, 0.470+safezoneSize, 0.4, waypointAddress, 8, 1, 1, 255, 255, 255, 255)
				SetScriptGfxDrawBehindPausemenu(false)
				SetScriptGfxDrawOrder(2)
			end
		else
			justPaused = false
		end

		-- Process menus
        	if (_menuPool:IsAnyMenuOpen()) then
           		_menuPool:ProcessMenus()
	    		DisableControlAction(0, 27, true)
        	end
    		_menuPool:ControlDisablingEnabled(false)
    		_menuPool:MouseControlsEnabled(false)


		-- No wanted levels!
		SetPlayerWantedLevel(PlayerId(), 0, false)
		SetPlayerWantedLevelNow(PlayerId(), false)


		-- Hiding Default UI
		-- Wanted Stars
		HideHudComponentThisFrame(1)
		-- Area name and Street Name
		HideHudComponentThisFrame(7)
		HideHudComponentThisFrame(9)
		-- Cash
		HideHudComponentThisFrame(3)
		HideHudComponentThisFrame(4)

		-- default 0.8
		SetParkedVehicleDensityMultiplierThisFrame(0.8)
		SetVehicleDensityMultiplierThisFrame(0.8)
		SetRandomVehicleDensityMultiplierThisFrame(0.8)
		
		SetPedDensityMultiplierThisFrame(1.5)
		
		SetArtificialLightsStateAffectsVehicles(false) -- Re-enable vehicle lights when in blackout


		if DoesBlipExist(GetBlipFromEntity(GetPlayerPed(1))) and not player.staff then
			HideMinimapExteriorMapThisFrame()
			HideMinimapInteriorMapThisFrame()
		end


		-- Draw PLD
		if hideAllUI then
			HideHudAndRadarThisFrame()
		elseif not showPlayerlist then
			drawPld()
		end

		-- MDT trigger
		if mdtOpen then
			DrawMdt()
		elseif (jobA == "Law Enforcement" or jobA == "Fire/EMS") and not hideAllUI then
			if mdtUnread == "Panic Button" then
				DrawRect(0.45+safezoneSize, 0.48+safezoneSize, 0.1, 0.04, 150, 0, 0, 255)
				drawTxt(0.45+safezoneSize, 0.465+safezoneSize, 0.5, "PANIC BUTTON", 4, 2, 0, 255, 255, 255, 255)
			elseif mdtUnread == "Crime Broadcast" then
				DrawRect(0.45+safezoneSize, 0.48+safezoneSize, 0.1, 0.04, 0, 0, 0, 255)
				drawTxt(0.45+safezoneSize, 0.465+safezoneSize, 0.5, "Crime Broadcast", 4, 2, 0, 255, 255, 255, 255)
			elseif mdtUnread then
				DrawRect(0.45+safezoneSize, 0.48+safezoneSize, 0.1, 0.04, 0, 0, 0, 255)
				drawTxt(0.45+safezoneSize, 0.465+safezoneSize, 0.5, "Unread MDT Calls", 4, 2, 0, 255, 255, 255, 255)
			else
				if player.status == "CLEAR" then DrawRect(0.46+safezoneSize, 0.48+safezoneSize, 0.08, 0.04, 33, 145, 134, 255) end
				if player.status == "CODE SIX" then DrawRect(0.46+safezoneSize, 0.48+safezoneSize, 0.08, 0.04, 36, 156, 62, 255) end
				if player.status == "ON SCENE" then DrawRect(0.46+safezoneSize, 0.48+safezoneSize, 0.08, 0.04, 36, 156, 62, 255) end
				if player.status == "UNAVAILABLE" then DrawRect(0.46+safezoneSize, 0.48+safezoneSize, 0.08, 0.04, 169, 0, 18, 255) end
				if player.status == "BUSY" then DrawRect(0.46+safezoneSize, 0.48+safezoneSize, 0.08, 0.04, 177, 78, 0, 255) end
				if player.status == "ENROUTE" then DrawRect(0.46+safezoneSize, 0.48+safezoneSize, 0.08, 0.04, 36, 78, 156, 255) end
				DrawRect(0.46+safezoneSize, 0.48+safezoneSize, 0.076, 0.036, 0, 0, 0, 255)
				drawTxt(0.46+safezoneSize, 0.465+safezoneSize, 0.5, player.status, 4, 2, 0, 255, 255, 255, 255)
			end
		end


		-- Show AOP menu
		if IsControlJustReleased(0, 212) and player.member and not voted then
			aopMenu:Visible(not aopMenu:Visible())		
		end


		if not vehicle.vehicle then

			if IsControlPressed(0, 33) and IsControlPressed(0, 32) then

				if IsControlPressed(0, 35) and walkingBackwards ~= 2 then
					TaskPlayAnim(ped, "move_strafe@first_person@generic", "walk_bwd_135_loop", 5.0, 1.0, -1, 1, 0.1)
					walkingBackwards = 2

				elseif IsControlPressed(0, 34) and walkingBackwards ~= 3 then
					TaskPlayAnim(ped, "move_strafe@first_person@generic", "walk_bwd_-135_loop", 5.0, 1.0, -1, 1, 0.1)
					walkingBackwards = 3
	
				elseif not (IsControlPressed(0, 34) or IsControlPressed(0, 35)) and walkingBackwards ~= 1 then
					TaskPlayAnim(ped, "move_strafe@first_person@generic", "walk_bwd_180_loop", 5.0, 1.0, -1, 1, 0.1) -- walk_trans_fwd_0_rf_bwd_180
					walkingBackwards = 1
				end
				

			elseif not IsControlPressed(0, 33) or not IsControlPressed(0, 32) then
				if walkingBackwards > 0 then
					ClearPossibleActiveEmotes(ped)
					walkingBackwards = 0
				end
			end

			if nearStop then
				ShowInfoLabel("TRANSIT_INFO")
			elseif showFlavorText then
				ShowInfoLabel("FLAVORTEXT")
			elseif nearPhoneBooth and callId == 0 then
				ShowInfo("~INPUT_CONTEXT~ Use Phone Booth")

				if IsControlJustPressed(0, 51) and nearPhoneBooth then


					phoneBoothMenu = NativeUI.CreateMenu("Phone Booth", "~b~" .. ServerName)
					_menuPool:Add(phoneBoothMenu)

					CreatePhoneBoothMenu(phoneBoothMenu)

					_menuPool:RefreshIndex()
					phoneBoothMenu:Visible(not phoneBoothMenu:Visible())
				end
			end
		end

		if (not showWarning) and showPlayerlist then
			RenderPlayerlist()
			RenderNamesAboveHead()
			DisableControlAction(0, 174, true)
			DisableControlAction(0, 175, true)

			if IsDisabledControlJustReleased(0, 174) and playerlistPage > 1 then
				playerlistPage = playerlistPage - 1
			elseif IsDisabledControlJustReleased(0, 175) and playerlistPage < math.ceil(#onlinePlayers / 24) then
				playerlistPage = playerlistPage + 1
			end

			if playerlistPage > math.ceil(#onlinePlayers / 24) then
				playerlistPage = math.ceil(#onlinePlayers / 24)
			elseif playerlistPage < 1 then
				playerlistPage = 1
			end
		end

            	if not IsPedArmed(GetPlayerPed(-1), 7) and not IsControlPressed(0, 25) and not vehicle.vehicle and not IsPauseMenuActive() and not phone then
			if GetUserSettings("Accidental Attack Prevention") then
				--print("Disabling attack controls")
				DisableControlAction(0, 18, true)
				DisableControlAction(0, 24, true)
				--DisableControlAction(0, 45, true)
				DisableControlAction(0, 69, true)
				--DisableControlAction(0, 80, true)
				DisableControlAction(0, 92, true)
				DisableControlAction(0, 106, true)
				DisableControlAction(0, 122, true)

		    		DisableControlAction(0, 135, true)
				--DisableControlAction(0, 140, true)
            			DisableControlAction(0, 142, true)
        	    		DisableControlAction(0, 144, true)
				DisableControlAction(0, 176, true)

				DisableControlAction(0, 223, true)
				DisableControlAction(0, 229, true)
				DisableControlAction(0, 237, true)
				--DisableControlAction(0, 250, true)
				DisableControlAction(0, 257, true)
				--DisableControlAction(0, 263, true)
				--DisableControlAction(0, 310, true)
				DisableControlAction(0, 329, true)
				DisableControlAction(0, 346, true)
				DisableControlAction(0, 359, true)
			end
		end

		if devmode then
			local PressedControls = ""
			for i=1,360 do
				if IsControlPressed(0, i) then
					PressedControls = PressedControls .. " " .. i
				end
			end
			AddTextEntry("DEV_CONTROLS", "Controls Pressed: ~n~" .. PressedControls)
		end

		if (not player.member) or devmode then
			local blacklisted = false
				for _, i in ipairs(memberOnlyVehicles) do
				if tonumber(i) then
					if GetVehicleClass(vehicle.vehicle) == i and GetIsVehicleEngineRunning(vehicle.vehicle) and vehicle.driver then
						blacklisted = true
					end
				else
					if GetEntityModel(vehicle.vehicle) == GetHashKey(i) then
						blacklisted = true
					end
				end
			end

			if blacklisted then
				SetVehicleEngineOn(vehicle.vehicle, false, true, true)
				if not vehicle.warned then
					ShowInfoLabel("RESTRICT_VEHICLE")
					vehicle.warned = true
				end

				if GetIsVehicleEngineRunning(vehicle.vehicle) and vehicle.driver then
					DisableControlAction(0, 71, true)
					DisableControlAction(0, 87, true)
					DisableControlAction(0, 129, true)
					SetVehicleCheatPowerIncrease(vehicle.vehicle, 0.0)
				end
			end
		end

		-- Car HUD stuff
		if vehicle.vehicle then
			if seatbeltOn and vehicle.speed > 5.0 then
				DisableControlAction(0, 75, true)
				if IsDisabledControlJustPressed(0, 75) then
					ShowInfo("You cannot exit vehicles at speed while your seatbelt is on.")
				end
			end
		end

		if vehicle.driver then
			if checkMap then
				drawVehicleUI()
			end
	
			if IsVehicleStopped(vehicle.vehicle) then
				SetVehicleBrakeLights(vehicle.vehicle, true)
			end

			if selfDriving then
				if (not IsWaypointActive()) or IsControlJustPressed(1, 72) or IsControlJustPressed(1, 71) or IsControlJustPressed(1, 63) or IsControlJustPressed(1, 64) or IsControlJustPressed(1, 75) then
					ShowInfo("Coil AutoDrive Disabled")
					ClearVehicleTasks(vehicle.vehicle)
					ClearPedTasks(GetPlayerPed(-1))
					selfDriving = false
				end
			end

			if IsControlJustPressed(1, 305) then
				if (IsVehicleModel(vehicle.vehicle, GetHashKey("raiden")) or IsVehicleModel(vehicle.vehicle, GetHashKey("taranis"))) and IsWaypointActive() then
					if not selfDriving then
						selfDriving = true
						x2, y2, z2 = table.unpack(GetBlipInfoIdCoord(GetFirstBlipInfoId(8)))
						SetDriverAbility(GetPlayerPed(-1), 1.0)
						SetDriverAggressiveness(GetPlayerPed(-1), 0.0)
						TaskVehicleDriveToCoordLongrange(GetPlayerPed(-1), vehicle.vehicle, x2, y2, z2, -1, 481542531, 10.0)
						ShowInfo("Coil AutoDrive Enabled")
					else
						ShowInfo("Coil AutoDrive Disabled")
						ClearVehicleTasks(vehicle.vehicle)
						ClearPedTasks(GetPlayerPed(-1))
						selfDriving = false
					end
				else
					enableLimiter()
				end
			end


			-- When you exit a vehicle
			if IsControlJustPressed(1, 75) then
				SetVehicleMaxSpeed(vehicle.vehicle, -1)
				speedLimiter = false
				if GetEntityModel(vehicle.vehicle) == GetHashKey("wheelchair") then
					ClearPedTasks(GetPlayerPed(-1))
				end
			end
			if sundayDrive then
				sundayDriverStuff()
			end
		elseif vehicle.vehicle then
			if not seatbeltOn and requireSeatbelt then
				DrawSprite("vehicleui", "seatbelt", 0.512-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 230, 0, 0, 200)
			else
				DrawSprite("vehicleui", "seatbelt", 0.512-safezoneSize, 0.468+safezoneSize, 0.016, 0.027, 0.0, 0, 0, 0, 80)
			end

			if GetPedInVehicleSeat(vehicle.vehicle, 0) == ped then
				if IsControlJustPressed(0, 72) then
					Citizen.Wait(5000)
					vehicle.driver = true
				elseif GetIsTaskActive(GetPlayerPed(-1), 165) then
					SetPedIntoVehicle(ped, vehicle.vehicle, 0)
					ShowInfo("Press ~INPUT_VEH_BRAKE~ to shuffle to the driver\'s seat")
				end
			end
		end
		if vehicleExitControl > 0 and draggedPlayerId ~= -1 then
			ClearPedTasks(ped)
			TriggerServerEvent("dragPlayer", draggedPlayerId, true)
			draggedPlayerId = -1
		end

		if GetVehiclePedIsTryingToEnter(ped) ~= 0 and not vehicle.vehicle and vehicleExitControl > 4 then
			vehicleDoorControls = GetVehiclePedIsTryingToEnter(ped)
		end

	if vehicleDoorControls then
		ClearPedTasks(ped)
		ShowInfo("~INPUT_SELECT_WEAPON_UNARMED~ Open Front Door~n~~INPUT_SELECT_WEAPON_MELEE~ Open Rear Door~n~~INPUT_SELECT_WEAPON_SHOTGUN~ Get In Back Seat~n~~INPUT_SELECT_WEAPON_HEAVY~ Toggle Trunk~n~~INPUT_SELECT_WEAPON_SPECIAL~ Toggle Hood~n~~INPUT_CELLPHONE_CANCEL~ Cancel")
		DisableControlAction(0, 157, true)
		DisableControlAction(0, 158, true)
		DisableControlAction(0, 160, true)
		DisableControlAction(0, 164, true)
		DisableControlAction(0, 165, true)
		if IsDisabledControlJustPressed(0, 157) then
			TaskOpenVehicleDoor(ped, vehicleDoorControls, 3000, -1, 1.0)
			vehicleDoorControls = nil
		end

		if IsDisabledControlJustPressed(0, 158) then
			TaskOpenVehicleDoor(ped, vehicleDoorControls, 3000, 1, 1.0)
			vehicleDoorControls = nil
		end

		if IsDisabledControlJustPressed(0, 160) then
			TaskEnterVehicle(ped, vehicleDoorControls, 3000, 1, 1.0, 1, 0)
			vehicleDoorControls = nil
		end

		if IsDisabledControlJustPressed(0, 164) then
			if GetVehicleDoorAngleRatio(vehicleDoorControls, 5) > 0 then
				SetVehicleDoorShut(vehicleDoorControls, 5, false)
			else	
				SetVehicleDoorOpen(vehicleDoorControls, 5, false, false)
			end
			vehicleDoorControls = nil
		end

		if IsDisabledControlJustPressed(0, 165) then
			if GetVehicleDoorAngleRatio(vehicleDoorControls, 4) > 0 then
				SetVehicleDoorShut(vehicleDoorControls, 4, false)
			else	
				SetVehicleDoorOpen(vehicleDoorControls, 4, false, false)
			end
			vehicleDoorControls = nil
		end

		DisableControlAction(0, 177, true)

		if IsDisabledControlJustPressed(0, 177) then
			vehicleDoorControls = nil
		end
	end

	if IsPlayerFreeAiming(PlayerId()) then
            	DisableControlAction(0, 22, true)
		if GetUserSettings("Switch to First Person while aiming") then
			if GetFollowPedCamViewMode() == 4 and check == false then
				check = false
			else
				SetFollowPedCamViewMode(4)
				check = true
			end
		end
	else
		if check == true then
			SetFollowPedCamViewMode(1)
			check = false
		end
		end
	end
end)

function fscale(inputValue, originalMin, originalMax, newBegin, newEnd, curve)
	local OriginalRange = 0.0
	local NewRange = 0.0
	local zeroRefCurVal = 0.0
	local normalizedCurVal = 0.0
	local rangedValue = 0.0
	local invFlag = 0

	if (curve > 10.0) then curve = 10.0 end
	if (curve < -10.0) then curve = -10.0 end

	curve = (curve * -.1)
	curve = 10.0 ^ curve

	if (inputValue < originalMin) then
	  inputValue = originalMin
	end
	if inputValue > originalMax then
	  inputValue = originalMax
	end

	OriginalRange = originalMax - originalMin

	if (newEnd > newBegin) then
		NewRange = newEnd - newBegin
	else
	  NewRange = newBegin - newEnd
	  invFlag = 1
	end

	zeroRefCurVal = inputValue - originalMin
	normalizedCurVal  =  zeroRefCurVal / OriginalRange

	if (originalMin > originalMax ) then
	  return 0
	end

	if (invFlag == 0) then
		rangedValue =  ((normalizedCurVal ^ curve) * NewRange) + newBegin
	else
		rangedValue =  newBegin - ((normalizedCurVal ^ curve) * NewRange)
	end

	return rangedValue
end

function ClearPossibleActiveEmotes(playerPed)
    StopAnimTask(playerPed, "move_strafe@first_person@generic", "walk_bwd_135_loop", 2.0)
    StopAnimTask(playerPed, "move_strafe@first_person@generic", "walk_bwd_-135_loop", 2.0)
    StopAnimTask(playerPed, "move_strafe@first_person@generic", "walk_bwd_180_loop", 2.0)
    StopAnimTask(playerPed, "move_strafe@first_person@generic", "walk_bwd_-90_loop", 2.0)
    StopAnimTask(playerPed, "move_strafe@first_person@generic", "walk_fwd_90_loop", 2.0)
end


function sundayDriverStuff()
	if GetVehicleClass(vehicle.vehicle) ~= 14 then -- Not for boats
					local factor = 1.0
						local accelerator = GetControlValue(2,71)
						local brake = GetControlValue(2,72)
						local speed = GetEntitySpeedVector(vehicle.vehicle, true)['y']
						-- Change Braking force
						local brk = fBrakeForce
						if speed >= 1.0 then
							-- Going forward
							if accelerator > 127 then
								-- Forward and accelerating
								local acc = fscale(accelerator, 127.0, 254.0, 0.1, 1.0, 10.0-(15.0))
								factor = factor * acc
							end
							if brake > 127 then
								-- Forward and braking
								isBrakingForward = true
								brk = fscale(brake, 127.0, 254.0, 0.01, fBrakeForce, 10.0-(10.0))
							end
						elseif speed <= -1.0 then
							-- Going reverse
							if brake > 127 then
								-- Reversing and accelerating (using the brake)
								local rev = fscale(brake, 127.0, 254.0, 0.1, 1.0, 10.0-(15.0))
								factor = factor * rev
							end
							if accelerator > 127 then
								-- Reversing and braking (Using the accelerator)
								isBrakingReverse = true
								brk = fscale(accelerator, 127.0, 254.0, 0.01, fBrakeForce, 10.0-(10.0))
							end
						else
							-- Stopped or almost stopped or sliding sideways
							local entitySpeed = GetEntitySpeed(vehicle.vehicle)
							if entitySpeed < 1 then
								-- Not sliding sideways
								if isBrakingForward == true then
									--Stopped or going slightly forward while braking
									DisableControlAction(2,72,true) -- Disable Brake until user lets go of brake
									SetVehicleForwardSpeed(vehicle.vehicle,speed*0.98)
									SetVehicleBrakeLights(vehicle.vehicle,true)
								end
								if isBrakingReverse == true then
									--Stopped or going slightly in reverse while braking
									DisableControlAction(2,71,true) -- Disable reverse Brake until user lets go of reverse brake (Accelerator)
									SetVehicleForwardSpeed(vehicle.vehicle,speed*0.98)
									SetVehicleBrakeLights(vehicle.vehicle,true)
								end
								if isBrakingForward == true and GetDisabledControlNormal(2,72) == 0 then
									-- We let go of the brake
									isBrakingForward=false
								end
								if isBrakingReverse == true and GetDisabledControlNormal(2,71) == 0 then
									-- We let go of the reverse brake (Accelerator)
									isBrakingReverse=false
								end
							end
						end
		if brk > fBrakeForce - 0.02 then
			brk = fBrakeForce
		end -- Make sure we can brake max.
		SetVehicleHandlingFloat(vehicle.vehicle, 'CHandlingData', 'fBrakeForce', brk)  -- Set new Brake Force multiplier
		SetVehicleEngineTorqueMultiplier(vehicle.vehicle, factor)
	end
end

wearingMask = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if GetPedDrawableVariation(PlayerPedId(), 1) == 46 then
			wearingMask = true
		elseif wearingMask then
			wearingMask = false
		end
		if wearingMask then
			SetEntityProofs(ped, false, false, false, false, false, false, true, true, false)
		else
			SetEntityProofs(ped, false, false, false, false, false, false, false, false, false)
		end
	end
end)

RegisterCommand("playtime", function(source, args, rawCommand)
	local playtime = GetResourceKvpInt(ServerId .. "-CORE:PT")

	if playtime >= 60 then
		ShowInfo("Current Playtime: " .. math.floor(playtime/60) .. " hours, " .. playtime % 60 .. " minutes")
	else
		ShowInfo("Current Playtime: " .. playtime .. " minutes")
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if vehicle.vehicle then
			local prevSpeed = currSpeed
			currSpeed = GetEntitySpeed(vehicle.vehicle)
                	
			position = GetEntityCoords(PlayerPedId())
			-- Eject PED when moving forward, vehicle was going over 45 MPH and acceleration over 100 G's
			local vehIsMovingFwd = GetEntitySpeedVector(vehicle.vehicle, true).y > 1.0
			local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()

			if vehicle.speed then
				if (vehicle.speed > 30 and vehAcc > 250 and (not seatbeltOn and requireSeatbelt)) then
					SetEntityCoords(GetPlayerPed(-1), position.x, position.y + 0.1, position.z - 0.47, true, true, true)
					SetEntityVelocity(GetPlayerPed(-1), prevVelocity.x/2, prevVelocity.y/2, prevVelocity.z/2)
					Citizen.Wait(10)
					SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)

					ApplyDamageToPed(GetPlayerPed(-1), math.floor((vehAcc*vehAcc)/10000), false)
					print("Dealing " .. math.floor((vehAcc*vehAcc)/10000) .. " damage to player")
				else


					--print(GetPedMaxHealth(GetPlayerPed(-1)))

					-- Do damage if velocity is still high
					if (vehAcc > 350) then
						ApplyDamageToPed(GetPlayerPed(-1), math.floor((vehAcc*vehAcc)/20000), false)
						print("Dealing " .. math.floor((vehAcc*vehAcc)/20000) .. " damage to player")

						--Citizen.Wait(500)
					end

					-- Update previous velocity for ejecting player
					prevVelocity = GetEntityVelocity(vehicle.vehicle)
				end
			end

			if IsControlJustPressed(1, 75) and seatbeltOn then
				seatbeltOn = false
				PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
			end
		elseif IsPedInAnyVehicle(GetPlayerPed(-1), true) then
			vehAcc = 0
			prevSpeed = 0
			currSpeed = 0
			vehicle.speed = 0
		else
			seatbeltOn = false
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if drag then
			wasDragged = true
			AttachEntityToEntity(PlayerPedId(), GetPlayerPed(GetPlayerFromServerId(draggedBy)), GetPedBoneIndex(PlayerPedId(), "SKEL_ROOT"), -0.5, 0.48, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true) -- -0.2, 0.48
			-- TaskPlayAnim(GetPlayerPed(-1), "anim@arrest_cop_2", "arrest_cop_2_clip", 8.0, 8.0, -1, 50, 0.0, false, false, false)			
		else
			if not IsPedInParachuteFreeFall(PlayerPedId()) and wasDragged then
				wasDragged = false
				DetachEntity(PlayerPedId(), true, false)
				--ClearPedTasks(GetPlayerPed(-1))
			end
		end
	end
end)

function GetClosestVehicleToPlayer()
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.0, 0.0)
	local radius = 3.0
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, radius, 10, plyPed, 7)
	local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
	return vehicle
end

Citizen.CreateThread(function()
	while true do
		if IsControlPressed(2, 75) then
			vehicleExitControl = vehicleExitControl + 1
		else
			vehicleExitControl = 0
		end

		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if #playerReportQueue > 0 then
			DrawRect(0.87, 0.88, 0.35,0.24,0,0,0,180)

			drawTxt(0.7, 0.76, 0.45,  "Reported Player: "..playerReportQueue[1].reportedName .. " (" .. playerReportQueue[1].reportedId .. ")", 4, 2, 1, 255, 255, 255, 255)
			drawTxt(0.7, 0.79, 0.38, playerReportQueue[1].reportText, 4, 2, 1, 255, 255, 255, 255)
			drawTxt(0.7, 0.88, 0.38,  "Reported by: " .. playerReportQueue[1].reporteeName .. " (" .. playerReportQueue[1].reporteeId .. ")", 4, 2, 1, 255, 255, 255, 255)
			drawTxt(0.7, 0.90, 0.45,  "Current Status: " .. playerReportQueue[1].reportStatus, 4, 2, 1, 255, 255, 255, 255)
			drawTxt(0.7, 0.93, 0.32,  "/rd to dismiss the report", 4, 2, 1, 255, 255, 255, 255)
			drawTxt(0.7, 0.95, 0.32,  "/rs [status] to set report status", 4, 2, 1, 255, 255, 255, 255)
			drawTxt(0.7, 0.97, 0.32,  "/rr [message] to send reply to player who reported", 4, 2, 1, 255, 255, 255, 255)
			DisableControlAction(0, 323, true)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		
		if isPlayerCuffed and not IsEntityPlayingAnim(PlayerPedId(), "anim@arrest_crooks", "arrest_crooks_clip", 1) then
			Citizen.Wait(100)
			TaskPlayAnim(PlayerPedId(), "anim@arrest_crooks", "arrest_crooks_clip", 8.0, -8, -1, 49, 0, 0, 0, 0)
		elseif isPlayerCuffed and IsPedRagdoll(ped) then
			repeat
				Citizen.Wait(100)
			until not IsPedRagdoll(ped)
			TaskPlayAnim(PlayerPedId(), "anim@arrest_crooks", "arrest_crooks_clip", 8.0, -8, -1, 49, 0, 0, 0, 0)
		end

	end
end)

RegisterCommand('playerlist', function(source, args, user)
	--loadTextDict("playerlist_icon")
	showPlayerlist = not showPlayerlist
	playerlistPage = 1
end, false)

handsup = false
handonhead = false
handsupkneeling = false

function RefreshHandsUp()
	ClearPedTasks(GetPlayerPed(-1))
	loadAnimDict("missminuteman_1ig_2")
	loadAnimDict("random@arrests@busted")
	loadAnimDict("random@arrests")

	if handsup then
		if handsonhead and handsupkneeling then
			TaskPlayAnim(GetPlayerPed(-1), "random@arrests@busted", "idle_a", 8.0, 8.0, -1, 1, 0, false, false, false)
		elseif handsonhead then
			TaskPlayAnim(GetPlayerPed(-1), "random@arrests@busted", "idle_a", 8.0, 8.0, -1, 50, 0, false, false, false)
		elseif handsupkneeling then
			TaskPlayAnim(GetPlayerPed(-1), "random@arrests", "kneeling_arrest_idle", 8.0, 8.0, -1, 1, 0, false, false, false)
		else
			TaskPlayAnim(GetPlayerPed(-1), "missminuteman_1ig_2", "handsup_enter", 100.0, 100.0, -1, 50, 0, false, false, false)
		end
	else
		if GetEntityModel(vehicle.vehicle) == GetHashKey("wheelchair") then
			TaskPlayAnim(GetPlayerPed(-1), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 50, 0, false, false, false)
		end
	end
end

RegisterCommand('hu', function(source, args, user)
	handsup = not handsup
	handsupkneeling = false
	handsonhead = false
	RefreshHandsUp()

	while handsup do
		Citizen.Wait(0)
		ShowInfoLabel("INFO_HANDSUP")

		if IsControlJustPressed(0, 36) then
			SetPedStealthMovement(ped, 0, 0)
			ResetPedMovementClipset( ped, 0 )

			handsupkneeling = not handsupkneeling
			RefreshHandsUp()


		elseif IsControlJustPressed(0, 19) then
			handsonhead = not handsonhead
			RefreshHandsUp()
		end
	end
	RefreshHandsUp()
end, false)

RegisterCommand('hh', function(source, args, user)
	--loadAnimDict("reaction@intimidation@cop@unarmed")
	loadAnimDict("anim@holster_walk")
	loadAnimDict("anim@holster_hold_there")

	if keepHandOnHolster then
		ClearPedTasks(ped)
		SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
		keepHandOnHolster = false
		Citizen.Wait(500)
		stopHolsterAnimation = false
	elseif not vehicle.vehicle and not IsControlPressed(0, 21) then
		keepHandOnHolster = true

		local holsterHandUp = false

		stopHolsterAnimation = true
		TaskPlayAnim(ped, "anim@holster_walk", "holster_walk", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 )

		while keepHandOnHolster == true do
			Citizen.Wait(0)
			ShowInfoLabel("INFO_HOLSTER")
			if IsControlPressed(0, 25) then
				for i = 1, #holsterWeapons do
					SetCurrentPedWeapon(ped, GetHashKey(holsterWeapons[i]), true)
				end
				SetCurrentPedWeapon(ped, GetHashKey("WEAPON_PISTOL"), true)
				ClearPedTasks(ped)
				keepHandOnHolster = false
				Citizen.Wait(500)
				stopHolsterAnimation = false
			elseif IsControlJustPressed(0, 19) then
				holsterHandUp = not holsterHandUp
				if holsterHandUp then
					TaskPlayAnim(ped, "anim@holster_hold_there", "holster_hold", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 )
				else
					TaskPlayAnim(ped, "anim@holster_walk", "holster_walk", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 )
				end
			elseif IsControlPressed(0, 21) then
				ClearPedTasks(ped)
				keepHandOnHolster = false
				stopHolsterAnimation = false
			end
		end
	end
end, false)

RegisterCommand('engine', function(source, args, user)
	if not (GetVehicleClass(vehicle.vehicle) == 15 or GetVehicleClass(vehicle.vehicle) == 16) then
		if GetIsVehicleEngineRunning(vehicle.vehicle) then
			SetVehicleEngineOn(vehicle.vehicle, false, false, true)
		elseif not ((vehicle.hp >= 0) and (vehicle.hp < 300)) then
			SetVehicleEngineOn(vehicle.vehicle, true, false, true)
		end
	end
end, false)


RegisterCommand('seatbelt', function(source, args, user)
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) and requireSeatbelt then
		if seatbeltOn then
			ShowInfo("Your seatbelt is now off.")
		else
			ShowInfo("Your seatbelt is now on.")
		end
		seatbeltOn = not seatbeltOn
		PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
	end
end, false)

RegisterCommand('settings', function(source, args, user)
	settingsMenu:Visible(not settingsMenu:Visible()) 
end, false)

RegisterCommand('vehicle', function(source, args, user)
	vehicleMenu:Visible(not vehicleMenu:Visible())
end, false)

RegisterCommand('session', function(source, args, user)
	if player.session ~= 0 then
		sessionMenu:Visible(not sessionMenu:Visible())
	end
end, false)

RegisterCommand('jobmenu', function(source, args, user)
	sessionMenu:Visible(not sessionMenu:Visible())
end, false)

RegisterCommand('onduty', function(source, args, user)
	if GetPlayerNick(PlayerId()) and #args > 1 then
		playerPed = GetPlayerPed(-1)

		for _, item in ipairs(agencies) do
			if string.upper(item.short) == string.upper(args[1]) then
				if item.type == "Tow Truck" or player.member then

					jobA = item.type
					jobB = item.long
					callsign = string.upper(args[2])

					if jobA == "Law Enforcement" then
						exports["rp-radio"]:GivePlayerAccessToFrequency(114)
						exports["rp-radio"]:GivePlayerAccessToFrequency(121)
						exports["rp-radio"]:GivePlayerAccessToFrequency(122)
						exports["rp-radio"]:GivePlayerAccessToFrequency(131)
						exports["rp-radio"]:GivePlayerAccessToFrequency(161)
					end

					AddTextEntry("MDT_CALLSIGN", callsign)
					AddTextEntry("MDT_DEPARTMENT", item.long)
					AddTextEntry("MDT_MOTTO", item.motto)

					if item.primary then
						mdtColourPrimary = item.primary
						mdtColourSecondary = item.secondary
					end

					TriggerServerEvent("ondutyServer", jobA, jobB, callsign)
					ShowInfo("~b~You are now on duty as " .. item.long)

					RemoveAllPedWeapons(playerPed, true)

					rack = {}

					if item.equipment then
						for _, subitem in ipairs(item.equipment) do
							if subitem.rack then
								table.insert(rack, subitem)
							elseif subitem.weapon then
								GiveWeaponToPed(playerPed, GetHashKey(subitem.weapon), 100, false, true)
								if subitem.components then
									for _, component in ipairs(subitem.components) do
										GiveWeaponComponentToPed(playerPed, GetHashKey(subitem.weapon), GetHashKey(component))
									end
								end
								if subitem.tint then
									SetPedWeaponTintIndex(playerPed, GetHashKey(subitem.weapon), subitem.tint)
								end
							end
						end
					end
				else
					ShowInfo("This job requires server membership.")
				end
			end
		end
	end
end, false)

RegisterCommand('offduty', function(source, args, user)
	mdtOpen = false
	jobA = "Civilian"
	jobB = "Unemployed"
	callsign = ""

	RemoveAllPedWeapons(GetPlayerPed(-1), true)

	exports["rp-radio"]:RemovePlayerAccessToFrequency(114)
	exports["rp-radio"]:RemovePlayerAccessToFrequency(121)
	exports["rp-radio"]:RemovePlayerAccessToFrequency(122)
	exports["rp-radio"]:RemovePlayerAccessToFrequency(131)
	exports["rp-radio"]:RemovePlayerAccessToFrequency(161)

	TriggerServerEvent("ondutyServer", jobA, jobB, callsign)
	ShowInfo("~r~You are now off duty.")
end, false)

RegisterCommand('p', function(source, args, user)
	if jobA == "Law Enforcement" or jobA == "Fire/EMS" then
		local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
		TriggerServerEvent("relaySpecialContact", "Panic Button", callsign .. " has pressed their Panic Button", GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z)), x, y, z, GetPlayerName(PlayerId()), GetPlayerServerId(PlayerId()), "CHAR_DEFAULT")
	end
end, false)

RegisterCommand('jail', function(source, args, user)
	if #args > 1 and jobA == "Law Enforcement" then
		TriggerServerEvent("jailServer", args[1], tonumber(args[2]), table.concat(args, " ", 3), jobB, callsign)
	end
end, false)

RegisterCommand('unjail', function(source, args, user)
	if #args > 1 and jobA == "Law Enforcement" then
		TriggerServerEvent("jailServer", args[1], 0, table.concat(args, " ", 2), jobB, callsign)
	end
end, false)

RegisterCommand('hospital', function(source, args, user)
	if #args == 2 and (jobA == "Law Enforcement" or jobA == "Fire/EMS") then
		TriggerServerEvent("hospitalServer", args[1], tonumber(args[2]))
	end
end, false)

RegisterCommand('unhospital', function(source, args, user)
	if #args == 2 and (jobA == "Law Enforcement" or jobA == "Fire/EMS") then
		TriggerServerEvent("hospitalServer", args[1], nil)
	end
end, false)

RegisterCommand('coroner', function(source, args, user)
	if #args == 2 and (jobA == "Coroner" or jobA == "Law Enforcement" or jobA == "Fire/EMS") then
		TriggerServerEvent("coronerServer", args[1], tonumber(args[2]))
	end
end, false)

RegisterCommand('uncoroner', function(source, args, user)
	if #args == 2 and (jobA == "Coroner" or jobA == "Law Enforcement" or jobA == "Fire/EMS") then
			TriggerServerEvent("coronerServer", args[1], nil)
	end
end, false)

RegisterCommand("job", function(source, args, raw)
	local sch = table.concat(args, " ")


	if #args > 0 then
		local found = false

		for _, item in ipairs(agencies) do
			if string.lower(item.short) == string.lower(sch) or string.lower(item.long) == string.lower(sch) then
				found = true
				ShowInfo("~r~ This job requires using the /onduty command.")
			end
		end
		
		if not found then
			jobA = "Civilian"
			jobB = sch
			mdtOpen = false
			callsign = ""

			for _, item in ipairs(customIcon) do
				if string.lower(item.name) == string.lower(sch) then
					jobB = item.name
				end
			end

			RemoveAllPedWeapons(GetPlayerPed(-1), true)

			exports["rp-radio"]:RemovePlayerAccessToFrequency(114)
			exports["rp-radio"]:RemovePlayerAccessToFrequency(121)
			exports["rp-radio"]:RemovePlayerAccessToFrequency(122)
			exports["rp-radio"]:RemovePlayerAccessToFrequency(131)
			exports["rp-radio"]:RemovePlayerAccessToFrequency(161)

			TriggerServerEvent("ondutyServer", jobA, jobB, callsign)
			ShowInfo("~b~You have now started a job as " .. jobB)


		end

	else
		
		mdtOpen = false
		jobA = "Civilian"
		jobB = "Unemployed"
		callsign = ""

		RemoveAllPedWeapons(GetPlayerPed(-1), true)

		exports["rp-radio"]:RemovePlayerAccessToFrequency(114)
		exports["rp-radio"]:RemovePlayerAccessToFrequency(121)
		exports["rp-radio"]:RemovePlayerAccessToFrequency(122)
		exports["rp-radio"]:RemovePlayerAccessToFrequency(131)
		exports["rp-radio"]:RemovePlayerAccessToFrequency(161)

		TriggerServerEvent("ondutyServer", jobA, jobB, callsign)
		ShowInfo("~r~You are now set as unemployed.")
	end
end, false)

RegisterCommand('postal', function(source, args, raw)
	if #args < 1 then
		ShowInfo("~HUD_COLOUR_WAYPOINTLIGHT~Please provide a postal.")
	else
			local n = string.upper(args[1])

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
			ShowInfo("~HUD_COLOUR_WAYPOINTLIGHT~Invalid Postal Given.")
			end
	end
end)

RegisterCommand("trunk", function(source, args, raw)
	local veh = GetVehiclePedIsUsing(ped)
	local vehLast = GetPlayersLastVehicle()
	local distanceToVeh = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(vehLast), 1)
	local door = 5

	if IsPedInAnyVehicle(ped, false) then
		if GetVehicleDoorAngleRatio(veh, door) > 0 then
			SetVehicleDoorShut(veh, door, false)
		else	
			SetVehicleDoorOpen(veh, door, false, false)
		end
	else
		if distanceToVeh < 8 then
			if GetVehicleDoorAngleRatio(vehLast, door) > 0 then
				SetVehicleDoorShut(vehLast, door, false)
			else
				SetVehicleDoorOpen(vehLast, door, false, false)
			end
		else
			ShowInfo("You must be near a vehicle.")
		end
	end
end)

RegisterCommand("hood", function(source, args, raw)
	local veh = GetVehiclePedIsUsing(ped)
	local vehLast = GetPlayersLastVehicle()
	local distanceToVeh = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(vehLast), 1)
	local door = 4

	if IsPedInAnyVehicle(ped, false) then
		if GetVehicleDoorAngleRatio(veh, door) > 0 then
			SetVehicleDoorShut(veh, door, false)
		else	
			SetVehicleDoorOpen(veh, door, false, false)
		end
	else
		if distanceToVeh < 6 then
			if GetVehicleDoorAngleRatio(vehLast, door) > 0 then
				SetVehicleDoorShut(vehLast, door, false)
			else	
				SetVehicleDoorOpen(vehLast, door, false, false)
			end
		else
			ShowInfo("You must be near a vehicle.")
		end
	end
end)

RegisterCommand("bus", function(source, args, rawCommand)
	local find = table.concat(args, " ")
	ClearGpsMultiRoute()
	firstStop = nil

	for _, item in ipairs(BusRoutes) do
		if item.name == find then
			DrawBusRoute(item.stops, item.color)

			for _, item2 in ipairs(BusStops) do
				if item2.name ==  item.stops[1] then
					firstStop = item2
				end
			end

			local found = false
		end
	end
end)

RegisterCommand('xmit', function(source, args, user)
	if jobA == "Law Enforcement" or jobA == "Fire/EMS" and #args > 0 then
		TriggerServerEvent('relayDispatchMessage', callsign, table.concat(args, " "))
	end
end)

RegisterCommand("window", function(source, args, raw)
	local veh = GetVehiclePedIsUsing(ped)
	local vehLast = GetPlayersLastVehicle()
	local distanceToVeh = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(vehLast), 1)
	local windowState = string.lower(args[2])

	if args[1] == "1" then window = 0
	elseif args[1] == "2" then window = 1
	elseif args[1] == "3" then window = 2
	elseif args[1] == "4" then window = 3
	elseif args[1] == "all" then window = 4
	elseif args[1] == "front" then window = 5
	elseif args[1] == "rear" then window = 6
	else
		window = nil
		ShowInfo("Usage: ~n~~b~/win [window] [up/down]. Windows are 1, 2, 3, 4, front, rear, all.")
	end
	
	if windowState == "down" then
		if window == 0 or window == 1 or window == 2 or window == 3 then
			if IsPedInAnyVehicle(ped, false) then
				RollDownWindow(veh, window)
			else
				if distanceToVeh < 6 then
					RollDownWindow(vehLast, window)
				else
					ShowInfo("You must be near a vehicle.")
				end
			end
		elseif window == 4 then
			if IsPedInAnyVehicle(ped, false) then
				RollDownWindows(veh)
			else
				if distanceToVeh < 6 then
					RollDownWindows(vehLast)
				else
					ShowInfo("You must be near a vehicle.")
				end
			end
		elseif window == 5 then
			if IsPedInAnyVehicle(ped, false) then
				RollDownWindow(veh, 0)
				RollDownWindow(veh, 1)
			else
				if distanceToVeh < 6 then
					RollDownWindow(vehLast, 0)
					RollDownWindow(vehLast, 1)
				else
					ShowInfo("You must be near a vehicle.")
				end
			end
		elseif window == 6 then
			if IsPedInAnyVehicle(ped, false) then
				RollDownWindow(veh, 2)
				RollDownWindow(veh, 3)
			else
				if distanceToVeh < 6 then
					RollDownWindow(vehLast, 2)
					RollDownWindow(vehLast, 3)
				else
					ShowInfo("You must be near a vehicle.")
				end
			end
		end
	elseif windowState == "up" then
		if window == 0 or window == 1 or window == 2 or window == 3 then
			if IsPedInAnyVehicle(ped, false) then
				RollUpWindow(veh, window)
			else
				if distanceToVeh < 6 then
					RollUpWindow(vehLast, window)
				else
					ShowInfo("You must be near a vehicle.")
				end
			end
		elseif window == 4 then
			if IsPedInAnyVehicle(ped, false) then
				RollUpWindow(veh, 0)
				RollUpWindow(veh, 1)
				RollUpWindow(veh, 2)
				RollUpWindow(veh, 3)
			else
				if distanceToVeh < 6 then
					RollUpWindows(vehLast)
				else
					ShowInfo("You must be near a vehicle.")
				end
			end
		elseif window == 5 then
			if IsPedInAnyVehicle(ped, false) then
				RollUpWindow(veh, 0)
				RollUpWindow(veh, 1)
			else
				if distanceToVeh < 6 then
					RollUpWindow(vehLast, 0)
					RollUpWindow(vehLast, 1)
				else
					ShowInfo("You must be near a vehicle.")
				end
			end
		elseif window == 6 then
			if IsPedInAnyVehicle(ped, false) then
				RollUpWindow(veh, 2)
				RollUpWindow(veh, 3)
			else
				if distanceToVeh < 6 then
					RollUpWindow(vehLast, 2)
					RollUpWindow(vehLast, 3)
				else
					ShowInfo("You must be near a vehicle.")
				end
			end
		end
	end
end)
	
RegisterCommand("door", function(source, args, raw)
	local veh = GetVehiclePedIsUsing(ped)
	local vehLast = GetPlayersLastVehicle()
	local distanceToVeh = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(vehLast), 1)
	
	if args[1] == "1" then -- Front Left Door
		door = 0
	elseif args[1] == "2" then -- Front Right Door
		door = 1
	elseif args[1] == "3" then -- Back Left Door
		door = 2
	elseif args[1] == "4" then -- Back Right Door
		door = 3
	elseif args[1] == "rear" then
		door = 4
	elseif args[1] == "front" then
		door = 5
	elseif args[1] == "all" then
		door = 6
	else
		door = nil
		ShowInfo("Usage: ~n~~b~/door [door]. Doors are 1, 2, 3, 4, front, rear, all.")
	end

	if door == 0 or door == 1 or door == 2 or door == 3 then
		if IsPedInAnyVehicle(ped, false) then
			if GetVehicleDoorAngleRatio(veh, door) > 0 then
				SetVehicleDoorShut(veh, door, false)
			else	
				SetVehicleDoorOpen(veh, door, false, false)
			end
		else
			if distanceToVeh < 6 then
				if GetVehicleDoorAngleRatio(vehLast, door) > 0 then
					SetVehicleDoorShut(vehLast, door, false)
				else	
					SetVehicleDoorOpen(vehLast, door, false, false)
				end
			else
				ShowInfo("You must be near a vehicle.")
			end
		end
	end
	if door == 4 or door == 5 or door == 6 then
		if IsPedInAnyVehicle(ped, false) then
			if door == 4 or door == 6 then
				if GetVehicleDoorAngleRatio(veh, 3) > 0 then
					SetVehicleDoorShut(veh, 3, false)
				else	
					SetVehicleDoorOpen(veh, 3, false, false)
				end
				if GetVehicleDoorAngleRatio(veh, 2) > 0 then
					SetVehicleDoorShut(veh, 2, false)
				else	
					SetVehicleDoorOpen(veh, 2, false, false)
				end
			end
			if door == 5 or door == 6 then
				if GetVehicleDoorAngleRatio(veh, 1) > 0 then
					SetVehicleDoorShut(veh, 1, false)
				else	
					SetVehicleDoorOpen(veh, 1, false, false)
				end
				if GetVehicleDoorAngleRatio(veh, 0) > 0 then
					SetVehicleDoorShut(veh, 0, false)
				else	
					SetVehicleDoorOpen(veh, 0, false, false)
				end
			end
		else
			if distanceToVeh < 6 then
				if door == 4 or door == 6 then
					if GetVehicleDoorAngleRatio(vehLast, 3) > 0 then
						SetVehicleDoorShut(vehLast, 3, false)
					else	
						SetVehicleDoorOpen(vehLast, 3, false, false)
					end
					if GetVehicleDoorAngleRatio(vehLast, 2) > 0 then
						SetVehicleDoorShut(vehLast, 2, false)
					else	
					SetVehicleDoorOpen(vehLast, 2, false, false)
				end
			end
	   		if door == 5 or door == 6 then
					if GetVehicleDoorAngleRatio(vehLast, 1) > 0 then
					SetVehicleDoorShut(vehLast, 1, false)
		   		else	
					SetVehicleDoorOpen(vehLast, 1, false, false)
					end
					if GetVehicleDoorAngleRatio(vehLast, 0) > 0 then
					SetVehicleDoorShut(vehLast, 0, false)
					else	
					SetVehicleDoorOpen(vehLast, 0, false, false)
					end
			end
			end
		end
	end
end)

RegisterCommand("cuff", function(source, args, user)
	if args[1] == nil then
		local nearestPlayer = getClosestPlayer()
		if nearestPlayer ~= nil then
			TriggerServerEvent("cuffPlayer", nearestPlayer)
			SendNuiMessage([[{"t":"PLAY_SOUND","d":{"sound":2}}]])
		end
	else
		TriggerServerEvent("cuffPlayer", args[1])
		SendNuiMessage([[{"t":"PLAY_SOUND","d":{"sound":2}}]])
	end
end)


RegisterCommand("drag", function(source, args, user)
	if draggedPlayerId ~= -1 then
		TriggerServerEvent("dragPlayer", draggedPlayerId, false)
		draggedPlayerId = -1
	else
		if args[1] == nil then
			local nearestPlayer = getClosestPlayer()
			if nearestPlayer ~= nil then
				draggedPlayerId = nearestPlayer
				TriggerServerEvent("dragPlayer", nearestPlayer, false)
			end
		else
			draggedPlayerId = args[1]
			TriggerServerEvent("dragPlayer", args[1], false)
		end
	end
end)

RegisterCommand('rack', function(source, args, user)
	local ped = GetPlayerPed(-1)
	local found = false

	for _, item in ipairs(rack) do
		if HasPedGotWeapon(ped, GetHashKey(item.weapon), false) then
			found = true
			TriggerServerEvent("weaponRacked")
			RemoveWeaponFromPed(ped, GetHashKey(item.weapon))
			SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
		end
	end
	if not found then
		ShowInfo("You do not have a weapon to rack")
	end
end)


RegisterCommand('unrack', function(source, args, user)
	local ped = GetPlayerPed(-1)
	local found = false

	for _, item in ipairs(rack) do
		if HasPedGotWeapon(ped, GetHashKey(item.weapon), false) then
			found = true
			TriggerServerEvent("weaponRacked")
			RemoveWeaponFromPed(ped, GetHashKey(item.weapon))
			SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
		end
	end

	if #args > 0 and not found then
		local unrack = table.concat(args, " ")
		local weapon = false

		if tonumber(unrack) then
			unrack = tonumber(unrack)
			if unrack <= #rack then
				weapon = rack[unrack]
			end
		else
			for _, item in ipairs(rack) do
				if item.rack == unrack then
					weapon = item
				end
			end
		end

		if weapon then
			TriggerServerEvent("weaponUnracked", "their " .. weapon.rack)

			GiveWeaponToPed(playerPed, GetHashKey(weapon.weapon), 100, false, true)
			if weapon.components then
				for _, component in ipairs(weapon.components) do
					GiveWeaponComponentToPed(playerPed, GetHashKey(weapon.weapon), GetHashKey(component))
				end
			end
			if weapon.tint then
				SetPedWeaponTintIndex(playerPed, GetHashKey(weapon.weapon), weapon.tint)
			end
		else
			if #rack == 0 then
				ShowInfo("You do not have any weapons you can take out.")
			else
				local weaponString = "Weapons you can unrack: "
				for i, item in ipairs(rack) do
					weaponString = weaponString .. "~n~[" .. i .. "] " .. item.rack
				end
				AddTextEntry("UNRACK_OPTIONS",  weaponString)
				ShowInfoLabel("UNRACK_OPTIONS")
			end
		end
	end
end, false)

-- Command allows player to drop their selected weapon, placing it as a model on the ground and printing a /me message
RegisterCommand('drop', function(source, args, user)
	playerPed = GetPlayerPed(-1)
	currentWeaponHash = GetSelectedPedWeapon(playerPed)
	
	if currentWeaponHash ~= -1569615261 then
		SetPedDropsInventoryWeapon(playerPed, currentWeaponHash, 0.0, 0.9, -0.9, -1)
		RemoveWeaponFromPed(playerPed, currentWeaponHash)
		TriggerServerEvent("weaponDropped")
	end
end)

-- Command allows player to drop their selected weapon, placing it as a model on the ground and printing a /me message
--[[RegisterCommand('dropslow', function(source, args, user)
	playerPed = GetPlayerPed(-1)
	currentWeaponHash = GetSelectedPedWeapon(playerPed)
	if currentWeaponHash == -1569615261 then
		ShowInfo("You cannot drop your hands.")
	else
		TaskPlayAnim(playerPed, "missfinale_c2ig_11", "pushcar_offcliff_f", 8.0, 8.0, -1, 0, 0.0, false, false, false)
		SetPedDropsInventoryWeapon(playerPed, currentWeaponHash, 0.0, 0.9, -0.9, -1)
		RemoveWeaponFromPed(playerPed, currentWeaponHash)
		TriggerServerEvent("weaponDropped")
	end
end)]]

-- NEW HOLSTER SCRIPT
local lastWeapon = nil
local lastDrawable = nil
local lastComponent = nil

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1e3)
    local ped = PlayerPedId()
    local hash = GetEntityModel(ped)
    if HolsterConfig.Peds[hash] then
      repeat
        local currentWeapon = GetSelectedPedWeapon(ped)
        if currentWeapon ~= lastWeapon then
          if HolsterConfig.Weapons[lastWeapon] and lastComponent then
            local drawable = GetPedDrawableVariation(ped, lastComponent)
            if lastDrawable ~= drawable and HolsterConfig.Peds[hash][lastComponent][lastDrawable] == drawable then
              local texture = GetPedTextureVariation(ped, lastComponent)
              SetPedComponentVariation(ped, lastComponent, lastDrawable, texture, 0)
              SendNuiMessage([[{"t":"PLAY_SOUND","d":{"sound":1}}]])
            else
              lastDrawable = nil
              lastComponent = nil
            end
          elseif HolsterConfig.Weapons[currentWeapon] then
            for component, holsters in pairs(HolsterConfig.Peds[hash]) do
              local drawable = GetPedDrawableVariation(ped, component)
              local texture = GetPedTextureVariation(ped, component)
              if holsters[drawable] then
                lastDrawable = drawable
                lastComponent = component
                SetPedComponentVariation(ped, component, holsters[drawable], texture, 0)
                SendNuiMessage([[{"t":"PLAY_SOUND","d":{"sound":0}}]])
                break
              end
            end
          end
        end
        lastWeapon = currentWeapon
        Citizen.Wait(200)
        ped = PlayerPedId()
      until not HolsterConfig.Peds[GetEntityModel(ped)]
    end
  end
end)

--[[RegisterNetEvent("Sonoran:ShotSpotter:Server", serverid, street, spotter)
AddEventHandler("Sonoran:ShotSpotter:Server", function(serverid, street, spotter)
	print("Player: " .. serverid .. " triggered shot spotter " .. spotter.Label .. " on " .. street)
end)]]

-- FIRE SELECTOR SCRIPT by Boz --

local AllowedAuto = {
	[GetHashKey('GROUP_RIFLE')] = true,
	[GetHashKey('GROUP_SMG')] = true,
}

local Weapons = {}

local Constants = {
	SEMI_AUTO = 1,
	BURST_FIRE = 2,
	FULL_AUTO = 3,
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
			-- VAR
		local ped = PlayerPedId()
		local _, weapon = GetCurrentPedWeapon(ped)
		local Weapon = GetWeapon(weapon)

			if IsPedShooting(ped) then
				--[[if not IsPedInAnyVehicle(ped) then
					local iter = 2
					if IsPedSprinting(ped) then
						iter = iter + 1
					end
					CreateThread(function()
						local last = GetGameplayCamRelativePitch()
						for _ = 1, iter do
							local camera = GetGameplayCamRelativePitch()
							local amount = camera - last
							if GetFollowPedCamViewMode() == 4 then
								amount = -amount
							end
							SetGameplayCamRelativePitch(camera - amount, 1.0)
							last = camera
							Wait(1)
						end
					end)
				end]]
			if AllowedAuto[GetWeapontypeGroup(weapon)] then
				({
					function()
						repeat
							DisablePlayerFiring(PlayerId(), true)
							Wait(0)
						until not (IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24))
					end,
					function()
						Wait(300)
						while IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24) do
							DisablePlayerFiring(PlayerId(), true)
							Wait(0)
						end
					end,
					function() end,
				})[Weapon.FiringMode]()
			end
		end
	end
end)


RegisterCommand('firingmode', function()
local ped = PlayerPedId()
	if DoesEntityExist(ped) and not IsEntityDead(ped) and IsArmed() then
	local _, weapon = GetCurrentPedWeapon(ped)
	if AllowedAuto[GetWeapontypeGroup(weapon)] then
		local Weapon = GetWeapon(weapon)
		Weapon.FiringMode = ({ 2, 3, 1 })[Weapon.FiringMode]
		ShowNotification(({
			[Constants.SEMI_AUTO]  = 'Switched firing mode to ~r~semi-auto.',
			[Constants.BURST_FIRE] = 'Switched firing mode to ~y~burst fire.',
			[Constants.FULL_AUTO]  = 'Switched firing mode to ~g~full-auto.',
		})[Weapon.FiringMode])
		PlayClick(ped)
		end
	end
end)

function WeaponStub()
	return {
	FiringMode = 1,
	}
end
	
function GetWeapon(hash)
	if not Weapons[hash] then
	Weapons[hash] = WeaponStub()
	end
	return Weapons[hash]
end

function IsArmed()
	return IsPedArmed(PlayerPedId(), 4)
end

function PlayClick(ped)
	PlaySoundFromEntity(-1, 'Faster_Click', ped, 'RESPAWN_ONLINE_SOUNDSET', false)
end
