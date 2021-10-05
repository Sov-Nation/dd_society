local authDone = false

Data = {
	Societies = {},
	Properties = {},
	Keys = {},
	Doors = {},
	Zones = {}
}

AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		SQLFetchData()
	end
end)

function SQLFetchData()
	local Societies = exports.oxmysql:executeSync('SELECT * FROM jobs', {})
	for k, v in pairs(Societies) do
		v.grades = json.decode(v.grades)
		Data.Societies[v.label] = v
		CreateAccounts()
	end

	local Properties = exports.oxmysql:executeSync('SELECT * FROM dd_properties', {})
	for k, v in pairs(Properties) do
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
		v.object = vectorize(json.decode(v.object))
		v.text = vectorize(json.decode(v.text))
		v.state = v.locked
		Data.Doors[v.id] = v
	end

	local Zones = exports.oxmysql:executeSync('SELECT * FROM dd_zones', {})
	for k, v in pairs(Zones) do
							
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
end

function setAuth(single, player, players)
	local Tab = players

	if single then
		Tab ={}
		Tab[1] = player
	end

	for k, v in pairs(Tab) do
		v.Auth = {
			Doors = {},
			Zones = {}
		}
		for k2, v2 in pairs(v.dd_keys) do
			for k3, v3 in pairs(Data.Doors) do
				if k2 == v3.property then
					for k4, v4 in pairs(v2) do
						local insert = false
						if v4 == 0 then
							insert = true
						else
							for k5, v5 in pairs(Data.Keys) do
								if k2 == v5.property and v4 == v5.designation then
									if not has_value(v5.exempt_doors, k3) then
										insert = true
									end
									break
								end
							end
						end
						if insert then
							if not has_value(v.Auth.Doors, k3) then
								table.insert(v.Auth.Doors, k3)
							end
						end
					end
				end
			end
			for k3, v3 in pairs(Data.Zones) do
				if k2 == v3.property then
					for k4, v4 in pairs(v2) do
						local insert = false
						if v4 == 0 then
							insert = true
						else
							for k5, v5 in pairs(Data.Keys) do
								if k2 == v5.property and v4 == v5.designation then
									if not has_value(v5.exempt_zones, k3) then
										insert = true
									end
									break
								end
							end
						end
						if insert then
							if not has_value(v.Auth.Zones, k3) then
								table.insert(v.Auth.Zones, k3)
							end
						end
					end
				end
			end
		end
	end
end

ESX.RegisterServerCallback('dd_society:getPlayer', function(source, cb, ident)
	if ident == 'self' then
		ident = nil
		while not ident do
			Wait(0)
			ident = ESX.GetPlayerFromId(source).identifier
		end
	end

	local result = exports.oxmysql:executeSync('SELECT identifier, dd_keys, firstname, lastname, job, job_grade FROM users WHERE identifier = ?', {ident})

	Player = result[1]

	Player.dd_keys = json.decode(Player.dd_keys)
	if Player.firstname ~= '' and Player.lastname ~= '' then
		Player.fullname = Player.firstname .. ' ' .. Player.lastname
	else
		Player.fullname = '(No name)'
	end

	setAuth(true, Player, nil)

	cb(Player)
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

-- RegisterNetEvent('dd_society:updatePlayer')
-- AddEventHandler('dd_society:updatePlayer', function(Player, save)
-- 	Data.Players[Player.identifier] = Player
-- 	TriggerClientEvent('dd_society:updatePlayer', -1, Player)
-- 	if save then
-- 		local Keys = json.encode(Player.dd_keys)
-- 		MySQL.Async.execute('UPDATE users SET dd_keys = @dd_keys WHERE identifier = @identifier', {
--             ['@identifier'] = Player.identifier,
--             ['@dd_keys'] 	= Keys
--         })
-- 	end
-- end)

-- RegisterNetEvent('dd_society:updateProperty')
-- AddEventHandler('dd_society:updateProperty', function(Property, save)
-- 	Data.Properties[Property.id] = Property
-- 	TriggerClientEvent('dd_society:updateProperty', source, Property)
-- 	if save then
-- 		MySQL.Async.execute('UPDATE dd_properties SET owner = @owner WHERE id = @id', {
--             ['@id'] 	= Property.id,
--             ['@owner'] 	= Property.owner
--         })
-- 	end
-- end)

RegisterNetEvent('dd_society:updateDoor')
AddEventHandler('dd_society:updateDoor', function(Door, save)
	Data.Doors[Door.id] = Door
	TriggerClientEvent('dd_society:updateDoor', -1, Door)
	if save then
		MySQL.Async.execute('UPDATE dd_doors SET name = @name, locked = @locked, distance = @distance WHERE id = @id', {
            ['@name'] 		= Door.name,
            ['@locked'] 	= Door.locked,
            ['@distance'] 	= Door.distance,
            ['@id'] 		= Door.id
        })
	end
end)

-- RegisterServerEvent('dd_society:washMoney') --TODO
-- AddEventHandler('dd_society:washMoney', function(society, amount)
-- 	local xPlayer = ESX.GetPlayerFromId(source)
-- 	local account = xPlayer.getAccount('black_money')
-- 	amount = ESX.Math.Round(tonumber(amount))

-- 	if xPlayer.job.name == society then
-- 		if amount and amount > 0 and account.money >= amount then
-- 			xPlayer.removeAccountMoney('black_money', amount)

-- 			MySQL.Async.execute('INSERT INTO society_moneywash (identifier, society, amount) VALUES (@identifier, @society, @amount)', {
-- 				['@identifier'] = xPlayer.identifier,
-- 				['@society'] = society,
-- 				['@amount'] = amount
-- 			}, function(rowsChanged)
-- 				xPlayer.showNotification(_U('you_have', ESX.Math.GroupDigits(amount)))
-- 			end)
-- 		else
-- 			xPlayer.showNotification(_U('invalid_amount'))
-- 		end
-- 	else
-- 		print(('dd_society: %s attempted to call washMoney!'):format(xPlayer.identifier))
-- 	end
-- end)

-- ESX.RegisterServerCallback('dd_society:setJob', function(source, cb, identifier, job, grade, type)
-- 	local xPlayer = ESX.GetPlayerFromId(source)
-- 	local isBoss = xPlayer.job.grade_name == 'boss'

-- 	if isBoss then
-- 		local xTarget = ESX.GetPlayerFromIdentifier(identifier)

-- 		if xTarget then
-- 			xTarget.setJob(job, grade)

-- 			if type == 'hire' then
-- 				xTarget.showNotification(_U('you_have_been_hired', job))
-- 			elseif type == 'promote' then
-- 				xTarget.showNotification(_U('you_have_been_promoted'))
-- 			elseif type == 'fire' then
-- 				xTarget.showNotification(_U('you_have_been_fired', xTarget.getJob().label))
-- 			end

-- 			cb()
-- 		else
-- 			MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @job_grade WHERE identifier = @identifier', {
-- 				['@job']        = job,
-- 				['@job_grade']  = grade,
-- 				['@identifier'] = identifier
-- 			}, function(rowsChanged)
-- 				cb()
-- 			end)
-- 		end
-- 	else
-- 		print(('dd_society: %s attempted to setJob'):format(xPlayer.identifier))
-- 		cb()
-- 	end
-- end)

-- function WashMoneyCRON(d, h, m)
-- 	MySQL.Async.fetchAll('SELECT * FROM society_moneywash', {}, function(result)
-- 		for i=1, #result, 1 do
-- 			local society = GetSociety(result[i].society)
-- 			local xPlayer = ESX.GetPlayerFromIdentifier(result[i].identifier)

-- 			-- add society money
-- 			TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
-- 				account.addMoney(result[i].amount)
-- 			end)

-- 			-- send notification if player is online
-- 			if xPlayer then
-- 				xPlayer.showNotification(_U('you_have_laundered', ESX.Math.GroupDigits(result[i].amount)))
-- 			end

-- 			MySQL.Async.execute('DELETE FROM society_moneywash WHERE id = @id', {
-- 				['@id'] = result[i].id
-- 			})
-- 		end
-- 	end)
-- end

-- TriggerEvent('cron:runAt', 3, 0, WashMoneyCRON)
