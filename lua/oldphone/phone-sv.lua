
RegisterNetEvent('phone_server:receiveMessage')
AddEventHandler('phone_server:receiveMessage', function(receiver, message, fallback)
	if receiver == 0 then
		receiver = fallback
	end
	print(receiver)
	print(message)
	print(fallback)
	TriggerClientEvent('phone:receiveMessage', receiver, GetPlayerNick(source), message, "CHAR_DEFAULT", -1)
	print("message sent")
end)


RegisterNetEvent('phone_server:callRequest')
AddEventHandler('phone_server:callRequest', function(receiver, anon)
	if anon then
		math.randomseed(os.time())
		local phoneNumber = "(555) 404-" .. math.random(1000, 9999)
		TriggerClientEvent('phone:callRequest', receiver, source, phoneNumber)
	else
		TriggerClientEvent('phone:callRequest', receiver, source, GetPlayerNick(source))
	end
end)

RegisterNetEvent('phone_server:callEnd')
AddEventHandler('phone_server:callEnd', function(receiver)
	TriggerClientEvent('phone:callEnd', receiver)
end)

RegisterNetEvent('phone_server:callAnswered')
AddEventHandler('phone_server:callAnswered', function(receiver)
	TriggerClientEvent('phone:callAnswered', receiver)
end)

RegisterNetEvent('callContact')
AddEventHandler('callContact', function(type, location, msg, x, y, z, name)
	TriggerClientEvent('registerCallContact', -1, type, location, msg, x, y, z, name)
end)

-- These were added as a way to identify if anyone had nicked the code for this script and was using it on their server, as well as a way to test the messaging functionality.
copypastaMessages = {
	"I saw Jennifer Adams at a grocery store in Los Santos yesterday. I told her how cool it was to meet her in person, but I didn’t want to be a douche and bother her and ask her for photos or anything. She said, “Oh, like you’re doing now?”~n~I was taken aback, and all I could say was “Huh?” but she kept cutting me off and going “huh? huh? huh?” and closing her hand shut in front of my face. I walked away and continued with my shopping, and I heard her chuckle as I walked off. When I came to pay for my stuff up front I saw her trying to walk out the doors with like fifteen Meteorite bars in her hands without paying. The girl at the counter was very nice about it and professional, and was like “Ma’am, you need to pay for those first.” At first she kept pretending to be tired and not hear her, but eventually turned back around and brought them to the counter. When she took one of the bars and started scanning it multiple times, she stopped her and told her to scan them each individually “to prevent any electrical infetterence,” and then turned around and winked at me. I don’t even think that’s a word. After she scanned each bar and put them in a bag and started to say the price, she kept interrupting her by yawning really loudly.",
	"It’s been 30 minutes without FiveM. I’m having withdrawals. My hands are shaking. I am beginning to form a migraine. I feel like I’ve had a stroke, my brain has lost oxygen. I’m calling for the paramedics to check me out now, because I think my life is over. A gunshot wound like feeling in my chest. I want to sleep until FiveM is back up. FiveM is my life. I quit my life for FiveM. FiveM is love, FiveM is life.",
	"I’ve never told anyone this but I’ve I’m sexually attracted to ambulances. I bought a house next to an EMS station to be closer to the ambulances. Every time they get a call and turn on their lights and sirens, I’m full mast so to speak. One time after a car wreck, the EMTs and paramedics put me in the ambulance. It was better than being inside a woman. Seeing all the medical equipment and laying on the stretcher almost brought me to completion. I get distracted while driving if I see an ambulance on the way to a call. I tried to take an EMT-B class but I couldn’t focus as I was drawing ambulances the entire time thinking about being with them.",
	"LEO. Civilian. FD. Criminal. Long ago, the four nations lived together in harmony. Then, everything changed when the LEO Nation attacked. Only the Chadmin, master of all four elements, could stop them, but when the world needed him most, he vanished.",
	"To heal all injuries, please apply quickclot to the head",
}

RegisterCommand('copypasta', function(source, args, user)
	local message = copypastaMessages[math.random(#copypastaMessages)]

	TriggerClientEvent('phone:receiveMessage', source, "John Bingle", message, "CHAR_DEFAULT", -1)
end)