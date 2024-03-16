
unreadBleets = 0
bleets = {}
profileBleets = {}
visibleBleets = {}

bleeterHandle = nil

showBleeter = false

bleeterSubpage = 1

profile = nil

RegisterNetEvent('setInitialBleets')
AddEventHandler('setInitialBleets', function(serverBleets)
	print("Set Initial Bleets")
	bleets = serverBleets
end)

RegisterNetEvent('bleetReceived')
AddEventHandler('bleetReceived', function(handle, message, icon)

	if message ~= nil then
		table.insert(bleets, 1, {handle = handle, message = message, icon = icon})
		if #bleets > 1000 then
			table.remove(bleets)
		end

		if GetBleeterHandle() then
			if bleetNotifySettings == "All" or (string.find(message, GetBleeterHandle()) and bleetNotifySettings == "Mentions") then
				ShowBleetNotification(handle, message, icon)
			end
		elseif bleetNotifySettings == "All" then
			ShowBleetNotification(handle, message, icon)
		end

		if currentApp == 7 then
			if currentRow ~= 1 then
				currentRow = currentRow+1
			end

			SetVisibleBleets()
		else
			unreadBleets = unreadBleets + 1
			SetHomeMenuApp(GlobalScaleform, 5, 4, "Bleeter", unreadBleets)
		end
	end
end)

function ShowBleetNotification(handle, message, icon)
	if string.len(message) > 99 then
		message = string.sub(message, 1, 95) .. "..."
	end

	PlaySoundFrontend(-1, "Phone_Generic_Key_01", "HUD_MINIGAME_SOUNDSET", 0)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	SetNotificationMessage(icon, icon, true, 2, "Bleeter", handle)

end

function SetVisibleBleets(insert)
	bleetOffset = 1

	if insert then
		bleetOffset = currentRow 
	else
		if currentRow > 1 then
			bleetOffset = currentRow - 1
		end
	end

	bleetTable = insert or bleets

	for i=1,5 do
		if #bleetTable >= i + bleetOffset - 1 then
			visibleBleets[i] = bleetTable[i + bleetOffset - 1]

			AddTextEntry("BLEET_" .. tostring(i), visibleBleets[i].message)

			if not visibleBleets[i].icon then
				visibleBleets[i].icon = "char_hao"
			end
		else
			visibleBleets[i] = nil
		end
	end
end



Citizen.CreateThread(function()
	TriggerServerEvent("getInitialBleets")
	while true do
		Citizen.Wait(0)
		if currentApp ~= 7 then
			showBleeter = false
		end

		if showBleeter then
			local ren = GetMobilePhoneRenderId()
			SetTextRenderId(ren)

			SetScriptGfxDrawOrder(4)
			
			-- Background
			

			if GetUserSettings("Phone Model") - 1 == 4 then

				DrawRect(0.5, 0.5, 1.0, 1.0, 230, 230, 230, 255)
			else
				DrawRect(0.5, 0.56, 1.0, 0.94, 230, 230, 230, 255)
			end

			if bleeterSubpage == 1 then
				
				DrawRect(0.5, 0.56, 1.0, 0.94, 46, 176, 88, 255)

				DrawRect(0.5, 0.34 * yRenderMultiplier, 1.0, 0.3 * yRenderMultiplier, 0, 153, 203, 255)
				DrawSprite("emailads_bleeter", "emailads_bleeter", 0.5, 0.19 * yRenderMultiplier, 1.0, 0.2 * yRenderMultiplier, 0.0, 255, 255, 255, 255)

				DrawRect(0.5, 0.68 * yRenderMultiplier, 0.6, 0.12 * yRenderMultiplier, 0, 0, 0, 150)
				drawTxtPhone(0.5, 0.63, 0.5, "Sign Up", 0, 0, 0, 255, 255, 255, 255)

			elseif bleeterSubpage == 2 then

				-- Banner
				DrawRect(0.5, 0.14 * yRenderMultiplier - yPositionOffset, 1.0, 0.1 * yRenderMultiplier, 0, 153, 203, 255)
				DrawSprite("emailads_bleeter", "emailads_bleeter", 0.22, 0.14 * yRenderMultiplier - yPositionOffset, 0.5, 0.1 * yRenderMultiplier, 0.0, 255, 255, 255, 255)

				yPoint = 0.0

				if currentRow == 1 then -- Top of screen, draw Bleet button
					DrawRect(0.5, 0.28 * yRenderMultiplier - yPositionOffset, 0.95, 0.15 * yRenderMultiplier, 45, 170, 80, 255)

					WriteText(0.18, 0.23, 0.3, "What's on your mind, " .. bleeterHandle .. "?", 0, 0, 0.8, false, false, true, 255, 255, 255, 255)

					yPoint = 0.2
				end

				-- Each line of text in a Bleet is 0.055 characters long

				for i, item in ipairs(visibleBleets) do
					DrawSprite(item.icon, item.icon, 0.11, (0.27 + yPoint) * yRenderMultiplier - yPositionOffset, 0.15, 0.1125 * yRenderMultiplier, 0.0, 255, 255, 255, 255)
	

					if item.verified then
						WriteText(0.2, 0.2 + yPoint, 0.35, "3", 3, 0, 1.0, false, false, true, 45, 170, 80, 255)
						WriteText(0.2, 0.2 + yPoint, 0.35, "4", 3, 0, 1.0, false, false, true, 45, 170, 80, 255)
						WriteText(0.25, 0.21 + yPoint, 0.35, item.handle, 0, 0, 1.0, false, false, true, 0, 0, 0, 255)
					else
						WriteText(0.2, 0.21 + yPoint, 0.35, item.handle, 0, 0, 1.0, false, false, true, 0, 0, 0, 255)
					end

					--lineCount = drawTxtBleet(0.2, 0.27 + yPoint, 0.3, "BLEET_" .. tostring(i), 0, 0, 1, 0, 0, 0, 255)
					lineCount = WriteText(0.2, 0.27 + yPoint, 0.3, "BLEET_" .. tostring(i), 0, 0, 0.96, true, false, true, 0, 0, 0, 255)

					if devMode then
						WriteText(0.95, 0.21 + yPoint, 0.3, lineCount, 0, 0, 1.0, false, false, true, 0, 0, 0, 255)
					end
				
					yPoint = yPoint + ((0.15 + lineCount * 0.055) * yRenderMultiplier)
				end
			elseif bleeterSubpage == 3 then

				-- Banner
				DrawRect(0.5, 0.14, 1.0, 0.1, 0, 153, 203, 255)
				DrawSprite("emailads_bleeter", "emailads_bleeter", 0.22, 0.14, 0.5, 0.1, 0.0, 255, 255, 255, 255)

				yPoint = 0.25

				DrawRect(0.5, 0.3, 1.0, 0.2, 190, 190, 190, 255)

				drawTxtPhone(0.2, 0.22, 0.4, profile.handle, 0, 0, 1, 0, 0, 0, 255)
				drawTxtPhone(0.2, 0.3, 0.3, "Viewing User Bleets", 0, 0, 1, 0, 0, 0, 255)

				DrawSprite(profile.icon, profile.icon, 0.11, 0.27, 0.15, 0.1125, 0.0, 255, 255, 255, 255)

				-- Each line of text in a Bleet is 0.055 characters long

				for i, item in ipairs(visibleBleets) do
					DrawSprite(item.icon, item.icon, 0.11, 0.27 + yPoint, 0.15, 0.1125, 0.0, 255, 255, 255, 255)
	
					--drawTxtPhone(0.2, 0.21 + yPoint, 0.35, item.handle, 0, 0, 1, 0, 0, 0, 255)
					if item.verified then
						WriteText(0.2, 0.2 + yPoint, 0.35, "3", 3, 0, 1.0, false, false, true, 45, 170, 80, 255)
						WriteText(0.2, 0.2 + yPoint, 0.35, "4", 3, 0, 1.0, false, false, true, 45, 170, 80, 255)
						WriteText(0.25, 0.21 + yPoint, 0.35, item.handle, 0, 0, 1.0, false, false, true, 0, 0, 0, 255)
					else
						WriteText(0.2, 0.21 + yPoint, 0.35, item.handle, 0, 0, 1.0, false, false, true, 0, 0, 0, 255)
					end


					--lineCount = drawTxtBleet(0.2, 0.27 + yPoint, 0.3, "BLEET_" .. tostring(i), 0, 0, 1, 0, 0, 0, 255)
					lineCount = WriteText(0.2, 0.27 + yPoint, 0.3, "BLEET_" .. tostring(i), 0, 0, 0.96, true, false, true, 0, 0, 0, 255)

					if devMode then
						WriteText(0.95, 0.21 + yPoint, 0.3, lineCount, 0, 0, 1.0, false, false, true, 0, 0, 0, 255)
					end
				
					yPoint = yPoint + 0.15 + lineCount * 0.055
				end

			end

			SetScriptGfxDrawOrder(3)
			SetTextRenderId(GetDefaultScriptRendertargetRenderId())

		end
	end
end)

function OpenBleeter()
	unreadBleets = 0
	SetHomeMenuApp(GlobalScaleform, 5, 4, "Bleeter", 0)

	bleeterHandle = GetBleeterHandle()

	PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
	PushScaleformMovieFunctionParameterInt(23) -- MENU PAGE
	PushScaleformMovieFunctionParameterInt(0) -- INDEX
	PopScaleformMovieFunctionVoid()

	showBleeter = true
	loadTextDict("emailads_bleeter")

	
	if bleeterHandle then
		bleeterSubpage = 2
		SetVisibleBleets()
	else
		bleeterSubpage = 1
	end
			
	while true do
		Wait(0)	

		if bleeterSubpage == 1 then

			if (IsControlJustPressed(3, 176)) then -- SELECT
				MoveFinger(5)
				PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Michael", 1)
				N_0x3ed1438c1f5c6612(2)
				DisplayOnscreenKeyboard(0, "FMMC_HANDLE", "", "", "", "", "", 100)
				repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
				if UpdateOnscreenKeyboard() == 1 then
					local newHandle = GetOnscreenKeyboardResult()
					if newHandle == "Bleeter" and not player.staff then
						Notification("Restricted Handle")
					elseif (#newHandle > 20) or (newHandle == "everyone") or (newHandle == "here") then
						Notification("Handle is too long or uses illegal words")
					elseif string.match(newHandle,"[a-zA-Z0-9_]+") == newHandle then
						newHandle = "@"..newHandle
						AddSetting(GlobalScaleform, 3, "~u~Bleeter Handle: ".. newHandle)
						
						local nick = GetPlayerNick(PlayerId())
						SetResourceKvp("KGV:PHONE:HANDLE:" .. nick, newHandle)
						
						bleeterHandle = GetBleeterHandle()

						bleeterSubpage = 2
						SetVisibleBleets()
					else
						Notification("Invalid Handle", 5000)
					end
				elseif UpdateOnscreenKeyboard() == 2 then
					Notification("Message Cancelled", 5000)
				end
			end

		elseif bleeterSubpage == 2 then
			if (IsControlJustPressed(3, 172)) then -- UP
				MoveFinger(1)
				if currentRow ~= 1 then
					currentRow = currentRow - 1
					SetVisibleBleets()		
				end
			end

			if (IsControlJustPressed(3, 173)) then -- DOWN
				MoveFinger(2)
				if currentRow ~= #bleets+1 and #bleets ~= 0 then
					currentRow = currentRow + 1
					SetVisibleBleets()
				
				end
			end

			if (IsControlJustPressed(3, 176)) then -- SELECT
				MoveFinger(5)
				PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Michael", 1)
				if currentRow == 1 then
					N_0x3ed1438c1f5c6612(2)
					DisplayOnscreenKeyboard(0, "FMMC_BLEET", "", "", "", "", "", 180)
					repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
					if UpdateOnscreenKeyboard() == 1 then
						local message = GetOnscreenKeyboardResult()
						if not (string.find(message, "@here") or string.find(message, "@everyone")) then
							local icon = "char_hao"
							local handle = GetBleeterHandle()
							local verified = false

							for _, item in ipairs(customIcon) do
								if item.handle == handle then
									icon = item.icon
									verified = true
								end
							end
							TriggerServerEvent("bleetSent", message, handle, icon, verified, GetPlayerName(PlayerId()))
							SetVisibleBleets()
						end
					elseif UpdateOnscreenKeyboard() == 2 then
						Notification("Message Cancelled", 5000)
					end
				elseif #visibleBleets > 0 then
					profile = visibleBleets[1]
					profileBleets = {}
					for _, item in ipairs(bleets) do
						if item.handle == profile.handle then
							table.insert(profileBleets, item)
						end
					end
					bleeterSubpage = 3
					currentRow = 1
					SetVisibleBleets(profileBleets)
				end
			end





		elseif bleeterSubpage == 3 then
			if (IsControlJustPressed(3, 172)) then -- UP
				MoveFinger(1)
				if currentRow ~= 1 then
					currentRow = currentRow - 1
					SetVisibleBleets(profileBleets)		
				end
			end

			if (IsControlJustPressed(3, 173)) then -- DOWN
				MoveFinger(2)
				if currentRow < #profileBleets then
					currentRow = currentRow + 1
					SetVisibleBleets(profileBleets)
				end
			end
		end



		if IsControlJustReleased(3, 177) then -- BACK
			if bleeterSubpage == 1 or bleeterSubpage == 2 then
				showBleeter = false
				PlaySoundFrontend(-1, "Menu_Back", "Phone_SoundSet_Michael", 1)
				PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
				PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
				PushScaleformMovieFunctionParameterInt(5) -- INDEX
				PopScaleformMovieFunctionVoid()
				Wait(500)
				currentColumn = 2
				currentRow = 1
				currentIndex = 1
				currentApp = 1
				return
			elseif bleeterSubpage == 3 then
				bleeterSubpage = 2
				currentRow = 1
				SetVisibleBleets()
			end
		end
	end
end