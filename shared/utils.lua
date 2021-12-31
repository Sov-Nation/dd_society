function has_value(tab, val)
	for index, value in pairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

function vectorize(data)
	local length = #data

	if length > 0 then
		if length == 1 then
			data = vec(data[1])
		elseif length == 2 then
			data = vec(data[1], data[2])
		elseif length == 3 then
			data = vec(data[1], data[2], data[3])
		else
			data = vec(data[1], data[2], data[3], data[4])
		end
	else
		if data.w then
			data = vec(data.x, data.y, data.z, data.w)
		elseif data.z then
			data = vec(data.x, data.y, data.z)
		elseif data.y then
			data = vec(data.x, data.y)
		else
			data = vec(data.x)
		end
	end

	return data
end

function colour(colour, str)
	return ('<span style="color: %s;">%s</span>'):format(colour, str)
end

function getName(target)
	return Indexed.Societies[target]?.label or GetResourceKvpString(('%s:name'):format(target))
end