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

function storeVehicle(zone)
	local playerPed = PlayerPedId()
	if IsPedInAnyVehicle(playerPed, false) then
		local vehicleId = GetVehiclePedIsIn(playerPed, false)
		if GetPedInVehicleSeat(vehicleId, -1) == playerPed then
			local vehicle = {}
			vehicle.props = GetVehicleProperties(vehicleId)
			if vehicle.props ~= nil then
				local change = {
					garage = zone.id,
					props = vehicle.props
				}
				ESX.TriggerServerCallback('dd_society:gModify', function(passed)
					if passed then
						for i = -1, GetVehicleMaxNumberOfPassengers(vehicleId) do
							TaskLeaveVehicle(GetPedInVehicleSeat(vehicleId, i), vehicleId, 4160)
						end
						Wait(1800)
						DeleteEntity(vehicleId)
						ESX.ShowNotification('Your ~y~vehicle ~w~is ~g~stored')
					else
						ESX.ShowNotification('~r~You cannot store this vehicle')
					end
				end, vehicle, change)
			else
				ESX.ShowNotification('Error finding vehicle')
			end
		else
			ESX.ShowNotification('~r~You are not the driver')
		end
	else
		ESX.ShowNotification('~r~There is no vehicle to store')
	end
end

function SpawnVehicle(vehicle, zone)
	if carInstance[vehicle.props.plate] then
		if DoesEntityExist(carInstance[vehicle.props.plate]) then
			ESX.Game.DeleteVehicle(carInstance[vehicle.props.plate])
			carInstance[vehicle.props.plate] = nil
		end
	end

	local Picks = {}

	for k, v in pairs(zone.spawn) do
		Picks[math.floor(#(v.coords - pedPos))] = v
	end

	local pick = nil

	for k, v in sipairs(Picks) do
		if ESX.Game.IsSpawnPointClear(v.coords, 3.0) then
			pick = v
			break
		end
	end

	if not pick then
		ESX.ShowNotification('~r~There is no space for your vehicle')
		local change = {
			garage = zone.id
		}
		ESX.TriggerServerCallback('dd_society:gModify', function(passed)
			if passed then
				gManage(zone)
			end
		end, vehicle, change)
		return
	end

	ESX.Game.SpawnVehicle(vehicle.props.model, pick.coords, pick.heading, function(callback_vehicle)
		SetVehicleProperties(callback_vehicle, vehicle.props)
		carInstance[vehicle.props.plate] = callback_vehicle
	end)

	ESX.ShowNotification('Your ~y~vehicle ~w~is ~g~ready')

	CreateThread(function()
		local vehicleBlip = AddBlipForCoord(pick.coords)
		Wait(10000)
		RemoveBlip(vehicleBlip)
	end)
end

function vehicleInUse(plate)
	local vehicleInUse = false
	local players = ESX.Game.GetPlayers()
	for k, v in pairs(players) do
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(v), false)
		if vehicle ~= 0 then
			local props = GetVehicleProperties(vehicle)
			if plate == props.plate then
				vehicleInUse = true
				break
			end
		end
	end
	return vehicleInUse
end

function SetVehicleProperties(vehicle, props)
    ESX.Game.SetVehicleProperties(vehicle, props)
	if props.fuel then
		DecorSetFloat(vehicle, '_FUEL_LEVEL', props.fuel)
	end
	
    if props.windows then
        for windowId = 1, 9, 1 do
            if props.windows[windowId] == false then
                SmashVehicleWindow(vehicle, windowId)
            end
        end
    end

    if props.tyres then
        for tyreId = 1, 7, 1 do
            if props.tyres[tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end

    if props.doors then
        for doorId = 0, 5, 1 do
            if props.doors[doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end
	if props.vehicleHeadLight then SetVehicleHeadlightsColour(vehicle, props.vehicleHeadLight) end
end

function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local props = ESX.Game.GetVehicleProperties(vehicle)

        props.tyres = {}
        props.windows = {}
        props.doors = {}
		props.fuel = DecorGetFloat(vehicle, '_FUEL_LEVEL')
		
        for id = 1, 7 do
            local tyreId = IsVehicleTyreBurst(vehicle, id, false)
        
            if tyreId then
                props.tyres[#props.tyres + 1] = tyreId
        
                if tyreId == false then
                    tyreId = IsVehicleTyreBurst(vehicle, id, true)
                    props.tyres[ #props.tyres] = tyreId
                end
            else
                props.tyres[#props.tyres + 1] = false
            end
        end

        for id = 1, 9 do
            local windowId = IsVehicleWindowIntact(vehicle, id)

            if windowId ~= nil then
                props.windows[#props.windows + 1] = windowId
            else
                props.windows[#props.windows + 1] = true
            end
        end
        
        for id = 0, 5 do
            local doorId = IsVehicleDoorDamaged(vehicle, id)
        
            if doorId then
                props.doors[#props.doors + 1] = doorId
            else
                props.doors[#props.doors + 1] = false
            end
        end
		props.vehicleHeadLight  = GetVehicleHeadlightsColour(vehicle)

        return props
	else
		return nil
    end
end
