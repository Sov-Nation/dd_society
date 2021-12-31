local table = import 'table'
local PropertyList
Respawn = {}

Data = {
	Properties = {},
	Doors = {},
	Zones = {},
}

Indexed = {
	Properties = {},
	Doors = {},
	Zones = {},
}

function data(name)
	local func, err = load(LoadResourceFile('dd_society', 'data/'..name..'.lua'), name, 't')
	assert(func, err == nil or '\n^1'..err..'^7')
	return func()
end

function createProperty(pType, id)
	local property = data('properties/' .. pType .. '/' .. id)

	property.id = id
	property.type = pType
	property.owner = Config.Bank
	property.ownerName = Config.BankName
	property.keys = {{name = 'Master', id = property.id .. ':0', holders = {}}}

	SetResourceKvp(id, json.encode(property))
end

function createTables()
	for k, v in pairs(PropertyList) do
		for k2, v2 in pairs(v) do
			local property = GetResourceKvpString(k2)
			property = json.decode(property)

			if property.respawn then
				Respawn[property.id] = property.respawn
			end

			Data.Properties[#Data.Properties + 1] = property

			for i = 1, #property.doors do
				property.doors[i].id = ('%s:%s'):format(property.id, i)
				property.doors[i].locked = property.doors[i].onstart
				Data.Doors[#Data.Doors + 1] = property.doors[i]
			end

			for i = 1, #property.zones do
				property.zones[i].id = ('%s:%s'):format(property.id, i)
				Data.Zones[#Data.Zones + 1] = property.zones[i]
			end
			SetResourceKvp(k2, json.encode(property))
		end
	end

	for i = 1, #Data.Properties do
		Indexed.Properties[Data.Properties[i].id] = Data.Properties[i]
	end

	for i = 1, #Data.Doors do
		Indexed.Doors[Data.Doors[i].id] = Data.Doors[i]
	end

	for i = 1, #Data.Zones do
		Indexed.Zones[Data.Zones[i].id] = Data.Zones[i]
	end

	for k, v in pairs(Data) do
		SetResourceKvp('Data:' .. k, json.encode(v))
		GlobalState['Data_' .. k] = Data[k]
	end

	for k, v in pairs(Indexed) do
		SetResourceKvp('Indexed:' .. k, json.encode(v))
		GlobalState['Indexed_' .. k] = Indexed[k]
	end

	SetResourceKvp('Respawn', json.encode(Respawn))
end

function loadTables()
	for k, v in pairs(Indexed) do
		Indexed[k] = json.decode(GetResourceKvpString('Indexed:' .. k))
		GlobalState['Indexed_' .. k] = Indexed[k]
	end

	for k, v in pairs(Data) do
		Data[k] = json.decode(GetResourceKvpString('Data:' .. k))
		GlobalState['Data_' .. k] = Data[k]
	end

	Respawn = json.decode(GetResourceKvpString('Respawn'))
end

function saveTables(tab, set, delete)
	Indexed[tab][set.id] = delete and nil or set

	for i = 1, #Data[tab] do
		if Data[tab][i].id == set.id then
			Data[tab][i] = delete and nil or set
			break
		end
	end

	SetResourceKvp('Indexed:'.. tab, json.encode(Indexed[tab]))
	GlobalState['Indexed_' .. tab] = Indexed[tab]

	SetResourceKvp('Data:'.. tab, json.encode(Data[tab]))
	GlobalState['Data_' .. tab] = Data[tab]
end

CreateThread(function()
	local PropertyData = {}
	local system = os.getenv('OS')
	local command = system and system:match('Windows') and 'dir "' or 'ls "'
	local path = GetResourcePath(GetCurrentResourceName())
	local types = path:gsub('//', '/') .. '/data/properties'
	local suffix = command == 'dir "' and '/" /b' or '/"'
	local dir = io.popen(command .. types .. suffix)
	for line in dir:lines() do
		PropertyData[line] = {}
		local properties = io.popen(command .. types .. '/' .. line .. suffix)
		for filename in properties:lines() do
			PropertyData[line][filename:gsub('.lua', '')] = true
		end
	end
	dir:close()

	PropertyList = GetResourceKvpString('PropertyList')
	if PropertyList then
		PropertyList = json.decode(PropertyList)
		if table.matches(PropertyList, PropertyData) then
			loadTables()
		else
			for k, v in pairs(PropertyData) do
				for k2, v2 in pairs(v) do
					if not PropertyList[k]?[k2] then
						createProperty(k, k2)
					end
				end
			end
			PropertyList = PropertyData
			SetResourceKvp('PropertyList', json.encode(PropertyList))
			createTables()
		end
	else
		PropertyList = PropertyData
		SetResourceKvp('PropertyList', json.encode(PropertyList))
		for k, v in pairs(PropertyList) do
			for k2, v2 in pairs(v) do
				createProperty(k, k2)
			end
		end
		createTables()
	end
	GlobalState['PropertyList'] = PropertyList

	for i = 1, #Data.Zones do
		local zone = Data.Zones[i]
		if zone.type == 'boss' then
			exports.ox_inventory:RegisterStash(zone.id, 'Boss Stash', 50, 50000, false)
		elseif zone.type == 'stash' then
			exports.ox_inventory:RegisterStash(zone.id, zone.name, 50, 50000, false)
		elseif zone.type == 'locker' then
			exports.ox_inventory:RegisterStash(zone.id, 'Personal Locker', 10, 10000, true)
		end
	end

	Data.Vehicles = data('vehicles')
	Indexed.Vehicles = {}
	for i = 1, #Data.Vehicles do
		local veh = Data.Vehicles[i]
		veh.hash = joaat(veh.model)
		Indexed.Vehicles[veh.hash] = veh
	end

	local Grades = exports.oxmysql:executeSync('SELECT * FROM job_grades', {})

	Data.Societies = exports.oxmysql:executeSync('SELECT * FROM jobs', {})
	Indexed.Societies = {}
	for i = 1, #Data.Societies do
		local society = Data.Societies[i]
		society.grades = {}
		for j = 1, #Grades do
			if Grades[j].job_name == society.name then
				society.grades[Grades[j].grade] = Grades[j]
			end
		end
		society.employees = json.decode(society.employees)
		society.acc = createAccount(society)
		Indexed.Societies[society.name] = society
	end

	GlobalState['Indexed_Societies'] = Indexed.Societies
	GlobalState['Data_Societies'] = Data.Societies
end)

ESX.RegisterServerCallback('dd_society:setJob', function(source, cb, societyId, ident, grade)
	local xPlayer = ESX.GetPlayerFromIdentifier(ident)
	local society = Indexed.Societies[societyId]
	if xPlayer then
		xPlayer.setJob(society.name, grade)
	else
		local oldJob = exports.oxmysql:scalarSync('SELECT job FROM users WHERE identifier = ?', {ident})

		if society.name ~= oldJob then
			local oldSociety = Indexed.Societies[oldJob]
			oldSociety.employees[xPlayer.identifier] = nil
			updateSociety(oldSociety)
		end

		local society = Indexed.Societies[job.name]
		society.employees[xPlayer.identifier] = {
			name = GetResourceKvpInt(('%s:name'):format(ident)),
			grade = grade
		}
		updateSociety(society)

		exports.oxmysql:update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job.name, job.grade, ident})
	end

	cb()
end)

ESX.RegisterServerCallback('dd_society:modifyGrade', function(source, cb, societyId, grade)
	local society = Indexed.Societies[societyId]
	society.grades[grade.grade] = grade

	updateSociety(society)

	exports.oxmysql:updateSync('UPDATE job_grades SET label = ?, salary = ? WHERE job_name = ? AND grade = ?', {grade.label, grade.salary, society.name, grade.grade})
	cb()
end)

function updateSociety(society)
	Indexed.Societies[society.name] = society

	for i = 1, #Data.Societies do
		if Data.Societies[i].name == society.name then
			Data.Societies[i] = society
			break
		end
	end

	GlobalState['Indexed_Societies'] = Indexed.Societies
	GlobalState['Data_Societies'] = Data.Societies

	exports.oxmysql:execute('UPDATE jobs SET colour = ?, account = ?, employees = ? WHERE name = ?', {society.colour, society.account, json.encode(society.employees), society.name})
end
