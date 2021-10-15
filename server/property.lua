ESX.RegisterServerCallback('dd_society:pTransferProperty', function(source, cb, id, target, name)
	if target == 'bank' then
		target = 'Doka & Doka'
	end

	exports.oxmysql:updateSync('UPDATE dd_properties SET owner = ? WHERE id = ?', {target, id})

	Data.Properties[id].owner = target
	Data.Properties[id].ownername = name

	TriggerClientEvent('dd_society:getProperties', -1, true)

	cb()
end)

ESX.RegisterServerCallback('dd_society:pRevokeAllKeys', function(source, cb, property, holders)
	for k, v in pairs(holders) do
		v.dd_keys[property] = nil

		local dd_keys = json.encode(v.dd_keys)
		exports.oxmysql:updateSync('UPDATE users SET dd_keys = ? WHERE identifier = ?', {dd_keys, v.identifier})

		local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
		if xPlayer then
			TriggerClientEvent('dd_society:getPlayer', xPlayer.source, 'self')
		end
	end

	cb()
end)

ESX.RegisterServerCallback('dd_society:pNewKey', function(source, cb, property, name)
	local insertId = exports.oxmysql:insertSync('INSERT INTO dd_keys (property, name) VALUES (?, ?)', {property, name})

	local NewKey = exports.oxmysql:singleSync('SELECT * FROM dd_keys WHERE id = ?', {insertId})

	NewKey.exempt_doors = {}
	NewKey.exempt_zones = {}
	Data.Keys[NewKey.id] = NewKey

	TriggerClientEvent('dd_society:syncKey', -1, NewKey)

	cb(NewKey)
end)

ESX.RegisterServerCallback('dd_society:pRenameKey', function(source, cb, id, name)
	exports.oxmysql:updateSync('UPDATE dd_keys SET name = ? WHERE id = ?', {name, id})

	Data.Keys[id].name = name

	TriggerClientEvent('dd_society:syncKey', -1, Data.Keys[id])

	cb()
end)

ESX.RegisterServerCallback('dd_society:pDeleteKey', function(source, cb, key, holders)
	if key.designation == 0 then
		cb(false)
		return
	end

	exports.oxmysql:executeSync('DELETE FROM dd_keys WHERE id = ?', {key.id})

	Data.Keys[key.id] = nil

	for k, v in pairs(holders) do
		removeKey(key.property, key.designation, v)
	end

	TriggerClientEvent('dd_society:syncKey', -1, key, true)

	cb(true)
end)

ESX.RegisterServerCallback('dd_society:pAddKey', function(source, cb, property, designation, player)
	if not player.dd_keys[property] then
		player.dd_keys[property] = {}
	elseif has_value(player.dd_keys[property], designation) then
		cb(false)
		return
	end

	table.insert(player.dd_keys[property], designation)

	local dd_keys = json.encode(player.dd_keys)
	exports.oxmysql:updateSync('UPDATE users SET dd_keys = ? WHERE identifier = ?', {dd_keys, player.identifier})

	local xPlayer = ESX.GetPlayerFromIdentifier(player.identifier)
	if xPlayer then
		TriggerClientEvent('dd_society:getPlayer', xPlayer.source, 'self')
	end

	cb(true)
end)

ESX.RegisterServerCallback('dd_society:pRemoveKey', function(source, cb, property, designation, player)
	removeKey(property, designation, player)

	cb()
end)

ESX.RegisterServerCallback('dd_society:pToggleKeyExemption', function(source, cb, key, id, holders, type)
	if key.designation == 0 then
		cb(false)
		return
	end

	local removed
	for k, v in pairs(key[type]) do
		if v == id then
			key[type][k] = nil
			removed = true
			break
		end
	end

	if not removed then
		table.insert(key[type], id)
	end

	Data.Keys[key.id] = key

	local exempt_doors = json.encode(key.exempt_doors)
	local exempt_zones = json.encode(key.exempt_zones)

	exports.oxmysql:updateSync('UPDATE dd_keys SET exempt_doors = ?, exempt_zones = ? WHERE id = ?', {exempt_doors, exempt_zones, key.id})

	for k, v in pairs(holders) do
		local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
		if xPlayer then
			TriggerClientEvent('dd_society:getPlayer', xPlayer.source, 'self')
		end
	end

	TriggerClientEvent('dd_society:syncKey', -1, key)

	cb(true)
end)

function removeKey(property, designation, player)
	for k, v in pairs(player.dd_keys[property]) do
		if v == designation then
			player.dd_keys[property][k] = nil
			break
		end
	end

	if #player.dd_keys[property] == 0 then
		player.dd_keys[property] = nil
	end

	local dd_keys = json.encode(player.dd_keys)
	exports.oxmysql:updateSync('UPDATE users SET dd_keys = ? WHERE identifier = ?', {dd_keys, player.identifier})

	local xPlayer = ESX.GetPlayerFromIdentifier(player.identifier)
	if xPlayer then
		TriggerClientEvent('dd_society:getPlayer', xPlayer.source, 'self')
	end
end

ESX.RegisterServerCallback('dd_society:pModifyDoor', function(source, cb, id, change)
	if change.name then
		exports.oxmysql:updateSync('UPDATE dd_doors SET name = ? WHERE id = ?', {change.name, id})
	elseif change.distance then
		exports.oxmysql:updateSync('UPDATE dd_doors SET distance = ? WHERE id = ?', {change.distance, id})
	elseif change.locked ~= nil then
		local locked = 0
		if change.locked then
			locked = 1
		end
		exports.oxmysql:updateSync('UPDATE dd_doors SET locked = ? WHERE id = ?', {locked, id})
	end

	for k, v in pairs(change) do
		Data.Doors[id][k] = v
	end

	TriggerClientEvent('dd_society:syncDoor', -1, Data.Doors[id])

	cb()
end)

ESX.RegisterServerCallback('dd_society:pModifyZone', function(source, cb, id, change)
	if change.name then
		exports.oxmysql:updateSync('UPDATE dd_zones SET name = ? WHERE id = ?', {change.name, id})
	elseif change.public ~= nil then
		local public = 0
		if change.public then
			public = 1
		end
		exports.oxmysql:updateSync('UPDATE dd_zones SET public = ? WHERE id = ?', {public, id})
	end

	for k, v in pairs(change) do
		Data.Zones[id][k] = v
	end

	TriggerClientEvent('dd_society:syncZone', -1, Data.Zones[id])

	cb()
end)
