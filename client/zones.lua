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
		if v.zone.type == 'poly' then
			zone = PolyZone:Create((v.zone.vecs), {
				minZ = v.zone.min,
				maxZ = v.zone.max,
				debugGrid = Config.debugZone,
				lazyGrid = true,
				data = v
			})
		elseif v.zone.type == 'circle' then
			zone = CircleZone:Create((v.zone.vec), v.zone.r, {
				useZ = true,
				debugPoly = Config.debugZone,
				data = v
			})
		end
		zone:onPlayerInOut(function(isPointInside, point)
			if Data.Player.Auth and has_value(Data.Player.Auth.Zones, Data.Zones[zone.data.id].id) or Data.Zones[zone.data.id].public then
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

		if not close then
			if Zone.type == 'garage' then
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
