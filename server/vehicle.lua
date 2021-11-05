ESX.RegisterCommand({'car', 'veh'}, 'admin', function(xPlayer, args, showError)
	if not args.car then
		args.car = 'elegy'
	elseif args.car == 'random' then
		args.car = Data.Vehicles[math.random(#Data.Vehicles)].model
	end
	TriggerClientEvent('dd_society:spawnVehicle', xPlayer.source, args.car, false, true)
end, false, {help = 'Spawn a vehicle', validate = false, arguments = {
	{name = 'car', help = 'vehicle', type = 'any'}
}})

ESX.RegisterCommand({'givecar', 'giveveh'}, 'admin', function(xPlayer, args, showError)
	if not args.vehicle then return end
	if not args.playerId then
		args.playerId = xPlayer
	else
		args.playerId = ESX.GetPlayerFromId(args.playerId)
	end
	TriggerClientEvent('dd_society:spawnVehicle', args.playerId.playerId, args.vehicle, false, true, true)
end, true, {help = 'Spawn a vehicle and give it to a player', validate = false, arguments = {
	{name = 'vehicle', help = 'Vehicle', type = 'string'},
	{name = 'playerId', help = 'The player id', type = 'any'}
}})

RegisterServerEvent('dd_society:vCreateVehicle', function(props, name)
	local xPlayer = ESX.GetPlayerFromId(source)
	local category, type = Indexed.Vehicles[props.model].category

	if category == 'Boat' then
		type = 'boat'
	elseif category == 'Helicopter' then
		type = 'heli'
	elseif category == 'Plane' then
		type = 'plane'
	else
		type = 'car'
	end

	exports.oxmysql:insertSync('INSERT INTO owned_vehicles (vehicle, owner, name, plate, type) VALUES (?, ?, ?, ?, ?)', {json.encode(props), xPlayer.identifier, name, props.plate, type})
end)

ESX.RegisterServerCallback('dd_society:vList', function(source, cb, garage)
	local xPlayer = ESX.GetPlayerFromId(source)
	local Vehicles

	if garage.type == 'boss' then
		local garages = {}
		for k, v in pairs(Data.Properties[garage.property].zones) do
			if v.type == 'garage' then
				table.insert(garages, v.id)
			end
		end
		if not next(garages) then
			garages[1] = 'x'
		end
		Vehicles = exports.oxmysql:executeSync('SELECT owned_vehicles.*, users.firstname, users.lastname FROM owned_vehicles LEFT JOIN users ON owned_vehicles.owner = users.identifier WHERE (owner = ? OR owner = ? OR garage IN (?))', {xPlayer.identifier, xPlayer.job.label, garages})
	else
		local type
		if garage.type == 'garage' then
			type = 'car'
		elseif garage.type == 'dock' then
			type = 'boat'
		elseif garage.type == 'pad' then
			type = 'heli'
		elseif garage.type == 'hangar' then
			type = 'plane'
		end

		Vehicles = exports.oxmysql:executeSync('SELECT * FROM owned_vehicles WHERE (owner = ? OR owner = ?) AND type = ?', {xPlayer.identifier, xPlayer.job.label, type})
	end

	cb(Vehicles)
end)

ESX.RegisterServerCallback('dd_society:vModify',function(source, cb, vehicle, change)
	local xPlayer = ESX.GetPlayerFromId(source)

	local Vehicle = exports.oxmysql:singleSync('SELECT * FROM owned_vehicles WHERE plate = ?', {vehicle.props.plate})

	if Vehicle then
		if change.garage then
			if change.garage ~= Vehicle.garage then
				exports.oxmysql:updateSync('UPDATE owned_vehicles SET garage = ? WHERE plate = ?', {change.garage, vehicle.props.plate})
			end
		end

		if change.props then
			local props = json.encode(change.props)
			if props ~= Vehicle.vehicle then
				exports.oxmysql:updateSync('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', {props, vehicle.props.plate})
			end
		end

		if change.owner then
			if Vehicle.owner == xPlayer.identifier or Vehicle.owner == xPlayer.job.label then
				if change.owner ~= Vehicle.owner then
					exports.oxmysql:updateSync('UPDATE owned_vehicles SET owner = ? WHERE plate = ?', {change.owner, vehicle.props.plate})
				end
			else
				cb(false)
				return
			end
		end

		if Vehicle.owner == xPlayer.identifier or Vehicle.owner == xPlayer.job.label then
			if change.name then
				if Vehicle.name ~= change.name then
					exports.oxmysql:updateSync('UPDATE owned_vehicles SET name = ? WHERE plate = ?', {change.name, vehicle.props.plate})
				end
			end

			if change.plate then
				if Vehicle.plate ~= change.plate then
					exports.oxmysql:updateSync('UPDATE owned_vehicles SET plate = ? WHERE plate = ?', {vehicle.props.plate, vehicle.props.plate})
				end
			end
		elseif change.name or change.plate then
			cb(false)
			return
		end

		cb(true)
	else
		cb(false)
	end
end)
