local ServerCallback = import 'callbacks'

function kmOpen()
	ESX.UI.Menu.Open('default', resName, 'keyMaster',{
		title    = 'Keymaster',
		align    = 'top-left',
		elements = {
			{label = 'Societies', value = 'societies'},
			{label = 'Players', value = 'players'},
			{label = 'Property types', value = 'propTypes'},
			{label = 'Properties', value = 'properties'},
		}
	},
	function(data, menu)
		if data.current.value == 'societies' then
			local elements = {}
			local societies = {}
			for i = 1, #Data.Societies do
				societies[Data.Societies[i].label] = {}
			end
			for i = 1, #Data.Properties do
				local property = Data.Properties[i]
				if societies[property.ownerName] then
					societies[property.ownerName][#societies[property.ownerName] + 1] = property
				end
			end
			for k, v in pairs(societies) do
				elements[#elements + 1] = {
					label = ('%s - (%s)'):format(k, #v),
					value = v,
					society = k
				}
			end
			ESX.UI.Menu.Open('default', resName, 'keymasterSocieties',{
				title    = 'Keymaster - Societies',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				local elements = {}
				for i = 1, #data2.current.value do
					local property = data2.current.value[i]
					elements[#elements + 1] = {
						label = property.id,
						value = property.id
					}
				end
				if not next(elements) then
					elements[1] = {label = 'None'}
				end
				ESX.UI.Menu.Open('default', resName, 'keymasterSocietyProperties',{
					title    = ('Keymaster - %s - Properties'):format(data2.current.society),
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
			local players = {}
			for i = 1, #Data.Properties do
				local property = Data.Properties[i]
				if not Indexed.Societies[property.owner] then
					if players[property.ownerName] then
						players[property.ownerName][#players[property.ownerName] + 1] = property
					else
						players[property.ownerName] = {property}
					end
				end
			end
			for k, v in pairs(players) do
				elements[#elements + 1] = {
					label = ('%s - (%s)'):format(k, #v),
					value = v,
					player = k
				}
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
					for i = 1, #data2.current.value do
						local property = data2.current.value[i]
						elements[#elements + 1] = {
							label = property.id,
							value = property.id
						}
					end
					ESX.UI.Menu.Open('default', resName, 'keymasterPlayerProperties',{
						title    = ('Keymaster - %s - Properties'):format(data2.current.player),
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
		elseif data.current.value == 'propTypes' then
			local elements = {}
			for k, v in pairs(GlobalState.PropertyList) do
				local pType = k:gsub("^%l", string.upper)
				local count = 0
				for _ in pairs(v) do
					count += 1
				end
				elements[#elements + 1] = {
					label = ('%s - (%s)'):format(pType, count),
					value = v,
					propType = pType
				}
			end
			ESX.UI.Menu.Open('default', resName, 'keymasterPropTypes',{
				title    = 'Keymaster - Property Types',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				local elements = {}
				for k, v in pairs(data2.current.value) do
					local property = Indexed.Properties[k]
					elements[#elements + 1] = {
						label = ('%s - (%s)'):format(property.id, property.ownerName),
						value = property.id,
					}
				end
				ESX.UI.Menu.Open('default', resName, 'keymasterPropTypesProperties',{
					title    = ('Keymaster - %s - Properties'):format(data2.current.propType),
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
		elseif data.current.value == 'properties' then
			local elements = {}
			for i = 1, #Data.Properties do
				local property = Data.Properties[i]
				elements[#elements + 1] = {
					label = ('%s - (%s)'):format(property.id, property.ownerName),
					value = property.id,
				}
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

function kmProperty(propertyId)
	local property = Indexed.Properties[propertyId]
	local elements = {
		{label = 'Toggle blip', value = 'blip'},
		{label = ('Owner: %s'):format(property.ownerName), value = 'owner'},
		{label = 'Doors', value = 'doors'},
		{label = 'Zones', value = 'zones'},
		{label = 'New key', value = 'newkey'},
	}
	for i = 1, #property.keys do
		local key = property.keys[i]
		elements[#elements + 1] = {
			label = ('%s - %s'):format(key.id, key.name),
			value = key,
		}
	end
	ESX.UI.Menu.Open('default', resName, 'keymasterProperty',{
		title    = ('Manage Property - %s'):format(property.id),
		align    = 'top-left',
		elements = elements
	},
	function(data, menu)
		if data.current.value == 'blip' then
			showBlips(property.id)
		elseif data.current.value == 'owner' then
			ESX.UI.Menu.Open('default', resName, 'keymasterPropertyOwner',{
				title    = ('%s - %s'):format(property.id, property.ownerName),
				align    = 'top-left',
				elements = {
					{label = 'Transfer ownership', value = 'transfer'},
					{label = 'Revoke all keys', value = 'revoke'},
				}
			},
			function(data2, menu2)
				if data2.current.value == 'transfer' then
					ESX.UI.Menu.Open('default', resName, 'keymasterPropertyTransfer',{
						title    = ('Transfer - %s - %s'):format(property.id, property.ownerName),
						align    = 'top-left',
						elements = {
							{label = Config.BankName, value = 'bank'},
							{label = 'Societies', value = 'societies'},
							{label = 'Players', value = 'players'},
						}
					},
					function(data3, menu3)
						if data3.current.value == 'bank' then
							exports.dd_menus:areYouSure({
								title = ('Are you sure that you want to transfer %s from %s to %s?'):format(property.id, property.ownerName, data3.current.label)
							},
							function(datad, menud)
								ESX.UI.Menu.CloseAll()
								ServerCallback.Async('dd_society', 'pTransferProperty', 100, function()
									ESX.ShowNotification(('~y~%s ~w~transferred from ~g~%s ~w~to ~y~%s'):format(property.id, property.ownerName, data3.current.label))
									kmOpenAfterUpdate(property.id)
								end, property.id, Config.Bank, Config.BankName)
							end, false)
						elseif data3.current.value == 'societies' then
							local elements = {}
							local societies = {}
							for i = 1, #Data.Societies do
								societies[Data.Societies[i].label] = {owner = Data.Societies[i].name}
							end
							for i = 1, #Data.Properties do
								local property = Data.Properties[i]
								if societies[property.ownerName] then
									societies[property.ownerName][#societies[property.ownerName] + 1] = property
								end
							end
							for k, v in pairs(societies) do
								elements[#elements + 1] = {
									label = ('%s - (%s)'):format(k, #v),
									value = v,
									society = k
								}
							end
							ESX.UI.Menu.Open('default', resName, 'keymasterPickSociety',{
								title    = ('Transfer - %s - %s'):format(property.id, property.ownerName),
								align    = 'top-left',
								elements = elements
							},
							function(data4, menu4)
								exports.dd_menus:areYouSure({
									title = ('Are you sure that you want to transfer %s from %s to %s?'):format(property.id, property.ownerName, data4.current.society)
								},
								function(datad, menud)
									ESX.UI.Menu.CloseAll()
									ServerCallback.Async('dd_society', 'pTransferProperty', 100, function()
										ESX.ShowNotification(('~y~%s ~w~transferred from ~g~%s ~w~to ~y~%s'):format(property.id, property.ownerName, data4.current.society))
										kmOpenAfterUpdate(property.id)
									end, property.id, data4.current.value.owner, data4.current.society)
								end, false)
							end,
							function(data4, menu4)
								menu4.close()
							end)
						elseif data3.current.value == 'players' then
							local elements = {{label = 'Nearby Players', value = 'nearbyPlayers'}}
							local players = {}
							for i = 1, #Data.Properties do
								local property = Data.Properties[i]
								if not Indexed.Societies[property.owner] then
									if players[property.ownerName] then
										players[property.ownerName][#players[property.ownerName] + 1] = property
									else
										players[property.ownerName] = {owner = property.owner, property}
									end
								end
							end
							for k, v in pairs(players) do
								elements[#elements + 1] = {
									label = ('%s - (%s)'):format(k, #v),
									value = v,
									player = k
								}
							end
							ESX.UI.Menu.Open('default', resName, 'keymasterPickPlayer',{
								title    = ('Transfer - %s - %s'):format(property.id, property.ownerName),
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
											title = ('Are you sure that you want to transfer %s from %s to %s?'):format(property.id, property.ownerName, datad.current.name)
										},
										function(datadd, menudd)
											ESX.UI.Menu.CloseAll()
											ServerCallback.Async('dd_society', 'pTransferProperty', 100, function()
												ESX.ShowNotification(('~y~%s ~w~transferred from ~g~%s ~w~to ~y~%s'):format(property.id, property.ownerName, datad.current.name))
												kmOpenAfterUpdate(property.id)
											end, property.id, datad.current.identifier, datad.current.name)
										end, false)
									end, false)
								else
									exports.dd_menus:areYouSure({
										title = ('Are you sure that you want to transfer %s from %s to %s?'):format(property.id, property.ownerName, data4.current.player)
									},
									function(datad, menud)
										ESX.UI.Menu.CloseAll()
										ServerCallback.Async('dd_society', 'pTransferProperty', 100, function()
											ESX.ShowNotification(('~y~%s ~w~transferred from ~g~%s ~w~to ~y~%s'):format(property.id, property.ownerName, data4.current.player))
											kmOpenAfterUpdate(property.id)
										end, property.id, data4.current.value.owner, data4.current.player)
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
						title = ('Are you sure that you want to revoke all keys for %s?'):format(property.id)
					},
					function(datad, menud)
						ESX.UI.Menu.CloseAll()
						ServerCallback.Async('dd_society', 'pRevokeAllKeys', 100, function()
							ESX.ShowNotification(('All keys for ~y~%s ~w~have been ~r~revoked'):format(property.id))
							kmOpenAfterUpdate(property.id)
						end, property.id)
					end, false)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'doors' then
			local elements = {}
			for i = 1, #property.doors do
				local door = property.doors[i]
				elements[#elements + 1] = {
					label = ('%s - %s [edit]'):format(door.id, door.name),
					value = door,
				}
			end
			if not next(elements) then
				elements[1] = {label = 'None'}
			end
			ESX.UI.Menu.Open('default', resName, 'keymasterPropertyDoors',{
				title    = ('%s - Doors'):format(property.id),
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				local door = data2.current.value
				local locked = door.locked and 'locked' or 'unlocked'
				ESX.UI.Menu.Open('default', resName, 'keymasterdoor',{
					title    = ('Manage Door - %s - %s'):format(door.id, door.name),
					align    = 'top-left',
					elements = {
						{label = ('Current state = %s'):format(locked)},
						{label = 'Rename', value = 'rename'},
						{label = ('Change distance (%s)'):format(door.distance), value = 'distance'},
					}
				},
				function(data3, menu3)
					if data3.current.value == 'rename' then
						exports.dd_menus:text({
							title = 'New door name, enter text'
						},
						function(datad, menud)
							if datad.value and datad.value:len() > 1 then
								door.name = datad.value
								ESX.UI.Menu.CloseAll()
								TriggerServerEvent('dd_society:pModifyDoor', door)
								ESX.ShowNotification(('Door renamed to ~g~%s'):format(datad.value))
								kmOpenAfterUpdate(property.id)
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
								door.distance = datad.value
								ESX.UI.Menu.CloseAll()
								TriggerServerEvent('dd_society:pModifyDoor', closeDoor)
								ESX.ShowNotification(('Door distance changed to ~g~%s'):format(datad.value))
								kmOpenAfterUpdate(property.id)
							else
								ESX.ShowNotification('~r~Cannot be empty')
							end
						end, false)
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
			for i = 1, #property.zones do
				local zone = property.zones[i]
				elements[#elements + 1] = {
					label = ('%s - %s [edit]'):format(zone.id, zone.name),
					value = zone,
				}
			end
			if not next(elements) then
				elements[1] = {label = 'None'}
			end
			ESX.UI.Menu.Open('default', resName, 'keymasterPropertyZones',{
				title    = ('%s - Doors'):format(property.id),
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				local zone = Data.Zones[data2.current.value.id]
				local public = zone.public and 'public' or 'private'
				ESX.UI.Menu.Open('default', resName, 'keymasterzone',{
					title    = ('Manage Zone - %s - %s'):format(zone.id, zone.name),
					align    = 'top-left',
					elements = {
						{label = 'Rename', value = 'rename'},
						{label = ('Switch state (%s)'):format(public), value = 'public'},
					}
				},
				function(data3, menu3)
					if data3.current.value == 'rename' then
						exports.dd_menus:text({
							title = 'New zone name, enter text'
						},
						function(datad, menud)
							if datad.value and datad.value:len() > 1 then
								zone.name = datad.value
								ESX.UI.Menu.CloseAll()
								ServerCallback.Async('dd_society', 'pModifyZone', 100, function()
									ESX.ShowNotification(('Zone renamed to ~g~%s'):format(datad.value))
									kmOpenAfterUpdate(property.id)
								end, zone)
							else
								ESX.ShowNotification('~r~Zone name cannot be empty')
							end
						end, false)
					elseif data3.current.value == 'public' then
						zone.public = not zone.public
						ESX.UI.Menu.CloseAll()
						ServerCallback.Async('dd_society', 'pModifyZone', 100, function()
							local switch = public == 'public' and 'private' or 'public'
							ESX.ShowNotification('Zone is now ~y~%s'):format(switch)
							kmOpenAfterUpdate(property.id)
						end, zone)
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
					ESX.ShowNotification(('~r~Pick a name other than "%s"'):format(datad.value))
				else
					ESX.UI.Menu.CloseAll()
					ServerCallback.Async('dd_society', 'pNewKey', 100, function(newKey)
						ESX.ShowNotification(('New key - ~y~%s ~w~- ~g~%s'):format(newKey.id, newKey.name))
						kmOpenAfterUpdate(property.id)
					end, property.id, datad.value)
				end
			end, false)
		else
			local key = data.current.value
			local _, id = string.strsplit(':', key.id)
			local elements = {
				{label = 'Key holders', value = 'holders'},
				{label = 'Doors', value = 'doors'},
				{label = 'Zones', value = 'zones'},
			}
			if tonumber(id) ~= 0 then
				elements[4] = {label = 'Rename', value = 'rename'}
				elements[5] = {label = 'Delete Key', value = 'delete'}
			end
			ESX.UI.Menu.Open('default', resName, 'keymasterKey',{
				title    = 	('%s - %s'):format(key.id, key.name),
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				if data2.current.value == 'holders' then
					local elements = {
						{label = 'Add holder', value = 'add'}
					}
					for k, v in pairs(key.holders) do
						elements[#elements + 1] = {
							label = ('%s [remove]'):format(v),
							ident = k,
							fullName = v,
						}
					end
					ESX.UI.Menu.Open('default', resName, 'keymasterKeyHolders',{
						title    = ('%s - Holders'):format(data.current.label),
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
								ESX.UI.Menu.CloseAll()
								ServerCallback.Async('dd_society', 'pAddKey', 100, function()
									ESX.ShowNotification(('~y~%s ~g~added ~w~to ~y~%s'):format(data.current.label, datad.current.name))
									kmOpenAfterUpdate(property.id)
								end, key.id, datad.current.identifier)
							end, false)
						else
							exports.dd_menus:areYouSure({
								title = ('Are you sure that you want to remove %s from %s?'):format(data.current.label, data3.current.fullName)
							},
							function(datad, menud)
								ESX.UI.Menu.CloseAll()
								ServerCallback.Async('dd_society', 'pRemoveKey', 100, function()
									ESX.ShowNotification(('~y~%s ~r~removed ~w~from ~y~%s'):format(data.current.label, data3.current.fullName))
									kmOpenAfterUpdate(property.id)
								end, key.id, data3.current.ident)
							end, false)
						end
					end,
					function(data3, menu3)
						menu3.close()
					end)
				elseif data2.current.value == 'doors' then
					local elements = {}
					for i = 1, #property.doors do
						local door = property.doors[i]
						local action
						if tonumber(id) == 0 then
							action = 'edit'
						elseif key.exempt.doors[door.id] then
							action = 'add'
						else
							action = 'remove'
						end
						elements[#elements + 1] = {
							label = ('%s - %s [%s]'):format(door.id, door.name, action),
							value = v,
							action = action
						}
					end
					if not next(elements) then
						elements[1] = {label = 'None'}
					end
					ESX.UI.Menu.Open('default', resName, 'keymasterKeyDoors',{
						title    = ('%s - %s - Doors'):format(property.id, data.current.label),
						align    = 'top-left',
						elements = elements
					},
					function(data3, menu3)
						if data3.current.action == 'edit' then
							-- kmDoor(property, data3.value)
							print('tbd')
						else
							ESX.UI.Menu.CloseAll()
							ServerCallback.Async('dd_society', 'pSwitchKeyExemption', 100, function(valid)
								if valid then
									if data3.current.action == 'add' then
										ESX.ShowNotification('~y~Door ~g~added ~w~to ~y~%s'):format(key.id, key.name)
									elseif data3.current.action == 'remove' then
										ESX.ShowNotification('~y~Door ~r~removed ~w~from ~y~%s'):format(key.id, key.name)
									end
								else
									ESX.ShowNotification('~r~You cannot edit the Master Key')
								end
								kmOpenAfterUpdate(property.id)
							end, key.id, 'doors', data3.current.value.id)
						end
					end,
					function(data3, menu3)
						menu3.close()
					end)
				elseif data2.current.value == 'zones' then
					local elements = {}
					for i = 1, #property.zones do
						local zone = property.zones[i]
						local action
						if tonumber(id) == 0 then
							action = 'edit'
						elseif key.exempt.zones[zone.id] then
							action = 'add'
						else
							action = 'remove'
						end
						elements[#elements + 1] = {
							label = ('%s - %s [%s]'):format(zone.id, zone.name, action),
							value = v,
							action = action
						}
					end
					if not next(elements) then
						elements[1] = {label = 'None'}
					end
					ESX.UI.Menu.Open('default', resName, 'keymasterKeyZones',{
						title    = ('%s - %s - Zones'):format(property.id, data.current.label),
						align    = 'top-left',
						elements = elements
					},
					function(data3, menu3)
						if data3.current.action == 'edit' then
							-- kmZone(property, data3.value)
							print('tbd')
						else
							ESX.UI.Menu.CloseAll()
							ServerCallback.Async('dd_society', 'pSwitchKeyExemption', 100, function(valid)
								if valid then
									if data3.current.action == 'add' then
										ESX.ShowNotification('~y~Zone ~g~added ~w~to ~y~%s'):format(key.id, key.name)
									elseif data3.current.action == 'remove' then
										ESX.ShowNotification('~y~Zone ~r~removed ~w~from ~y~%s'):format(key.id, key.name)
									end
								else
									ESX.ShowNotification('~r~You cannot edit the Master key')
								end
								kmOpenAfterUpdate(property.id)
							end, key.id, 'zones', data3.current.value.id)
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
						if datad.value and datad.value:len() > 1 then
							ESX.UI.Menu.CloseAll()
							ServerCallback.Async('dd_society', 'pRenameKey', 100, function()
								ESX.ShowNotification(('Key renamed to ~g~%s'):format(datad.value))
								kmOpenAfterUpdate(property.id)
							end, key.id, datad.value)
						else
							ESX.ShowNotification('~r~Key name cannot be empty')
						end
					end, false)
				elseif data2.current.value == 'delete' then
					exports.dd_menus:areYouSure({
						title = ('Are you sure that you want to delete %s?'):format(data.current.label)
					},
					function(datad, menud)
						ESX.UI.Menu.CloseAll()
						ServerCallback.Async('dd_society', 'pDeleteKey', 100, function(valid)
							if valid then
								ESX.ShowNotification('~y~%s has been ~r~deleted'):format(data.current.label)
							else
								ESX.ShowNotification('~r~You cannot delete the Master key')
							end
							kmOpenAfterUpdate(property.id)
						end, key.id)
					end, false)
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

RegisterNetEvent('dd_society:keymaster', function()
	kmOpen()
end)

function kmOpenAfterUpdate(propertyId)
	kmUpdate = false
	repeat Wait(0) until kmUpdate
	kmProperty(propertyId)
end