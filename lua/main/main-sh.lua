postals = json.decode(LoadResourceFile(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'postal_sa_file')))
streets_lc = json.decode(LoadResourceFile(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'street_lc_file')))

function table.duplicate(t)
   local t2 = {}
   for k,v in pairs(t) do
      t2[k] = v
   end
   return t2
end

function string.split(inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end

function GetNearestPostal(x, y, z)
        local nd = -1
        local ni = -1
        for i, p in ipairs(postals) do
            	local d = math.sqrt((x - p.x)^2 + (y - p.y)^2) -- pythagorean theorem
            	if nd == -1 or d < nd then
                	ni = i
                	nd = d
            	end
        end
        if ni ~= -1 then
            	nearest = {dist = nd, i = ni}
        end
	return postals[nearest.i].code
end

function GetNearestStreetLC(x, y, z)
	local nd = -1
        local ni = -1
        for i, p in ipairs(streets_lc) do
            	local d = math.sqrt((x - p.x)^2 + (y - p.y)^2) -- pythagorean theorem
            	if nd == -1 or d < nd then
                	ni = i
                	nd = d
            	end
        end

	if ni ~= -1 then
		nearest = {dist = nd, i = ni}
	end
	return streets_lc[nearest.i].street
end


function RotationToDirection(rotation)

  local adjustedRotation =

  {

    x = (math.pi / 180) * rotation.x,

    y = (math.pi / 180) * rotation.y,

    z = (math.pi / 180) * rotation.z

  }

  local direction =

  {

    x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),

    y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),

    z = math.sin(adjustedRotation.x)

  }

  return direction

end

function RayCastGamePlayCamera(distance)

  local cameraRotation = GetGameplayCamRot()

  local cameraCoord = GetGameplayCamCoord()

  local direction = RotationToDirection(cameraRotation)

  local destination =

  {

    x = cameraCoord.x + direction.x * distance,

    y = cameraCoord.y + direction.y * distance,

    z = cameraCoord.z + direction.z * distance

  }

  local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, 27, PlayerPedId(), 0))

  return b, c, e

end