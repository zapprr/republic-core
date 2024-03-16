-- Character Creator Menu
--characterMenu = NativeUI.CreateMenu("Characters", "", 0, 0, "nativeui_headers", "header_misc")
--_menuPool:Add(characterMenu)

-- Developmental code for an overhaul to the character creation system. Someone'll have to figure out databases - lord knows I haven't been able to.

-- This is used for visually displaying the character menu
characterMenuTemplate =
{
	{name = "Name", description = "The full name of your character", options = "text", default = "Default Danny"},
	{name = "Date of Birth", description = "The date of birth of your character, in the format YYYY/MM/DD", options = "text", default = nil},
	{name = "Address", description = "The current address of your character, including the postal and street name", options = "text", default = nil},
	{name = "Gender", description = "Your character\'s legally defined gender", options = {"Male", "Female", "Other/Prefer Not To Say"}, default = 3},

	{categoryName = "Appearance...", components = {
		{name = "Hair Color", description = "Your character\'s hair color", options = {"Black", "Blonde", "Brown", "Red", "Grey"}, default = 3},
		{name = "Eye Color", description = "Your character\'s eye color", options = {"Black", "Blue", "Brown", "Green", "Hazel"}, default = 3},
		{name = "Height", description = "Your character\'s height in feet/inches", options = {"5\'0\"", "5\'1\"", "5\'2\"", "5\'3\"", "5\'4\"", "5\'5\"", "5\'6\"", "5\'7\"", "5\'8\"", "5\'9\"", "5\'10\"", "5\'11\"", "6\'0\"", "6\'1\"", "6\'2\"", "6\'3\"", "6\'4\""}, default = 10},
		{name = "Height", description = "Your character\'s weight in pounds, rounded to the nearest 10", options = {"100 lbs", "110 lbs", "120 lbs", "130 lbs", "140 lbs", "150 lbs", "160 lbs", "170 lbs", "180 lbs", "190 lbs", "200 lbs", "210 lbs", "220 lbs", "230 lbs", "240 lbs", "250 lbs", "260 lbs", "270 lbs", "280 lbs"}, default = 8},
		
	}},
	{categoryName = "Licences...", components = {
		{name = "Driver\'s Licence", description = "Your character\'s driver licence status", options = {"Valid", "Expired", "Suspended", "Revoked", "None"}, default = 1},
		{name = "Commercial D. Licence", description = "Your character\'s driver licence status", options = {"Valid", "Expired", "Suspended", "Revoked", "None"}, default = 5},
		{name = "Boating Licence", description = "Your character\'s driver licence status", options = {"Valid", "Expired", "Suspended", "Revoked", "None"}, default = 5},
		{name = "Pilot\'s Licence", description = "Your character\'s driver licence status", options = {"Valid", "Expired", "Suspended", "Revoked", "None"}, default = 5},
		{name = "CCWP", description = "Your character\'s concealed carry weapon permit status", options = {"Valid", "Expired", "Suspended", "Revoked", "None"}, default = 5},
		{name = "Hunting Licence", description = "Your character\'s hunting licence status", options = {"Valid", "Expired", "Suspended", "Revoked", "None"}, default = 5},
		{name = "Fishing Licence", description = "Your character\'s hunting licence status", options = {"Valid", "Expired", "Suspended", "Revoked", "None"}, default = 5},
	}},
}

-- This is used for storing character information
currentCharacter = {}

function CreateCharacterMenu(menu)

	for i, item in ipairs(characterMenuTemplate) do
		if item.components then
			item.menu = _menuPool:AddSubMenu(menu, item.categoryName)
			for j, subitem in ipairs(item.components) do
				subitem.menu = NativeUI.CreateListItem(subitem.name, subitem.options, GetCharacterInformation(subitem.name), subitem.description)
				item.menu.SubMenu:AddItem(subitem.menu)
			end
		else
			if item.options == "text" then
				item.menu = NativeUI.CreateItem(item.name, item.description)
				menu:AddItem(item.menu)
				item.menu:RightLabel(GetCharacterInformation(item.name))

			elseif item.options == "checkbox" then

			else
				item.menu = NativeUI.CreateListItem(item.name, item.options, GetCharacterInformation(item.name), item.description)
				menu:AddItem(item.menu)
			end
		end
	end

	local saveButton = NativeUI.CreateItem("Save Character", "Save your current character\'s details")
	menu:AddItem(saveButton)
	saveButton:SetRightBadge(BadgeStyle.Tick)

	menu.OnItemSelect = function(sender, item, index)
		if item == saveButton then
			if IsCharacterValid(currentCharacter) then
				local name = GetCharacterInformation("Name")
				TriggerServerEvent("SetCharacterName", name)
				SetResourceKvp("SAR-CORE:CHARACTER:" .. name, json.encode(currentCharacter))
				characterMenu:Visible(false)
			end
		else
			for _, x in ipairs(characterMenuTemplate) do
				if x.options == "text" and x.menu == item then
					print(x.item)
				end
			end
		end
	end
end


RegisterCommand('character', function(source, args, user)
	if #args > 0 and player.staff then
		local character = table.concat(args, " ")
		if GetResourceKvpString("SAR-CORE:CHARACTER:" .. character) then
			currentCharacter = json.decode(GetResourceKvpString("SAR-CORE:CHARACTER:" .. character))
			TriggerServerEvent("SetCharacterName", GetCharacterInformation("Name"))
		else
			currentCharacter = {}
			for _, item in ipairs(characterMenuTemplate) do
				if item.name then
					if item.name == "Name" and character then
						table.insert(currentCharacter, {item.name, character})
					elseif item.name == "Gender" and GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
						table.insert(currentCharacter, {item.name, 1})
					elseif item.name == "Gender" and GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
						table.insert(currentCharacter, {item.name, 2})
					else
						table.insert(currentCharacter, {item.name, item.default})
					end
				elseif item.categoryName then
					for _, item2 in ipairs(item.components) do
						table.insert(currentCharacter, {item2.name, item2.default})
					end
				end
			end

			characterMenu = NativeUI.CreateMenu("Characters", "", 0, 0, "nativeui_headers", "header_misc")
			_menuPool:Add(characterMenu)
			CreateCharacterMenu(characterMenu)

			_menuPool:RefreshIndex()

			characterMenu:Visible(not characterMenu:Visible())
		end
	end
end, false)

function GetCharacterInformation(search)
	found = false
	for _, item in ipairs(currentCharacter) do
		if item[1] == search then
			found = true
			return item[2]
		end
	end
	if not found then
		return nil
	end
end

function IsCharacterValid(character)
	local valid = true
	local rejectionReason = nil

	for _, item in ipairs(character) do
		if item[1] == "Name" then
			if (string.upper(item[2]) == item[2] or string.lower(item[2]) == item[2]) then
				valid = false
				rejectionReason = "Your character\'s name must be properly capitalised"
			elseif string.find(string.lower(item[2]), "bingle") and not player.staff then
				valid = false
				rejectionReason = "You are not allowed to use the name \'Bingle\' in your character\'s name"
			elseif #(string.split(item[2], " ")) < 2 then
				valid = false
				rejectionReason = "You must have at least a first name and a last name"
			end
		end
	end

	if rejectionReason then
		ShowNotification(rejectionReason)
	end

	return valid
end

function IsDateValid(str)
  -- perhaps some sanity checks to see if `str` really is a date
  local y, m, d = str:match("(%d+)/(%d+)/(%d+)")

  m, d, y = tonumber(m), tonumber(d), tonumber(y)

  if d < 0 or d > 31 or m < 0 or m > 12 or y < 0 then
    -- Cases that don't make sense
    return false
  elseif m == 4 or m == 6 or m == 9 or m == 11 then 
    -- Apr, Jun, Sep, Nov can have at most 30 days
    return d <= 30
  elseif m == 2 then
    -- Feb
    if y%400 == 0 or (y%100 ~= 0 and y%4 == 0) then
      -- if leap year, days can be at most 29
      return d <= 29
    else
      -- else 28 days is the max
      return d <= 28
    end
  else 
    -- all other months can have at most 31 days
    return d <= 31
  end

end