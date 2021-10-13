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
					elements[1] = {label = 'None'}
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymastersocietyproperties',{
					title    = 'Keymaster - ' .. data2.current.value.label .. ' - Properties',
					align    = 'top-left',
					elements = elements
				},
				function(data3, menu3)
					if data3.current.value then
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
			local Players = {}
			for k, v in pairs(Data.Properties) do
				if not Data.Societies[v.owner] then
					if not Players[v.owner] then
						Players[v.owner] = 1
					else
						Players[v.owner] += 1
					end
				end
			end
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
		{label = 'Doors', value = 'doors'},
		{label = 'Zones', value = 'zones'},
		{label = 'New key', value = 'newkey'},
		{label = 'Master', value = {name = 'Master', designation = 0}},
	}
	while not next(Data.Keys) do
		Wait(100)
	end
	for k, v in pairs(Data.Keys) do
		if v.property == property.id and v.name ~= 'Master' then
			table.insert(elements, {
				label = v.name .. ' - (' .. v.designation .. ')',
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
		elseif data.current.value == 'doors' then
		elseif data.current.value == 'zones' then
		elseif data.current.value == 'newkey' then
			exports.dd_menus:text({
				title = 'Choose a name for the new key, enter text'
			},
			function(datad, menud)
				if datad.value == 'Master' or datad.value == 'master' then
					ESX.ShowNotification('~r~Pick a name other than "' .. datad.value .. '"')
				else
					ESX.TriggerServerCallback('dd_society:pNewKey', function(NewKey)
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
				if data.current.value.name ~= 'Master' then
					elements[4] = {label = 'Rename', value = 'rename'}
					elements[5] = {label = 'Delete Key', value = 'delete'}
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterkey',{
					title    = property.id .. ' - ' .. data.current.label,
					align    = 'top-left',
					elements = elements
				},
				function(data2, menu2)
					if data2.current.value == 'holders' then
						local elements = {
							{label = 'Add holder', value = 'add'}
						}
						for k, v in pairs(Holders) do
							table.insert(elements, {label = v.fullname .. ' [remove]', value = v})
						end
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterkeyholders',{
							title    = property.id .. ' - ' .. data.current.label .. ' - Holders',
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							if data3.current.value == 'add' then
								exports.dd_menus:nearbyPlayers({
									title = nil,
									self = true,
									distance = nil
								},
								function(datad, menud)
									local Player
									for k, v in pairs(Players) do
										if datad.current.identifier == v.identifier then
											Player = v
										end
									end
									ESX.TriggerServerCallback('dd_society:pAddKey', function(valid)
										menu3.close()
										menu2.close()
										menu.close()
										kmProperty(property, km)
										if valid then
											ESX.ShowNotification('~g~' .. data.current.label .. ' ~w~for ~y~' .. property.id .. ' ~g~added ~w~to ~y~' .. datad.current.value.fullname)
										else
											ESX.ShowNotification('~y~' .. datad.current.name .. ' ~w~already has this key')
										end
									end, property.id, data.current.value.designation, Player)
								end, false)
							else
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
							end
						end,
						function(data3, menu3)
							menu3.close()
						end)
					elseif data2.current.value == 'doors' then
						local elements = {}
						for k, v in pairs(Data.Doors) do
							if v.property == property.id then
								if data.current.value.name == 'Master' then
									table.insert(elements, {
										label = v.name .. ' (' .. v.id .. ')',
										value = v
									})
								elseif has_value(data.current.value.exempt_doors, v.id) then
									table.insert(elements, {
										label = v.name .. ' - (' .. v.id .. ') [add]',
										value = v,
										action = 'add'
									})
								else
									table.insert(elements, {
										label = v.name .. ' - (' .. v.id .. ') [remove]',
										value = v,
										action = 'remove'
									})
								end
							end
						end
						if not next(elements) then
							elements[1] = {label = 'None'}
						end
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterkeydoors',{
							title    = property.id .. ' - ' .. data.current.label .. ' - Doors',
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							if data3.current.action then
								ESX.TriggerServerCallback('dd_society:pToggleKeyExemption', function(valid)
									menu3.close()
									menu2.close()
									menu.close()
									kmProperty(property, km)
									if valid then
										if data3.current.action == 'add' then
											ESX.ShowNotification('~y~' .. data3.current.value.name  .. ' ~w~- (' .. data3.current.value.id .. ')' .. ' has been ~g~added ~w~to ~y~' .. data.current.value.name .. ' ~w~- (' .. data.current.value.id .. ')')
										elseif data3.current.action == 'remove' then
											ESX.ShowNotification('~y~' .. data3.current.value.name  .. ' ~w~- (' .. data3.current.value.id .. ')' .. ' has been ~r~removed ~w~from ~y~' .. data.current.value.name .. ' ~w~- (' .. data.current.value.id .. ')')
										end
									else
										ESX.ShowNotification('~r~You cannot edit the Master key')
									end
								end, data.current.value, data3.current.value.id, Holders, 'exempt_doors')
							end
						end,
						function(data3, menu3)
							menu3.close()
						end)
					elseif data2.current.value == 'zones' then
						local elements = {}
						for k, v in pairs(Data.Zones) do
							if v.property == property.id then
								if data.current.value.name == 'Master' then
									table.insert(elements, {
										label = v.name .. ' (' .. v.id .. ') [edit]',
										value = v
									})
								elseif has_value(data.current.value.exempt_zones, v.id) then
									table.insert(elements, {
										label = v.name .. ' - (' .. v.id .. ') [add]',
										value = v,
										action = 'add'
									})
								else
									table.insert(elements, {
										label = v.name .. ' - (' .. v.id .. ') [remove]',
										value = v,
										action = 'remove'
									})
								end
							end
						end
						if not next(elements) then
							elements[1] = {label = 'None'}
						end
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterkeyzones',{
							title    = property.id .. ' - ' .. data.current.label .. ' - Zones',
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							if data3.current.action == 'edit' then
							else
								ESX.TriggerServerCallback('dd_society:pToggleKeyExemption', function(valid)
									menu3.close()
									menu2.close()
									menu.close()
									kmProperty(property, km)
									if valid then
										if data3.current.action == 'add' then
											ESX.ShowNotification('~y~' .. data3.current.value.name  .. ' ~w~- (' .. data3.current.value.id .. ')' .. ' has been ~g~added ~w~to ~y~' .. data.current.value.name .. ' ~w~- (' .. data.current.value.id .. ')')
										elseif data3.current.action == 'remove' then
											ESX.ShowNotification('~y~' .. data3.current.value.name  .. ' ~w~- (' .. data3.current.value.id .. ')' .. ' has been ~r~removed ~w~from ~y~' .. data.current.value.name .. ' ~w~- (' .. data.current.value.id .. ')')
										end
									else
										ESX.ShowNotification('~r~You cannot edit the Master key')
									end
								end, data.current.value, data3.current.value.id, Holders, 'exempt_zones')
							end
						end,
						function(data3, menu3)
							menu3.close()
						end)
					elseif data2.current.value == 'rename' then
						exports.dd_menus:text({
							title = 'New key name, enter text'
						},
						function(datad, menud)
							if datad.value and string.len(datad.value) > 1 then
								ESX.TriggerServerCallback('dd_society:pRenameKey', function()
									menu2.close()
									menu.close()
									kmProperty(property, km)
									ESX.ShowNotification('Key renamed to ~g~' .. datad.value )
								end, data.current.value.id, datad.value)
							else
								ESX.ShowNotification('~r~Key name cannot be empty')
							end
						end, false)
					elseif data2.current.value == 'delete' then
						exports.dd_menus:areYouSure({
							title = 'Are you sure that you want to delete ' .. data.current.label .. ' for ' .. property.id .. '?'
						},
						function(datad, menud)
							ESX.TriggerServerCallback('dd_society:pDeleteKey', function(valid)
								if valid then
									menu2.close()
									menu.close()
									kmProperty(property, km)
									ESX.ShowNotification('~g~' .. data.current.label .. ' ~w~for ~y~' .. property.id .. ' ~r~deleted')
								else
									ESX.ShowNotification('~r~You cannot delete the Master key')
								end
							end, data.current.value, Holders)
						end, false)
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
