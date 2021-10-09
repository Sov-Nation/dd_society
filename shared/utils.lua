function has_value(tab, val)
	for index, value in pairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

function vectorize(data)
	local n = #data

	if n == 4 then
		heading = data[4]
	end

	if n == 1 then
		data = vec(data[1])
	elseif n == 2 then
		data = vec(data[1], data[2])
	else
		data = vec(data[1], data[2], data[3])
	end

	return data, heading
end

function sipairs(Tab)
	local TempTab = {}
	local i, _ = next(Tab)
	while i do
		TempTab[#TempTab+1] = i
		i, _ = next(Tab, i)
	end
	table.sort(TempTab)
	local j = 1

	return function()
	local i = TempTab[j]
		j = j + 1
		if i then
		   return i, Tab[i]
		end
	end
end