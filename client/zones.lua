local currentZone = {}
local zoneMenus = {
	'garage',
	'boss',
	'property',
	'stash',
	'locker',
	'shop',
	'teleport'
}

CreateThread(function()
	while not PlayerBags.Player.ped do Wait(0) end
	for i = 1, #Data.Zones do
		local pz, zone = Data.Zones[i]
		pz.property = string.strsplit(':', pz.id)
		if pz.poly then
			zone = PolyZone:Create((pz.poly), {
				name = ('%s - %s'):format(pz.property, pz.name),
				minZ = pz.minZ,
				maxZ = pz.maxZ,
				debugGrid = Config.debugZone or Indexed.Properties[pz.property].debug or pz.debug,
				lazyGrid = true,
				data = pz
			})
		elseif pz.circle then
			zone = CircleZone:Create((vectorize(pz.circle)), 1.8, {
				name = ('%s - %s'):format(pz.property, pz.name),
				useZ = true,
				debugPoly = Config.debugZone or Indexed.Properties[pz.property].debug or pz.debug,
				data = pz
			})
		end
		zone:onPlayerInOut(function(isPointInside, point)
			if PlayerBags.Player.auth.zones[zone.data.id] or Indexed.Zones[zone.data.id].public then
				local insideZone = isPointInside
				if insideZone then
					local name = zone.name
					currentZone = zone.data
					exports.ox_inventory:notify({text = name, duration = 5000})
				else
					if currentZone.id == zone.data.id then
						currentZone = {}
						for i = 1, #zoneMenus do
							local menu = zoneMenus[i]
							if ESX.UI.Menu.IsOpen('default', resName, menu) then
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
	if next(currentZone) then
		local close
		for i = 1, #zoneMenus do
			local menu = zoneMenus[i]
			if ESX.UI.Menu.IsOpen('default', resName, menu) then
				close = true
				break
			end
		end
		ESX.UI.Menu.CloseAll()

		if not close and canInteract() then
			if currentZone.type == 'garage' or currentZone.type == 'pad' or currentZone.type == 'dock' or currentZone.type == 'hangar' then
				gOpen(currentZone)
			elseif currentZone.type == 'boss' then
				bOpen(currentZone)
			elseif currentZone.type == 'property' then
				pOpen(currentZone)
			elseif currentZone.type == 'stash' then
				TriggerEvent('ox_inventory:openInventory', 'stash', currentZone.id)
			elseif currentZone.type == 'locker' then
				TriggerEvent('ox_inventory:openInventory', 'stash', currentZone.id)
			elseif currentZone.type == 'shop' then
				TriggerEvent('ox_inventory:openInventory', 'shop', {type = 'Property', id = currentZone.property})
			elseif currentZone.type == 'uniform' then
				uOpen(currentZone)
			elseif currentZone.type == 'teleport' then
				tOpen(currentZone)
			end
		end
	end
end)
