carInstance = {}

RegisterNetEvent('dd_society:createVehicle', function(model, plate)
	local heading = GetEntityHeading(pedPos)

	ESX.Game.SpawnVehicle(model, pedPos, heading, function(veh)
		local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
		SetVehicleNumberPlateText(veh, plate)
		local props = getVehicleProperties(veh)
		TaskWarpPedIntoVehicle(ped, veh, -1)

		TriggerServerEvent('dd_society:vCreateVehicle', props, GetPlayerServerId(PlayerId()), name)

		carInstance[props.plate] = veh
	end)
end)

function storeVehicle(zone)
	if IsPedInAnyVehicle(ESX.PlayerData.ped, false) then
		local vehicleId = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		if GetPedInVehicleSeat(vehicleId, -1) == ESX.PlayerData.ped then
			local vehicle = {}
			vehicle.props = getVehicleProperties(vehicleId)
			if vehicle.props ~= nil then
				local change = {
					garage = zone.id,
					props = vehicle.props
				}
				ESX.TriggerServerCallback('dd_society:vModify', function(passed)
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

	local spot, found

	for i = 1, #zone.spawn*2 do
		spot = zone.spawn[math.random(1, #zone.spawn)]
		if ESX.Game.IsSpawnPointClear(spot.xyz, 3.0) then
			found = true
			print(spot.xyz)
			break
		end
	end

	if found then
		ESX.Game.SpawnVehicle(vehicle.props.model, spot.xyz, spot.w, function(veh)
			setVehicleProperties(veh, vehicle.props)
			carInstance[vehicle.props.plate] = veh
		end)

		ESX.ShowNotification('Your ~y~vehicle ~w~is ~g~ready')

		CreateThread(function()
			local vehicleBlip = AddBlipForCoord(spot.coords)
			Wait(10000)
			RemoveBlip(vehicleBlip)
		end)
	else
		ESX.ShowNotification('~r~There was no spot found for your vehicle')
		ESX.TriggerServerCallback('dd_society:vModify', function(passed)
			if passed then
				gManage(zone)
			end
		end, vehicle, {garage = zone.id})
	end
end

function vehicleInUse(plate)
	local vehicleInUse = false
	local players = ESX.Game.GetPlayers()
	for k, v in pairs(players) do
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(v), false)
		if vehicle ~= 0 then
			local props = getVehicleProperties(vehicle)
			if plate == props.plate then
				vehicleInUse = true
				break
			end
		end
	end
	return vehicleInUse
end

function setVehicleProperties(vehicle, props)
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

function getVehicleProperties(vehicle)
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
