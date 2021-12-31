function setAuth(ident, keys)
	local keys = keys or json.decode(GetResourceKvpString(('%s:keys'):format(ident)))
	local auth = json.decode(GetResourceKvpString(('%s:auth'):format(ident))) or {doors = {}, zones = {}}

	for k, v in pairs(keys) do
		local property, id = string.strsplit(':', k)
		property = Indexed.Properties[property]

		for i = 1, #property.keys do
			if property.keys[i].id == k then
				local key = property.keys[i]
				for j = 1, #property.doors do
					local door = property.doors[j]
					if tonumber(id) == 0 or not key.exempt.doors[door.id] then
						auth.doors[door.id] = true
					end
				end

				for j = 1, #property.zones do
					local zone = property.zones[j]
					if tonumber(id) == 0 or not key.exempt.zones[zone.id] then
						auth.zones[zone.id] = true
					end
				end
				break
			end
		end
	end

	SetResourceKvp(('%s:keys'):format(ident), json.encode(keys))
	SetResourceKvp(('%s:auth'):format(ident), json.encode(auth))
	return keys, auth
end

ESX.RegisterCommand('keymaster', 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('dd_society:keymaster', xPlayer.playerId)
end, true, {help = 'Open Keymaster', validate = false, arguments = {}
})

ESX.RegisterCommand('revive', 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('dd_society:revive', args.playerId or xPlayer.playerId, false)
end, true, {help = 'Revive a player', validate = false, arguments = {
	{name = 'playerId', help = 'The player id', type = 'any'}
}})

ESX.RegisterCommand('ko', 'admin', function(xPlayer, args, showError)
	Player(args.playerId or xPlayer.playerId).state.ko = tonumber(args.time) or 30
end, true, {help = 'Knock a player out', validate = false, arguments = {
	{name = 'playerId', help = 'The player id', type = 'any'},
	{name = 'time', help = 'Seconds to knock out for', type = 'any'},
}})

ESX.RegisterCommand('unko', 'admin', function(xPlayer, args, showError)
	Player(args.playerId or xPlayer.playerId).state.ko = tonumber(args.time) or 0
end, true, {help = 'Wake a player up', validate = false, arguments = {
	{name = 'playerId', help = 'The player id', type = 'any'},
	{name = 'time', help = 'Seconds to wait before the player is woken up', type = 'any'},
}})

ESX.RegisterCommand({'fr', 'fullrevive'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('dd_society:revive', args.playerId or xPlayer.playerId, true)
end, true, {help = 'Fully revive and reset a player', validate = false, arguments = {
	{name = 'playerId', help = 'The player id', type = 'any'}
}})

RegisterServerEvent('esx:playerLoaded', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local plyState = Player(playerId).state

	plyState.ident = xPlayer.identifier

	plyState.dead = GetResourceKvpInt(('%s:dead'):format(plyState.ident)) == 1 or false
	plyState.ko = GetResourceKvpInt(('%s:ko'):format(plyState.ident)) or 0
	plyState.cuffed = GetResourceKvpInt(('%s:cuffed'):format(plyState.ident)) == 1 or false
	plyState.keys = json.decode(GetResourceKvpString(('%s:keys'):format(plyState.ident))) or {}
	plyState.auth = json.decode(GetResourceKvpString(('%s:auth'):format(plyState.ident))) or {doors = {}, zones = {}}

	plyState.escorted = false
	plyState.escorting = false
	plyState.handsUp = false
	plyState.loaded = true
end)

RegisterServerEvent('dd_society:saveState', function()
	local plyState = Player(source).state

	plyState.loaded = false

	SetResourceKvp(('%s:name'):format(plyState.ident), plyState.name)
	SetResourceKvp(('%s:job'):format(plyState.ident), plyState.job)
	SetResourceKvp(('%s:grade'):format(plyState.ident), plyState.grade)
	SetResourceKvpInt(('%s:dead'):format(plyState.ident), plyState.dead and 1 or 0)
	SetResourceKvpInt(('%s:ko'):format(plyState.ident), plyState.ko)
	SetResourceKvpInt(('%s:cuffed'):format(plyState.ident), plyState.cuffed and 1 or 0)
	SetResourceKvp(('%s:keys'):format(plyState.ident), json.encode(plyState.keys))
	SetResourceKvp(('%s:auth'):format(plyState.ident), json.encode(plyState.auth))
end)

RegisterServerEvent('dd_society:revivePlayer', function(player, coords)
	if coords then
		local xPlayer = ESX.GetPlayerFromId(player)
		local inventory = {}
		if next(xPlayer.inventory) then
			for k, v in pairs(xPlayer.inventory) do
				inventory[#inventory + 1] = {v.name, v.count, v.metadata}
			end
			TriggerEvent('ox_inventory:customDrop', xPlayer.getName() .. "'s Dropped Items", inventory, vec(coords.xy, coords.z + 1))
		end
		TriggerEvent('ox_inventory:clearPlayerInventory', player)
	end
	TriggerClientEvent('dd_society:revive', player, false, coords and nearestRespawn(coords))
end)

RegisterNetEvent('dd_society:cuff', function(target)
	local plyState, tgtState = Player(source).state, Player(target).state
	tgtState.cuffed = not tgtState.cuffed
	if tgtState.cuffed then
		tgtState.escorted = source
		plyState.escorting = target
	else
		tgtState.escorted = false
		plyState.escorting = false
	end
	TriggerClientEvent('dd_society:restrainer', source, tgtState.cuffed)
	TriggerClientEvent('dd_society:cuff', target, source, tgtState.cuffed)
end)

RegisterNetEvent('dd_society:escort', function(target, vehicle, seat)
	local plyState, tgtState = Player(source).state, Player(target).state
	if tgtState.escorted ~= source then
		tgtState.escorted = source
		plyState.escorting = target
	else
		tgtState.escorted = false
		plyState.escorting = false
	end
	TriggerClientEvent('dd_society:escort', target, source, tgtState.escorted, vehicle, seat)
end)

RegisterServerEvent('dd_society:saveJob', function(job)
	local xPlayer = ESX.GetPlayerFromId(source)
	local oldJob = exports.oxmysql:singleSync('SELECT job, job_grade FROM users WHERE identifier = ?', {xPlayer.identifier})

	if job.name ~= oldJob.job then
		local oldSociety = Indexed.Societies[oldJob.job]
		oldSociety.employees[xPlayer.identifier] = nil
		updateSociety(oldSociety)
	end

	local society = Indexed.Societies[job.name]
	society.employees[xPlayer.identifier] = {
		name = ('%s %s'):format(xPlayer.variables.firstName, xPlayer.variables.lastName),
		grade = job.grade
	}
	updateSociety(society)

	exports.oxmysql:update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job.name, job.grade, xPlayer.identifier})
end)

function nearestRespawn(coords)
	local closest, distance = {}
	for k, v in pairs(Respawn) do
		distance = #(coords - v.xyz)
		if not next(closest) or distance < closest.dist then
			closest.coords = v
			closest.dist = distance
		end
	end
	return closest.coords
end
