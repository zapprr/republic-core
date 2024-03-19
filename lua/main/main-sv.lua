-- Republic Core server.lua

serverHour = 8
serverMinute = 0
minuteDuration = 8000

serverMap = "San Andreas"

Webhooks = {
ServerLog = nil,
FiveMLiveChat = nil, -- To provide your server with a public facing FiveM live chat
AdminLog = nil, -- For staff actions to be logged
DispatchLog = nil, -- For general LEO/EMS/FD related messages to be logged
UserReports = nil, -- For if users in-game use the /report command
PrisonLog = nil, -- Can be used for logging prison sentences separately
txAdminAdminLog = nil -- For use with txAdmin stuff
}

ServerLog = {}

whitelist = false
updatingBanList = false

aoplist = {}

aop = "Please wait..."
aopTime = 0

alert = ""
unitLocations = {}

-- The entity spawn list contains all entities in the server
entitySpawnList = {}

busy = false

players = {}

serverStarted = false

messageIncrementer = 0

incidentNumber = 0

flavorTextList = {}

--- Code ---

function GetSourceName(sourceId)
	if sourceId == 0 then
		return "Console"
	else
		return GetPlayerName(sourceId)
	end
end

function GetPlayerNick(sourceId)
	if sourceId == 0 then
		return "Console"
	else
		for _, player in ipairs(players) do
			if tonumber(player.id) == sourceId then
				return player.nick
			end
		end
	end
end

function LogWebhook(url, message)
	if not devmode then
		if url then
			local message = string.gsub(message, "@everyone", "everyone")
			local message = string.gsub(message, "@here", "here")
			PerformHttpRequest(url, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
		end
	end
end


AddEventHandler("playerConnecting", function(name, setCallback, deferrals)

	local player = source

	deferrals.defer()
	deferrals.update("Checking bans...")

	local rejectionReason = nil

	if serverStarted == false then
		rejectionReason = "The server is currently restarting."
	end

	local content = LoadResourceFile(GetCurrentResourceName(), "json/banlist.json")
	if not content then
		SaveResourceFile(GetCurrentResourceName(), "json/banlist.json", json.encode({}), -1)
		content = json.encode({})
	end

	local blacklist = json.decode(content)
	if not blacklist then
		rejectionReason = "There was an error getting the server ban list. Please contact the developer team if this problem persists."
	end

	for _, ban in ipairs(blacklist) do
		for _, ban_ident in ipairs(ban.ident) do
			for _, identifier in ipairs(GetAllPlayerIdentifiers(player)) do
				if identifier == ban_ident then
					if ban.expires == 0 then
						rejectionReason = "You are banned from the server. This ban is permenant. Your ban ID: " .. ban.id
					elseif ban.expires > os.time() then
						local temp = os.date("*t", ban.expires)
						local banExpiryDate = temp.year .. "/" .. temp.month .. "/" .. temp.day

						rejectionReason = "You are banned from the server. Ban expiry date: " .. banExpiryDate .. ". Your ban ID: " .. ban.id
					elseif ban.expires then
						UnbanPlayer(ban.id)
					end
				end
			end
		end
	end

	deferrals.update("Checking permissions...")

	local identifierDiscord = nil
	local identifierLicense = nil
	local isInDiscord = false
	local isMember = false
	local isStaff = false
	local isDev = false
	local isLOA = false

	if not rejectionReason then
	-- First, we check if they're a server member.
		for k, v in ipairs(GetPlayerIdentifiers(player)) do
			if string.sub(v, 1, string.len("discord:")) == "discord:" then
				identifierDiscord = string.sub(v, 9)
				if exports.discord_perms:GetRoles(player) ~= nil then
					isInDiscord = true
				end
				isMember = exports.discord_perms:IsRolePresent(player, "Member")
				isStaff = exports.discord_perms:IsRolePresent(player, "Staff")
				isDev = exports.discord_perms:IsRolePresent(player, "Dev")
				isLOA = exports.discord_perms:IsRolePresent(player, "LOA")
			
			elseif string.sub(v, 1, string.len("license:")) == "license:" then
				identifierLicense = v
			end
		end


		-- Now, we authenticate them against various server checks.
		if identifierLicense == nil then
			rejectionReason = "Unable to locate your licence key. Contact the server development team for more details."
		elseif identifierDiscord == nil then
			rejectionReason = "Unable to locate your Discord key. Ensure that you have Discord installed on your computer, and linked to your FiveM application."
		elseif not isInDiscord and CheckIfPlayerInDiscord then
			rejectionReason = "You need to join the Discord server in order to connect to the server."
		elseif string.len(name) > 20 then
			rejectionReason = "We do not allow player names in excess of 25 characters - please change your name to be shorter."
		elseif string.len(name) < 3 then
			rejectionReason = "We do not allow player names with fewer than 3 characters - please change your name to be longer."
		elseif isLOA then
			rejectionReason = "You need to remove your LOA tags before you can join the server."
		elseif not isMember and whitelist then
			rejectionReason = "The server is currently restricted to server members."
		end
	end

	logString = "Name: " .. name
	if identifierLicense then
		logString = logString .. "\nLicence Key: " .. identifierLicense
	end
	if identifierDiscord and (isStaff or isDev) then
		logString = logString .. "\nDiscord Handle: " .. identifierDiscord
	elseif identifierDiscord then
		logString = logString .. "\nDiscord Handle: <@" .. identifierDiscord .. ">"
	end


	if rejectionReason then
		-- Player rejected from connecting to the server.
		LogWebhook(Webhooks.ServerLog, "[Player Manager] Rejected Connection\n" .. logString .. "\nReason: " .. rejectionReason)
		deferrals.done(rejectionReason)
	else
		-- Player able to connect to the server
		if isStaff then
			logString = logString .. "\nPermission Level: Staff Member"
		elseif isDev then
				logString = logString .. "\nPermission Level: Server Developer"	
		elseif isMember then
			logString = logString .. "\nPermission Level: Server Member"
		else
			logString = logString .. "\nPermission Level: Guest"
		end
		LogWebhook(Webhooks.ServerLog, "[Player Manager] Player Connecting\n" .. logString)

		messageIncrementer = messageIncrementer + 1
		deferrals.done()
	end
end)

AddEventHandler('playerJoining', function()
	LogWebhook(Webhooks.FiveMLiveChat, "`".. GetSourceName(source).." joined...`")
	TriggerClientEvent("connectionMessage", -1, GetSourceName(source) .. " joined")
end)

RegisterCommand("wl", function(source, args, rawCommand)
	pWL = GetSourceName(source)
	whitelist = not whitelist
	TriggerClientEvent("clientSetWhitelist", -1, whitelist)
	messageIncrementer = messageIncrementer + 1
	if whitelist == true then
		SetConvarServerInfo('Currently Allowing', "Members Only")
		LogWebhook(Webhooks.FiveMLiveChat, "> Server has been whitelisted.")
		LogWebhook(Webhooks.ServerLog, "[Whitelist] Server has been whitelisted by ".. pWL)
	else
		SetConvarServerInfo('Currently Allowing', "Anyone")
		LogWebhook(Webhooks.FiveMLiveChat, "> Server has been un-whitelisted.")
		LogWebhook(Webhooks.ServerLog, "[Whitelist] Server has been un-whitelisted by "..pWL)
	end
end, true)

AddEventHandler('playerDropped', function (reason)
	messageIncrementer = messageIncrementer + 1
	LogWebhook(Webhooks.FiveMLiveChat, "`"..GetSourceName(source).." left ("..reason..")`")

	TriggerClientEvent("connectionMessage", -1, GetSourceName(source) .. " left (" .. reason ..")")

	for i, player in ipairs(players) do
		if tonumber(player.id) == source then
			if player.job == "Fire/EMS" or player.job == "Law Enforcement" or player.job == "Coroner" then
				TriggerClientEvent('dispatchText', -1, player.callsign, "End of Watch")
				LogWebhook(Webhooks.DispatchLog, "```"..player.name.." is now off duty as ".. player.dept .."```")
				LogWebhook(Webhooks.ServerLog, "[Job Manager] " .. GetPlayerName(source).." is now off duty")
			end
			table.remove(players, i)
		end
	end

	entityRemovedCounter = 0

	for i, entity in ipairs(entitySpawnList) do
		if source == entity.creator and DoesEntityExist(entity.entity) and GetEntityRoutingBucket(entity.entity) ~= 2 then
			DeleteEntity(entity.entity)
			entityRemovedCounter = entityRemovedCounter + 1
		end
	end

	LogWebhook(Webhooks.ServerLog, "[Player Manager] " .. GetSourceName(source) .. " disconnected from the server")
	if entityRemovedCounter > 0 then
		LogWebhook(Webhooks.ServerLog, "[Entity] " .. tostring(entityRemovedCounter) .. " entities removed")
	end
end)

AddEventHandler('chatMessage', function(source, name, message)
	local namePlus = "OOC | " .. name
	CancelEvent()
	if GetPlayerName(source) ~= name then
		LogWebhook(Webhooks.AdminLog, "**Automatic Kick Issued**\nPlayer: ".. GetPlayerName(source) .. " (<@"..  GetDiscordHandle(source) .. ">)\nIssued By: Barry the Beaver\nReason: Attempting to send a false chat message.")
		DropPlayer(source, "You have been kicked. Reason: Attempting to send a false chat message")
	elseif string.sub(message, 1, string.len("/")) ~= "/" then
		message = emojify(message)
		print(message)
		TriggerClientEvent('chat:addMessage', -1, {color = {128,128,128}, args = { namePlus, message }})
		messageIncrementer = messageIncrementer + 1
		LogWebhook(Webhooks.FiveMLiveChat, "**OOC | "..GetPlayerName(source).."**: "..message)
	end
end)

function IsLegal(entity) 
	local model = GetEntityModel(entity)
	if (model ~= nil and GetEntityPopulationType(entity) ~= 7 and GetEntityRoutingBucket(entity) > 5) then
		if GetEntityType(entity) == 2 then
			for _, item in ipairs(blacklistedVehicles) do
				hashkey = tonumber(item) ~= nil and tonumber(item) or GetHashKey(item)
				if hashkey == model then
					return true
				end
			end
		else
			for _, item in ipairs(blacklistedModels) do
				hashkey = tonumber(item) ~= nil and tonumber(item) or GetHashKey(item)
				if hashkey == model then
					return true
				end
			end
		end
	end
    	return false
end

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then -- check if the resource that is restarting, is the resource where our script is located
        SetResourceKvp(ServerId .. "-CORE:PLAYERLIST", json.encode(players))
    end
end)

AddEventHandler("entityCreating", function(entity)
	local owner = NetworkGetEntityOwner(entity)
	local model = IsLegal(entity);
	if model then
		-- We just stop the prop from spawning.
		CancelEvent()
	end

	if owner ~= nil and owner > 0 and GetEntityModel(entity) ~= 0 and GetEntityType(entity) == 3 then
		table.insert(entitySpawnList, {entity = entity, creator = NetworkGetEntityOwner(entity), location = GetEntityCoords(entity), heading = GetEntityHeading(entity)})
		LogWebhook(Webhooks.ServerLog, "[Entity] Player " .. GetPlayerName(NetworkGetEntityOwner(entity)) .. " ["..NetworkGetEntityOwner(entity).."] created Entity ".. entity .. ", Model Hash " .. GetEntityModel(entity) .. ", Location " .. GetEntityCoords(entity))
	elseif GetEntityModel(entity) == GetHashKey("metrotrain") then
		table.insert(entitySpawnList, {entity = entity, creator = NetworkGetEntityOwner(entity)})
		LogWebhook(Webhooks.ServerLog, "[Entity] Player " .. GetPlayerName(NetworkGetEntityOwner(entity)) .. " ["..NetworkGetEntityOwner(entity).."] spawned in a metro train")
	end
end)

AddEventHandler("entityRemoved", function(entity)
	for i, item in ipairs(entitySpawnList) do
		if entity == item.entity then
			table.remove(entitySpawnList, i)
		end
	end
end)

function IsPlayerMember(id)
	for _, player in ipairs(players) do
		if player.id == id and player.member then
			return true
		end
	end
	return false
end

local explosionTypes = {'DONTCARE', 'GRENADE', 'GRENADELAUNCHER', 'STICKYBOMB', 'MOLOTOV', 'ROCKET', 'TANKSHELL', 'HI_OCTANE', 'CAR', 'PLANE', 'PETROL_PUMP', 'BIKE', 'DIR_STEAM', 'DIR_FLAME', 'DIR_WATER_HYDRANT', 'DIR_GAS_CANISTER', 'BOAT', 'SHIP_DESTROY', 'TRUCK', 'BULLET', 'SMOKEGRENADELAUNCHER', 'SMOKEGRENADE', 'BZGAS', 'FLARE', 'GAS_CANISTER', 'EXTINGUISHER', 'PROGRAMMABLEAR', 'TRAIN', 'BARREL', 'PROPANE', 'BLIMP', 'DIR_FLAME_EXPLODE', 'TANKER', 'PLANE_ROCKET', 'VEHICLE_BULLET', 'GAS_TANK', 'BIRD_CRAP', 'RAILGUN', 'BLIMP2', 'FIREWORK', 'SNOWBALL', 'PROXMINE', 'VALKYRIE_CANNON', 'AIR_DEFENCE', 'PIPEBOMB', 'VEHICLEMINE', 'EXPLOSIVEAMMO', 'APCSHELL', 'BOMB_CLUSTER', 'BOMB_GAS', 'BOMB_INCENDIARY', 'BOMB_STANDARD', 'TORPEDO', 'TORPEDO_UNDERWATER', 'BOMBUSHKA_CANNON', 'BOMB_CLUSTER_SECONDARY', 'HUNTER_BARRAGE', 'HUNTER_CANNON', 'ROGUE_CANNON', 'MINE_UNDERWATER', 'ORBITAL_CANNON', 'BOMB_STANDARD_WIDE', 'EXPLOSIVEAMMO_SHOTGUN', 'OPPRESSOR2_CANNON', 'MORTAR_KINETIC', 'VEHICLEMINE_KINETIC', 'VEHICLEMINE_EMP', 'VEHICLEMINE_SPIKE', 'VEHICLEMINE_SLICK', 'VEHICLEMINE_TAR', 'SCRIPT_DRONE', 'RAYGUN', 'BURIEDMINE', 'SCRIPT_MISSIL'}

AddEventHandler('explosionEvent', function(sender, ev)
	local allowed = IsPlayerMember(sender)

	if ev.explosionType ~= nil and ev.explosionType < -1 or ev.explosionType > 72 then
		ev.explosionType = "UNKNOWN"
	else
		ev.explosionType = explosionTypes[ev.explosionType+2]
	end

	if allowed then
		LogWebhook(Webhooks.ServerLog, "[Explosions] " .. GetPlayerName(sender) .. " caused an explosion (Type " .. ev.explosionType .. ")")
	else
		CancelEvent()
		LogWebhook(Webhooks.ServerLog, "[Explosions] " .. GetPlayerName(sender) .. " attempted to cause explosion (Type " .. ev.explosionType .. "), but this was blocked.")
	end
	-- ExecuteCommand("screen " .. sender )
end)	


RegisterCommand('deleteentity', function(source, args, user)
	if args[1] then
		local entity = tonumber(args[1])
		if DoesEntityExist(entity) then
			DeleteEntity(entity)
			LogWebhook(Webhooks.ServerLog, "[Entity] Entity " .. entity .. " (Hash " .. GetEntityModel(entity) .. ") has been deleted by " .. GetPlayerName(source))
		end
	end
end, false)

RegisterCommand('ft', function(source, args, user)
	if #args > 0 then
		local coords = GetEntityCoords(GetPlayerPed(source))
		table.insert(flavorTextList, {coords = coords, player = source, text = table.concat(args, " ")})
	end
end, false)

RegisterCommand('rft', function(source, args, user)
	local position = GetEntityCoords(GetPlayerPed(source))

	for i, item in ipairs(flavorTextList) do
		if #(position - item.coords) < 1.0 then
			table.remove(flavorTextList, i)
			break
		end
	end
end, false)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(minuteDuration)

		if serverMinute >= 59 then
			serverMinute = 0
			if serverHour >= 23 then
				serverHour = 0
			else
				serverHour = serverHour + 1
			end
		else
			serverMinute = serverMinute + 1
		end
		
		TriggerClientEvent("CoreTimeSync", -1, serverMinute, serverHour)
		SetResourceKvpInt(ServerId .. "-CORE:MINUTE", serverMinute)
		SetResourceKvpInt(ServerId .. "-CORE:HOUR", serverHour)
	end
end)

RegisterCommand("time", function(source, args, rawCommand)
	if #args > 1 then
		if tonumber(args[1]) and tonumber(args[2]) then
			local hor = tonumber(args[1])
			local min = tonumber(args[2])
			if hor <= 24 and hor >= 0 and min >= 0 and min <= 60 then
				serverMinute = min
				serverHour = hor
			end
		end
	end			
end, true)


Citizen.CreateThread(function()
	SetRoutingBucketEntityLockdownMode(0, "strict")

	-- Set Map Location
	if GetResourceState("LibertyV") == "started" then
		serverMap = "Liberty City"
	end

	math.randomseed(os.time())
	
	-- Get Playerlist (if restarting)
	if (#GetPlayers()) > 0 then
		-- Playerlist
        	players = json.decode(GetResourceKvpString(ServerId .. "-CORE:PLAYERLIST")) or {}

		-- Server Time
		serverMinute = GetResourceKvpInt(ServerId .. "-CORE:MINUTE") or 0
		serverHour = GetResourceKvpInt(ServerId .. "-CORE:HOUR") or 8

		-- AOP
		aop = GetResourceKvpString(ServerId .. "-CORE:AOP") or serverMap
	else

		if serverMap == "San Andreas" then
			aop = initialAOPs[math.random(1, #initialAOPs)]
		elseif serverMap == "Liberty City" then
			aop = "Liberty City"
		else
			aop = "Unknown Map"
		end
		SetResourceKvp("REPUBLC_CORE:AOP", aop)

		LogWebhook(Webhooks.FiveMLiveChat, "```Server Has Been Restarted\n\nServer Status: \nCurrent AOP: " .. aop .. "```")
	end
	print("AOP is " .. aop)

	SetGameType("Roleplay")
	SetMapName(serverMap)
	SetConvarServerInfo('Currently Allowing', "Anyone")
	SetConvarServerInfo('Area of Play', aop)

	serverStarted = true

	local content = LoadResourceFile(GetCurrentResourceName(), "json/calls.json")
	if not content then
		SaveResourceFile(GetCurrentResourceName(), "json/calls.json", json.encode({}), -1)
		content = json.encode({})
	end

	emergencyCallList = json.decode(content)

	if not emergencyCallList then
		LogWebhook(Webhooks.ServerLog, "[ERROR] json/calls.json corrupted - please restore from last backup")
	end

	incidentNumber = 20000
	if #emergencyCallList > 0 then
		incidentNumber = emergencyCallList[#emergencyCallList].incidentNumber or 20000
	end
	

	print("Server script initialised")

	while true do
		if messageIncrementer > 20 then
			messageIncrementer = 0
			if whitelist then
				LogWebhook(Webhooks.FiveMLiveChat, "```Server Status \nCurrent AOP: "..aop.."\nPlayers Online: "..#players.."\nLaw Enforcement Available: " .. counts[1][3] .. "/" .. counts[1][2] .. "\nFire Department Available: " .. counts[2][3] .. "/" .. counts[2][2] .. "\nMembers Only```")
			else
				LogWebhook(Webhooks.FiveMLiveChat, "```Server Status \nCurrent AOP: "..aop.."\nPlayers Online: "..#players.."\nLaw Enforcement Available: " .. counts[1][3] .. "/" .. counts[1][2] .. "\nFire Department Available: " .. counts[2][3] .. "/" .. counts[2][2] .. "\nAll Players Allowed```")
			end
		end
		aopTime = aopTime + 1
		Citizen.Wait(1000)
	end
end)

-- Handles player list functionality for players who join and leave.

Citizen.CreateThread(function()
	while true do
		oldPlayers = players
		players = {}
		for _, player in ipairs(GetPlayers()) do
			playerFound = false
			for _, oldPlayer in ipairs(oldPlayers) do
				if player == oldPlayer.id then
					table.insert(players, oldPlayer)
					playerFound = true
				end
			end
			if not playerFound then -- New player, need to get roles
				local playermember = nil
				local playermember = exports.discord_perms:IsRolePresent(player, "Member")

				while playermember == nil do
					Citizen.Wait(0)
					print("Getting Player Member Information")
				end

				local playerstaff = nil
				local playerstaff = exports.discord_perms:IsRolePresent(player, "Staff")

				while playerstaff == nil do
					Citizen.Wait(0)
					--print("Getting Player Staff Information")
				end

				table.insert(players, {id = player, name = GetSourceName(player), member = playermember, staff = playerstaff, session = 0, nick = nil, job = "Civilian", dept = "Unemployed", callsign = "", status = "UNAVAILABLE", incident = 0})
			end
		end

		counts = {{"Law Enforcement", 0, 0}, {"Fire/EMS", 0, 0}}
		for _, player in ipairs(players) do

			for _, item in ipairs(counts) do
				if item[1] == player.job then
					item[2] = item[2] + 1
					if player.status == "CLEAR" then
						item[3] = item[3] + 1
					end
				end
			end
		end

		TriggerClientEvent("syncPlayerList", -1, players)

		TriggerClientEvent("syncUnitCounts", -1, counts)

		TriggerClientEvent("syncFlavorText", -1, flavorTextList)
		
		Citizen.Wait(1000)
	end
end)


RegisterNetEvent("SetCharacterName")
AddEventHandler("SetCharacterName", function(newNick)
	for _, player in ipairs(players) do
		if tonumber(player.id) == source then
			player.nick = newNick
			TriggerEvent("SetRadioName", source, newNick)
			LogWebhook(Webhooks.ServerLog, "[Character] " .. GetPlayerName(source) .. " has updated their name to " .. newNick)
		end
	end
end)


RegisterCommand('char', function(source, args, user)
	if #args > 1 then
		newNick = table.concat(args, " ")
		if (string.upper(newNick) == newNick or string.lower(newNick) == newNick) then
			newNick = ""
			for _, item in ipairs(args) do
				if newNick ~= "" then
					newNick = newNick .. " "
				end
				newNick = newNick .. (string.lower(item)):gsub("^%l", string.upper)
			end
		end

		for _, player in ipairs(players) do
			if tonumber(player.id) == source then
				if not (string.find(newNick, "Bingle") and not player.staff) then
					player.nick = newNick
					TriggerEvent("SetRadioName", source, newNick)
					LogWebhook(Webhooks.ServerLog, "[Character] " .. GetPlayerName(source) .. " has updated their name to " .. newNick)
				end
			end
		end
	end
end, false)



RegisterCommand('aop', function(source, args, user)
	aop = table.concat(args, " ")
	aopTime = 0
	TriggerClientEvent('updateAOP', -1, aop, 0)

	-- Saves the AOP for next restart, so the script can be restarted without breaking stuff
	SetResourceKvp(ServerId .. "-CORE:AOP", aop)

	-- Sets the AOP on the FiveM status page for the server
	SetConvarServerInfo('Area of Play', aop)

	-- Send chat message indicating AOP
	messageIncrementer = messageIncrementer + 1
	LogWebhook(Webhooks.ServerLog, "[AOP] " .. GetSourceName(source) .. " has changed the AOP to "..aop)
	LogWebhook(Webhooks.FiveMLiveChat, "> ".."AOP changed to " .. aop)
end, true)

RegisterCommand('alert', function(source, args, user)
	alert = table.concat(args, " ")
	TriggerClientEvent('updateAlert', -1, alert, true)
end, true)

function AOPVote(voteOptions, tiebreaker)
	aoplist = {}
	TriggerClientEvent("BeginAOPVote", -1, voteOptions, tiebreaker)
	if tiebreaker then
		Citizen.Wait(60000)
	else
		Citizen.Wait(120000)
	end
	TriggerClientEvent("EndAOPVote", -1)

	local winningAOPs = {}
	local voteLimit = -1

	for _, item in ipairs(aoplist) do
		if item[2] == voteLimit then
			table.insert(winningAOPs, item[1])
		elseif item[2] > voteLimit then
			winningAOPs = {}
			table.insert(winningAOPs, item[1])
			voteLimit = item[2]
		end
	end

	if #winningAOPs > 1 and (#winningAOPs < #voteOptions) then
		AOPVote(winningAOPs, true)
	else
		aop = winningAOPs[1]
		aopTime = 0
		TriggerClientEvent('updateAOP', -1, aop, 0)

		-- Saves the AOP for next restart, so the script can be restarted without breaking stuff
		SetResourceKvp(ServerId .. "-CORE:AOP", aop)

		SetConvarServerInfo('Area of Play', aop)
		messageIncrementer = messageIncrementer + 1
		LogWebhook(Webhooks.FiveMLiveChat, "> ".."AOP Changed to " .. aop)
	end

end

RegisterCommand("aopvote", function(source, args, rawCommand)
	aoplist = {}
	if #args > 0 then
		if not (string.find(table.concat(args, " "), "Keep") or string.find(table.concat(args, " "), "Change")) then
			LogWebhook(Webhooks.ServerLog, "[AOP] " .. GetSourceName(source) .. " has started an AOP vote: "..table.concat(args, " "))
			aopstoadd = table.concat(args, " ")
			AOPVote(string.split(aopstoadd, "/"), false)
		end
	end
end, true)

RegisterCommand('warn', function(source, args, user)
	if #args > 1 then
		if tonumber(args[1]) ~= -1 then
			TriggerClientEvent('showWarning', args[1], table.concat(args, " ", 2), 2)
			LogWebhook(Webhooks.AdminLog, "**Warning Issued**\nPlayer: ".. GetSourceName(args[1]) .. " (<@"..  GetDiscordHandle(args[1]) .. ">)\nIssued By: " .. GetSourceName(source) .. "\nWarning: " .. table.concat(args, " ", 2))
		end
	end
end, true)

RegisterCommand('advise', function(source, args, user)
	if args[1] ~= nil then
		TriggerClientEvent('showWarning', args[1], table.concat(args, " ", 2), 1)
	end
end, true)


RegisterCommand('kick', function(source, args, user)
	if #args > 1 then
		if tonumber(args[1]) ~= -1 then
			message = table.concat(args, " ", 2)
			LogWebhook(Webhooks.AdminLog, "**Kick Issued**\nPlayer: ".. GetSourceName(args[1]) .. " (<@"..  GetDiscordHandle(args[1]) .. ">)\nIssued By: " .. GetSourceName(source) .. "\nReason: " .. message)
			DropPlayer(args[1], "You have been kicked. Reason: "..message)
		end
	end
end, true)


function mergeTables(t1, t2)
	local t = t1
	for i,v in pairs(t2) do
		table.insert(t, v)
	end
	return t
end

function GetAllPlayerIdentifiers(playerId) --Gets all info that could identify a player
	local identifiers = GetPlayerIdentifiers(playerId)
	local tokens = {}
	if GetConvar("ea_useTokenIdentifiers", "true") == "true" then
		for i=0,GetNumPlayerTokens(playerId) do
			table.insert(tokens, GetPlayerToken(playerId, i))
		end
	end
	return mergeTables(identifiers, tokens)
end

RegisterCommand('tempban', function(source, args, user)
	if #args > 2 then
		if tonumber(args[1]) and tonumber(args[2]) then
			if GetSourceName(args[1]) and tonumber(args[2]) < 60 then
				message = table.concat(args, " ", 3)
				BanPlayer(args[1], message, os.time() + (args[2]*86400))
				LogWebhook(Webhooks.AdminLog, "**Temporary Ban Issued**\nPlayer: ".. GetSourceName(args[1]) .. " (<@"..  GetDiscordHandle(args[1]) .. ">)\nBan ID: " .. banId .. "\nIssued By: " .. GetSourceName(source) .. "\nTime: " .. args[2] .. " days\nReason: " .. message)
				DropPlayer(args[1], "You have been temporarily banned. Your ban ID: " .. banId .. ". Ban Expires: " .. args[2] .. " days. Reason: ".. message)
			end
		end
	end
end, true)

RegisterCommand('ban', function(source, args, user)
	if #args > 1 then
		if tonumber(args[1]) then
			if GetSourceName(args[1]) then
				message = table.concat(args, " ", 2)
				BanPlayer(args[1], message, 0)
				LogWebhook(Webhooks.AdminLog, "**Permanent Ban Issued**\nPlayer: ".. GetSourceName(args[1]) .. " (<@"..  GetDiscordHandle(args[1]) .. ">)\nBan ID: " .. banId .. "\nIssued By: " .. GetSourceName(source) .. "\nReason: " .. message)
				DropPlayer(args[1], "You have been banned. Your ban ID: " .. banId .. ". Reason: ".. message)
			end
		end
	end
end, true)

RegisterCommand('unban', function(source, args, user)
	UnbanPlayer(args[1])
end, true)

function BanPlayer(id, reason, expiryTime)
	if updatingBanList then
		Citizen.Wait(100)
	end
	updatingBanList = true
	local content = LoadResourceFile(GetCurrentResourceName(), "json/banlist.json")
	if not content then
		SaveResourceFile(GetCurrentResourceName(), "json/banlist.json", json.encode({}), -1)
		content = json.encode({})
	end
	local blacklist = json.decode(content)
	if not blacklist then
		LogWebhook(Webhooks.AdminLog, "```Error: Unable to process bans. Contact server admin immediately.```")
	else
		if blacklist[#blacklist] then
			banId = blacklist[#blacklist].id + 1
		else
			banId = 1
		end

		identifiers = GetAllPlayerIdentifiers(id)

		data = {id = banId, ident = identifiers, reason = message, expires = expiryTime}

		table.insert(blacklist, data)

		SaveResourceFile(GetCurrentResourceName(), "json/banlist.json", json.encode(blacklist, {indent = true}), -1)
	end
	updatingBanList = false
end

function WarnPlayer(id, reason)
	if updatingBanList then
		Citizen.Wait(100)
	end
	updatingBanList = true

	local content = LoadResourceFile(GetCurrentResourceName(), "json/banlist.json")
	if not content then
		SaveResourceFile(GetCurrentResourceName(), "json/banlist.json", json.encode({}), -1)
		content = json.encode({})
	end
	local blacklist = json.decode(content)
	if not blacklist then
		LogWebhook(Webhooks.AdminLog, "```Error: Unable to process bans. Contact a server administrator immediately.```")
	else
		if blacklist[#blacklist] then
			banId = blacklist[#blacklist].id + 1
		else
			banId = 1
		end

		identifiers = GetAllPlayerIdentifiers(id)

		data = {id = banId, ident = identifiers, reason = message, type = "Warning"}

		table.insert(blacklist, data)

		SaveResourceFile(GetCurrentResourceName(), "json/banlist.json", json.encode(blacklist, {indent = true}), -1)
	end
	updatingBanList = false
end

function UnbanPlayer(id)
	if updatingBanList then
		Citizen.Wait(100)
	end
	updatingBanList = true
	local content = LoadResourceFile(GetCurrentResourceName(), "json/banlist.json")
	if not content then
		SaveResourceFile(GetCurrentResourceName(), "json/banlist.json", json.encode({}), -1)
		content = json.encode({})
	end
	local blacklist = json.decode(content)
	if not blacklist then
		LogWebhook(Webhooks.AdminLog, "```Error: Unable to process bans. Contact server admin immediately.```")
	else
		for i, item in ipairs(blacklist) do
			if item.id == tonumber(id) then
				table.remove(blacklist, i)
			end
		end
		SaveResourceFile(GetCurrentResourceName(), "json/banlist.json", json.encode(blacklist, {indent = true}), -1)
	end
	updatingBanList = false
end

RegisterCommand('staff', function(source, args, user)
	local name = "OOC | ^3[STAFF]^9 " .. GetSourceName(source)
	local message = table.concat(args, " ")
        if not (string.find(message, "@here") or string.find(message, "@everyone")) and #args > 0 then
		TriggerClientEvent('chat:addMessage', -1, {color = {128,128,128}, args = { name, message }})
		messageIncrementer = messageIncrementer + 1
		LogWebhook(Webhooks.FiveMLiveChat, "**OOC | [STAFF] "..GetSourceName(source).."**: "..message)
	end
end, true)

RegisterCommand('msg', function(source, args, user)
	if #args > 1 then
		target = tonumber(args[1])
		message = table.concat(args, " ", 2)
		if GetPlayerName(target) then
			local namePlus = "Message | You > " .. GetSourceName(target)
			TriggerClientEvent('chat:addMessage', source, {color = {46,121,189}, args = {namePlus, message}})

			local namePlus = "Message | " .. GetSourceName(source) .. " > You"
			TriggerClientEvent('chat:addMessage', target, {color = {46,121,189}, args = {namePlus, message}})

			LogWebhook(Webhooks.ServerLog, "[Message] " .. GetSourceName(source) .. " sent a message to " .. GetSourceName(target) .. ": " .. message)
		end
	end
end, false)

RegisterCommand('smsg', function(source, args, user)
	if #args > 1 then
		target = tonumber(args[1])
		message = table.concat(args, " ", 2)
		if GetPlayerName(target) then
			local namePlus = "Message | ^3[STAFF]^9 You ~s~> " .. GetSourceName(target)
			TriggerClientEvent('chat:addMessage', source, {color = {46,121,189}, args = {namePlus, message}})

			local namePlus = "Message | ^3[STAFF]^9 " .. GetSourceName(source) .. "~s~ > You"
			TriggerClientEvent('chat:addMessage', target, {color = {46,121,189}, args = {namePlus, message}})

			LogWebhook(Webhooks.ServerLog, "[Message] " .. GetSourceName(source) .. " sent a message to " .. GetSourceName(target) .. ": " .. message)
		end
	end
end, true)

function SendActionMessage(message, id, localAction)
	if not (string.find(message, "@here") or string.find(message, "@everyone")) then

		TriggerClientEvent("ActionMessage", -1, message, id, localAction)

		local prefix = "[Global Action]"
		if localAction then
			prefix = "[Local Action]"
		end

		messageIncrementer = messageIncrementer + 1
		LogWebhook(Webhooks.FiveMLiveChat, "*"..message.."*")
		LogWebhook(Webhooks.ServerLog, prefix .. " "..GetSourceName(id).." ["..id.."]: " .. message)
	end
end

RegisterCommand('gme', function(source, args, user)
	if #args ~= 0 and GetPlayerNick(source) then
		SendActionMessage(GetPlayerNick(source) .. " " .. table.concat(args, " "), source, false)
	end
end, false)

RegisterCommand('me', function(source, args, user)
	if #args ~= 0 and GetPlayerNick(source) then
		SendActionMessage(GetPlayerNick(source) .. " " .. table.concat(args, " "), source, true)
	end
end, false)

RegisterCommand('gmy', function(source, args, user)
	if #args ~= 0 and GetPlayerNick(source) then
		SendActionMessage(GetPlayerNick(source) .. "'s' " .. table.concat(args, " "), source, false)
	end
end, false)

RegisterCommand('my', function(source, args, user)
	if #args ~= 0 and GetPlayerNick(source) then
		SendActionMessage(GetPlayerNick(source) .. "'s' " .. table.concat(args, " "), source, true)
	end
end, false)

RegisterCommand('do', function(source, args, user)
	DoCommand(source, args, user)
end, false)

RegisterCommand('gdo', function(source, args, user)
	GlobalDoCommand(source, args, user)
end, false)

-- SAR Legacy Commands
RegisterCommand('action', function(source, args, user)
	DoCommand(source, args, user)
end, false)

-- SAR Legacy Commands
RegisterCommand('gaction', function(source, args, user)
	GlobalDoCommand(source, args, user)
end, false)

RegisterCommand('run', function(source, args, user)
	if #args ~= 0 and GetPlayerNick(source) then
		SendActionMessage(GetPlayerNick(source).." runs " .. table.concat(args, " ") .. ", what comes back?", source, false)
	end
end, false)

RegisterCommand('search', function(source, args, user)
	if #args ~= 0 and GetPlayerNick(source) then
		SendActionMessage(GetPlayerNick(source).." searches " .. table.concat(args, " ") .. ", what do I find?", source, false)
	end
end, false)

function DoCommand(source, args, user)
	if #args ~= 0 and GetPlayerNick(source) then
		SendActionMessage(table.concat(args, " "), source, true)
	end
end
function GlobalDoCommand(source, args, user)
	if #args ~= 0 and GetPlayerNick(source) then
		SendActionMessage(table.concat(args, " "), source, true)
	end
end

reportId = 1000

RegisterCommand('report', function(source, args, user)
	if #args > 1 then
		if GetPlayerName(args[1]) then
			local message = table.concat(args, " ")
        		if not (string.find(message, "@here") or string.find(message, "@everyone")) then
				reportId = reportId + 1
				LogWebhook(Webhooks.UserReports, "**Reported Player: **"..GetPlayerName(args[1]) .. " (ID: ".. args[1] .. ", <@"..  GetDiscordHandle(args[1]) .. ">) \n**Reported by: **"..GetPlayerName(source).." (ID: "..source..") \n**Report:** "..table.concat(args, " ", 2))

				TriggerClientEvent('reportSubmitted', source, "Your report has been submitted. Thank you for help keeping the server awesome!")
				TriggerClientEvent('reportSubmittedAll', -1, GetPlayerName(args[1]), args[1], GetPlayerName(source), source, table.concat(args, " ", 2), reportId)
				ExecuteCommand("screen "..args[1] )

			end
		end
	end
end, false)

RegisterServerEvent("markReportAsHandled")
AddEventHandler("markReportAsHandled", function(message, id)
	TriggerClientEvent('updateReportState', -1, message .. " (" .. GetPlayerName(source) .. ")", id)
end)

RegisterServerEvent("sendReportReply")
AddEventHandler("sendReportReply", function(message, id)
	TriggerClientEvent('reportSubmitted', id, message)
end)


RegisterServerEvent("getInitialInformation")
AddEventHandler("getInitialInformation", function()
	while aop == "Please wait..." do
		Citizen.Wait(100)
	end

	TriggerClientEvent("setInitialInformation", source, whitelist, aop, aopTime, alert, serverHour, serverMinute)
end)

function GetDiscordHandle(source)
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.sub(v, 1, string.len("discord:")) == "discord:" then
			return(string.sub(v, 9))
		end
	end
end

RegisterServerEvent("ServerLog", message)
AddEventHandler("ServerLog", function(message)
	LogWebhook(Webhooks.ServerLog, message)
end)

RegisterServerEvent("SendAOPVote", aoptoadd)
AddEventHandler("SendAOPVote", function(aoptoadd)
	LogWebhook(Webhooks.ServerLog, "[AOP] " .. GetPlayerName(source) .. " added a vote for "..aoptoadd)
	aopadded = false
	for i in ipairs(aoplist) do
		if aoplist[i][1] == aoptoadd then
			aoplist[i][2] = aoplist[i][2] + 1
			aopadded = true
		end
	end
	if aopadded == false then
		table.insert(aoplist, {aoptoadd, 1})
	end
end)

RegisterServerEvent("jailServer", playerId, time, report, dept, callsign)
AddEventHandler("jailServer", function(playerId, time, report, dept, callsign)
	if GetPlayerName(playerId) then
		if time == 0 then
			TriggerClientEvent("unjailPlayer", playerId)
			LogWebhook(Webhooks.PrisonLog, "*San Andreas State Prison Authority* \n**Name of Released Subject:** "..GetPlayerName(playerId).." \n**Releasing Officer:** "..GetPlayerName(source) .. " ("..callsign..") \n**Report:** ".. report)
		else
			TriggerClientEvent("jailPlayer", playerId, time)
			LogWebhook(Webhooks.PrisonLog, "*San Andreas State Prison Authority* \n**Name of Incarcerated Subject:** "..GetPlayerName(playerId).." \n**Arresting Officer:** ".. GetPlayerName(source) .. " ("..callsign..") \n**Length of Sentence:** ".. time .. " seconds \n**Report:** ".. report)
		end
	end
end)


RegisterServerEvent("coronerServer", playerId, time)
AddEventHandler("coronerServer", function(playerId, time)
	if GetPlayerName(playerId) then
		if time == nil then
			TriggerClientEvent("uncoronerPlayer", playerId)
		else
			TriggerClientEvent("coronerPlayer", playerId, time)
			LogWebhook(Webhooks.ServerLog, "*San Andreas Coroner* \n**Deceased Subject:** "..GetPlayerName(playerId).." \n**Examiner:** ".. GetPlayerName(source) .. " \n**Length:** ".. time .. " seconds ")
		end
	end
end)

RegisterServerEvent("hospitalServer", playerId, time)
AddEventHandler("hospitalServer", function(playerId, time)
	if GetPlayerName(playerId) then
		if time == nil then
			TriggerClientEvent("unhospitalPlayer", playerId)
		else
			TriggerClientEvent("hospitalPlayer", playerId, time)
			LogWebhook(Webhooks.ServerLog, "*San Andreas Medical Services* \n**Hospitalized Subject:** "..GetPlayerName(playerId).." \n**Examiner:** ".. GetPlayerName(source) .. " \n**Length:** ".. time .. " seconds ")
		end
	end
end)

--[[

RegisterNetEvent("ServerLog")
AddEventHandler("ServerLog", function(type, player, message)
	local time = os.time()
	table.insert(ServerLog, {type = type, player = player, message = message, sent = false, time = time)
end)



]]

RegisterNetEvent("changeSession")
AddEventHandler("changeSession", function(newSession)
	if newSession == -1 then
		SetPlayerRoutingBucket(source, source + 5)
	else
		SetPlayerRoutingBucket(source, newSession)
	end
	for _, player in ipairs(players) do
		player.session = GetPlayerRoutingBucket(player.id)
	end
end)

RegisterNetEvent("setSessionPopulation")
AddEventHandler("setSessionPopulation", function(toggle)
	SetRoutingBucketPopulationEnabled(source + 5, toggle)
end)

RegisterServerEvent("ondutyServer", jobA, jobB, cs)
AddEventHandler("ondutyServer", function(jobA, jobB, cs)
	for i, player in ipairs(players) do
		if tonumber(player.id) == source then

			if player.job == "Law Enforcement" or player.job == "Fire/EMS" or player.job == "Coroner" then
				TriggerClientEvent('dispatchText', -1, player.callsign, "End of Watch")
				LogWebhook(Webhooks.DispatchLog, "```"..player.name.." is now off duty as ".. player.dept .."```")
				LogWebhook(Webhooks.ServerLog, "[Job Manager] " .. GetPlayerName(source).." is now off duty")
			end
			if jobA == "Law Enforcement" or jobA == "Fire/EMS" or jobA == "Coroner" then
				TriggerClientEvent('dispatchText', -1, cs, "Start of Watch, " .. jobB)
				LogWebhook(Webhooks.DispatchLog, "```"..GetPlayerName(source).." is now on duty as "..jobA.."\nAgency: ".. jobB .."\nCallsign: " .. cs.."```")
				LogWebhook(Webhooks.ServerLog, "[Job Manager] " .. GetPlayerName(source).." is now on duty as "..jobA.. " ["..jobB..", "..cs.."]")
			end

			if cs == "" then
				TriggerEvent("SetRadioName", source, GetPlayerNick(source))
			else
				TriggerEvent("SetRadioName", source, GetPlayerNick(source) .. " | " .. cs)
			end

			player.job = jobA
			player.dept = jobB
			player.callsign = cs
			player.status = "UNAVAILABLE"
			player.incident = 0
		end
	end
end)

RegisterServerEvent("playtimeReached")
AddEventHandler("playtimeReached", function()
	local identifierDiscord = ""
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.sub(v, 1, string.len("discord:")) == "discord:" then
			identifierDiscord = string.sub(v, 9)
		end
	end

	LogWebhook(Webhooks.ServerLog, "[Playtime Logger] " .. GetPlayerName(source) .. ", Discord ID <@"..identifierDiscord..">, has now reached 30 hours of playtime on the server.")
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(120000)
		if #emergencyCallList > 0 then
			SaveResourceFile(GetCurrentResourceName(), "json/calls.json", json.encode(emergencyCallList, {indent = true}), -1)
		end
	end
end)




RegisterServerEvent("relaySpecialContact", type, message, location, x, y, z, playerName, playerID, icon)
AddEventHandler("relaySpecialContact", function(type, message, location, x, y, z, playerName, playerID, icon)
	
	postal = GetNearestPostal(x, y, z)
	if serverMap == "Liberty City" then
		address = GetNearestStreetLC(x, y, z)
	else
		address = location
	end

	if type == "911 Emergency" or type == "311 Non-Emergency" or type == "Panic Button" or type == "Requesting LEO" or type == "Requesting Fire/EMS" or type == "Requesting Coroner" or type == "Crime Broadcast" or type == "Shot Spotter" or type == "Created Incident" then
		incidentNumber = incidentNumber + 1

		table.insert(emergencyCallList, {type = type, message = string.upper(message), address = address, postal = postal, playerName = playerName, id = playerID, incidentNumber = incidentNumber, notes = "", state = "Outstanding"})

		TriggerClientEvent("callSpecialContact", -1, type, message, address, postal, playerName, playerID, incidentNumber, "Outstanding")
		if type == "911 Emergency" or type == "311 Non-Emergency" then
			LogWebhook(Webhooks.DispatchLog, "**" .. type .. "** | **Incident:** " .. incidentNumber .. " **| Caller ID:** " .. playerName .. " **| Location:** ".. postal .. " " .. address .. " **| Details:** " .. message)
		elseif type == "Shot Spotter" then
			LogWebhook(Webhooks.DispatchLog, "**Shot Spotter Activation**")
		else
			LogWebhook(Webhooks.DispatchLog, "**" .. type .. ":** " .. playerName .. " **| Location:** ".. postal .. " " .. address .. " **| Message:** " .. message)
		end
		LogWebhook(Webhooks.ServerLog, "[Phone] Call made to ".. type .. " by " .. GetPlayerName(playerID) .. " | Details: " .. message)
	end

	for _, player in ipairs(players) do
		if (player.job == "Public Worker" or player.job == "Animal Control") and type == "311 Non-Emergency" then
			TriggerClientEvent('phone:receiveMessage', player.id, "311 Pager", "Location: " .. postal .. " " .. address .. "~n~" .. message, "CHAR_DIAL_A_SUB", postal)
		elseif player.dept == type or player.job == type then
			TriggerClientEvent('phone:receiveMessage', player.id, player.dept, "Location: " .. postal .. " " .. address .. "~n~".. message, icon, postal)
		end
	end
end)

RegisterServerEvent("responseSpecialContact", lastCaller, icon, name, message)
AddEventHandler("relaySpecialContact", function(lastCaller, icon, name, message)
	TriggerClientEvent("callResponseSpecialContact", lastCaller, icon, name, message)
end)

RegisterServerEvent("cuffPlayer", playerToCuff)
AddEventHandler("cuffPlayer", function(playerToCuff)
	TriggerClientEvent("getCuffed", playerToCuff)
end)

RegisterServerEvent("dragPlayer", playerToDrag, vehicle)
AddEventHandler("dragPlayer", function(playerToDrag, vehicle)
	TriggerClientEvent("getDragged", playerToDrag, source, vehicle)
end)

RegisterServerEvent("weaponUnracked", weaponName)
AddEventHandler("weaponUnracked", function(weaponName)
	if GetPlayerNick(source) then
		SendActionMessage(GetPlayerNick(source) .. " has unracked "..weaponName.." from their vehicle.", source, true)
	end
end)

RegisterServerEvent("weaponRacked")
AddEventHandler("weaponRacked", function()
	if GetPlayerNick(source) then
		SendActionMessage(GetPlayerNick(source) .. " has racked a weapon.", source, true)
	end
end)

RegisterServerEvent("relayDispatchMessage", callsign, message)
AddEventHandler("relayDispatchMessage", function(callsign, message)
	LogWebhook(Webhooks.DispatchLog, callsign .. ", " .. message)
	TriggerClientEvent('dispatchText', -1, callsign, message)
	print("did the thing")
end)

RegisterServerEvent("putPlayerInVehicle")
AddEventHandler("putPlayerInVehicle", function(playerToForce)
	TriggerClientEvent("putPlayerInVehicle", playerToForce)
end)

RegisterServerEvent("weaponDropped")
AddEventHandler("weaponDropped", function()
	if GetPlayerNick(source) then
		SendActionMessage(GetPlayerNick(source) .. " has dropped their weapon on the ground.", source, true)
	end
end)

RegisterServerEvent("Sonoran:ShotSpotter:Server", serverid, street, spotter)
AddEventHandler("Sonoran:ShotSpotter:Server", function(serverid, street, spotter)
	--TriggerEvent("relaySpecialContact", "Shot Spotter", spotter.Label, street, spotter.Position.x, spotter.Position.y, spotter.Position.z, serverid, serverid, serverid)
	LogWebhook(Webhooks.DispatchLog, "**Shot Spotter Activation | Spotter: **" .. spotter.Label .. " | **Location: **" .. street)
end)

-- txAdmin Logging

--[[AddEventHandler('txAdmin:events:playerKicked', function(eventData)
	LogWebhook(Webhooks.txAdminAdminLog, "**Warning Issued** via txAdmin\nPlayer: ".. GetSourceName(eventData.target) .. " (<@"..  GetDiscordHandle(eventData.target) .. ">)Issued By: " .. eventData.author .. "\nReason: " .. eventData.reason)
end)]]

AddEventHandler('txAdmin:events:playerWarned', function(eventData)
	LogWebhook(Webhooks.txAdminAdminLog, "**Warning Issued** via txAdmin\nPlayer: ".. GetSourceName(eventData.target) .. " (<@"..  GetDiscordHandle(eventData.target) .. ">)\ntxAdmin ID: " .. eventData.actionId .. "\nIssued By: " .. eventData.author .. "\nReason: " .. eventData.reason)
end)

AddEventHandler('txAdmin:events:playerBanned', function(eventData)
	local txBanExpiryDate = eventData.expiration
	if txBanExpiryDate ~= false then
		LogWebhook(Webhooks.txAdminAdminLog, "**Temporary Ban issued** via txAdmin\nPlayer: ".. GetSourceName(eventData.target) .. " (<@"..  GetDiscordHandle(eventData.target) .. ">)\ntxAdmin ID: " .. eventData.actionId .. "\nIssued By: " .. eventData.author .. "\nReason: " .. eventData.reason .. "\nExpires: <t:" .. txBanExpiryDate .. ">")
	else
		LogWebhook(Webhooks.txAdminAdminLog, "**Permanent Ban issued** via txAdmin\nPlayer: ".. GetSourceName(eventData.target) .. " (<@"..  GetDiscordHandle(eventData.target) .. ">)\ntxAdmin ID: " .. eventData.actionId .. "\nIssued By: " .. eventData.author .. "\nReason: " .. eventData.reason)
	end
end)
