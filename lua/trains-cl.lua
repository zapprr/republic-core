
Citizen.CreateThread(function()

	if trainsEnabled then
    		SwitchTrainTrack(3, true)
    		N_0x21973bbf8d17edfa(3, 120000)
    		SetRandomTrains(true)
	else
    		SwitchTrainTrack(3, false)
    		N_0x21973bbf8d17edfa(3, 120000)
    		SetRandomTrains(false)
	end
end)
