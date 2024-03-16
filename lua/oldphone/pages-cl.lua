adverts = {}

showPages = false

RegisterNetEvent("newAdvert", title, message)
AddEventHandler("newAdvert", function(title, message)
	icon = "CHAR_DEFAULT"
	for _, item in ipairs(customIcon) do
		if title == item.name then
			icon = item.icon
		end
	end
	PlaySoundFrontend(-1, "Phone_Generic_Key_01", "HUD_MINIGAME_SOUNDSET", 0)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	SetNotificationMessage(icon, icon, true, 2, title, "Advertisement")
end)

RegisterNetEvent("syncAdverts", advertsToSync)
AddEventHandler("syncAdverts", function(advertsToSync)
	adverts = advertsToSync
	currentPage = 1
	if #adverts > 0 then
		AddTextEntry("AD_TEXT", adverts[1][3])
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if currentApp ~= 4 then
			showPages = false
		end

		if showPages then
			local ren = GetMobilePhoneRenderId()
			SetTextRenderId(ren)

			SetScriptGfxDrawOrder(4)
			
			-- Background
			DrawRect(0.5, 0.56, 1.0, 0.94, 230, 230, 230, 255)
			-- Banner
			DrawRect(0.5, 0.14, 1.0, 0.1, 131, 77, 48, 255)
			-- Text
			drawTxtPhone(0.05, 0.1, 0.4, "craplist.net", 0, 0, 1, 200, 124, 0, 255)


			if #adverts > 0 then
				WriteText(0.95, 0.9, 0.3, "Page "..currentPage .." of ".. #adverts + 1, 0, 0, 0.0, false, false, true, 0, 0, 0, 255)
			else
				WriteText(0.95, 0.9, 0.3, "No Adverts Posted", 0, 0, 0.0, false, false, true, 0, 0, 0, 255)
			end

			if currentPage < #adverts + 1 then
				WriteText(0.05, 0.2, 0.45, "~h~"..adverts[currentPage][2], 0, 0, 1.0, false, false, true, 0, 0, 0, 255)
				WriteText(0.05, 0.3, 0.35, "AD_TEXT", 0, 0, 1.0, true, false, true, 0, 0, 0, 255)

				--drawTxtPhone(0.05, 0.2, 0.45, adverts[currentPage][2], 0, 2, 1, 255, 255, 255, 255)
				--drawTxtLabel(0.05, 0.3, 0.35, , 0, 0, 1, 0, 0, 0, 255)

				WriteText(0.05, 0.8, 0.3, "Listing created by ~h~" .. adverts[currentPage][5], 0, 0, 0.7, false, false, true, 0, 0, 0, 255)

				DrawRect(0.8, 0.83, 0.25, 0.08, 131, 77, 48, 255)
				if adverts[currentPage][1] == GetPlayerServerId(PlayerId()) then
					WriteText(0.8, 0.8, 0.3, "Delete", 0, 0, nil, false, false, true, 255, 255, 255, 255)
				else
					WriteText(0.8, 0.8, 0.3, "Reply", 0, 0, nil, false, false, true, 255, 255, 255, 255)
				end
			else
				WriteText(0.05, 0.2, 0.35, "Promote your business~n~Sell your junk~n~Create a craplist.net listing today!", 0, 0, 1.0, false, false, true, 0, 0, 0, 255)
				DrawRect(0.5, 0.5, 0.8, 0.15, 131, 77, 48, 255)
				WriteText(0.5, 0.45, 0.45, "Create Advert", 0, 0, nil, false, false, true, 255, 255, 255, 255)
			end

			SetScriptGfxDrawOrder(3)
			SetTextRenderId(GetDefaultScriptRendertargetRenderId())

		end
	end
end)

function OpenPages()

	currentPage = 1

	TriggerServerEvent("requestAdverts")
	while adverts == nil do
		Citizen.Wait(50)
	end

	PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
	PushScaleformMovieFunctionParameterInt(14) -- MENU PAGE
	PushScaleformMovieFunctionParameterInt(0) -- INDEX
	PopScaleformMovieFunctionVoid()

	if #adverts > 0 then
		AddTextEntry("AD_TEXT", adverts[1][3])
	end

	showPages = true

	while true do
		Citizen.Wait(0)

		if (IsControlJustPressed(3, 174)) then -- LEFT
			if currentPage > 1 then
				MoveFinger(3)
				PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Michael", 1)
				currentPage = currentPage - 1
				AddTextEntry("AD_TEXT", adverts[currentPage][3])
			end
		end

		if (IsControlJustPressed(3, 175)) then -- RIGHT
			if currentPage < #adverts + 1 then
				MoveFinger(4)
				PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Michael", 1)
				currentPage = currentPage + 1
				if currentPage <= #adverts then
					AddTextEntry("AD_TEXT", adverts[currentPage][3])
				end
			end		
		end


		if (IsControlJustPressed(3, 176)) then -- SELECT
			MoveFinger(5)
			PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Michael", 1)
			if currentPage < #adverts + 1 then
				if adverts[currentPage][1] == GetPlayerServerId(PlayerId()) then
					-- Advert belongs to the sender, delete it
					TriggerServerEvent("deleteAdvert", adverts[currentPage][4])
					Citizen.Wait(500)
					TriggerServerEvent("requestAdverts")
				else

					N_0x3ed1438c1f5c6612(2)
					DisplayOnscreenKeyboard(0, "FMMC_SMS4", "", "", "", "", "", 500)
					repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
					if UpdateOnscreenKeyboard() == 1 then
						local message = GetOnscreenKeyboardResult()
						local receiver = adverts[currentPage][1]
						TriggerServerEvent("phone_server:receiveMessage", receiver, message, GetPlayerServerId(PlayerId()))
					elseif UpdateOnscreenKeyboard() == 2 then
						Notification("Message cancelled.", 5000)
					end
				end
			else
				N_0x3ed1438c1f5c6612(2)
				DisplayOnscreenKeyboard(0, "FMMC_ADTITLE", "", "", "", "", "", 25)
				repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
				if UpdateOnscreenKeyboard() == 1 then

					local title = GetOnscreenKeyboardResult()

					for _, item in ipairs(customIcon) do
						if string.lower(item.name) == string.lower(title) then
							title = item.name
						end
					end

					N_0x3ed1438c1f5c6612(2)
					DisplayOnscreenKeyboard(0, "FMMC_ADDESC", "", "", "", "", "", 200)
					repeat Wait(0) until UpdateOnscreenKeyboard() ~= 0
					if UpdateOnscreenKeyboard() == 1 then
						local message = GetOnscreenKeyboardResult()

						if title ~= message then
							TriggerServerEvent("addAdvert", GetPlayerServerId(PlayerId()), title, message)
						end

						Citizen.Wait(500)
						TriggerServerEvent("requestAdverts")
					end
				end
			end
		end

		if IsControlJustReleased(3, 177) then -- BACK
			showPages = false
			PlaySoundFrontend(-1, "Menu_Back", "Phone_SoundSet_Michael", 1)
			PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
			PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
			PushScaleformMovieFunctionParameterInt(2) -- INDEX
			PopScaleformMovieFunctionVoid()
			Wait(500)
			currentColumn = 2
			currentRow = 0
			currentIndex = 1
			currentApp = 1
			return
		end


	end

end