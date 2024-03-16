-- Advanced prop spawning menu :)

propMenu = NativeUI.CreateMenu("Prop Spawner", "", 0, 0, "nativeui_headers", "header_misc")
_menuPool:Add(propMenu)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if propMenu:Visible() and devmode then
			EnableCrosshairThisFrame()
		end
	end
end)


function CreatePropMenu(menu)
	local deletebutton = NativeUI.CreateItem("Delete Nearest Object", "Delete nearest object.")
	menu:AddItem(deletebutton)

	for i, item in ipairs(PropConfig) do
		item.menu = _menuPool:AddSubMenu(menu, item.categoryName, item.description, "nativeui_headers", "misc_header")
		for j, subitem in ipairs(item.components) do
			subitem.menu = NativeUI.CreateItem(subitem.name, "Spawn this item in front of you")
			item.menu.SubMenu:AddItem(subitem.menu)
		end
	end

	deletebutton.Activated = function(sender, item, index)
		local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
		for _, item in ipairs(PropConfig) do
			for _, item2 in ipairs(item.components) do
				local hash = GetHashKey(item2.spawn)
				if DoesObjectOfTypeExistAtCoords(x, y, z, 0.9, hash, true) then
					local spawn = GetClosestObjectOfType(x, y, z, 0.9, hash, false, false, false)
					DeleteObject(spawn)
					break
				end
			end
		end
	end

	for i, prop in ipairs(PropConfig) do
		prop.menu.SubMenu.OnItemSelect = function(sender, item, checked_)
			print("Thing clicked!")
			for j, item2 in ipairs(prop.components) do
				if item2.menu == item then
					SpawnProp(item2.spawn)
				end
			end
		end
	end
end

function SpawnProp(objectname)
	if devmode then
		local hit, coords, entity = RayCastGamePlayCamera(1000.0)
		local heading = GetGameplayCamRelativeHeading()

		local playercoords = GetEntityCoords(GetPlayerPed(-1), true)

		if GetDistanceBetweenCoords(coords, playercoords, true) < 10.0 then
			RequestModel(objectname)
			while not HasModelLoaded(objectname) do
				Citizen.Wait(10)
			end

			local obj = CreateObject(GetHashKey(objectname), coords.x, coords.y, coords.z, true, false)
			PlaceObjectOnGroundProperly(obj)
			SetEntityHeading(obj, heading)
			FreezeEntityPosition(obj, true)
		end
	else

		local Player = GetPlayerPed(-1)
		local heading = GetEntityHeading(Player)
		local x, y, z = table.unpack(GetEntityCoords(Player, true))

		RequestModel(objectname)
		while not HasModelLoaded(objectname) do
			Citizen.Wait(10)
		end
		local obj = CreateObject(GetHashKey(objectname), x, y, z, true, false)
		PlaceObjectOnGroundProperly(obj)
		SetEntityHeading(obj, heading)
		FreezeEntityPosition(obj, true)

	end
end


RegisterCommand("prop", function(source, args, rawCommand)
	propMenu:Visible(not propMenu:Visible())
end, false)