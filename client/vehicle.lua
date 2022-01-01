local ServerCallback = import 'callbacks'

carInstance = {}
SetDefaultVehicleNumberPlateTextPattern(-1, Config.defaultPlate)

RegisterNetEvent('dd_society:spawnVehicle', function(vehicle, coords, delete, owner)
	local veh = spawnVehicle(vehicle, coords, delete)
	if owner and veh then
		local props = getVehicleProperties(veh)
		local name = GetLabelText(GetDisplayNameFromVehicleModel(props.model))

		TriggerServerEvent('dd_society:vCreateVehicle', props, name)
		carInstance[props.plate] = veh
	end
end)

function spawnVehicle(vehicle, coords, delete)
	local model = lib.requestModel(vehicle, 5000)
	if model then
		local vec = coords and coords.xyz or pedPos
		local heading = coords and coords.w or GetEntityHeading(PlayerBags.Player.ped)

		local oldVeh = GetVehiclePedIsIn(PlayerBags.Player.ped)
		local vehicle = CreateVehicle(model, vec, heading, true, false)
		SetModelAsNoLongerNeeded(model)

		RequestCollisionAtCoord(vec)
		repeat Wait(0) until HasCollisionLoadedAroundEntity(vehicle)

		if delete then
			if oldVeh and oldVeh ~= 0 then
				local velocity = GetEntityVelocity(oldVeh)
				local fVec = GetEntityForwardVector(oldVeh)
				DeleteEntity(oldVeh)
				if #velocity > 0.1 then
					local fVel = fVec * velocity
					local lVel = fVec / velocity
					SetEntityVelocity(vehicle, lVel)
					if fVel.x > 0 and fVel.y > 0 and fVel.z > 0 then
						SetVehicleForwardSpeed(vehicle, #fVel)
					end
				end
			end
			SetVehicleHasBeenOwnedByPlayer(vehicle, true)
			SetVehicleNeedsToBeHotwired(vehicle, false)
			SetVehRadioStation(vehicle, 'OFF')
			SetVehicleEngineOn(vehicle, true, true, true)
			SetPedIntoVehicle(PlayerBags.Player.ped, vehicle, -1)
		end
		return vehicle
	else
		TriggerEvent('chat:addMessage', { args = { '^1SYSTEM', 'Unable to load vehicle model - ' .. vehicle } })
	end
end

function storeVehicle(zone)
	if IsPedInAnyVehicle(PlayerBags.Player.ped, false) then
		local vehicleId = GetVehiclePedIsIn(PlayerBags.Player.ped, false)
		if GetPedInVehicleSeat(vehicleId, -1) == PlayerBags.Player.ped then
			local vehicle = {}
			vehicle.props = getVehicleProperties(vehicleId)
			if vehicle.props then
				ServerCallback.Async('dd_society', 'vModify', 100, function(valid)
					if valid then
						ESX.UI.Menu.CloseAll()
						for i = -1, GetVehicleMaxNumberOfPassengers(vehicleId) do
							TaskLeaveVehicle(GetPedInVehicleSeat(vehicleId, i), vehicleId, 4160)
						end
						Wait(1800)
						DeleteEntity(vehicleId)
						ESX.ShowNotification('Your ~y~vehicle ~w~is ~g~stored')
					else
						ESX.ShowNotification('~r~You cannot store this vehicle')
					end
				end, vehicle, {garage = ('%s-stored'):format(zone.id), props = vehicle.props})
			else
				ESX.ShowNotification('~r~Error finding vehicle')
			end
		else
			ESX.ShowNotification('~r~You are not the driver')
		end
	else
		ESX.ShowNotification('~r~There is no vehicle to store')
	end
end

function pickSpot(zone)
	for i = 1, #zone.spawn*2 do
		local spot = vectorize(zone.spawn[math.random(1, #zone.spawn)])
		if ESX.Game.IsSpawnPointClear(spot.xyz, 3.0) then
			return spot
		end
	end
	return false
end

function spawnAtSpot(vehicle, spot)
	local veh = spawnVehicle(vehicle.props.model, spot, false, false)

	setVehicleProperties(veh, vehicle.props)

	if carInstance[vehicle.props.plate] then
		if DoesEntityExist(carInstance[vehicle.props.plate]) then
			ESX.Game.DeleteVehicle(carInstance[vehicle.props.plate])
			carInstance[vehicle.props.plate] = veh
		end
	end

	ESX.ShowNotification('Your ~y~vehicle ~w~is ~g~ready')

	CreateThread(function()
		local vehicleBlip = AddBlipForCoord(spot.xy)
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
