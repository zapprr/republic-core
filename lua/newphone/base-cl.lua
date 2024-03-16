-- Developmental code for an overhaul of the in-game phone system, focusing more on drawables than scaleforms, but still using the built-in phone scaleforms. Intended to provide a more modern UI.


local PhoneOpen = false
local CurrentApp = nil
local CurrentOverlay = nil

local BackspaceCounter = 0

RegisterCommand('devphone', function(source, args, user)
	if #args > 0 then
		OpenPhone(tonumber(args[1]))
	else
		OpenPhone(1)
	end
end)


function OpenPhone(type)
	showPlayerlist = false

    	SetMobilePhonePosition(Floatify(55),Floatify(-22),Floatify(-60))
    	SetMobilePhoneRotation(Floatify(-90),Floatify(0),Floatify(0))
    	SetMobilePhoneScale(Floatify(280))

	CreateMobilePhone(type)

	PhoneOpen = true

	SetPedConfigFlag(PlayerPedId(), 242, not true)
	SetPedConfigFlag(PlayerPedId(), 243, not true)
	SetPedConfigFlag(PlayerPedId(), 244, true)

	N_0x83a169eabcdb10a2(PlayerPedId(), 2)

	while PhoneOpen do
		Citizen.Wait(0)

		if GetFollowPedCamViewMode() == 4 then
			SetMobilePhoneScale(Floatify(0))
		else
			SetMobilePhoneScale(Floatify(350))
		end

		local ren = GetMobilePhoneRenderId()
		SetTextRenderId(ren)

		DrawRect(0.5, 0.5, 1.0, 1.0, 128, 128, 128, 255)

		DrawRect(0.5, 0.03, 1.0, 0.06, 0, 0, 0, 255)
		WriteText(0.5, 0.0, 0.3, "CURRENT_TIME", 0, 0, nil, true, false, true, 255, 255, 255, 255)

		for i=0, 14 do
			WriteText(0.05, 0.1 + (0.04 * i), 0.25, "ABCDEFG - " .. i, i, 0, 0.8, false, false, true, 255, 255, 255, 255)
		end

		for i= 15, 28  do
			WriteText(0.5, 0.1 + (0.04 * (i - 14)), 0.25, "ABCDEFG - " .. i, i, 0, 0.8, false, false, true, 255, 255, 255, 255)
		end

		--[[SetScriptGfxDrawOrder(5)

		DrawRect(0.5, 0.5, 0.4, 0.2, 0, 0, 0, 200)
		WriteText(0.5, 0.5, 0.3, "Example Popup", 0, 0, nil, false, false, true, 255, 255, 255, 255)

		SetScriptGfxDrawOrder(4)]]

		SetTextRenderId(GetDefaultScriptRendertargetRenderId())


		-- Basically a way to force close the phone by holding down backspace
		if BackspaceCounter > 5 then
			PhoneOpen = false
		end

		if IsControlJustReleased(0, 177) then
			-- If there's an overlay currently open, close that
			-- Otherwise, if there's no apps open, close the phone

			if CurrentOverlay then
				CurrentOverlay = nil
			elseif not CurrentApp then
				PhoneOpen = false
			end
		end
	end

	DestroyMobilePhone()
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		if IsControlPressed(0, 177) and PhoneOpen then
			BackspaceCounter = BackspaceCounter + 1
		else
			BackspaceCounter = 0
		end
	end
end)