RegisterCommand('billsMenu', function()
	local close = ESX.UI.Menu.IsOpen('default', resName, 'playerBills')
	ESX.UI.Menu.CloseAll()
	if not close and not ESX.PlayerData.dead and not ESX.PlayerData.ko then
		billsOpen()
	end
end)

function billsOpen()
	ESX.TriggerServerCallback('dd_society:aGetPlayerBills', function(Bills)
		local elements = {}
		for k, v in pairs(Bills) do
			local label
			if v.time > 1 then
				label = cSpan('green', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [due ', v.time, ' days]'), v.target)
			elseif v.time == 1 then
				label = cSpan('yellow', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [due ', v.time, ' day]'), v.target)
			elseif v.time == 0 then
				label = cSpan('orange', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [due]'), v.target)
			elseif v.time == -1 then
				label = cSpan('red', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [overdue ', math.abs(v.time), ' day]'), v.target)
			elseif v.time < -1 then
				label = cSpan('red', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [overdue ', math.abs(v.time), ' days]'), v.target)
			end
			table.insert(elements, {
				label = label,
				value = v.id
			})
		end
		if not next(elements) then
			elements[1] = {label = 'None'}
		end
		ESX.UI.Menu.Open('default', resName, 'playerBills', {
			title    = 'Outstanding bills',
			align    = 'bottom-right',
			elements = elements
		},
		function(data, menu)
			menu.close()
			if data.current.value then
				ESX.TriggerServerCallback('dd_society:aPayBill', function(cb)
					if cb then
						billsOpen()
					end
				end, data.current.value)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end
