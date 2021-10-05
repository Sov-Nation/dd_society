ESX.RegisterCommand({'givecar', 'giveveh'}, 'admin', function(xPlayer, args, showError)
	if not args.playerId then 
		args.playerId = xPlayer 
	else 
		args.playerId = ESX.GetPlayerFromId(args.playerId) 
	end
	Wait(500)
end, true, {help = 'Spawn a vehicle and give it to a player', validate = false, arguments = {
	{name = 'vehicle', help = 'Vehicle', type = 'any'},
	{name = 'playerId', help = 'The player id', type = 'any'}
}})


ESX.RegisterServerCallback('dd_society:gList', function(source, cb, garage)
	local xPlayer = ESX.GetPlayerFromId(source)
	local Vehicles 

	if garage.type == 'boss' then
		local garages = {}
		for k, v in pairs(Data.Zones) do
			if v.property == garage.property and v.type == 'garage' then
				table.insert(garages, v.id)
			end
		end
		Vehicles = exports.oxmysql:executeSync("SELECT * FROM owned_vehicles WHERE (owner = ? OR owner = ? OR garage IN (?))", {xPlayer.identifier, xPlayer.job.label, garages})
	else
		Vehicles = exports.oxmysql:executeSync("SELECT * FROM owned_vehicles WHERE (owner = ? OR owner = ?)", {xPlayer.identifier, xPlayer.job.label})
	end

	cb(Vehicles)
end)

ESX.RegisterServerCallback('dd_society:gModify',function(source, cb, vehicle, change)
	local xPlayer = ESX.GetPlayerFromId(source)

	local Vehicle = exports.oxmysql:singleSync("SELECT * FROM owned_vehicles WHERE plate = ?", {vehicle.props.plate})

	if next(Vehicle) then
		if change.garage then
			if change.garage ~= Vehicle.garage then
				local _ = exports.oxmysql:update("UPDATE owned_vehicles SET garage = ? WHERE plate = ?", {change.garage, vehicle.props.plate})
			end
		end

		if change.props then
			local props = json.encode(change.props)
			if props ~= Vehicle.vehicle then
				local _ = exports.oxmysql:update("UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?", {props, vehicle.props.plate})
			end
		end

		if Vehicle.owner == xPlayer.identifier or Vehicle.owner == xPlayer.job.label then
			if change.name then
				if Vehicle.name ~= change.name then
					local _ = exports.oxmysql:update("UPDATE owned_vehicles SET name = ? WHERE plate = ?", {change.name, vehicle.props.plate})
				end
			end

			if change.plate then
				if Vehicle.plate ~= change.plate then
					local _ = exports.oxmysql:update("UPDATE owned_vehicles SET plate = ? WHERE plate = ?", {vehicle.props.plate, vehicle.props.plate})
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
