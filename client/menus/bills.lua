RegisterCommand('billsmenu', function()
	ESX.UI.Menu.CloseAll()
	ActionMsg = nil
    billsOpen()
end)

function billsOpen()
	ESX.TriggerServerCallback('dd_society:aGetPlayerBills', function(Bills)
		local elements = {}
		for k, v in pairs(Bills) do
			local label
			if v.time > 1 then
				label = ('<span style="color: green;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [due ' .. v.time .. ' days]')
			elseif v.time == 1 then
				label = ('<span style="color: yellow;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [due ' .. v.time .. ' day]')
			elseif v.time == 0 then
				label = ('<span style="color: orange;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [due]')
			elseif v.time == -1 then
				label = ('<span style="color: red;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [overdue ' .. math.abs(v.time) .. ' day]')
			elseif v.time < -1 then
				label = ('<span style="color: red;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [overdue ' .. math.abs(v.time) .. ' days]')
			end
			table.insert(elements, {
				label = v.target .. ': ' .. label,
				value = v.id
			})
		end
		if not next(elements) then
			elements[1] = {label = 'None'}
		end
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'playerbills', {
			title    = 'Outstanding bills',
			align    = 'bottom-right',
			elements = elements
		}, 
		function(data, menu)
			menu.close()
			ESX.TriggerServerCallback('dd_society:aPayBill', function(cb)
				if cb then
					billsOpen()
				end
			end, data.current.value)
		end, function(data, menu)
			menu.close()
		end)
	end)
end
