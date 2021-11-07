ESX.RegisterCommand('revive', 'admin', function(xPlayer, args, showError)
	if not args.playerId then args.playerId = xPlayer.playerId end
	TriggerClientEvent('dd_society:revive', args.playerId, false)
end, true, {help = 'Revive a player', validate = false, arguments = {
	{name = 'playerId', help = 'The player id', type = 'any'}
}})

ESX.RegisterCommand('ko', 'admin', function(xPlayer, args, showError)
	if not args.playerId then args.playerId = xPlayer.playerId end
	TriggerClientEvent('dd_society:ko', args.playerId, args.time)
end, true, {help = 'Knock a player out', validate = false, arguments = {
	{name = 'playerId', help = 'The player id', type = 'any'},
	{name = 'time', help = 'Seconds to knock out for', type = 'any'},
}})

ESX.RegisterCommand('unko', 'admin', function(xPlayer, args, showError)
	if not args.playerId then args.playerId = xPlayer.playerId end
	TriggerClientEvent('dd_society:unko', args.playerId, args.time)
end, true, {help = 'Wake a player up', validate = false, arguments = {
	{name = 'playerId', help = 'The player id', type = 'any'},
	{name = 'time', help = 'Seconds to wait before the player is woken up', type = 'any'},
}})

ESX.RegisterCommand({'fr', 'fullrevive'}, 'admin', function(xPlayer, args, showError)
	if not args.playerId then args.playerId = xPlayer.playerId end
	TriggerClientEvent('dd_society:revive', args.playerId, true)
end, true, {help = 'Fully revive a player', validate = false, arguments = {
	{name = 'playerId', help = 'The player id', type = 'any'}
}})

RegisterServerEvent('dd_society:updateDeath', function(isDead)
	local xPlayer = ESX.GetPlayerFromId(source)

	if type(isDead) == 'boolean' then
		exports.oxmysql:update('UPDATE users SET is_dead = ? WHERE identifier = ?', {isDead, xPlayer.identifier})
	end
end)

RegisterServerEvent('dd_society:saveJob', function(job)
	local xPlayer = ESX.GetPlayerFromId(source)
	exports.oxmysql:update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job.name, job.grade, xPlayer.identifier})
end)
