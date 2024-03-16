radioTable = {

{"RADIO_01_CLASS_ROCK", "char_property_arms_trafficking"},
{"RADIO_02_POP", "char_property_bar_airport"},
{"RADIO_03_HIPHOP_NEW", "char_property_bar_bayview"},
{"RADIO_04_PUNK", "char_property_bar_cafe_rojo"},
{"RADIO_05_TALK_01", "char_property_bar_cockotoos"},
{"RADIO_06_COUNTRY", "char_property_bar_eclipse"},
{"RADIO_07_DANCE_01", "char_property_bar_fes"},
{"RADIO_08_MEXICAN", "char_property_bar_hen_house"},
{"RADIO_09_HIPHOP_OLD", "char_property_bar_hi_men"},
{"RADIO_11_TALK_02", "char_property_bar_hookies"},
{"RADIO_12_REGGAE", "char_property_bar_irish"},
{"RADIO_13_JAZZ", "char_property_bar_les_bianco"},
{"RADIO_14_DANCE_02", "char_property_bar_mirror_park"},
{"RADIO_15_MOTOWN", "char_property_bar_pitchers"},
{"RADIO_16_SILVERLAKE", "char_property_bar_singletons"},
{"RADIO_17_FUNK", "char_property_bar_tequilala"},
{"RADIO_18_90S_ROCK", "char_property_bar_unbranded"},
{"RADIO_20_THELAB", "char_property_car_mod_shop"},
{"RADIO_21_DLC_XM17", "char_property_car_scrap_yard"},
{"RADIO_22_DLC_BATTLE_MIX1_RADIO", "char_property_cinema_downtown"},

}

stationIcon = "char_property_cinema_morningwood"
stationText = "Radio Off"
stationTime = ""

showRadio = true

function OpenRadio()

		loadTextDict("char_property_cinema_morningwood")

		PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
		PushScaleformMovieFunctionParameterInt(23) -- MENU PAGE
		PushScaleformMovieFunctionParameterInt(0) -- INDEX
		PopScaleformMovieFunctionVoid()

		showRadio = true

		while true do
			Citizen.Wait(0)

			if (IsControlJustPressed(3, 174)) then -- LEFT
				if IsMobilePhoneRadioActive() ~= false then
					MoveFinger(3)
					local newStation = (GetPlayerRadioStationIndex() - 1) % MaxRadioStationIndex()
					stationIcon, stationText = GetStationInformation(newStation)
					SetRadioToStationIndex(newStation)
				end
			end

			if (IsControlJustPressed(3, 175)) then -- RIGHT
				if IsMobilePhoneRadioActive() ~= false then
					MoveFinger(4)
					local newStation = (GetPlayerRadioStationIndex() + 1) % MaxRadioStationIndex()
					stationIcon, stationText = GetStationInformation(newStation)
					SetRadioToStationIndex(newStation)
					
				end
			end

			if (IsControlJustPressed(3, 176)) then -- SELECT
				MoveFinger(5)
				PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Michael", 1)
				if IsMobilePhoneRadioActive() == false then
					SetAudioFlag("MobileRadioInGame", 1)
					SetMobilePhoneRadioState(1)
					SetUserRadioControlEnabled(false)
				else
					SetAudioFlag("MobileRadioInGame", 0)
					SetMobilePhoneRadioState(0)
					SetUserRadioControlEnabled(true)
				end
				Citizen.Wait(200)
				stationIcon, stationText = GetStationInformation(GetPlayerRadioStationIndex())
			end

			if IsControlJustReleased(3, 177) then -- BACK
				PlaySoundFrontend(-1, "Menu_Back", "Phone_SoundSet_Michael", 1)
				PushScaleformMovieFunction(GlobalScaleform, "DISPLAY_VIEW")
				PushScaleformMovieFunctionParameterInt(1) -- MENU PAGE
				PushScaleformMovieFunctionParameterInt(3) -- INDEX
				PopScaleformMovieFunctionVoid()
				showRadio = false
				Wait(500)
				currentColumn = 0
				currentRow = 1
				currentIndex = 4
				currentApp = 1
				return
			end
		end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if currentApp ~= 5 then
			showRadio = false
		end

		if showRadio then
			local ren = GetMobilePhoneRenderId()
			SetTextRenderId(ren)

			SetScriptGfxDrawOrder(4)
				
			DrawRect(0.5, 0.49, 1.0, 0.8, 30, 30, 30, 255)
			
			drawTxtPhone(0.5, 0.62, 0.45, stationText, 0, 2, 0, 255, 255, 255, 255)
			drawTxtPhone(0.2, 0.8, 0.3, stationTime, 0, 2, 0, 255, 255, 255, 255)
			DrawRect(0.6, 0.85, 0.6, 0.01, 255, 255, 255, 255)
			DrawSprite(stationIcon, stationIcon, 0.5, 0.4, 0.55, 0.4, 0.0, 255, 255, 255, 255)
			DrawRect(0.05, 0.4, 0.1, 0.3, 0, 0, 0, 100)
			DrawRect(0.95, 0.4, 0.1, 0.3, 0, 0, 0, 100)
			

			SetScriptGfxDrawOrder(3)
			SetTextRenderId(GetDefaultScriptRendertargetRenderId())
		end
	end
end)


Citizen.CreateThread(function()
	while true do
		if showRadio then
			local time = math.ceil(GetCurrentRadioTrackPlaybackTime(GetPlayerRadioStationName()) / 1000)
			if math.floor(time % 60) < 10 then
				stationTime = math.floor(time / 60) .. ":0" .. math.floor(time % 60)
			else
				stationTime = math.floor(time / 60) .. ":" .. math.floor(time % 60)
			end
		else
			stationTime = "0:00"
		end
		Citizen.Wait(500)
	end
end)

function GetStationInformation(index)
	local raw = GetRadioStationName(index)
	print(raw)
	if raw == nil or not IsMobilePhoneRadioActive() then
		return "char_property_cinema_morningwood", "Radio Off"
	else
		name = GetLabelText(raw)
		for i,k in ipairs(radioTable) do
			if k[1] == raw then
				loadTextDict(k[2])
				return k[2], name
			end
		end
		return "char_property_cinema_morningwood", name
	end
end