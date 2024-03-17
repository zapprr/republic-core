phone = false
model = 0

frontCam = false
doingGesture = false

messageCount = 0

loadedContacts = {}

receivedMessages = {}

unreadMessages = 0

yRenderMultiplier = 1.0
yPositionOffset = 0.0

timeHours = 0
timeMinutes = 0

callId = 0

-- Currently unused
callDetails = {
	channel = 0, participants = {
	{name = "Test", id = -1},
}}

otherCaller = 0
callerName = ""

missedCall = 0

torch = false

days = {
	[1] = "Mon",
	[2] = "Tue",
	[3] = "Wed",
	[4] = "Thu",
	[5] = "Fri",
	[6] = "Sat",
	[7] = "Sun"
}

pdk1 = 0
pdk2 = 0

wallpapers = {
	{name = "iFruit", txd = "Phone_Wallpaper_ifruitdefault"},
	{name = "Badger", txd = "Phone_Wallpaper_badgerdefault"},
	{name = "Bittersweet", txd = "Phone_Wallpaper_bittersweet_b"},
	{name = "Blue Angles", txd = "Phone_Wallpaper_blueangles"},
	{name = "Blue Shards", txd = "Phone_Wallpaper_blueshards"},
	{name = "Blue Triangles", txd = "Phone_Wallpaper_bluetriangles"},
	{name = "Blue Circles", txd = "Phone_Wallpaper_bluecircles"},
	{name = "Blue Diamonds", txd = "Phone_Wallpaper_diamonds"},
	{name = "Purple Glow", txd = "Phone_Wallpaper_purpleglow"},
	{name = "Purple Tartan", txd = "Phone_Wallpaper_purpletartan"},
	{name = "Green Squares", txd = "Phone_Wallpaper_greensquares"},
	{name = "Green Glow", txd = "Phone_Wallpaper_greenglow"},
	{name = "Green Triangles", txd = "Phone_Wallpaper_greentriangles"},
	{name = "Green Shards", txd = "Phone_Wallpaper_greenshards"},
	{name = "Orange 8-Bit", txd = "Phone_Wallpaper_orange8bit"},
	{name = "Orange Triangles", txd = "Phone_Wallpaper_orangetriangles"},
	{name = "Orange Herring Bone", txd = "Phone_Wallpaper_orangeherringbone"},
	{name = "Orange Halftone", txd = "Phone_Wallpaper_orangehalftone"},
	--[[{name = "Jerry", txd = "Phone_Wallpaper_jerry"},
	{name = "LGBTQ+ Pride", txd = "phone_wallpaper_pride"},
	{name = "Trans Pride", txd = "phone_wallpaper_trans"},
	{name = "Sheepdog", txd = "phone_wallpaper_sheepdog"},
	{name = "Fix", txd = "phone_wallpaper_pride"},
	{name = "Fix", txd = "phone_wallpaper_trans"},
	{name = "Fix", txd = "phone_wallpaper_sheepdog"},]]
}

themes = {
	"Blue",
	"Green",
	"Red",
	"Orange",
	"Gray",
	"Purple",
	"Pink",
}

ringtones = {
	{name = "Default", id = "Remote_Ring"},
	{name = "Chirp", id = "PHONE_GENERIC_RING_01"},
	{name = "Flirt", id = "PHONE_GENERIC_RING_02"},
	{name = "Bell", id = "PHONE_GENERIC_RING_03"},
}

contacts = {
	{name = "911 Emergency", icon = "CHAR_CALL911"},
	{name = "311 Non-Emergency", icon = "CHAR_DIAL_A_SUB"},
}

contactsCayo = {
	{name = "123 Emergency", icon = "CHAR_DEFAULT"},
	{name = "113 Non-Emergency", icon = "CHAR_DEFAULT"},
}


function loopGestures()
	currentGestureDict = 0
	doingGesture = false
	while frontCam do Wait(0)
		if not IsControlPressed(0, 186) then
			if IsControlJustPressed(0, 313) then
				currentGestureDict = (currentGestureDict + 1) % #gestureDicts
				DisplayHelpText("Action Selected:\n" .. gestureNames[currentGestureDict+1], 1000)
			end
			if IsControlJustPressed(0, 312) then
				if currentGestureDict-1 < 0 then 
					currentGestureDict = #gestureDicts-1
				else
					currentGestureDict = (currentGestureDict - 1)
				end
				DisplayHelpText("Action Selected:\n" .. gestureNames[currentGestureDict+1], 1000)
			end
		end
	
		gestureDir = "anim@mp_player_intselfie" .. gestureDicts[currentGestureDict+1]
		
		if IsControlPressed(0, 173) then
			if doingGesture == false then
					doingGesture = true
				if not HasAnimDictLoaded(gestureDir) then
					RequestAnimDict(gestureDir)
					repeat Wait(0) until HasAnimDictLoaded(gestureDir)
				end
				TaskPlayAnim(PlayerPedId(), gestureDir, "enter", 4.0, 4.0, -1, 128, -1.0, false, false, false)
				Wait(GetAnimDuration(gestureDir, "enter")*1000)
				TaskPlayAnim(PlayerPedId(), gestureDir, "idle_a", 8.0, 4.0, -1, 129, -1.0, false, false, false)
			end
		else
			if doingGesture == true then
				doingGesture = false
				TaskPlayAnim(PlayerPedId(), gestureDir, "exit", 4.0, 4.0, -1, 128, -1.0, false, false, false)
				Wait(GetAnimDuration(gestureDir, "exit")*1000)
				RemoveAnimDict(gestureDir)
			end
		end
	end
	TaskPlayAnim(PlayerPedId(), "", "", 4.0, 4.0, -1, 128, -1.0, false, false, false)
	RemoveAnimDict(gestureDir)
end

isCalling = false

function OpenApp(app)
	Citizen.CreateThread(function()
		currentApp = app
		if app == 2 then -- MESSAGES

			unreadMessages = 0
			inSubMenu = false
			SetHomeMenuApp(GlobalScaleform, 0, 2, "Texts", unreadMessages)

			PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
			PushScaleformMovieFunctionParameterInt(6) -- MENU PAGE
			PushScaleformMovieFunctionParameterInt(0) -- INDEX
			PopScaleformMovieFunctionVoid()
			while true do
				Wait(0)

				if messageCount > 0 then
					if (IsControlJustPressed(3, 172)) then -- UP
						NavigateMenu(GlobalScaleform, 1)
						MoveFinger(1)
						if not inSubMenu then
							currentRow = currentRow - 1
						end
					end

					if (IsControlJustPressed(3, 173)) then -- DOWN
						NavigateMenu(GlobalScaleform, 3)
						MoveFinger(2)
						if not inSubMenu then
							currentRow = currentRow + 1
						end
						
					end

					currentRow = currentRow % messageCount
				end

				DisableControlAction(0, 323, true)
				if IsDisabledControlJustPressed(0, 323) and messageCount > 0 and inSubMenu then
					if receivedMessages[currentRow+1].postal ~= -1 then
						print(receivedMessages[currentRow+1].postal)
						local n = string.upper(receivedMessages[currentRow+1].postal)
						local fp = nil
						for _, p in ipairs(postals) do
							if string.upper(p.code) == n then
								fp = p
							end
						end

		   				if fp then
							SetNewWaypoint(fp.x, fp.y)
							ShowInfo("~HUD_COLOUR_WAYPOINTLIGHT~Drawing a route to ".. fp.code)
						end
					end
				end

				if (IsControlJustPressed(3, 176)) and messageCount > 0 then -- SELECT
					if inSubMenu then
						ShowInfo("Quick Message Responses coming soon")
					else
						if receivedMessages[currentRow+1] ~= 0 then
							inSubMenu = true
							AddTextEntry("TEXT_MSG_DISPLAY", receivedMessages[currentRow+1].message)

							PushScaleformMovieFunction(GlobalScaleform, "SET_DATA_SLOT")
							PushScaleformMovieFunctionParameterInt(7)
							PushScaleformMovieFunctionParameterInt(0)

							BeginTextComponent("STRING")
							AddTextComponentSubstringPlayerName(receivedMessages[currentRow+1].name)
							EndTextComponent()
							BeginTextComponent("TEXT_MSG_DISPLAY")
							--AddTextComponentSubstringPlayerName()
							EndTextComponent()
							BeginTextComponent("STRING")
							AddTextComponentSubstringPlayerName(receivedMessages[currentRow+1].icon)
							EndTextComponent()

							PopScaleformMovieFunctionVoid()

							PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
							PushScaleformMovieFunctionParameterInt(7) -- MENU PAGE
							PushScaleformMovieFunctionParameterInt(0) -- INDEX

							PopScaleformMovieFunctionVoid()

						ShowInfo("Press ~INPUT_REPLAY_TIMELINE_PICKUP_CLIP~ to set waypoint")
						end
					end
				end

				if IsControlJustReleased(3, 177) then -- BACK
					PlaySoundFrontend(-1, "Menu_Back", "Phone_SoundSet_Michael", 1)
					if inSubMenu then
						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(6) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(0) -- INDEX
						PopScaleformMovieFunctionVoid()
						inSubMenu = false

						currentColumn = 0
						currentRow = 0
						currentRowSubmenu = 0
					else
						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(0) -- INDEX
						PopScaleformMovieFunctionVoid()
						Wait(1000)
						currentColumn = 0
						currentRow = 0
						currentIndex = 1
						currentApp = 1
						return
					end
				end
			end
		end

		if app == 3 then -- CONTACTS

			--for i=0,100 do
			PushScaleformMovieFunction(GlobalScaleform, "SET_DATA_SLOT_EMPTY")
			PushScaleformMovieFunctionParameterInt(2)
			PushScaleformMovieFunctionParameterInt(0) -- Index
	
			PopScaleformMovieFunctionVoid()
			--end

			local contactAmount = 0
			inSubMenu = false

			if currentAOP == "Cayo Perico" then
				for i,v in ipairs(contactsCayo) do
					SetContactRaw(GlobalScaleform, contactAmount, v.name, v.icon)
					contactAmount = contactAmount + 1
					table.insert(loadedContacts, contactAmount, {name = v.name, icon = v.icon})
				end
			else
				for i,v in ipairs(contacts) do
					SetContactRaw(GlobalScaleform, contactAmount, v.name, v.icon)
					contactAmount = contactAmount + 1
					table.insert(loadedContacts, contactAmount, {name = v.name, icon = v.icon})
				end
			end

			specialContactArray = {}

			for i, player in ipairs(onlinePlayers) do
				if player.job ~= "Fire/EMS" and player.job ~= "Law Enforcement" and player.dept ~= "Civilian" and player.dept ~= "Unemployed" then
					local found = false
					for _, item in ipairs(specialContactArray) do
						if player.dept == item then
							found = true
						end
					end

					if not found then
						local contactIcon = "CHAR_DEFAULT"
						for j, v in ipairs(customIcon) do
							if player.job == v.name or player.dept == v.name then
								contactIcon = v.icon
							end
						end

						SetContactRaw(GlobalScaleform, contactAmount, player.dept, contactIcon)
						contactAmount = contactAmount + 1
						table.insert(loadedContacts, contactAmount, {name = player.dept, icon = contactIcon})
						table.insert(specialContactArray, player.dept)
					end
				end
			end

			for i, item in ipairs(onlinePlayers) do
				if tonumber(item.id) ~= GetPlayerServerId(PlayerId()) then
					if item.nick then

						local contactId = tonumber(item.id)
						if missedCall == contactId then
							SetContactRaw(GlobalScaleform, contactAmount, item.nick, "CHAR_DEFAULT", 1)
						else
							SetContactRaw(GlobalScaleform, contactAmount, item.nick, "CHAR_DEFAULT")
						end

						contactAmount = contactAmount+1
						table.insert(loadedContacts, contactAmount, {name = item.nick, icon = txdString, id = contactId, isPlayer = true})
					end
				end
			end

			PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
			PushScaleformMovieFunctionParameterInt(2) -- MENU PAGE
			PushScaleformMovieFunctionParameterInt(0) -- INDEX
			PopScaleformMovieFunctionVoid()

			while true do

				Wait(0)

				if (IsControlJustPressed(3, 172)) then -- UP
					NavigateMenu(GlobalScaleform, 1)
					MoveFinger(1)
					if inSubMenu then
						currentRowSubmenu = currentRowSubmenu - 1
					else
						currentRow = currentRow - 1
					end
				end

				if (IsControlJustPressed(3, 173)) then -- DOWN
					NavigateMenu(GlobalScaleform, 3)
					MoveFinger(2)
					if inSubMenu then
						currentRowSubmenu = currentRowSubmenu + 1
					else
						currentRow = currentRow + 1
					end
				end

				if (IsControlJustPressed(3, 176)) then -- SELECT
					MoveFinger(5)
					PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Michael", 1)

					if inSubMenu then
						if currentRowSubmenu == 0 then
							callId = tonumber(loadedContacts[currentRow+1].id)
							otherCaller = tonumber(loadedContacts[currentRow+1].id)
							callerName = loadedContacts[currentRow+1].name
							exports["pma-voice"]:addPlayerToCall(callId + 30)

							PlayPedRingtone("Dial_and_Remote_Ring", GetPlayerPed(-1), 1)
							currentApp = 11

							TriggerServerEvent("phone_server:callRequest", otherCaller, false)

							return
							OpenApp(11)

						elseif currentRowSubmenu == 1 then
							N_0x3ed1438c1f5c6612(2)
							DisplayOnscreenKeyboard(0, "FMMC_SMS4", "", "", "", "", "", 500)
							repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
							if UpdateOnscreenKeyboard() == 1 then
								local message = GetOnscreenKeyboardResult()
								TriggerServerEvent("phone_server:receiveMessage", loadedContacts[currentRow+1].id, message, GetPlayerServerId(PlayerId()))
							elseif UpdateOnscreenKeyboard() == 2 then
								Notification("Message cancelled.", 5000)
							end
						end

					else

						if loadedContacts[currentRow+1].isPlayer then

							inSubMenu = true

							PushScaleformMovieFunction(GlobalScaleform, "SET_DATA_SLOT")
							PushScaleformMovieFunctionParameterInt(13)
							PushScaleformMovieFunctionParameterInt(0)
							PushScaleformMovieFunctionParameterInt(22)
							BeginTextComponent("STRING")
							AddTextComponentSubstringPlayerName("Call")
							EndTextComponent()
							PopScaleformMovieFunctionVoid()

							PushScaleformMovieFunction(GlobalScaleform, "SET_DATA_SLOT")
							PushScaleformMovieFunctionParameterInt(13)
							PushScaleformMovieFunctionParameterInt(1)
							PushScaleformMovieFunctionParameterInt(19)
							BeginTextComponent("STRING")
							AddTextComponentSubstringPlayerName("Message")
							EndTextComponent()
							PopScaleformMovieFunctionVoid()

							PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
							PushScaleformMovieFunctionParameterInt(13) -- MENU PAGE
							PushScaleformMovieFunctionParameterInt(0) -- INDEX
							PopScaleformMovieFunctionVoid()
						else
							print("is not player")
							N_0x3ed1438c1f5c6612(2)
							DisplayOnscreenKeyboard(0, "FMMC_SMS4", "", "", "", "", "", 500)
							repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
							if UpdateOnscreenKeyboard() == 1 then
								local message = GetOnscreenKeyboardResult()
								local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(PlayerId()), true))
								local location = GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z))
								local phoneNumber = GetPlayerServerId(PlayerId())
								if phoneNumber < 10 then
									phoneNumber = "(555) 690-000" .. phoneNumber
								elseif phoneNumber < 100 then
									phoneNumber = "(555) 690-00" .. phoneNumber
								else
									phoneNumber = "(555) 690-0" .. phoneNumber
								end

								TriggerServerEvent('relaySpecialContact', loadedContacts[currentRow+1].name, message, location, x, y, z, phoneNumber, GetPlayerServerId(PlayerId()), loadedContacts[currentRow+1].icon)
							elseif UpdateOnscreenKeyboard() == 2 then
								Notification("Message Cancelled", 5000)
							end
						end
					end
				end

				currentRow = currentRow % contactAmount
				currentRowSubmenu = currentRowSubmenu % 2

				if IsControlJustReleased(3, 177) then -- BACK
					PlaySoundFrontend(-1, "Menu_Back", "Phone_SoundSet_Michael", 1)
					if inSubMenu then
						inSubMenu = false
						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(2) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(0) -- INDEX
						PopScaleformMovieFunctionVoid()
						Wait(500)
						currentRow = 0
						currentRowSubmenu = 0
					else
						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(1) -- INDEX
						PopScaleformMovieFunctionVoid()
						Wait(500)
						currentColumn = 1
						currentRow = 0
						currentIndex = 2
						currentApp = 1

						currentApp = 1
						return
					end
				end
			end
		end

		if app == 4 then -- NOTES
			OpenPages()
		end
		
		if app == 5 then -- MOBILE RADIO
			OpenRadio()
		end

		--[[if app == 6 then -- Daily Globe
			alternateBrowserControl = false

			local webX, webY = 450, 512
			
			local cursorX = webX / 2
			local cursorY = webY / 2
			local cursorSpeed = 10
			local scrollSpeed = 50

			webindex = 1
			
			PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
			PushScaleformMovieFunctionParameterInt(23) -- MENU PAGE
			PushScaleformMovieFunctionParameterInt(0) -- INDEX
			PopScaleformMovieFunctionVoid()	
			
			--SetPhoneLean(true)
			--SetMobilePhoneRotation(-90.0, 0.0, 90.0)
			
			while true do
			
				Wait(0)
				
				if not duiObj and not txd then
					txd = CreateRuntimeTxd('kgv_phone')
					duiObj = CreateDui(websites[webindex], webX, webY)
				
					_G.duiObj = duiObj

					dui = GetDuiHandle(duiObj)
					tx = CreateRuntimeTextureFromDuiHandle(txd, 'kgv_phone_tex', dui)
				end

				if (IsControlPressed(3, 172)) then -- UP
					MoveFinger(1)
					SendDuiMouseWheel(duiObj, scrollSpeed, 0.0)
				end

				if (IsControlPressed(3, 173)) then -- DOWN
					MoveFinger(2)
					SendDuiMouseWheel(duiObj, -scrollSpeed, 0.0)
				end

				if (IsControlJustReleased(3, 174)) then -- LEFT
					MoveFinger(3)
					if webindex <= 1 then
						webindex = #websites
					else
						webindex = webindex - 1
					end
					SetDuiUrl(duiObj, websites[webindex])
				end

				if (IsControlJustReleased(3, 175)) then -- RIGHT
					MoveFinger(4)
					if webindex >= #websites then
						webindex = 1
					else
						webindex = webindex + 1
					end
					SetDuiUrl(duiObj, websites[webindex])
				end
				
				--SendDuiMouseMove(duiObj, 0.5, 0.5)
				
				local ren = GetMobilePhoneRenderId()
				SetTextRenderId(ren)

				SetScriptGfxDrawOrder(4)
				
				DrawRect(0.5, 0.56, 1.0, 0.94, 255, 255, 255, 255)

				DrawSprite('kgv_phone', 'kgv_phone_tex', 0.5, 0.59, 1.0, 1.0, 0.0, 255, 255, 255, 255)

				SetTextRenderId(GetDefaultScriptRendertargetRenderId())

				SetScriptGfxDrawOrder(3)

				if IsControlJustReleased(3, 177) then -- BACK
					DestroyDui(duiObj)
					duiObj = nil
					txd = nil
					PlaySoundFrontend(-1, "Menu_Back", "Phone_SoundSet_Michael", 1)
					PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
					PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
					PushScaleformMovieFunctionParameterInt(4) -- INDEX
					PopScaleformMovieFunctionVoid()
					Wait(500)
					currentColumn = 1
					currentRow = 1
					currentIndex = 5
					currentApp = 1

					return
				end
			end
		end
		]]

		if app == 7 then -- Bleeter

			OpenBleeter()
		end

		
		if app == 8 then -- SETTINGS
			AddSetting(GlobalScaleform, 1, "~u~Theme: "..themes[theme+1])
			AddSetting(GlobalScaleform, 2, "~u~Background: "..wallpapers[wallpaper].name)

			if GetBleeterHandle() == nil then
				AddSetting(GlobalScaleform, 3, "~u~Bleeter Handle: Not Set")
			else
				AddSetting(GlobalScaleform, 3, "~u~Bleeter Handle: ".. GetBleeterHandle())
			end

			AddSetting(GlobalScaleform, 4, "~u~Bleeter Notifications: "..bleetNotifySettings)
			
			PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
			PushScaleformMovieFunctionParameterInt(18) -- MENU PAGE
			PushScaleformMovieFunctionParameterInt(0) -- INDEX
			PopScaleformMovieFunctionVoid()

			currentRow = 0
			
			while true do
				Wait(0)

				if (IsControlJustPressed(3, 172)) then -- UP
					MoveFinger(1)
					if currentRow ~= 0 then
						NavigateMenu(GlobalScaleform, 1)
						currentRow = currentRow - 1
					end
				end

				if (IsControlJustPressed(3, 173)) then -- DOWN
					MoveFinger(2)
					if currentRow ~= 3 then
						NavigateMenu(GlobalScaleform, 3)
						currentRow = currentRow + 1
					end
				end

				if (IsControlJustPressed(3, 174)) then -- LEFT
					MoveFinger(3)
					
					if currentRow == 0 then

						theme = (theme - 1) % 7

						AddSetting(GlobalScaleform, 1, "~u~Theme: "..themes[theme+1])
						SetResourceKvpInt("KGV:PHONE:THEME", theme+1)

						PushScaleformMovieFunction(GlobalScaleform, "SET_THEME")
						PushScaleformMovieFunctionParameterInt(theme+1) -- 1-8
						PopScaleformMovieFunctionVoid()
						--N_0x83a169eabcdb10a2(PlayerPedId(), theme)
						
						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(18) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(0) -- INDEX
						PopScaleformMovieFunctionVoid()
					elseif currentRow == 1 then

						wallpaper = wallpaper - 1
						if wallpaper <= 0 then
							wallpaper = #wallpapers
						end

						AddSetting(GlobalScaleform, 2, "~u~Background: "..wallpapers[wallpaper].name)
						SetResourceKvpInt("KGV:PHONE:WALLPAPER", wallpaper)

						PushScaleformMovieFunction(GlobalScaleform, "SET_BACKGROUND_CREW_IMAGE")
						BeginTextComponent("STRING")
						AddTextComponentSubstringPlayerName(wallpapers[wallpaper].txd)
						EndTextComponent()
						PopScaleformMovieFunctionVoid()
						
						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(18) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(1) -- INDEX
						PopScaleformMovieFunctionVoid()
					elseif currentRow == 3 then
						if bleetNotifySettings == "All" then
							bleetNotifySettings = "Off"
							SetResourceKvpInt("KGV:PHONE:BLEETNOT", 2)
						elseif bleetNotifySettings == "Mentions" then
							bleetNotifySettings = "All"
							SetResourceKvpInt("KGV:PHONE:BLEETNOT", 1)
						else
							bleetNotifySettings = "Mentions"
							SetResourceKvpInt("KGV:PHONE:BLEETNOT", 0)
						end
						AddSetting(GlobalScaleform, 4, "~u~Bleeter Notifications: "..bleetNotifySettings)

						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(18) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(3) -- INDEX
						PopScaleformMovieFunctionVoid()
					end
					
					NavigateMenu(GlobalScaleform, 2)
				end

				if (IsControlJustPressed(3, 175)) then -- RIGHT
					MoveFinger(4)
					
					if currentRow == 0 then
						theme = (theme + 1) % 7
						AddSetting(GlobalScaleform, 1, "~u~Theme: "..themes[theme+1])
						SetResourceKvpInt("KGV:PHONE:THEME", theme+1)

						PushScaleformMovieFunction(GlobalScaleform, "SET_THEME")
						PushScaleformMovieFunctionParameterInt(theme+1) -- 1-8
						PopScaleformMovieFunctionVoid()

						print(theme)
						
						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(18) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(0) -- INDEX
						PopScaleformMovieFunctionVoid()
					elseif currentRow == 1 then
						wallpaper = wallpaper + 1
						if wallpaper > #wallpapers then
							wallpaper = 1
						end
						AddSetting(GlobalScaleform, 2, "~u~Background: "..wallpapers[wallpaper].name)
						SetResourceKvpInt("KGV:PHONE:WALLPAPER", wallpaper)
						print(wallpaper)


						PushScaleformMovieFunction(GlobalScaleform, "SET_BACKGROUND_CREW_IMAGE")
						BeginTextComponent("STRING")
						AddTextComponentSubstringPlayerName(wallpapers[wallpaper].txd)
						EndTextComponent()
						PopScaleformMovieFunctionVoid()
						
						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(18) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(1) -- INDEX
						PopScaleformMovieFunctionVoid()
					elseif currentRow == 3 then
						if bleetNotifySettings == "Off" then
							bleetNotifySettings = "All"
							SetResourceKvpInt("KGV:PHONE:BLEETNOT", 1)
						elseif bleetNotifySettings == "All" then
							bleetNotifySettings = "Mentions"
							SetResourceKvpInt("KGV:PHONE:BLEETNOT", 0)
						else
							bleetNotifySettings = "Off"
							SetResourceKvpInt("KGV:PHONE:BLEETNOT", 2)
						end
						AddSetting(GlobalScaleform, 4, "~u~Bleeter Notifications: "..bleetNotifySettings)
						
						PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
						PushScaleformMovieFunctionParameterInt(18) -- MENU PAGE
						PushScaleformMovieFunctionParameterInt(3) -- INDEX
						PopScaleformMovieFunctionVoid()
					end

					NavigateMenu(GlobalScaleform, 4)
				end

				if (IsControlJustPressed(3, 176)) then -- SELECT
					MoveFinger(5)
					PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Michael", 1)

					if currentRow == 2 then
						

						N_0x3ed1438c1f5c6612(2)
						DisplayOnscreenKeyboard(0, "FMMC_HANDLE", "", "", "", "", "", 100)
						repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
						if UpdateOnscreenKeyboard() == 1 then
							local newHandle = GetOnscreenKeyboardResult()
							if (#newHandle < 21) and (newHandle ~= "everyone") and (newHandle ~= "here") and string.match(newHandle,"[a-zA-Z0-9_]+") == newHandle then
								newHandle = "@"..newHandle
								AddSetting(GlobalScaleform, 3, "~u~Bleeter Handle: "..newHandle)
								local nick = GetPlayerNick(PlayerId())
								SetResourceKvp("KGV:PHONE:HANDLE:" .. nick, newHandle)
								PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
								PushScaleformMovieFunctionParameterInt(18) -- MENU PAGE
								PushScaleformMovieFunctionParameterInt(2) -- INDEX
								PopScaleformMovieFunctionVoid()
							else
								Notification("Invalid Handle", 5000)
							end
						elseif UpdateOnscreenKeyboard() == 2 then
							Notification("Message Cancelled", 5000)
						end

					end

				end

				if IsControlJustReleased(3, 177) then -- BACK
					PlaySoundFrontend(-1, "Menu_Back", "Phone_SoundSet_Michael", 1)
					PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
					PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
					PushScaleformMovieFunctionParameterInt(6) -- INDEX
					PopScaleformMovieFunctionVoid()
					Wait(500)
					currentColumn = 0
					currentRow = 2
					currentIndex = 7
					currentApp = 1
					return
				end
			end
		end

		if app == 9 then -- CAMERA
			frontCam = false
			SetPedConfigFlag(PlayerPedId(), 242, true)
			SetPedConfigFlag(PlayerPedId(), 243, true)
			SetPedConfigFlag(PlayerPedId(), 244, not true)

			CellCamActivate(true, true)
			CellFrontCamActivate(frontCam)
			
			local xOffset = 0.0
			local yOffset = 1.0
			local roll = 0.0
			local distance = 1.0
			
			local headY = 0.0
			local headRoll = 0.0
			local headHeight = 0.0
			
			local currentTimecyc = 0
			
			currentGestureDict = 0
			flashEnabled = false

			hideAllUI = true
			
			while true do 

				Citizen.Wait(0)
				for i=1,22 do
					HideHudComponentThisFrame(i)
				end

				HideHudAndRadarThisFrame()
				ThefeedHideThisFrame()
				
				local mouseX = GetDisabledControlNormal(0, 1) / 2.0
				local mouseY = -GetDisabledControlNormal(0, 2) / 2.0

				local LeftRightControl = GetDisabledControlNormal(0, 30) / 12.0
				local FovControl = GetDisabledControlNormal(0, 39) / 5.0

				if (IsControlJustPressed(3, 23)) and frontCam == false then -- TOGGLE FLASH
					flashEnabled = not flashEnabled
					if flashEnabled == true then
						DisplayHelpText("Flash Enabled", 1000)
					else
						DisplayHelpText("Flash Disabled", 1000)
					end	
				end	
				
				if IsControlPressed(0, 179) and frontCam == true then -- Hold Spacebar to adjust camera position
					DisableControlAction(0, 1, true)
					DisableControlAction(0, 2, true)
					
					xOffset = math.clamp(xOffset + mouseX, 0.0, 1.0)
					yOffset = math.clamp(yOffset + mouseY, 0.0, 2.0)
					roll = math.clamp(roll + LeftRightControl, -1.0, 1.0)
					-- distance = math.clamp(distance + FovControl, 0.0, 1.0)
				elseif IsControlPressed(0, 185) and frontCam == true then -- Hold F to adjust head rotation
					DisableControlAction(0, 1, true)
					DisableControlAction(0, 2, true)
					
					headY = math.clamp(headY + mouseX, -1.0, 1.0)
					headRoll = math.clamp(headRoll + LeftRightControl, -1.0, 1.0)
					headHeight = math.clamp(headHeight + mouseY, -1.0, 1.0)
				end
				
				CellCamSetHorizontalOffset(xOffset)
				CellCamSetVerticalOffset(yOffset)
				CellCamSetRoll(roll)
				CellCamSetDistance(distance)
				
				CellCamSetHeadY(headY)
				CellCamSetHeadRoll(headRoll)
				CellCamSetHeadHeight(headHeight)

				-- local x,y,z=table.unpack(GetEntityRotation(PlayerPedId()))
				-- local rotz=GetGameplayCamRelativeHeading()
				-- rz = (z+rotz)
				-- SetEntityRotation(PlayerPedId(), x,y,rz+180.0)

				if (IsControlJustPressed(3, 174)) then -- LEFT
					MoveFinger(3)
					currentTimecyc = currentTimecyc - 1
					if currentTimecyc < 0 then currentTimecyc = #filters end
					if currentTimecyc == 0 then 
						ClearTimecycleModifier() 
					else
						SetTimecycleModifier(filters[currentTimecyc])
					end
					DisplayHelpText("Filter Selected: " .. currentTimecyc+1, 1000)
				end

				if (IsControlJustPressed(3, 175)) then -- RIGHT
					MoveFinger(4)
					currentTimecyc = currentTimecyc + 1
					if currentTimecyc > #filters then currentTimecyc = 0 end
					
					if currentTimecyc == 0 then 
						ClearTimecycleModifier() 
					else
						SetTimecycleModifier(filters[currentTimecyc])
					end
					DisplayHelpText("Filter Selected: " .. currentTimecyc+1, 1000)
					-- sorry
				end

				if IsControlJustPressed(3, 172) then -- UP
					frontCam = not frontCam
					CellFrontCamActivate(frontCam)
					Citizen.CreateThread(loopGestures)
				end
				
				if (IsControlJustPressed(3, 176)) then -- SELECT
					RequestNamedPtfxAsset("scr_rcpaparazzo1")
					MoveFinger(5)
					PlaySoundFrontend(-1, "Camera_Shoot", "Phone_SoundSet_Michael", 1)
					if not frontCam and flashEnabled then
						UseParticleFxAsset("scr_rcpaparazzo1")
						StartNetworkedParticleFxNonLoopedOnPedBone("scr_rcpap1_camera", PlayerPedId(), 0.0, 0.0, -0.05, 0.0, 0.0, 90.0, 57005, 1065353216, 0, 0, 0)
						Wait(50)
					end

				end

				if IsControlJustReleased(3, 177) then -- BACK
					ClearTimecycleModifier() 
					PlaySoundFrontend(-1, "Menu_Back", "Phone_SoundSet_Michael", 1)
					PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
					PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
					PushScaleformMovieFunctionParameterInt(7) -- INDEX
					PopScaleformMovieFunctionVoid()
					SetPedConfigFlag(PlayerPedId(), 242, not true)
					SetPedConfigFlag(PlayerPedId(), 243, not true)
					SetPedConfigFlag(PlayerPedId(), 244, true)

					hideAllUI = false
					CellCamActivate(false, false)
					frontCam = false
					Wait(500)
					currentColumn = 1
					currentRow = 2
					currentIndex = 8
					currentApp = 1
					return
				end
			end
		end


		if app == 10 then -- Gallery

			if devmode then

			PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
			PushScaleformMovieFunctionParameterInt(6) -- MENU PAGE
			PushScaleformMovieFunctionParameterInt(0) -- INDEX
			PopScaleformMovieFunctionVoid()

			while true do
				Wait(0)
				
				local ren = GetMobilePhoneRenderId()
				SetTextRenderId(ren)

				SetScriptGfxDrawOrder(4)
			
				-- Background
				DrawRect(0.5, 0.56, 1.0, 0.94, 230, 230, 230, 255)

				for i=1,8 do
					if images[i] then
						if images[i].tx then
							DrawSprite('kgv_gallery', 'image_' .. i, 0.25 + ((i % 2) * 0.5), 0.0 + (math.ceil(i / 2) *0.21), 0.48, 0.2025, 0.0, 255, 255, 255, 255)
						else
							if not txd then
								txd = CreateRuntimeTxd('kgv_gallery')
							end

							duiObj = CreateDui(images[i].image, 160, 90)
							_G.duiObj = duiObj

							images[i].dui = GetDuiHandle(duiObj)
							images[i].tx = CreateRuntimeTextureFromDuiHandle(txd, 'image_' .. i, images[i].dui)
						end
					end
				end

				SetScriptGfxDrawOrder(3)
				SetTextRenderId(GetDefaultScriptRendertargetRenderId())

				if IsControlJustReleased(3, 177) then -- BACK
					PlaySoundFrontend(-1, "Menu_Back", "Phone_SoundSet_Michael", 1)
					PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
					PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
					PushScaleformMovieFunctionParameterInt(8) -- INDEX
					PopScaleformMovieFunctionVoid()
					Wait(1000)
					currentColumn = 2
					currentRow = 2
					currentIndex = 9
					currentApp = 1
					return
				end
			end
		
			else
				ShowInfo("Coming Soon")
			end
		end

		if app == 11 then -- Call Screen

			missedCall = 0

			PushScaleformMovieFunction(GlobalScaleform, "SET_DATA_SLOT")
			PushScaleformMovieFunctionParameterInt(4)
			PushScaleformMovieFunctionParameterInt(0)
			BeginTextComponent("STRING")
			AddTextComponentSubstringPlayerName("")
			EndTextComponent()
			BeginTextComponent("STRING")
			AddTextComponentSubstringPlayerName(callerName)
			EndTextComponent()
			BeginTextComponent("STRING")
			AddTextComponentSubstringPlayerName("CHAR_DEFAULT")
			EndTextComponent()
			BeginTextComponent("STRING")
			AddTextComponentSubstringPlayerName("Phone Call")
			EndTextComponent()
			PopScaleformMovieFunctionVoid()

			PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
			PushScaleformMovieFunctionParameterInt(4) -- MENU PAGE
			PushScaleformMovieFunctionParameterInt(0) -- INDEX
			PopScaleformMovieFunctionVoid()

			SetAudioFlag("MobileRadioInGame", 0)
			SetMobilePhoneRadioState(0)
			SetUserRadioControlEnabled(true)

			if callId == 0 then -- Not caller, display option to receive the call

				PushScaleformMovieFunction(GlobalScaleform, "SET_SOFT_KEYS")
				PushScaleformMovieFunctionParameterInt(1)
				PushScaleformMovieFunctionParameterBool(true)
				PushScaleformMovieFunctionParameterInt(5)
				PopScaleformMovieFunctionVoid()
				PlayPedRingtone("Remote_Ring", GetPlayerPed(-1), 1)

			else -- Is caller, display option to hide the phone

				PushScaleformMovieFunction(GlobalScaleform, "SET_SOFT_KEYS")
				PushScaleformMovieFunctionParameterInt(1)
				PushScaleformMovieFunctionParameterBool(true)
				PushScaleformMovieFunctionParameterInt(8)
				PopScaleformMovieFunctionVoid()
				TaskUseMobilePhoneTimed(PlayerPedId(), 1.0)
			end



			PushScaleformMovieFunction(GlobalScaleform, "SET_SOFT_KEYS")
			PushScaleformMovieFunctionParameterInt(3)
			PushScaleformMovieFunctionParameterBool(true)
			PushScaleformMovieFunctionParameterInt(6)
			PopScaleformMovieFunctionVoid()

			while true do
				Wait(0)
				if (IsControlJustPressed(3, 176)) then -- SELECT
					if callId == 0 then
						PushScaleformMovieFunction(GlobalScaleform, "SET_SOFT_KEYS")
						PushScaleformMovieFunctionParameterInt(1)
						PushScaleformMovieFunctionParameterBool(true)
						PushScaleformMovieFunctionParameterInt(8)
						PopScaleformMovieFunctionVoid()
						TaskUseMobilePhoneTimed(PlayerPedId(), 1.0)

						StopPedRingtone(GetPlayerPed(-1))
						callId = GetPlayerServerId(PlayerId())
						TriggerServerEvent('phone_server:callAnswered', otherCaller)
						exports["pma-voice"]:addPlayerToCall(callId + 30)
					else
						currentColumn = 0
						currentRow = 0
						currentIndex = 1
						currentApp = 1

						DisableControlAction(2, 21, false)
						DestroyMobilePhone()
						phone = false
						torch = false
						return
					end
				end
					

				if IsControlJustReleased(3, 177) or otherCaller == 0 then -- CANCEL / CLOSE PHONE

					if otherCaller ~= 0 then
						TriggerServerEvent('phone_server:callEnd', otherCaller)
						if callId == 0 then -- Not answered
							missedCall = otherCaller
						end
					end

					exports["pma-voice"]:removePlayerFromCall()
					callId = 0
					otherCaller = 0

					currentColumn = 0
					currentRow = 0
					currentIndex = 1
					currentApp = 1

					StopPedRingtone(GetPlayerPed(-1))
					PlaySoundFrontend(-1, "Put_Away", "Phone_SoundSet_Michael", 1)
					DisableControlAction(2, 21, false)
					DestroyMobilePhone()
					phone = false
					torch = false
					return
				end
			end

		end

		currentApp = 1
		return
	end)
end

RegisterCommand("pdk2", function(source, args, user)
	pdk1 = tonumber(args[1])
	pdk2 = tonumber(args[2])
end, false)

--[[ PDK Documentation

1 - Home
2 - Contacts
3 -
4 - Call screen
5 -
6 - Messages
7 - Text message recieving
8 - Email
9 - Horizontal blank? Looks like email reading thing
10 - 
11 - Keypad
12 - 
13 - Blank vertical
14 - Blank vertical with brown header, used for Craplist
15 - Checklist
16 -
17 - Also checklist?
18 - Messages alt (used by settings app)
19 - Not sure? Looks cool tho
20 - Weird list thing, used for Bleeter
21 - Horizontal blank with header
22 - Blank vertical, same as 13?
23 - Trackify app
24 - No idea, similar to keypad but different?
25 - Yellowed, no background
26 - Securoserv no signal
]]

function HandleInput(scaleform)
	if currentApp == 1 then
		if (IsControlJustPressed(3, 172)) then -- UP
			NavigateMenu(scaleform, 1)
			MoveFinger(1)
			currentRow = currentRow - 1
		end

		if (IsControlJustPressed(3, 173)) then -- DOWN
			NavigateMenu(scaleform, 3)
			MoveFinger(2)
			currentRow = currentRow + 1
		end

		if (IsControlJustPressed(3, 174)) then -- LEFT
			NavigateMenu(scaleform, 4)
			MoveFinger(3)
			currentColumn = currentColumn - 1
		end

		if (IsControlJustPressed(3, 175)) then -- RIGHT
			NavigateMenu(scaleform, 2)
			MoveFinger(4)
			currentColumn = currentColumn + 1
		end

		currentColumn = currentColumn % 3
		currentRow = currentRow % 3
		currentIndex = getCurrentIndex(currentColumn+1, currentRow+1)

		if (IsControlJustPressed(3, 176)) then -- SELECT
			MoveFinger(5)
			PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Michael", 1)
			OpenApp(currentIndex+1)
		end

		if (IsControlJustPressed(3, 179)) then
			RequestNamedPtfxAsset("scr_rcpaparazzo1")
			MoveFinger(5)
			torch = not torch
		end

		if IsControlJustReleased(3, 177)  then -- CANCEL / CLOSE PHONE
			PlaySoundFrontend(-1, "Put_Away", "Phone_SoundSet_Michael", 1)
			DisableControlAction(2, 21, false)
			DestroyMobilePhone()
			phone = false
			torch = false
		end
	end
end

contactAmount = 0

Citizen.CreateThread(function()
	while true do

		timeHours = GetClockHours()
		timeMinutes = GetClockMinutes()
		Citizen.Wait(3000)
	end
end)


Citizen.CreateThread(function()
	while true do
		if torch then
			UseParticleFxAsset("scr_rcpaparazzo1")
			StartNetworkedParticleFxNonLoopedOnPedBone("scr_rcpap1_camera", PlayerPedId(), 0.16, -0.05, -0.05, 0.0, 0.0, 90.0, 57005, 1065353216, 0, 0, 0)
		end
		Citizen.Wait(0)
	end
end)


Citizen.CreateThread(function()
	streamedDictionaries = {"CHAR_DEFAULT", "CHAR_HAO"}
	for _, item in ipairs(contacts) do
		table.insert(streamedDictionaries, item.icon)
	end
	for _, item in ipairs(customIcon) do
		table.insert(streamedDictionaries, item.icon)
	end

	print("time to request dictionaries")

	for i, k in ipairs(streamedDictionaries) do
		if not HasStreamedTextureDictLoaded(k) then
			RequestStreamedTextureDict(k, true)
			local textureTimeout = 0
			while not HasStreamedTextureDictLoaded(k) and textureTimeout < 20 do
				Citizen.Wait(100)
				textureTimeout = textureTimeout + 1
			end
		end
	end


	DestroyMobilePhone()
	phone = false
	torch = false

	GlobalScaleform = RequestScaleformMovie("cellphone_ifruit")
	while not HasScaleformMovieLoaded(GlobalScaleform) do
		Citizen.Wait(0)
	end


	SetHomeMenuApp(GlobalScaleform, 0, 2, "Texts")
	SetHomeMenuApp(GlobalScaleform, 1, 5, "Contacts")
	SetHomeMenuApp(GlobalScaleform, 2, 12, "Craplist")
	SetHomeMenuApp(GlobalScaleform, 3, 59, "Mobile Radio")
	SetHomeMenuApp(GlobalScaleform, 4, 6, "Eyefind")
	SetHomeMenuApp(GlobalScaleform, 5, 4, "Bleeter")
	SetHomeMenuApp(GlobalScaleform, 6, 24, "Settings")
	SetHomeMenuApp(GlobalScaleform, 7, 1, "Camera")
	SetHomeMenuApp(GlobalScaleform, 8, 57, "SecuroServ")
	
	-- 1 - Snapmatic/Camera
	-- 2 - Texts
	-- 4 - Email
	-- 5 - Contacts
	-- 6 - Browser
	-- 11 - Add Contact icon
	-- 12 - To-Do List
	-- 14 - Alternative Contacts icon?
	-- 24 - Settings
	-- 27 - interesting [!] icon
	-- 
	-- 42 - Trackify
	-- 57 - SecuroServ
	-- 59 - RSS Icon
	
	-- 27 is an interesting [!] icon
	-- 42 is Trackify, should work

	-- for i,v in pairs(contacts) do
		-- SetContactRaw(GlobalScaleform, contactAmount, v.name, v.icon)
		-- contactAmount = contactAmount + 1
	-- end

	
	-- wallpaper = GetResourceKvpInt("KGV:PHONE:WALLPAPER")
	-- if wallpaper > #wallpapers or wallpaper = 0 then
		-- wallpaper = 1
	-- end

	wallpaper = GetResourceKvpInt("KGV:PHONE:WALLPAPER")
	if wallpaper == 0 or wallpapers[wallpaper].name == nil then
		wallpaper = 1
	end

	bleetNotifySettings = GetResourceKvpInt("KGV:PHONE:BLEETNOT")
	if bleetNotifySettings == 1 then
		bleetNotifySettings = "All"
	elseif bleetNotifySettings == 2 then
		bleetNotifySettings = "Off"
	else
		bleetNotifySettings = "Mentions"
	end

	RequestStreamedTextureDict(wallpapers[wallpaper].txd)
	repeat Wait(0) until HasStreamedTextureDictLoaded(wallpapers[wallpaper].txd)

	
	theme = GetResourceKvpInt("KGV:PHONE:THEME")
	if theme == 0 then theme = 1 end

	PushScaleformMovieFunction(GlobalScaleform, "SET_THEME")
	PushScaleformMovieFunctionParameterInt(theme) -- 1-8
	PopScaleformMovieFunctionVoid()

	
	theme = theme - 1

	PushScaleformMovieFunction(GlobalScaleform, "SET_SLEEP_MODE")
	PushScaleformMovieFunctionParameterInt(0)
	PopScaleformMovieFunctionVoid()


	PushScaleformMovieFunction(GlobalScaleform, "SET_BACKGROUND_CREW_IMAGE")
	BeginTextComponent("STRING")
	AddTextComponentSubstringPlayerName(wallpapers[wallpaper].txd)
	EndTextComponent()
	PopScaleformMovieFunctionVoid()

	while true do
		Wait(0)
		if phone == false and IsControlJustReleased(1, 27) and GetPlayerNick(PlayerId()) and not isPlayerCuffed then -- OPEN PHONE
			showPlayerlist = false
			Phone(55,-26) -- CREATING PHONE
			currentColumn = 0
			currentRow = 0
			currentRowSubmenu = 0
			currentIndex = 1
			currentApp = 1

			PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
			PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
			PushScaleformMovieFunctionParameterInt(0) -- INDEX
			PopScaleformMovieFunctionVoid()	

			model = GetUserSettings("Phone Model") - 1	

			CreateMobilePhone(model)
			phone = true

			SetPedConfigFlag(PlayerPedId(), 242, not true)
			SetPedConfigFlag(PlayerPedId(), 243, not true)
			SetPedConfigFlag(PlayerPedId(), 244, true)

			N_0x83a169eabcdb10a2(PlayerPedId(), theme-1)
			
			DisableControlAction(2, 21, true)

			PushScaleformMovieFunction(GlobalScaleform, "SET_SOFT_KEYS")
			PushScaleformMovieFunctionParameterInt(1)
			PushScaleformMovieFunctionParameterBool(true)
			PushScaleformMovieFunctionParameterInt(1)
			PopScaleformMovieFunctionVoid()

			PushScaleformMovieFunction(GlobalScaleform, "SET_SOFT_KEYS")
			PushScaleformMovieFunctionParameterInt(3)
			PushScaleformMovieFunctionParameterBool(true)
			PushScaleformMovieFunctionParameterInt(1)
			PopScaleformMovieFunctionVoid()

			if callId ~= 0 then
				OpenApp(11)
			end

		end
		if phone == true then
			HandleInput(GlobalScaleform)

			if GetFollowPedCamViewMode() == 4 then
				SetMobilePhoneScale(Floatify(0))
			else
				SetMobilePhoneScale(Floatify(300))
			end

			PushScaleformMovieFunction(GlobalScaleform, "SET_TITLEBAR_TIME")
			PushScaleformMovieFunctionParameterInt(timeHours) -- HOURS
			PushScaleformMovieFunctionParameterInt(timeMinutes) -- MINUTES
			PushScaleformMovieFunctionParameterString("") -- DAYS
			PopScaleformMovieFunctionVoid()

			PushScaleformMovieFunction(GlobalScaleform, "SET_SIGNAL_STRENGTH")
			PushScaleformMovieFunctionParameterInt(GetZoneScumminess(GetZoneAtCoords(GetEntityCoords(PlayerPedId()))))
			PopScaleformMovieFunctionVoid()

			local ren = GetMobilePhoneRenderId()
			SetTextRenderId(ren)

			if model == 4 then
				yRenderMultiplier = 1.3
				yPositionOffset = 0.12
			else
				yRenderMultiplier = 1.0
				yPositionOffset = 0.0
			end
			DrawScaleformMovie(GlobalScaleform, 0.1, 0.18, 0.2, 0.35 * yRenderMultiplier, 255, 255, 255, 255, 0)

			SetTextRenderId(GetDefaultScriptRendertargetRenderId())
		end
	end

end)

RegisterNetEvent('phone:callRequest')
AddEventHandler('phone:callRequest', function(caller, callerName2)
	if phone == false then
		showPlayerlist = false
		Phone(55,-26) -- CREATING PHONE
		currentColumn = 0
		currentRow = 0
		currentRowSubmenu = 0
		currentIndex = 1
		currentApp = 1

		PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
		PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
		PushScaleformMovieFunctionParameterInt(0) -- INDEX
		PopScaleformMovieFunctionVoid()

		model = GetUserSettings("Phone Model") - 1	


		CreateMobilePhone(model)
		phone = true
		SetPedConfigFlag(PlayerPedId(), 242, not true)
		SetPedConfigFlag(PlayerPedId(), 243, not true)
		SetPedConfigFlag(PlayerPedId(), 244, true)
		N_0x83a169eabcdb10a2(PlayerPedId(), theme-1)
			
		DisableControlAction(2, 21, true)
	end
	otherCaller = caller
	callerName = callerName2
	OpenApp(11)
end)

RegisterNetEvent('phone:callEnd')
AddEventHandler('phone:callEnd', function()

	if IsPedRingtonePlaying(GetPlayerPed(-1)) then
		missedCall = otherCaller
	end

	otherCaller = 0

	StopPedRingtone(GetPlayerPed(-1))
end)

RegisterNetEvent('phone:callAnswered')
AddEventHandler('phone:callAnswered', function()
	StopPedRingtone(GetPlayerPed(-1))
end)



function AddSetting(scaleform, index, setting)
	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(18)
	
	PushScaleformMovieFunctionParameterInt(index-1)
	
	PushScaleformMovieFunctionParameterInt(0)
	
	BeginTextComponent("STRING")
	AddTextComponentSubstringPlayerName(setting)
	EndTextComponent()
	
	PopScaleformMovieFunctionVoid()
end

CellCamSetHorizontalOffset = N_0x1b0b4aeed5b9b41c -- -1.0 to 1.0 but there's actually no limit
CellCamSetVerticalOffset = N_0x3117d84efa60f77b -- 0.0 to 2.0
CellCamSetRoll = N_0x15e69e2802c24b8d -- -1.0 to 1.0
CellCamSetDistance = N_0x53f4892d18ec90a4 -- -1.0 to 1.0

CellCamSetHeadY = N_0xd6ade981781fca09 -- -1.0 to 1.0
CellCamSetHeadRoll = N_0xf1e22dc13f5eebad -- -1.0 to 1.0
CellCamSetHeadHeight = N_0x466da42c89865553 -- -1.0 to 0.0

function math.clamp(value, minClamp, maxClamp)
	return math.min(maxClamp, math.max(value, minClamp))
end

function lerp(x1, x2, t) 
    return x1 + (x2 - x1) * t
end


function chatMessage(msg)
	TriggerEvent('chatMessage', '', {0, 0, 0}, msg)
end

function Notification(text,duration)
    Citizen.CreateThread(function()
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        local Notification = DrawNotification(false, false)
        Citizen.Wait(duration)
        RemoveNotification(Notification)
    end)
end

function DisplayHelpText(helpText, time)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringWebsite(helpText)
	EndTextCommandDisplayHelp(0, 0, 1, time or -1)
end

RegisterNetEvent('phone:receiveMessage')
AddEventHandler('phone:receiveMessage', function(sender, message, icon, postal)

	unreadMessages = unreadMessages + 1
	SetHomeMenuApp(GlobalScaleform, 0, 2, "Texts", unreadMessages)

	table.insert(receivedMessages, {name = sender, message = message, icon = icon, postal = postal})

	local txdString = icon

	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	SetNotificationMessage(txdString, txdString, true, 2, sender, "Private Message")
	PlaySoundFrontend(-1, "Phone_Generic_Key_01", "HUD_MINIGAME_SOUNDSET", 0)

	-- message adding stuff

	messageCount = messageCount + 1

	PushScaleformMovieFunction(GlobalScaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(6)
	
	PushScaleformMovieFunctionParameterInt(messageCount - 1)
	
	PushScaleformMovieFunctionParameterInt(timeHours)
	PushScaleformMovieFunctionParameterInt(timeMinutes)

	PushScaleformMovieFunctionParameterInt(33)

	BeginTextComponent("STRING")
	AddTextComponentSubstringPlayerName(sender)
	EndTextComponent()
	
	BeginTextComponent("STRING")
	AddTextComponentSubstringPlayerName(message)
	EndTextComponent()
	
	PopScaleformMovieFunctionVoid()
end)


filters = {
	"phone_cam",
	"phone_cam1",
	"phone_cam10",
	"phone_cam11",
	"phone_cam12",
	"phone_cam13",
	"phone_cam2",
	"phone_cam3",
	"phone_cam3_REMOVED",
	"phone_cam4",
	"phone_cam5",
	"phone_cam6",
	"phone_cam7",
	"phone_cam8",
	"phone_cam8_REMOVED",
	"phone_cam9",
}

gestureDicts = {
	"blow_kiss",
	"dock",
	"jazz_hands",
	"the_bird",
	"thumbs_up",
	"wank",
}

gestureNames = {
	"Blow Kiss",
	"OK",
	"Arrested",
	"FUCK",
	"Thumbs Up",
	"Wank",
}



function Floatify(Int)
  return Int + .0
end

function Phone(X,Y,P,Yaw,R,Z,S)
    SetMobilePhonePosition(Floatify(X or 0),Floatify(Y or 5),Floatify(Z or -60))
    SetMobilePhoneRotation(Floatify(P or -90),Floatify(Yaw or 0),Floatify(R or 0)) -- 75<X<75
    SetMobilePhoneScale(Floatify(S or 300))
end

function CellFrontCamActivate(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

function math.round(num)
	local frac = num - math.floor(num)
	if frac >= 0.5 then
		return math.ceil(num)
	elseif frac < 0.5 then
		return math.floor(num)
	end
end
		
function NavigateMenu(scaleform, inputControl)
	PushScaleformMovieFunction(scaleform, "SET_INPUT_EVENT")
	PushScaleformMovieFunctionParameterInt(inputControl)
	PopScaleformMovieFunctionVoid()
	PlaySoundFrontend(-1, "Menu_Navigate", "Phone_SoundSet_Michael", 1)
end

currentColumn = 0
currentRow = 0
currentRowSubmenu = 0
currentIndex = 1
currentApp = 1

function getCurrentIndex(column, row)
	if 	   (row == 1 and column == 1) then
		return 1
	elseif (row == 1 and column == 2) then
		return 2
	elseif (row == 1 and column == 3) then
		return 3	
	elseif (row == 2 and column == 1) then
		return 4
	elseif (row == 2 and column == 2) then
		return 5
	elseif (row == 2 and column == 3) then
		return 6
	elseif (row == 3 and column == 1) then
		return 7
	elseif (row == 3 and column == 2) then
		return 8
	elseif (row == 3 and column == 3) then
		return 9
	end
end

function SetContactRaw(scaleform, index, name, iconName, hasMissedCall)
	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(2)

	PushScaleformMovieFunctionParameterInt(index) -- Index

	-- 0 - Missed call present
	PushScaleformMovieFunctionParameterInt(hasMissedCall or 0)

	-- 1 - Name
	BeginTextComponent("STRING")
	AddTextComponentSubstringPlayerName(name)
	EndTextComponent()

	-- 2 - Keep empty
	BeginTextComponent("CELL_999")
	EndTextComponent()

	-- 3 - Icon
	BeginTextComponent("CELL_2000")
	AddTextComponentSubstringPlayerName(iconName or "")
	EndTextComponent()
	
	PopScaleformMovieFunctionVoid()
end


function SetHomeMenuApp(scaleform, index, icon, name, notifications, opacity)
	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(1)

	-- Index
	PushScaleformMovieFunctionParameterInt(index)

	-- 0 - Icon
	PushScaleformMovieFunctionParameterInt(icon)

	-- 1 - Notifications count
	PushScaleformMovieFunctionParameterInt(notifications or 0)

	-- 2 - Name
	BeginTextComponent("STRING")
	AddTextComponentSubstringPlayerName(name)
	EndTextComponent()

	-- 3 - Opacity
	PushScaleformMovieFunctionParameterInt((opacity or 0.5) * 100.0)

	PopScaleformMovieFunctionVoid()
end

