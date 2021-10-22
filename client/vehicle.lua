carInstance = {}

RegisterNetEvent('dd_society:spawnVehicle', function(vehicle, coords, delete, owner, plate)
	local veh = spawnVehicle(vehicle, coords, delete)
	if owner and veh then
		SetVehicleNumberPlateText(veh, plate)
		local props = getVehicleProperties(veh)
		local name = GetLabelText(GetDisplayNameFromVehicleModel(props.model))

		TriggerServerEvent('dd_society:vCreateVehicle', props, name)
		carInstance[props.plate] = veh
	end
end)

function spawnVehicle(vehicle, coords, delete)
	local model = (type(vehicle) == 'number' and vehicle or joaat(vehicle))

	if IsModelInCdimage(model) then
		ESX.Streaming.RequestModel(model)

		local vec = coords and coords.xyz or pedPos
		if coords then
			heading = coords.w
		else
			heading = GetEntityHeading(ESX.PlayerData.ped)
		end
		local oldVeh = GetVehiclePedIsIn(ESX.PlayerData.ped)
		local vehicle = CreateVehicle(model, vec.xyz, heading, false, false)

		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)
		SetVehRadioStation(vehicle, 'OFF')

		RequestCollisionAtCoord(coords)
		while not HasCollisionLoadedAroundEntity(vehicle) do
			Wait(0)
		end

		if delete then
			if oldVeh and oldVeh ~= 0 then
				local velocity = GetEntityVelocity(oldVeh)
				local fVec = GetEntityForwardVector(oldVeh)
				local fVel = fVec * velocity
				local lVel = fVec / velocity
				DeleteEntity(oldVeh)
				SetEntityVelocity(vehicle, lVel)
				if fVel.x > 0 and fVel.y > 0 and fVel.z > 0 then
					SetVehicleForwardSpeed(vehicle, #fVel)
				end
			end
			SetVehicleEngineOn(vehicle, true, true, true)
			TaskWarpPedIntoVehicle(ESX.PlayerData.ped, vehicle, -1)
		end
		return vehicle
	else
		TriggerEvent('chat:addMessage', { args = { '^1SYSTEM', 'Invalid vehicle model - ' .. vehicle } })
	end
end

function storeVehicle(zone)
	if IsPedInAnyVehicle(ESX.PlayerData.ped, false) then
		local vehicleId = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		if GetPedInVehicleSeat(vehicleId, -1) == ESX.PlayerData.ped then
			local vehicle = {}
			vehicle.props = getVehicleProperties(vehicleId)
			if vehicle.props then
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
				end, vehicle, {garage = zone.id, props = vehicle.props})
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

function pickSpawn(vehicle, zone)
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
			break
		end
	end

	if found then
		local veh = spawnVehicle(vehicle.props.model, spot, false, false)

		setVehicleProperties(veh, vehicle.props)
		carInstance[vehicle.props.plate] = veh

		ESX.ShowNotification('Your ~y~vehicle ~w~is ~g~ready')

		CreateThread(function()
			local vehicleBlip = AddBlipForCoord(spot.xyz)
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
		for i = 1, 9 do
			if props.windows[i] == false then
				SmashVehicleWindow(vehicle, i)
			end
		end
	end

	if props.tyres then
		for i = 1, 7 do
			if props.tyres[i] ~= false then
				SetVehicleTyreBurst(vehicle, i, true, 1000)
			end
		end
	end

	if props.doors then
		for i = 0, 5 do
			if props.doors[i] ~= false then
				SetVehicleDoorBroken(vehicle, i - 1, true)
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
