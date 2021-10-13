function kmOpen()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymaster',{
		title    = 'Keymaster',
		align    = 'top-left',
		elements = {
			{label = 'Societies', value = 'societies'},
			{label = 'Players', value = 'players'},
			{label = 'Properties', value = 'properties'},
		}
	},
	function(data, menu)
		if data.current.value == 'societies' then
			local elements = {}
			for k, v in pairs(Data.Societies) do
				v.props = {}
				for k2, v2 in pairs(Data.Properties) do
					if v.label == v2.owner then
						table.insert(v.props, v2)
					end
				end
				table.insert(elements, {
					label = v.label .. ' - (' .. #v.props .. ')',
					value = v
				})
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymastersocieties',{
				title    = 'Keymaster - Societies',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				elements = {}
				for k, v in pairs(data2.current.value.props) do
					table.insert(elements, {
						label = v.id,
						value = v
					})
				end
				if not next(elements) then
					table.insert(elements, {label = 'None'})
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymastersocietyproperties',{
					title    = 'Keymaster - ' .. data2.current.value.label .. ' - Properties',
					align    = 'top-left',
					elements = elements
				},
				function(data3, menu3)
					if data2.current.value then
						kmProperty(data3.current.value, true)
					end
				end,
				function(data3, menu3)
					menu3.close()
				end)
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'players' then
		elseif data.current.value == 'properties' then
			local elements = {}
			for k, v in pairs(Data.Properties) do
				table.insert(elements, {
					label = v.id .. ' - (' .. v.owner .. ')',
					value = v
				})
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterproperties',{
				title    = 'Keymaster - Properties',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				if data2.current.value then
					kmProperty(data2.current.value, true)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		end
	end,
	function(data, menu)
		menu.close()
	end)
end

function kmProperty(property, km)
	local elements = {
		{label = 'Toggle blip', value = 'blip'},
		{label = 'Owner: ' .. property.owner, value = 'owner'},
		{label = 'New key', value = 'newkey'},
		{label = 'Master', value = {name = 'Master', designation = 0}},
	}
	for k, v in pairs(Data.Keys) do
		if v.property == property.id and v.name ~= 'Master' then
			table.insert(elements, {
				label = v.name .. ' (' .. v.designation .. ')',
				value = v
			})
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterproperty',{
		title    = 'Manage Property - ' .. property.id,
		align    = 'top-left',
		elements = elements
	},
	function(data, menu)
		if data.current.value == 'blip' then
			showBlips(property.id)
		elseif data.current.value == 'owner' and km then
			-- transfer ownership
			-- revoke all keys
		elseif data.current.value == 'newkey' then
			exports.dd_menus:text({
				title = 'Choose a name for the new key, enter text'
			},
			function(datad, menud)
				if datad.value == 'Master' or datad.value == 'master' then
					ESX.ShowNotification('~r~Pick a name other than "' .. datad.value .. '"')
				else
					ESX.TriggerServerCallback('dd_society:pNewKey', function(NewKey)
						menu2.close()
						menu.close()
						kmProperty(property, km)
						ESX.ShowNotification('New key - ~g~' .. NewKey.name .. ' ~w~(~y~' .. NewKey.designation .. '~w~) - created for ~y~' .. property.id)
					end, property.id, datad.value)
				end
			end, false)
		else
			ESX.TriggerServerCallback('dd_society:getPlayers', function(Players)
				local Holders = {}
				for k, v in pairs(Players) do
					if v.dd_keys[property.id] then
						if has_value(v.dd_keys[property.id], data.current.value.designation) then
							table.insert(Holders, v)
						end
					end
				end
				local elements = {
					{label = 'Key holders', value = 'holders'},
					{label = 'Doors', value = 'doors'},
					{label = 'Zones', value = 'zones'},
				}
				if data.current.value ~= 'master' then
					elements[4] = {label = 'Delete Key', value = 'delete'}
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterkey',{
					title = property.id .. ' - ' .. data.current.label,
					align    = 'top-left',
					elements = elements
				},
				function(data2, menu2)
					if data2.current.value == 'holders' then
						local elements = {} --possibly have the option to add a holder here
						for k, v in pairs(Holders) do
							table.insert(elements, {label = v.fullname .. ' [remove]', value = v})
						end
						if not next(elements) then
							elements[1] = {label = 'None'}
						end
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterkeyholders',{
							title    = data.current.label .. ' - Holders',
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							exports.dd_menus:areYouSure({
								title = 'Are you sure that you want to remove ' .. data.current.label .. ' for ' .. property.id .. ' from ' .. data3.current.value.fullname
							},
							function(datad, menud)
								ESX.TriggerServerCallback('dd_society:pRemoveKey', function()
									menu3.close()
									menu2.close()
									menu.close()
									kmProperty(property, km)
									ESX.ShowNotification('~g~' .. data.current.label .. ' ~w~for ~y~' .. property.id .. ' ~r~removed ~w~from ~y~' .. data3.current.value.fullname)
								end, property.id, data.current.value.designation, data3.current.value)
							end, false)
						end,
						function(data3, menu3)
							menu3.close()
						end)
					elseif data2.current.value == 'doors' then
					elseif data2.current.value == 'zones' then
					elseif data2.current.value == 'delete' then
					end
				end,
				function(data2, menu2)
					menu2.close()
				end)
			end)
		end
	end,
	function(data, menu)
		menu.close()
	end)
end
