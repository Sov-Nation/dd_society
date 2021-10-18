function kmOpen()
	dataReady()
	ESX.UI.Menu.Open('default', resName, 'keyMaster',{
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
			ESX.UI.Menu.Open('default', resName, 'keymasterSocieties',{
				title    = 'Keymaster - Societies',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				local elements = {}
				for k, v in pairs(data2.current.value.props) do
					table.insert(elements, {
						label = v.id,
						value = v
					})
				end
				if not next(elements) then
					elements[1] = {label = 'None'}
				end
				ESX.UI.Menu.Open('default', resName, 'keymasterSocietyProperties',{
					title    = string.strjoin(' - ', 'Keymaster', data2.current.value.label, 'Properties'),
					align    = 'top-left',
					elements = elements
				},
				function(data3, menu3)
					if data3.current.value then
						kmProperty(data3.current.value)
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
			local elements = {}
			local Players = {}
			for k, v in pairs(Data.Properties) do
				if not Data.Societies[v.owner] then
					if not Players[v.owner] then
						Players[v.owner] = {
							owner = v.owner,
							ownername = v.ownername,
							props = {v}
						}
					else
						table.insert(Players[v.owner].props, v)
					end
				end
			end
			for k, v in pairs(Players) do
				table.insert(elements, {
					label = v.ownername .. ' - (' .. #v.props .. ')',
					value = v
				})
			end
			if not next(elements) then
				elements[1] = {label = 'None'}
			end
			ESX.UI.Menu.Open('default', resName, 'keymasterPlayers',{
				title    = 'Keymaster - Players',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				if data2.current.value then
					local elements = {}
					for k, v in pairs(data2.current.value.props) do
						table.insert(elements, {
							label = v.id,
							value = v
						})
					end
					ESX.UI.Menu.Open('default', resName, 'keymasterPlayerProperties',{
						title    = string.strjoin(' - ', 'Keymaster', data2.current.value.ownername, 'Properties'),
						align    = 'top-left',
						elements = elements
					},
					function(data3, menu3)
						if data3.current.value then
							kmProperty(data3.current.value)
						end
					end,
					function(data3, menu3)
						menu3.close()
					end)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'properties' then
			local elements = {}
			for k, v in pairs(Data.Properties) do
				table.insert(elements, {
					label = v.id .. ' - (' .. (v.ownername or v.owner) .. ')',
					value = v
				})
			end
			ESX.UI.Menu.Open('default', resName, 'keymasterProperties',{
				title    = 'Keymaster - Properties',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				if data2.current.value then
					kmProperty(data2.current.value)
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

function kmProperty(property)
	dataReady()
	local elements = {
		{label = 'Toggle blip', value = 'blip'},
		{label = 'Owner: ' .. (property.ownername or property.owner), value = 'owner'},
		{label = 'Doors', value = 'doors'},
		{label = 'Zones', value = 'zones'},
		{label = 'New key', value = 'newkey'},
		{label = 'Master', value = {name = 'Master', designation = 0}},
	}
	for k, v in pairs(Data.Keys) do
		if v.property == property.id and v.name ~= 'Master' then
			table.insert(elements, {
				label = v.name .. ' - (' .. v.designation .. ')',
				value = v
			})
		end
	end
	ESX.UI.Menu.Open('default', resName, 'keymasterProperty',{
		title    = string.strjoin(' - ', 'Manage Property', property.id),
		align    = 'top-left',
		elements = elements
	},
	function(data, menu)
		if data.current.value == 'blip' then
			showBlips(property.id)
		elseif data.current.value == 'owner' then
			ESX.UI.Menu.Open('default', resName, 'keymasterPropertyOwner',{
				title    = property.id .. ' - ' .. (property.ownername or property.owner),
				align    = 'top-left',
				elements = {
					{label = 'Transfer ownership', value = 'transfer'},
					{label = 'Revoke all keys', value = 'revoke'},
				}
			},
			function(data2, menu2)
				if data2.current.value == 'transfer' then
					ESX.UI.Menu.Open('default', resName, 'keymasterPropertyTransfer',{
						title    = 'Transfer ' .. property.id .. ' - ' .. (property.ownername or property.owner),
						align    = 'top-left',
						elements = {
							{label = 'Doka & Doka', value = 'bank'},
							{label = 'Societies', value = 'societies'},
							{label = 'Players', value = 'players'},
						}
					},
					function(data3, menu3)
						if data3.current.value == 'bank' then
							exports.dd_menus:areYouSure({
								title = 'Are you sure that you want to transfer ' .. property.id .. ' from ' .. (property.ownername or property.owner) .. ' to ' .. data3.current.label .. '?'
							},
							function(datad, menud)
								ESX.TriggerServerCallback('dd_society:pTransferProperty', function()
									ESX.UI.Menu.CloseAll()
									ESX.ShowNotification('~y~' .. property.id .. ' ~w~transferred from ~g~' .. (property.ownername or property.owner) .. ' ~w~to ~y~' .. data3.current.label)
								end, property.id, 'bank')
							end, false)
						elseif data3.current.value == 'societies' then
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
							ESX.UI.Menu.Open('default', resName, 'keymasterPickSociety',{
								title    = 'Transfer ' .. property.id .. ' - ' .. (property.ownername or property.owner),
								align    = 'top-left',
								elements = elements
							},
							function(data4, menu4)
								exports.dd_menus:areYouSure({
									title = 'Are you sure that you want to transfer ' .. property.id .. ' from ' .. (property.ownername or property.owner) .. ' to ' .. data4.current.value.label .. '?'
								},
								function(datad, menud)
									ESX.TriggerServerCallback('dd_society:pTransferProperty', function()
										ESX.UI.Menu.CloseAll()
										ESX.ShowNotification('~y~' .. property.id .. ' ~w~transferred from ~g~' .. (property.ownername or property.owner) .. ' ~w~to ~y~' .. data4.current.value.label)
									end, property.id, data4.current.value.label)
								end, false)
							end,
							function(data4, menu4)
								menu4.close()
							end)
						elseif data3.current.value == 'players' then
							local elements = {{label = 'Nearby Players', value = 'nearbyPlayers'}}
							local Players = {}
							for k, v in pairs(Data.Properties) do
								if not Data.Societies[v.owner] then
									if not Players[v.owner] then
										Players[v.owner] = {owner = v.owner, ownername = v.ownername, props = 1}
									else
										Players[v.owner].props += 1
									end
								end
							end
							for k, v in pairs(Players) do
								table.insert(elements, {
									label = v.ownername .. ' - (' .. v.props .. ')',
									value = v
								})
							end
							ESX.UI.Menu.Open('default', resName, 'keymasterPickPlayer',{
								title    = 'Transfer ' .. property.id .. ' - ' .. (property.ownername or property.owner),
								align    = 'top-left',
								elements = elements
							},
							function(data4, menu4)
								if data4.current.value == 'nearbyPlayers' then
									exports.dd_menus:nearbyPlayers({
										title = nil, 
										self = true,
										distance = nil
									},
									function(datad, menud)
										exports.dd_menus:areYouSure({
											title = 'Are you sure that you want to transfer ' .. property.id .. ' from ' .. (property.ownername or property.owner) .. ' to ' .. datad.current.name .. '?'
										},
										function(datadd, menudd)
											ESX.TriggerServerCallback('dd_society:pTransferProperty', function()
												ESX.UI.Menu.CloseAll()
												ESX.ShowNotification('~y~' .. property.id .. ' ~w~transferred from ~g~' .. (property.ownername or property.owner) .. ' ~w~to ~y~' .. datad.current.name)
											end, property.id, datad.current.identifier, datad.current.name)
										end, false)
									end, false)
								else
									exports.dd_menus:areYouSure({
										title = 'Are you sure that you want to transfer ' .. property.id .. ' from ' .. (property.ownername or property.owner) .. ' to ' .. data4.current.value.ownername .. '?'
									},
									function(datad, menud)
										ESX.TriggerServerCallback('dd_society:pTransferProperty', function()
											ESX.UI.Menu.CloseAll()
											ESX.ShowNotification('~y~' .. property.id .. ' ~w~transferred from ~g~' .. (property.ownername or property.owner) .. ' ~w~to ~y~' .. data4.current.value.ownername)
										end, property.id, data4.current.value.owner, data4.current.value.ownername)
									end, false)
								end
							end,
							function(data4, menu4)
								menu4.close()
							end)
						end
					end,
					function(data3, menu3)
						menu3.close()
					end)
				elseif data2.current.value == 'revoke' then
					exports.dd_menus:areYouSure({
						title = 'Are you sure that you want to revoke all keys for ' .. property.id .. '?'
					},
					function(datad, menud)
						ESX.TriggerServerCallback('dd_society:getPlayers', function(Players)
							local Holders = {}
							for k, v in pairs(Players) do
								if v.dd_keys[property.id] then
									table.insert(Holders, v)
								end
							end
							ESX.TriggerServerCallback('dd_society:pRevokeAllKeys', function()
								ESX.UI.Menu.CloseAll()
								ESX.ShowNotification('All keys for ~y~' .. property.id .. ' ~w~have been ~r~revoked')
							end, property.id, Holders)
						end)
					end, false)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'doors' then
			local elements = {}
			for k, v in pairs(Data.Doors) do
				if v.property == property.id then
					table.insert(elements, {
						label = v.name .. ' (' .. v.id .. ') [edit]',
						value = v
					})
				end
			end
			if not next(elements) then
				elements[1] = {label = 'None'}
			end
			ESX.UI.Menu.Open('default', resName, 'keymasterPropertyDoors',{
				title    = property.id .. ' - Doors',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				local door = Data.Doors[data2.current.value.id]
				local state = door.state and 'locked' or 'unlocked'
				local locked = door.locked and 'locked' or 'unlocked'
				ESX.UI.Menu.Open('default', resName, 'keymasterdoor',{
					title    = 'Manage Door - ' .. door.name .. ' - ' .. property.id,
					align    = 'top-left',
					elements = {
						{label = 'Current state = ' .. state},
						{label = 'Rename', value = 'rename'},
						{label = 'Change distance (' .. door.distance .. ')', value = 'distance'},
						{label = 'Toggle default state (' .. locked .. ')', value = 'state'},
					}
				},
				function(data3, menu3)
					if data3.current.value == 'rename' then
						exports.dd_menus:text({
							title = 'New door name, enter text'
						},
						function(datad, menud)
							if datad.value and string.len(datad.value) > 1 then
								ESX.TriggerServerCallback('dd_society:pModifyDoor', function()
									menu3.close()
									menu2.close()
									menu.close()
									kmProperty(property, door.id)
									ESX.ShowNotification('Door renamed to ~g~' .. datad.value)
								end, door.id, {name = datad.value})
							else
								ESX.ShowNotification('~r~Door name cannot be empty')
							end
						end, false)
					elseif data3.current.value == 'distance' then
						exports.dd_menus:amount({
							title = 'New door distance, enter amount',
							min = 1, 
							max = 20
						},
						function(datad, menud)
							if datad.value then
								ESX.TriggerServerCallback('dd_society:pModifyDoor', function()
									menu3.close()
									menu2.close()
									menu.close()
									kmProperty(property, door.id)
									ESX.ShowNotification('Door distance changed to ~y~' .. datad.value)
								end, door.id, {distance = datad.value})
							else
								ESX.ShowNotification('~r~Cannot be empty')
							end
						end, false)
					elseif data3.current.value == 'state' then
						ESX.TriggerServerCallback('dd_society:pModifyDoor', function()
							menu3.close()
							menu2.close()
							menu.close()
							kmProperty(property, door.id)
							if locked == 'locked' then
								toggle = 'unlocked'
							else
								toggle = 'locked'
							end
							ESX.ShowNotification('Door default toggled to ~y~' .. toggle)
						end, door.id, {locked = not door.locked})
					end
				end,
				function(data3, menu3)
					menu3.close()
				end)
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'zones' then
			local elements = {}
			for k, v in pairs(Data.Zones) do
				if v.property == property.id then
					table.insert(elements, {
						label = v.name .. ' (' .. v.id .. ') [edit]',
						value = v
					})
				end
			end
			if not next(elements) then
				elements[1] = {label = 'None'}
			end
			ESX.UI.Menu.Open('default', resName, 'keymasterPropertyZones',{
				title    = property.id .. ' - Zones',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				local zone = Data.Zones[data2.current.value.id]
				local state = zone.public and 'public' or 'private'
				ESX.UI.Menu.Open('default', resName, 'keymasterzone',{
					title    = 'Manage Zone - ' .. zone.name .. ' - ' .. property.id,
					align    = 'top-left',
					elements = {
						{label = 'Rename', value = 'rename'},
						{label = 'Toggle state (' .. state .. ')', value = 'state'},
					}
				},
				function(data3, menu3)
					if data3.current.value == 'rename' then
						exports.dd_menus:text({
							title = 'New zone name, enter text'
						},
						function(datad, menud)
							if datad.value and string.len(datad.value) > 1 then
								ESX.TriggerServerCallback('dd_society:pModifyZone', function()
									menu3.close()
									menu2.close()
									menu.close()
									kmProperty(property, zone.id)
									ESX.ShowNotification('Zone renamed to ~g~' .. datad.value)
								end, zone.id, {name = datad.value})
							else
								ESX.ShowNotification('~r~Zone name cannot be empty')
							end
						end, false)
					elseif data3.current.value == 'state' then
						ESX.TriggerServerCallback('dd_society:pModifyZone', function()
							menu3.close()
							menu2.close()
							menu.close()
							kmProperty(property, zone.id)
							if state == 'public' then
								toggle = 'private'
							else
								toggle = 'public'
							end
							ESX.ShowNotification('Zone state toggled to ~y~' .. toggle)
						end, zone.id, {public = not zone.public})
					end
				end,
				function(data3, menu3)
					menu3.close()
				end)
			end,
			function(data2, menu2)
				menu2.close()
			end)
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
			local key = data.current.value
			ESX.TriggerServerCallback('dd_society:getPlayers', function(Players)
				local Holders = {}
				for k, v in pairs(Players) do
					if v.dd_keys[property.id] then
						if has_value(v.dd_keys[property.id], key.designation) then
							table.insert(Holders, v)
						end
					end
				end
				local elements = {
					{label = 'Key holders', value = 'holders'},
					{label = 'Doors', value = 'doors'},
					{label = 'Zones', value = 'zones'},
				}
				if key.name ~= 'Master' then
					elements[4] = {label = 'Rename', value = 'rename'}
					elements[5] = {label = 'Delete Key', value = 'delete'}
				end
				ESX.UI.Menu.Open('default', resName, 'keymasterKey',{
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
						ESX.UI.Menu.Open('default', resName, 'keymasterKeyHolders',{
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
											ESX.ShowNotification('~g~' .. data.current.label .. ' ~w~for ~y~' .. property.id .. ' ~g~added ~w~to ~y~' .. datad.current.name)
										else
											ESX.ShowNotification('~y~' .. datad.current.name .. ' ~w~already has this key')
										end
									end, property.id, key.designation, Player)
								end, false)
							else
								local holder = data3.current.value
								exports.dd_menus:areYouSure({
									title = 'Are you sure that you want to remove ' .. data.current.label .. ' for ' .. property.id .. ' from ' .. holder.fullname
								},
								function(datad, menud)
									ESX.TriggerServerCallback('dd_society:pRemoveKey', function()
										menu3.close()
										menu2.close()
										menu.close()
										kmProperty(property, km)
										ESX.ShowNotification('~g~' .. data.current.label .. ' ~w~for ~y~' .. property.id .. ' ~r~removed ~w~from ~y~' .. holder.name)
									end, property.id, key.designation, holder)
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
								if key.name == 'Master' then
									table.insert(elements, {
										label = v.name .. ' (' .. v.id .. ') [edit]',
										value = v,
										action = 'edit'
									})
								elseif has_value(key.exempt_doors, v.id) then
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
						ESX.UI.Menu.Open('default', resName, 'keymasterKeyDoors',{
							title    = property.id .. ' - ' .. data.current.label .. ' - Doors',
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							if data3.current.action == 'edit' then
								kmDoor(property, data3.value)
							else
								ESX.TriggerServerCallback('dd_society:pToggleKeyExemption', function(valid)
									menu3.close()
									menu2.close()
									menu.close()
									kmProperty(property, km)
									if valid then
										if data3.current.action == 'add' then
											ESX.ShowNotification('~y~' .. data3.current.value.name  .. ' ~w~- (' .. data3.current.value.id .. ')' .. ' has been ~g~added ~w~to ~y~' .. key.name .. ' ~w~- (' .. key.id .. ')')
										elseif data3.current.action == 'remove' then
											ESX.ShowNotification('~y~' .. data3.current.value.name  .. ' ~w~- (' .. data3.current.value.id .. ')' .. ' has been ~r~removed ~w~from ~y~' .. key.name .. ' ~w~- (' .. key.id .. ')')
										end
									else
										ESX.ShowNotification('~r~You cannot edit the Master key')
									end
								end, key, data3.current.value.id, Holders, 'exempt_doors')
							end
						end,
						function(data3, menu3)
							menu3.close()
						end)
					elseif data2.current.value == 'zones' then
						local elements = {}
						for k, v in pairs(Data.Zones) do
							if v.property == property.id then
								if key.name == 'Master' then
									table.insert(elements, {
										label = v.name .. ' (' .. v.id .. ') [edit]',
										value = v,
										action = 'edit'
									})
								elseif has_value(key.exempt_zones, v.id) then
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
						ESX.UI.Menu.Open('default', resName, 'keymasterKeyZones',{
							title    = property.id .. ' - ' .. data.current.label .. ' - Zones',
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							if data3.current.action == 'edit' then
								kmZone(property, data3.value)
							else
								ESX.TriggerServerCallback('dd_society:pToggleKeyExemption', function(valid)
									menu3.close()
									menu2.close()
									menu.close()
									kmProperty(property, km)
									if valid then
										if data3.current.action == 'add' then
											ESX.ShowNotification('~y~' .. data3.current.value.name  .. ' ~w~- (' .. data3.current.value.id .. ')' .. ' has been ~g~added ~w~to ~y~' .. key.name .. ' ~w~- (' .. key.id .. ')')
										elseif data3.current.action == 'remove' then
											ESX.ShowNotification('~y~' .. data3.current.value.name  .. ' ~w~- (' .. data3.current.value.id .. ')' .. ' has been ~r~removed ~w~from ~y~' .. key.name .. ' ~w~- (' .. key.id .. ')')
										end
									else
										ESX.ShowNotification('~r~You cannot edit the Master key')
									end
								end, key, data3.current.value.id, Holders, 'exempt_zones')
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
									ESX.ShowNotification('Key renamed to ~g~' .. datad.value)
								end, key.id, datad.value)
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
							end, key, Holders)
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
