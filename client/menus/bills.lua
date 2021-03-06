local ServerCallback = import 'callbacks'

RegisterCommand('billsMenu', function()
	local close = ESX.UI.Menu.IsOpen('default', resName, 'playerBills')
	ESX.UI.Menu.CloseAll()
	if not close and canInteract() then
		billsOpen()
	end
end)

function billsOpen()
	ServerCallback.Async('dd_society', 'aGetPlayerBills', 100, function(bills)
		local elements = {}
		for i = 1, #bills do
			local label
			local bill = bills[i]
			if bill.time > 1 then
				label = colour('green', ('%s - $%s [due %s days] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.time, bill.targetName))
			elseif bill.time == 1 then
				label = colour('yellow', ('%s - $%s [due 1 day] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.targetName))
			elseif bill.time == 0 then
				label = colour('orange', ('%s - $%s [due] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.targetName))
			elseif bill.time == -1 then
				label = colour('red', ('%s - $%s [overdue 1 day] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.targetName))
			elseif bill.time < -1 then
				label = colour('red', ('%s - $%s [overdue %s days] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), math.abs(bill.time), bill.targetName))
			end
			elements[#elements + 1] = {
				label = label,
				value = bill.id
			}
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
				ServerCallback.Async('dd_society', 'aPayBill', 100, function(cb)
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
