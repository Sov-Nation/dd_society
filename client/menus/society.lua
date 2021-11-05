RegisterCommand('societymenu', function()
	local close = ESX.UI.Menu.IsOpen('default', resName, 'society')
	ESX.UI.Menu.CloseAll()
	if not close and not ESX.PlayerData.dead and not ESX.PlayerData.ko then
		sOpen()
	end
end)

function sOpen()
	local elements = {{label = 'New bill', value = 'newBill'}}
	if ESX.PlayerData.job.label ~= 'Unemployed' then
		local SocietyPropertyTypes = {}
		elements[2] = {label = 'View society bills', value = 'societyBills'}
		for k, v in pairs(Data.Properties) do
			if ESX.PlayerData.job.label == v.owner then
				if not has_value(SocietyPropertyTypes, v.type) then
					table.insert(SocietyPropertyTypes, v.type)
				end
			end
		end

		for k, v in pairs(SocietyPropertyTypes) do
			for k2, v2 in pairs(Config.PropertyTypes[v].sMenu) do
				if not has_value(elements, v2) then
					table.insert(elements, Config.Menus[v2])
				end
			end
		end
	end

	ESX.UI.Menu.Open('default', resName, 'society', {
		title    = 'Society menu - ' .. ESX.PlayerData.job.label,
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
						title = 'Billing ' .. datad.current.name .. ', enter value',
						min = 1,
						max = nil
					},
					function(datadd, menudd)
						exports.dd_menus:text({
							title = 'Billing note for ' .. datad.current.name .. ', enter text (optional)'
						},
						function(dataddd, menuddd)
							menu2.close() 
							local details = dataddd.value
							if not details or string.len(details) < 1 then
								details = 'Invoice'
							end
							local target = ESX.PlayerData.job.label
							if data2.current.value == 'personal' then
								target = GetPlayerServerId(PlayerId())
							end
							TriggerServerEvent('dd_society:aCreateBill', datad.current.value, datadd.value, target, details)
						end, false)
					end, false)
				end, false)
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'societyBills' then
			ESX.TriggerServerCallback('dd_society:aGetTargetBills', function(Bills)
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
					table.insert(elements, {label = v.firstname .. ' ' .. v.lastname .. ': ' .. label})
				end
				if not next(elements) then
					elements[1] = {label = 'None'}
				end
				ESX.UI.Menu.Open('default', resName, 'societyBills', {
					title    = ESX.PlayerData.job.label .. ' bills',
					align    = 'top-left',
					elements = elements
				},
				function(data2, menu2)
				end, function(data2, menu2)
					menu2.close()
				end)
			end, ESX.PlayerData.job.label)
		elseif data.current.value == 'keyMaster' then
			kmOpen()
		end
	end,
	function(data, menu)
		menu.close()
	end)
end
