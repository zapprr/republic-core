--[[
	Wiwang MDT
	Created by Jennifer Adams for Republic Core
]]


mdtState = {
	"Outstanding",
	"Assigned",
	"On Scene",
	"Resolved",
}

function CompareStateScores(old, new)
	oldScore = 0
	newScore = 0
	for i, item in ipairs(mdtState) do
		if old == item then
			oldScore = i
		end
		if new == item then
			newScore = i
		end
	end
	print(newScore)
	print(oldScore)
	if newScore > oldScore then
		return true
	else
		return false
	end
end


function GetStatusCode(status)
	for _, item in ipairs(mdtStatusCodes) do
		if status == item[1] then
			return item[2]
		elseif status == item[2] then
			return item[1]
		end
	end
	return -1
end

RegisterServerEvent("mdt:SetCallState")
AddEventHandler("mdt:SetCallState", function(incidentNumberRequest, state)
	for _, item in ipairs(emergencyCallList) do
		if incidentNumberRequest == item.incidentNumber then
			print("Found call, updating state")
			if CompareStateScores(item.state, state) then
				item.state = state
				Citizen.Wait(1000)
				TriggerClientEvent("mdt:setSpecificCallInformation", -1, incidentNumberRequest, state)
			end
		end
	end
end)

RegisterServerEvent("mdt:SetStatus")
AddEventHandler("mdt:SetStatus", function(callsign, newstatus, incidentNumberRequest)

	for _, player in ipairs(players) do
		if player.callsign == callsign then
			player.status = newstatus
			player.incident = incidentNumberRequest
		end
	end

end)

RegisterServerEvent("mdt:GetEmergencyCall", incidentNumberRequest)
AddEventHandler("mdt:GetEmergencyCall", function(incidentNumberRequest)

	incidentNumberSearch = incidentNumberRequest or incidentNumber
	found = false

	for _, item in ipairs(emergencyCallList) do
		if incidentNumberSearch == item.incidentNumber then
			TriggerClientEvent("mdt:setCallInformation", source, item)
			found = true
		end
	end
	if #emergencyCallList == 0 then
		TriggerClientEvent("mdt:setCallInformation", source)
	elseif not found then
		TriggerClientEvent("mdt:setCallInformation", source, emergencyCallList[#emergencyCallList])
	end
end)

RegisterServerEvent("mdt:SetNotes", incidentNumberSearch, mdtNote)
AddEventHandler("mdt:SetNotes", function(incidentNumberSearch, mdtNote)
	for _, item in ipairs(emergencyCallList) do
		if incidentNumberSearch == item.incidentNumber then
			item.notes = mdtNote
			TriggerClientEvent("mdt:setSpecificCallInformation", -1, incidentNumberSearch, -1, mdtNote)
		end
	end
end)