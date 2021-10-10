function CreateAccounts()
	while not next(Data.Societies) do
		wait(10)
	end
	for k, v in pairs(Data.Societies) do
		v.acc = createAccount(v)
	end
end

function createAccount(society)
	local self = {}

	self.label  = society.label
	self.account = society.account

	self.addMoney = function(m)
		self.account = self.account + m
		self.save()
	end

	self.removeMoney = function(m)
		self.account = self.account - m
		self.save()
	end

	self.setMoney = function(m)
		self.account = m
		self.save()
	end

	self.save = function()
		Data.Societies[self.label].account = self.account
		updateSociety(Data.Societies[self.label], true)
	end

	return self
end

ESX.RegisterServerCallback('dd_society:aPayMoney', function(source, cb, amount, account, target, details, cut) -- add cut functionality
	local xPlayer = ESX.GetPlayerFromId(source)
	local acc = xPlayer.getAccount(account)

	if acc.money >= amount then
		if target then
			local Society = Data.Societies[target]
			if Society then
				Society.acc.addMoney(amount)
				xPlayer.showNotification('Paid ~g~$' .. amount .. ' ~w~from ' .. account .. ' account to ~y~' .. target) --fix up so it makes more sense with different accounts
			else
				local xTarget = ESX.GetPlayerFromId(target)
				xTarget.addAccountMoney('bank', amount)
				xPlayer.showNotification('Paid ~g~$' .. amount .. ' ~w~from ' .. account .. ' account to ~y~' .. target) --fix up so it makes more sense with different accounts and player name
			end
		else
			xPlayer.showNotification('Paid ~g~$' .. amount .. ' ~w~from ' .. account .. ' account into the void')
		end
		xPlayer.removeAccountMoney(account, amount)
		cb(true)
	elseif account == 'bank' and amount <= 10000 and target then
		TriggerEvent('dd_society:aCreateBill', source, amount, target, details)
		xPlayer.showNotification('~r~There is not enough money in your bank account, bill added instead')
		cb(true)
	else
		xPlayer.showNotification("~r~You don't have enough money")
		cb(false)
	end
end)

ESX.RegisterServerCallback('dd_society:aPaySocietyMoney', function(source, cb, amount, account, target, society)
	local xPlayer = ESX.GetPlayerFromId(source)
	local Soc = Data.Societies[society]

	if Soc.account >= amount then
		if target then
			local tSoc = Data.Societies[target]
			if tSoc then
				tSoc.acc.addMoney(amount)
				xPlayer.showNotification('~y~' .. target .. ' ~w~received ~g~$' .. amount .. ' ~w~from ~y~' .. society)
			else
				local xTarget = ESX.GetPlayerFromId(target)
				xTarget.addAccountMoney(account, amount)
				xPlayer.showNotification('~y~' .. target .. ' ~w~received ~g~$' .. amount .. ' ~w~from ~y~' .. society)
			end
		else
			xPlayer.addAccountMoney(account, amount)
			xPlayer.showNotification('You ~w~received ~g~$' .. amount .. ' ~w~from ~y~' .. society)
		end
		Soc.acc.removeMoney(amount)
		cb(true)
	else
		xPlayer.showNotification("~r~You don't have enough money")
		cb(false)
	end
end)

RegisterServerEvent('dd_society:aCreateBill')
AddEventHandler('dd_society:aCreateBill', function(player, amount, target, details)
	local xPlayer = ESX.GetPlayerFromId(player)
	local Society = Data.Societies[target]

	if not Society then
		xTarget = ESX.GetPlayerFromId(target)
		target = xTarget.identifier
	end

	if xPlayer then
		exports.oxmysql:insert('INSERT INTO dd_bills (player, target, amount, details, timestamp) VALUES (?, ?, ?, ?, ?)', {xPlayer.identifier, target, amount, details, os.time() + 75600},
		function(insertId)
			xPlayer.showNotification('You have received an invoice')
		end)
	end
end)

ESX.RegisterServerCallback('dd_society:aGetPlayerBills', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if target then
		xPlayer = ESX.GetPlayerFromId(target)
	end

	exports.oxmysql:execute('SELECT id, target, amount, details, timestamp FROM dd_bills WHERE player = ? ORDER BY timestamp', {xPlayer.identifier},
	function(result)
		for k, v in pairs(result) do
			v.time = math.ceil((v.timestamp - os.time())/10800)
		end
		cb(result)
	end)
end)

ESX.RegisterServerCallback('dd_society:aGetTargetBills', function(source, cb, target)
	local Society = Data.Societies[target]

	if not Society then
		xTarget = ESX.GetPlayerFromId(target)
		target = xTarget.identifier
	end

	exports.oxmysql:execute('SELECT dd_bills.id, dd_bills.player, dd_bills.amount, dd_bills.details, dd_bills.timestamp, users.firstname, users.lastname FROM dd_bills INNER JOIN users ON dd_bills.player = users.identifier WHERE target = ? ORDER BY timestamp', {target},
	function(result)
		for k, v in pairs(result) do
			v.time = math.ceil((v.timestamp - os.time())/10800)
		end
		cb(result)
	end)
end)

ESX.RegisterServerCallback('dd_society:aPayBill', function(source, cb, id, cancel)
	local xPlayer = ESX.GetPlayerFromId(source)
	local account = xPlayer.getAccount('bank')

	local Bill = exports.oxmysql:singleSync('SELECT id, target, amount, details, timestamp FROM dd_bills WHERE player = ? AND id = ?', {xPlayer.identifier, id})

	if account.money >= Bill.amount or cancel then
		if not cancel then
			local Society = Data.Societies[Bill.target]
			if Society then
				Society.acc.addMoney(Bill.amount)
				xPlayer.showNotification('Paid bill of ~g~$' .. Bill.amount .. ' ~w~from bank account to ~y~' .. Bill.target)
			else
				local xTarget = ESX.GetPlayerFromIdentifier(Bill.target)
				xTarget.addAccountMoney('bank', Bill.amount)
				xPlayer.showNotification('Paid bill of ~g~$' .. Bill.amount .. ' ~w~from bank account to ~y~' .. Bill.target) --handle for player name
			end
			xPlayer.removeAccountMoney(account, Bill.amount)
		end

		exports.oxmysql:execute('DELETE FROM dd_bills WHERE player = ? AND id = ?', {xPlayer.identifier, id},
		function(result)
			cb(true)
		end)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('dd_society:aWashMoney', function(source, cb, amount, property)
	local xPlayer = ESX.GetPlayerFromId(source)
	local acc = xPlayer.getAccount('black_money')

	if acc.money >= amount then
		xPlayer.removeAccountMoney('black_money', amount)
		exports.oxmysql:insert('INSERT INTO dd_moneywash (property, amount, timestamp) VALUES (?, ?, ?)', {property, amount, os.time() + 10800},
		function(insertId)
			cb(true)
			xPlayer.showNotification('Your ~g~$' .. amount .. ' ~w~will be washed in 24 hours')
		end)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('dd_society:aGetWashedMoney', function(source, cb, property)
	exports.oxmysql:execute('SELECT id, property, amount, timestamp FROM dd_moneywash WHERE property = ?', {property},
	function(result)
		local Ready = {
			amount = 0,
		}

		for k, v in pairs(result) do
			if v.timestamp < os.time() then
				Ready.amount += v.amount
				v.time = 0
			else
				v.time = math.ceil((v.timestamp - os.time())/450)
			end
		end

		cb(result, Ready)
	end)
end)

ESX.RegisterServerCallback('dd_society:aCollectWashedMoney', function(source, cb, property, Money)
	local xPlayer = ESX.GetPlayerFromId(source)
	local amount = 0
	local ids = {}

	for k, v in pairs(Money) do
		if v.time == 0 then
			table.insert(ids, v.id)
			amount += v.amount
		end
	end

	xPlayer.addAccountMoney('money', amount)

	exports.oxmysql:execute('DELETE FROM dd_moneywash WHERE property = ? AND id IN (?)', {property, ids},
	function(result)
		cb(true)
	end)
end)
