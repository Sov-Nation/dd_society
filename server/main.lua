Data = {
	Societies = {},
	Properties = {},
	Keys = {},
	Doors = {},
	Zones = {}
}

CreateThread(function()
	local Societies = exports.oxmysql:executeSync('SELECT * FROM jobs', {})
	for k, v in pairs(Societies) do
		v.grades = json.decode(v.grades)
		v.acc = createAccount(v)
		Data.Societies[v.label] = v
	end

	local Properties = exports.oxmysql:executeSync('SELECT dd_properties.*, users.firstname, users.lastname FROM dd_properties LEFT JOIN users ON dd_properties.owner = users.identifier', {})
	for k, v in pairs(Properties) do
		if v.firstname and v.lastname then
			v.ownername = v.firstname .. ' ' .. v.lastname
			v.fistname = nil
			v.lastname = nil
		end

		v.blip = vectorize(json.decode(v.blip))
		Data.Properties[v.id] = v
	end

	local Keys = exports.oxmysql:executeSync('SELECT * FROM dd_keys', {})
	for k, v in pairs(Keys) do
		v.exempt_doors = json.decode(v.exempt_doors)
		v.exempt_zones = json.decode(v.exempt_zones)
		Data.Keys[v.id] = v
	end
	for k, v in pairs(Data.Properties) do
		table.insert(Data.Keys, {
			name = 'Master',
			designation = 0,
			property = v.name,
			exempt_doors = {},
			exempt_zones = {}
		})
	end

	local Doors = exports.oxmysql:executeSync('SELECT * FROM dd_doors', {})
	for k, v in pairs(Doors) do
		if v.locked == 1 then
			v.locked = true
		else
			v.locked = false
		end

		v.object = vectorize(json.decode(v.object))
		v.text = vectorize(json.decode(v.text))
		v.state = v.locked
		Data.Doors[v.id] = v
	end

	local Zones = exports.oxmysql:executeSync('SELECT * FROM dd_zones', {})
	for k, v in pairs(Zones) do

		if v.public == 1 then
			v.public = true
		else
			v.public = false
		end

		v.zone = json.decode(v.zone)
		if v.zone.vec then
			v.zone.vec = vectorize(v.zone.vec)
		elseif v.zone.vecs then
			for k2, v2 in pairs(v.zone.vecs) do
				v.zone.vecs[k2] = vectorize(v2)
			end
		end

		local spawn = json.decode(v.spawn)
		v.spawn = {}
		for k2, v2 in pairs(spawn) do
			v.spawn[k2] = {}
			v.spawn[k2].coords, v.spawn[k2].heading = vectorize(v2)
		end

		Data.Zones[v.id] = v
	end
end)

function setAuth(Player)
	Player.Auth = {
		Doors = {},
		Zones = {}
	}
	for k, v in pairs(Player.dd_keys) do
		for k2, v2 in pairs(Data.Doors) do
			if k == v2.property then
				for k3, v3 in pairs(v) do
					local insert = false
					if v3 == 0 then
						insert = true
					else
						for k4, v4 in pairs(Data.Keys) do
							if k == v4.property and v3 == v4.designation then
								if not has_value(v4.exempt_doors, k2) then
									insert = true
								end
								break
							end
						end
					end
					if insert then
						if not has_value(Player.Auth.Doors, k2) then
							table.insert(Player.Auth.Doors, k2)
						end
					end
				end
			end
		end
		for k2, v2 in pairs(Data.Zones) do
			if k == v2.property then
				for k3, v3 in pairs(v) do
					local insert = false
					if v3 == 0 then
						insert = true
					else
						for k4, v4 in pairs(Data.Keys) do
							if k == v4.property and v3 == v4.designation then
								if not has_value(v4.exempt_zones, k2) then
									insert = true
								end
								break
							end
						end
					end
					if insert then
						if not has_value(Player.Auth.Zones, k2) then
							table.insert(Player.Auth.Zones, k2)
						end
					end
				end
			end
		end
	end
end

ESX.RegisterServerCallback('dd_society:setJob', function(source, cb, society, identifier, grade)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
	if xPlayer then
		xPlayer.setJob(society.name, grade)
	else
		exports.oxmysql:updateSync('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {society.name, grade, identifier})
	end

	cb()
end)

ESX.RegisterServerCallback('dd_society:modifyGrade', function(source, cb, society, grade, change)
	if change.label then
		exports.oxmysql:updateSync('UPDATE job_grades SET label = ? WHERE job_name = ? AND grade = ?', {change.label, society.name, grade})
	elseif change.salary then
		exports.oxmysql:updateSync('UPDATE job_grades SET salary = ? WHERE job_name = ? AND grade = ?', {change.salary, society.name, grade})
	end

	cb()
end)

ESX.RegisterServerCallback('dd_society:getPlayer', function(source, cb, ident)
	if ident == 'self' then
		ident = nil
		while not ident do
			Wait(0)
			ident = ESX.GetPlayerFromId(source).identifier
		end
	end

	local Player = exports.oxmysql:singleSync('SELECT identifier, dd_keys, firstname, lastname FROM users WHERE identifier = ?', {ident})

	Player.dd_keys = json.decode(Player.dd_keys)
	Player.fullname = Player.firstname .. ' ' .. Player.lastname

	setAuth(Player)

	cb(Player)
end)

ESX.RegisterServerCallback('dd_society:getPlayers', function(source, cb)
	local Players = exports.oxmysql:executeSync('SELECT identifier, dd_keys, firstname, lastname FROM users', {})

	for k, v in pairs(Players) do
		v.dd_keys = json.decode(v.dd_keys)
		v.fullname = v.firstname .. ' ' .. v.lastname
	end

	cb(Players)
end)

ESX.RegisterServerCallback('dd_society:getEmployees', function(source, cb, society)
	local Employees = exports.oxmysql:executeSync('SELECT identifier, dd_keys, firstname, lastname, job_grade FROM users WHERE job = ?', {society.name})

	local Grades = exports.oxmysql:executeSync('SELECT job_grades.grade, job_grades.name, job_grades.label, job_grades.salary FROM job_grades WHERE job_name = ?', {society.name})
	
	for k, v in pairs(Employees) do
		for k2, v2 in pairs(Grades) do
			if v.job_grade == v2.grade then
				v.grade = v2
				v.job_grade = nil
				break
			end
		end
		
		v.dd_keys = json.decode(v.dd_keys)
		v.fullname = v.firstname .. ' ' .. v.lastname
	end

	cb(Employees, Grades)
end)

ESX.RegisterServerCallback('dd_society:getSocieties', function(source, cb)
	cb(Data.Societies)
end)

ESX.RegisterServerCallback('dd_society:getProperties', function(source, cb)
	cb(Data.Properties)
end)

ESX.RegisterServerCallback('dd_society:getKeys', function(source, cb)
	cb(Data.Keys)
end)

ESX.RegisterServerCallback('dd_society:getDoors', function(source, cb)
	cb(Data.Doors)
end)

ESX.RegisterServerCallback('dd_society:getZones', function(source, cb)
	cb(Data.Zones)
end)

function updateSociety(Society, save)
	Data.Societies[Society.label] = Society
	TriggerClientEvent('dd_society:updateSociety', -1, Society)
	if save then
		exports.oxmysql:execute('UPDATE jobs SET colour = ?, account = ? WHERE name = ?', {Society.colour, Society.account, Society.name})
	end
end

RegisterNetEvent('dd_society:updateDoor', function(Door)
	Data.Doors[Door.id] = Door
	TriggerClientEvent('dd_society:updateDoor', -1, Door)
end)
