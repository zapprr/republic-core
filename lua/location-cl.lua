-- I was working on a new location system that would allow locations to be defined as polygons, instead of the series of rectangles they currently are.
-- It was a massive headache, but I think it's got legs. For now, locations are based on the in-game location things, with some bodges for areas like Harmony.

function GetAreaFromCoords(x, y)

	for _, item in ipairs(AreaDefinitions) do

		if not item.upperX then
			item.points = {}
			for _, item2 in ipairs(item.configpoints) do
				table.insert(item.points, AreaPoints[item2])
			end

			item.upperX = item.points[1].x
			item.upperY = item.points[1].y
			item.lowerX = item.points[1].x
			item.lowerY = item.points[1].y

			for _, item2 in ipairs(item.points) do
				if item2.x > item.upperX then
					item.upperX = item2.x
				end
				if item2.x < item.lowerX then
					item.lowerX = item2.x
				end
				if item2.y > item.upperY then
					item.upperY = item2.y
				end
				if item2.y < item.lowerY then
					item.lowerY = item2.y
				end
			end
		end
					

		-- We can save a lot of time by checking if the point is close to the
		-- area we're checking before finding out if it's exactly in bounds

		if x < item.upperX and x > item.lowerX and y < item.upperY and y > item.lowerY then

			if IsPointInBounds(x, y, item.points) then
				return item.area, item.region
			end
		end
	end
	return "None", "None"
end

function IsPointInBounds(x, y, polygon)
    local oddNodes = false
    local j = #polygon
    for i = 1, #polygon do
        if (polygon[i].y < y and polygon[j].y >= y or polygon[j].y < y and polygon[i].y >= y) then
            if (polygon[i].x + ( y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < x) then
                oddNodes = not oddNodes;
            end
        end
        j = i;
    end
    return oddNodes 
end

