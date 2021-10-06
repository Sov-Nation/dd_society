CurrentZone = {}
ActionMsg = nil
carInstance = {}

CreateThread(function() --ESX.UI.Menu.GetOpened(type, namespace, name)
    while not DataReady do
        Wait(100)
    end
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
			local insideZone = isPointInside
			if insideZone then
				CurrentZone = zone.data
				zone.data.message = Config.Zones[zone.data.type].message
				ActionMsg = zone.data.message
			else
				CurrentZone = {}
				ActionMsg = nil
				ESX.UI.Menu.CloseAll()
			end
		end)
	end
end)
 
CreateThread(function()
	while true do
		Wait(0)
		if ActionMsg then
			ESX.ShowHelpNotification(ActionMsg)
		end
	end
end)

RegisterCommand('interact', function()
	ESX.UI.Menu.CloseAll()
	ActionMsg = nil

	if CurrentZone.type == 'garage' then
		gOpen(CurrentZone)
	elseif CurrentZone.type == 'boss' then
		bOpen(CurrentZone)
	elseif CurrentZone.type == 'property' then
		pOpen(CurrentZone)
	elseif CurrentZone.type == 'uniform' then
		uOpen(CurrentZone)
	elseif CurrentZone.type == 'teleport' then
		tOpen(CurrentZone)
	end
end)
