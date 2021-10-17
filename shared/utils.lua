function has_value(tab, val)
	for index, value in pairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

function vectorize(data)
	if #data == 4 then
		heading = data[4]
	end

	if #data == 1 then
		data = vec(data[1])
	elseif #data == 2 then
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

function cSpan(colour, b, a, c)
	local str = string.strconcat('<span style="color: ', colour, ';">', b, '</span>')

	if a then
		str = string.strconcat(a, ': ', str)
	end

	if c then
		str = string.strconcat(str, ' ', c)
	end

	return str
end