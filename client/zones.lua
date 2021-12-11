local Zone = {}
local ZoneMenus = {
	'garage',
	'boss',
	'property',
	'stash',
	'locker',
	'shop',
	'teleport'
}

CreateThread(function()
	dataReady()
	for k, v in pairs(Data.Zones) do
		local zone
		if v.poly then
			zone = PolyZone:Create((v.poly), {
				name = v.property .. ' - ' .. v.name,
				minZ = v.minZ,
				maxZ = v.maxZ,
				debugGrid = Config.debugZone or Data.Properties[v.property].debug or v.debug,
				lazyGrid = true,
				data = v
			})
		elseif v.circle then
			zone = CircleZone:Create((v.circle), 1.8, {
				name = v.property .. ' - ' .. v.name,
				useZ = true,
				debugPoly = Config.debugZone or Data.Properties[v.property].debug or v.debug,
				data = v
			})
		end
		zone:onPlayerInOut(function(isPointInside, point)
			if Data.Player.Auth and has_value(Data.Player.Auth.Zones, zone.data.id) or Data.Zones[zone.data.id].public then
				local insideZone = isPointInside
				if insideZone then
					Zone = zone.data
					exports.ox_inventory:notify({text = zone.data.property .. ' - ' .. zone.data.name, duration = 5000})
				else
					if Zone.id == zone.data.id then
						Zone = {}
						for k, v in pairs(ZoneMenus) do
							if ESX.UI.Menu.IsOpen('default', resName, v) then
								ESX.UI.Menu.CloseAll()
								break
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
		local close
		for k, v in pairs(ZoneMenus) do
			if ESX.UI.Menu.IsOpen('default', resName, v) then
				close = true
				break
			end
		end
		ESX.UI.Menu.CloseAll()

		if not close and not (LocalPlayer.state.dead or LocalPlayer.state.ko > 0 or LocalPlayer.state.cuffed) then
			if Zone.type == 'garage' or Zone.type == 'pad' or Zone.type == 'dock' or Zone.type == 'hangar' then
				gOpen(Zone)
			elseif Zone.type == 'boss' then
				bOpen(Zone)
			elseif Zone.type == 'property' then
				pOpen(Zone)
			elseif Zone.type == 'stash' then
				TriggerEvent('ox_inventory:openInventory', 'stash', string.strconcat(Zone.property, ':', Zone.type, '-', Zone.designation))
			elseif Zone.type == 'locker' then
				TriggerEvent('ox_inventory:openInventory', 'stash', string.strconcat(Zone.property, ':', Zone.type, '-', Zone.designation))
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
