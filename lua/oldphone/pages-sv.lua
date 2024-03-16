adverts = {}

advCount = 0
adId = 0


RegisterServerEvent("addAdvert", id, title, message)
AddEventHandler("addAdvert", function(id, title, message)
	table.insert(adverts, {id, title, message, adId, GetPlayerNick(id)})
	adId = adId + 1
	TriggerClientEvent("newAdvert", -1, title, message)
end)

RegisterServerEvent("deleteAdvert", advertId)
AddEventHandler("deleteAdvert", function(advertId)
	advCount = #adverts
	for i = advCount, 1, -1 do
		if advertId == adverts[i][4] then
			table.remove(adverts, i)
		end
	end
end)


RegisterServerEvent("requestAdverts")
AddEventHandler("requestAdverts", function()
	advCount = #adverts
	for i = advCount, 1, -1 do
		if not GetPlayerName(adverts[i][1]) then
			table.remove(adverts, i)
		end
	end
	TriggerClientEvent("syncAdverts", source, adverts)
end)

RegisterNetEvent("GetAdvertsOnSpawn")
AddEventHandler("GetAdvertsOnSpawn", function()
	for i = advCount, 1, -1 do
		if not GetPlayerName(adverts[i][1]) then
			table.remove(adverts, i)
		end
	end

	for _, ad in ipairs(adverts) do
		TriggerClientEvent("newAdvert", source, ad[2], ad[3])
	end
end)
