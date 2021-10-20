Data = {
	Societies = {},
	Properties = {},
	Keys = {},
	Doors = {},
	Zones = {}
}

function data(name)
	local func, err = load(LoadResourceFile('dd_society', 'data/'..name..'.lua'), name, 't')
	assert(func, err == nil or '\n^1'..err..'^7')
	return func()
end

CreateThread(function()
	Data.Vehicles = data('vehicles')

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

		Data.Properties[v.id] = v
	end

	local Keys = exports.oxmysql:executeSync('SELECT * FROM dd_keys', {})
	for k, v in pairs(Keys) do
		v.exempt_doors = json.decode(v.exempt_doors)
		v.exempt_zones = json.decode(v.exempt_zones)
		Data.Keys[v.id] = v
	end

	local Doors = exports.oxmysql:executeSync('SELECT * FROM dd_doors', {})
	for k, v in pairs(Doors) do
		v.locked = v.onstart

		Data.Doors[v.id] = v
	end

	local Zones = exports.oxmysql:executeSync('SELECT * FROM dd_zones', {})
	for k, v in pairs(Zones) do		
		Data.Zones[v.id] = v
	end

	for i = 1, #Config.Properties do
		local property = data('properties/' .. Config.Properties[i])
		if not property then
			print(Config.Properties[i] .. '.lua file not found, fix your config at shared/properties.lua')
			return
		end
		property.id = Config.Properties[i]
		property.doors = property.doors or {}
		property.zones = property.zones or {}

		local Master = {name = 'Master', designation = 0, property = property.id}

		Data.Keys[#Data.Keys + 1] = Master

		if not Data.Properties[property.id] then
			Data.Properties[property.id] = property

			exports.oxmysql:insertSync('INSERT INTO dd_properties (id, owner) VALUES (?, ?)', {property.id, Config.Bank})


			for j = 1, #property.doors do
				door = property.doors[j]
				door.designation = j
				door.property = property.id
				door.id = #Data.Doors + 1

				Data.Doors[#Data.Doors + 1] = door
				
				exports.oxmysql:insertSync('INSERT INTO dd_doors (property, designation, name, distance, onstart) VALUES (?, ?, ?, ?, ?)', {door.property, door.designation, door.name, door.distance, door.onstart})
			end

			for j = 1, #property.zones do
				zone = property.zones[j]
				zone.designation = j
				zone.property = property.id
				zone.id = #Data.Zones + 1
				
				Data.Zones[#Data.Zones + 1] = zone

				exports.oxmysql:insertSync('INSERT INTO dd_zones (property, designation, name, public) VALUES (?, ?, ?, ?)', {zone.property, zone.designation, zone.name, zone.public})
			end
		else
			property.owner = Data.Properties[property.id].owner
			Data.Properties[property.id] = property

			for j = 1, #property.doors do
				door = property.doors[j]
				door.designation = j

				local dupeDoor
				for k = 1, #Data.Doors do
					if Data.Doors[k].property == property.id and Data.Doors[k].designation == door.designation then
						dupeDoor = Data.Doors[k]
						break
					end
				end

				if not dupeDoor then
					Data.Doors[#Data.Doors + 1] = door

					exports.oxmysql:insertSync('INSERT INTO dd_doors (property, designation, name, distance, onstart) VALUES (?, ?, ?, ?, ?)', {property.id, door.designation, door.name, door.distance, door.onstart})
				else
					door.id = dupeDoor.id
					door.property = dupeDoor.property
					door.name = dupeDoor.name
					door.distance = dupeDoor.distance
					door.onstart = dupeDoor.onstart
					door.locked = dupeDoor.locked

					Data.Doors[dupeDoor.id] = door
				end
			end

			for j = 1, #property.zones do
				zone = property.zones[j]
				zone.designation = j

				local dupe
				for k = 1, #Data.Zones do

					if Data.Zones[k].property == property.id and Data.Zones[k].designation == zone.designation then
						dupeZone = Data.Zones[k]
						break
					end
				end

				if not dupeZone then
					Data.Zones[#Data.Zones + 1] = zone

					exports.oxmysql:insertSync('INSERT INTO dd_zones (property, designation, name, public) VALUES (?, ?, ?, ?)', {property.id, zone.designation, zone.name, zone.public})
				else
					zone.id = dupeZone.id
					zone.property = dupeZone.property
					zone.name = dupeZone.name
					zone.public = dupeZone.public

					Data.Zones[dupeZone.id] = zone
				end
			end
		end
	end
end)

function setAuth(Player)
	Player.Auth = {
		Doors = {},
		Zones = {}
	}
	for k, v in pairs(Player.dd_keys) do
		if not Data.Properties[k] then
			Player.dd_keys[k] = nil
		end
	end
	for k, v in pairs(Player.dd_keys) do
		for k2, v2 in pairs(Data.Properties[k].doors) do
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
					if not has_value(Player.Auth.Doors, v2.id) then
						table.insert(Player.Auth.Doors, v2.id)
					end
				end
			end
		end
		for k2, v2 in pairs(Data.Properties[k].zones) do
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
					if not has_value(Player.Auth.Zones, v2.id) then
						table.insert(Player.Auth.Zones, v2.id)
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
