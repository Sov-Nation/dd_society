ESX.RegisterCommand('revive', 'admin', function(xPlayer, args, showError)
	args.playerId = args.playerId or xPlayer.playerId
	Player(args.playerId).state.dead = false
	TriggerClientEvent('dd_society:revive', args.playerId, false)
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
	local ply = Player(playerId)
	ply.state.id = xPlayer.identifier
	local state = exports.oxmysql:scalarSync('SELECT state FROM users WHERE identifier = ?', {ply.state.id})
	state = json.decode(state)
	ply.state.dead = state.dead or false
	ply.state.ko = state.ko or 0
	ply.state.cuffed = state.cuffed or false
	ply.state.escorted = false
	ply.state.escorting = false
	ply.state.handsUp = false
end)

RegisterServerEvent('dd_society:saveState', function()
	local ply = Player(source)
	local state = {
		dead = ply.state.dead,
		ko = ply.state.ko,
		cuffed = ply.state.cuffed
	}
	exports.oxmysql:update('UPDATE users SET state = ? WHERE identifier = ?', {json.encode(state), ply.state.id})
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

RegisterNetEvent('dd_society:cuffPlayer', function(target)
	TriggerClientEvent('dd_society:cuffer', source, target, Player(target).state.cuffed, Player(target).state.escorted)
	TriggerClientEvent('dd_society:cuffee', target)
end)

RegisterNetEvent('dd_society:escortPlayer', function(target, vehicle, seat)
	local id = source
	local ply = Player(source)
	if ply.state.escorting == target then
		ply.state.escorting = false
		id = false
	elseif ply.state.escorting then
		TriggerClientEvent('dd_society:escort', ply.state.escorting, false, vehicle, seat)
		ply.state.escorting = target
	else
		ply.state.escorting = target
	end
	TriggerClientEvent('dd_society:escort', target, id, vehicle, seat)
end)

RegisterServerEvent('dd_society:saveJob', function(job)
	local xPlayer = ESX.GetPlayerFromId(source)
	exports.oxmysql:update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job.name, job.grade, xPlayer.identifier})
end)

function nearestRespawn(coords)
	local closest, distance = {}
	for k, v in pairs(Data.Respawn) do
		distance = #(coords - v.xyz)
		if not next(closest) or distance < closest.dist then
			closest.coords = v
			closest.dist = distance
		end
	end
	return closest.coords
end
