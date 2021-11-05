local Zone = {}
local ZoneMenus = {
	'garage',
	'boss',
	'property',
	'stash',
	'locker',
	'shop',
	'uniform',
	'teleport'
}

CreateThread(function()
	dataReady()
	for k, v in pairs(Data.Zones) do
		local zone
		zone = PolyZone:Create((v.poly), {
			name = v.property .. ' - ' .. v.name,
			minZ = v.minZ,
			maxZ = v.maxZ,
			debugGrid = Config.debugZone or v.debug,
			lazyGrid = true,
			data = v
		})
		zone:onPlayerInOut(function(isPointInside, point)
			if Data.Player.Auth and has_value(Data.Player.Auth.Zones, zone.data.id) or Data.Zones[zone.data.id].public then
				local insideZone = isPointInside
				if insideZone then
					Zone = zone.data
					exports.ox_inventory:Notify({text = zone.data.property .. ' - ' .. zone.data.name, duration = 5000})
				else
					if Zone.id == zone.data.id then
						Zone = {}
						for k, v in pairs(ZoneMenus) do
							if ESX.UI.Menu.IsOpen('default', resName, v) then
								ESX.UI.Menu.Close('default', resName, v)
							end
						end
					end
				end
			end
		end)
	end
end)

RegisterCommand('interact', function()
	if next(Zone) then
		local open, close = ESX.UI.Menu.GetOpenedMenus()
		for k, v in pairs(open) do
			if v.namespace == resName then
				if has_value(ZoneMenus, v.name) then
					close = true
					break
				end
			end
		end
		ESX.UI.Menu.CloseAll()

		if not close and not ESX.PlayerData.dead and not ESX.PlayerData.ko then
			if Zone.type == 'garage' or Zone.type == 'pad' or Zone.type == 'dock' or Zone.type == 'hangar' then
				gOpen(Zone)
			elseif Zone.type == 'boss' then
				bOpen(Zone)
			elseif Zone.type == 'property' then
				pOpen(Zone)
			elseif Zone.type == 'stash' then
				TriggerEvent('ox_inventory:openInventory', 'stash', {
					name = string.strconcat(Zone.property, ':', Zone.type, '-', Zone.designation),
					label = 'Stash',
					owner = false,
					slots = 50,
					weight = 50000
				})
			elseif Zone.type == 'locker' then
				TriggerEvent('ox_inventory:openInventory', 'stash', {
					name = string.strconcat(Zone.property, ':', Zone.type, '-', Zone.designation, ':'),
					label = 'Personal Locker',
					owner = true,
					slots = 10,
					weight = 10000
				})
			elseif Zone.type == 'shop' then
				TriggerEvent('ox_inventory:openInventory', 'shop', {type = 'Property', id = Zone.property})
			elseif Zone.type == 'uniform' then
				uOpen(Zone)
			elseif Zone.type == 'teleport' then
				tOpen(Zone)
			end
		end
	end
end)
