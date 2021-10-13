ESX.RegisterServerCallback('dd_society:pNewKey', function(source, cb, property, name)
	local insertId = exports.oxmysql:insertSync('INSERT into dd_keys (property, name) VALUES (?, ?)', {property, name})

	local NewKey = exports.oxmysql:singleSync('SELECT * FROM dd_keys WHERE id = ?', {insertId})

	NewKey.exempt_doors = {}
	NewKey.exempt_zones = {}
	Data.Keys[NewKey.id] = NewKey

	TriggerClientEvent('dd_society:getKeys', -1)

	cb(NewKey)
end)

ESX.RegisterServerCallback('dd_society:pAddKey', function(source, cb, property, designation, player)
	local xPlayer = ESX.GetPlayerFromIdentifier(player.identifier)

	table.insert(player.dd_keys[property], designation)

	local dd_keys = json.encode(player.dd_keys)
	exports.oxmysql:updateSync('UPDATE users SET dd_keys = ? WHERE identifier = ?', {dd_keys, player.identifier})

	if xPlayer then
		TriggerClientEvent('dd_society:getPlayer', xPlayer.source, 'self')
	end

	cb()
end)

ESX.RegisterServerCallback('dd_society:pRemoveKey', function(source, cb, property, designation, player)
	local xPlayer = ESX.GetPlayerFromIdentifier(player.identifier)

	for k, v in pairs(player.dd_keys[property]) do
		if v == designation then
			player.dd_keys[property][k] = nil
			break
		end
	end

	local dd_keys = json.encode(player.dd_keys)
	exports.oxmysql:updateSync('UPDATE users SET dd_keys = ? WHERE identifier = ?', {dd_keys, player.identifier})

	if xPlayer then
		TriggerClientEvent('dd_society:getPlayer', xPlayer.source, 'self')
	end

	cb()
end)
