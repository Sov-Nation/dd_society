local ServerCallback = import 'callbacks'

RegisterCommand('societyMenu', function()
	local close = ESX.UI.Menu.IsOpen('default', resName, 'society')
	ESX.UI.Menu.CloseAll()
	if not close and canInteract() then
		sOpen()
	end
end)

function sOpen()
	local elements = {{label = 'New bill', value = 'newBill'}}
	if PlayerBags.Player.job ~= 'unemployed' then
		elements[2] = {label = 'View society bills', value = 'societyBills'}

		local activePropertyTypes = {}
		for k, v in pairs(GlobalState.PropertyList) do
			for k2, v2 in pairs(v) do
				if k2 ~= 'config' and Indexed.Properties[k2].owner == PlayerBags.Player.job then
					activePropertyTypes[k] = v.config
				end
			end
		end

		local menus = {}
		for k, v in pairs(activePropertyTypes) do
			for k2, v2 in pairs(v.society) do
				menus[k2] = Config.Menus[k2]
			end
		end

		for k, v in pairs(menus) do
			elements[#elements + 1] = v
		end
	end

	ESX.UI.Menu.Open('default', resName, 'society', {
		title    = ('Society Menu - %s'):format(Indexed.Societies[PlayerBags.Player.job].label),
		align    = 'top-left',
		elements = elements
	},
	function(data, menu)
		if data.current.value == 'newBill' then
			ESX.UI.Menu.Open('default', resName, 'payBillTo', {
				title    = 'What kind of bill?',
				align    = 'top-left',
				elements = {
					{label = 'Society', value = 'society'},
					{label = 'Personal', value = 'personal'},
				}
			},
			function(data2, menu2)
				exports.dd_menus:nearbyPlayers({
					title = nil,
					self = false,
					distance = nil
				},
				function(datad, menud)
					exports.dd_menus:amount({
						title = ('Billing %s, enter value'):format(datad.current.name),
						min = 1,
						max = nil
					},
					function(datadd, menudd)
						exports.dd_menus:text({
							title = ('Billing note for %s, enter text (optional)'):format(datad.current.name)
						},
						function(dataddd, menuddd)
							menu2.close()
							local details = dataddd.value
							if not details or details:len() < 1 then
								details = 'Invoice'
							end
							local target = PlayerBags.Player.job
							if data2.current.value == 'personal' then
								target = PlayerBags.Player.ident
							end
							TriggerServerEvent('dd_society:aCreateBill', datad.current.value, datadd.value, target, details)
						end, false)
					end, false)
				end, false)
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'societyBills' then
			ServerCallback.Async('dd_society', 'aGetTargetBills', 100, function(bills)
				local elements = {}
				for i = 1, #bills do
					local label
					local bill = bills[i]
					if bill.time > 1 then
						label = colour('green', ('%s - $%s [due %s days] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.time, bill.playerName))
					elseif bill.time == 1 then
						label = colour('yellow', ('%s - $%s [due 1 day] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.playerName))
					elseif bill.time == 0 then
						label = colour('orange', ('%s - $%s [due] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.playerName))
					elseif bill.time == -1 then
						label = colour('red', ('%s - $%s [overdue 1 day] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.playerName))
					elseif bill.time < -1 then
						label = colour('red', ('%s - $%s [overdue %s days] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), math.abs(bill.time), bill.playerName))
					end
					elements[#elements + 1] = {
						label = label,
						value = bill.id
					}
				end
				if not next(elements) then
					elements[1] = {label = 'None'}
				end
				ESX.UI.Menu.Open('default', resName, 'societyBills', {
					title    = ('%s Bills'):format(Indexed.Societies[PlayerBags.Player.job].label),
					align    = 'top-left',
					elements = elements
				},
				function(data2, menu2)
				end,
				function(data2, menu2)
					menu2.close()
				end)
			end, PlayerBags.Player.job)
		elseif data.current.value == 'keyMaster' then
			kmOpen()
		end
	end,
	function(data, menu)
		menu.close()
	end)
end
