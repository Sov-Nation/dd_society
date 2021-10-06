ESX.RegisterCommand({'givecar', 'giveveh'}, 'admin', function(xPlayer, args, showError)
	if not args.vehicle then return end
	if not args.playerId then 
		args.playerId = xPlayer 
	else 
		args.playerId = ESX.GetPlayerFromId(args.playerId) 
	end
	local plate = genPlate()
	TriggerClientEvent('dd_society:createVehicle', args.playerId.playerId, args.vehicle, plate)
end, true, {help = 'Spawn a vehicle and give it to a player', validate = false, arguments = {
	{name = 'vehicle', help = 'Vehicle', type = 'string'},
	{name = 'playerId', help = 'The player id', type = 'any'}
}})

local Chars = {}
for i = 48, 57 do
    table.insert(Chars, utf8.char(i))
	table.insert(Chars, utf8.char(i))
	table.insert(Chars, utf8.char(i))
	table.insert(Chars, utf8.char(i))
	table.insert(Chars, utf8.char(i))
end
for i = 65, 90 do
    table.insert(Chars, utf8.char(i))
    table.insert(Chars, utf8.char(i))
end

function genPlate()
	local Vehicles = exports.oxmysql:executeSync('SELECT plate FROM owned_vehicles', {})
	for k, v in pairs(Vehicles) do 
		v = v.plate
	end

	math.randomseed(os.time())
	for i = 1, 10 do
		local plate

		for i = 1, 7 do
			local c = Chars[math.random(#Chars)]
			if not plate then
				plate = c
			elseif i == 4 then
				plate = plate .. ' '
			else
				plate = plate .. c
			end
		end

		if not has_value(Vehicles, plate) then
			return plate
		end

		return false
	end
end

RegisterServerEvent('dd_society:vCreateVehicle')
AddEventHandler('dd_society:vCreateVehicle', function(props, owner, name)
	local Society = Data.Societies[owner]
	local plate = props.plate
	props = json.encode(props)
	local type = 'car'
	-- local type = Data.Vehicles[vehicle.model].type -- need to finish vehicles table first

	if not Society then
		xOwner = ESX.GetPlayerFromId(owner)
		owner = xOwner.identifier
	end

	exports.oxmysql:insert('INSERT INTO owned_vehicles (vehicle, owner, name, plate, type) VALUES (?, ?, ?, ?, ?)', {props, owner, name, plate, type}, 
	function(insertId)
	end)

	cb(Vehicles)
end)

ESX.RegisterServerCallback('dd_society:vList', function(source, cb, garage)
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

ESX.RegisterServerCallback('dd_society:vModify',function(source, cb, vehicle, change)
	local xPlayer = ESX.GetPlayerFromId(source)

	local Vehicle = exports.oxmysql:singleSync("SELECT * FROM owned_vehicles WHERE plate = ?", {vehicle.props.plate})

	if next(Vehicle) then
		if change.garage then
			if change.garage ~= Vehicle.garage then
				exports.oxmysql:update("UPDATE owned_vehicles SET garage = ? WHERE plate = ?", {change.garage, vehicle.props.plate})
			end
		end

		if change.props then
			local props = json.encode(change.props)
			if props ~= Vehicle.vehicle then
				exports.oxmysql:update("UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?", {props, vehicle.props.plate})
			end
		end

		if Vehicle.owner == xPlayer.identifier or Vehicle.owner == xPlayer.job.label then
			if change.name then
				if Vehicle.name ~= change.name then
					exports.oxmysql:update("UPDATE owned_vehicles SET name = ? WHERE plate = ?", {change.name, vehicle.props.plate})
				end
			end

			if change.plate then
				if Vehicle.plate ~= change.plate then
					exports.oxmysql:update("UPDATE owned_vehicles SET plate = ? WHERE plate = ?", {vehicle.props.plate, vehicle.props.plate})
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