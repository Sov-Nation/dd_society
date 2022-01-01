local AddCommand = import 'commands'
local ServerCallback = import 'callbacks'

AddCommand('admin', {'car', 'veh'}, function(source, args)
	if not args.vehicle then
		args.vehicle = 'elegy'
	elseif args.vehicle == 'random' then
		args.vehicle = Data.Vehicles[math.random(#Data.Vehicles)].model
	end
	TriggerClientEvent('dd_society:spawnVehicle', source, args.vehicle, false, true, false)
end, {'vehicle:?string'})

AddCommand('admin', {'givecar', 'giveveh'}, function(source, args)
	TriggerClientEvent('dd_society:spawnVehicle', args.target or source, args.vehicle, false, true, true)
end, {'vehicle:string', 'target:?number'})

RegisterServerEvent('dd_society:vCreateVehicle', function(props, name)
	local plyState = Player(source).state
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

	MySQL.insert.await('INSERT INTO owned_vehicles (vehicle, owner, name, plate, type) VALUES (?, ?, ?, ?, ?)', {json.encode(props), plyState.ident, name, props.plate, type})
end)

ServerCallback.Register('vList', function(source, cb, garage)
	local plyState = Player(source).state
	local vehicles

	if garage.type == 'boss' then
		local garages = {}
		local property = Indexed.Properties[garage.property]
		for i = 1, #property.zones do
			local zone = property.zones[i]
			if zone.type == 'garage' then
				garages[#garages + 1] = zone.id
			end
		end
		if next(garages) then
			vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner IN (?) OR garage IN (?)', {{plyState.ident, property.owner}, garages})
		else
			vehicles = MySQL.query.await('SELECT * WHERE owner IN ?', {{plyState.ident, property.owner}})
		end
		for i = 1, #vehicles do
			local vehicle = vehicles[i]
			vehicle.ownerName = getName(vehicle.owner)
		end
	else
		local vType
		if garage.type == 'garage' then
			vType = 'car'
		elseif garage.type == 'dock' then
			vType = 'boat'
		elseif garage.type == 'pad' then
			vType = 'heli'
		elseif garage.type == 'hangar' then
			vType = 'plane'
		end

		vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner IN (?) AND type = ?', {{plyState.ident, plyState.job}, vType})
	end

	cb(vehicles)
end)

ServerCallback.Register('vModify',function(source, cb, vehicle, change)
	local plyState = Player(source).state

	local Vehicle = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ?', {vehicle.props.plate})

	if Vehicle then
		if change.garage then
			if change.garage ~= Vehicle.garage then
				MySQL.update.await('UPDATE owned_vehicles SET garage = ? WHERE plate = ?', {change.garage, vehicle.props.plate})
			end
		end

		if change.props then
			local props = json.encode(change.props)
			if props ~= Vehicle.vehicle then
				MySQL.update.await('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', {props, vehicle.props.plate})
			end
		end

		if change.owner then
			if change.owner ~= Vehicle.owner then
				MySQL.update.await('UPDATE owned_vehicles SET owner = ? WHERE plate = ?', {change.owner, vehicle.props.plate})
			end
		end

		if change.name then
			if Vehicle.name ~= change.name then
				MySQL.update.await('UPDATE owned_vehicles SET name = ? WHERE plate = ?', {change.name, vehicle.props.plate})
			end
		end

		if change.plate then
			if Vehicle.plate ~= change.plate then
				MySQL.update.await('UPDATE owned_vehicles SET plate = ? WHERE plate = ?', {vehicle.props.plate, vehicle.props.plate})
			end
		end

		cb(true)
	else
		cb(false)
	end
end)
