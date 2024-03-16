bleets = {} -- All Bleets will go here

Citizen.CreateThread(function()
	local content = LoadResourceFile(GetCurrentResourceName(), "bleets.json")
	if not content then
		SaveResourceFile(GetCurrentResourceName(), "bleets.json", json.encode({}), -1)
		content = json.encode({})
	end

	bleets = json.decode(content)
end)

RegisterServerEvent("bleetSent", message, handle, icon, verified, user)
AddEventHandler("bleetSent", function(message, handle, icon, verified, user)

	table.insert(bleets, 1, {handle = handle, message = message, icon = icon, verified = verified})
	if #bleets > 1000 then
		table.remove(bleets)
	end

	SaveResourceFile(GetCurrentResourceName(), "bleets.json", json.encode(bleets, {indent = true}), -1)

	TriggerClientEvent('bleetReceived', -1, handle, message, icon)
end)

RegisterServerEvent("getInitialBleets")
AddEventHandler("getInitialBleets", function()
	TriggerClientEvent('setInitialBleets', source, bleets)
end)