local ServerCallback = import 'callbacks'

function createAccount(society)
	local self = {}

	self.name  = society.name
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
		Indexed.Societies[self.name].account = self.account
		updateSociety(Indexed.Societies[self.label])
	end

	return self
end

ServerCallback.Register('aPayMoney', function(source, cb, amount, account, target, details, cut)
	local xPlayer = ESX.GetPlayerFromId(source)
	local acc = xPlayer.getAccount(account)

	if acc.money >= amount then
		if target then
			local Society = Indexed.Societies[target]
			if Society then
				Society.acc.addMoney(amount)
				xPlayer.showNotification('Paid ~g~$' .. amount .. ' ~w~from ' .. account .. ' account to ~y~' .. target)
			else
				local xTarget = ESX.GetPlayerFromId(target)
				xTarget.addAccountMoney('bank', amount)
				xPlayer.showNotification('Paid ~g~$' .. amount .. ' ~w~from ' .. account .. ' account to ~y~' .. target)
			end
		else
			xPlayer.showNotification('Paid ~g~$' .. amount .. ' ~w~from ' .. account .. ' account into the void')
		end
		xPlayer.removeAccountMoney(account, amount)
		cb(true)
	elseif account == 'bank' and amount <= Config.MaxCredit and target then
		TriggerEvent('dd_society:aCreateBill', source, amount, target, details)
		xPlayer.showNotification('~r~There is not enough money in your bank account, bill added instead')
		cb(true)
	else
		xPlayer.showNotification("~r~You don't have enough money")
		cb(false)
	end
end)

ServerCallback.Register('aPaySocietyMoney', function(source, cb, amount, account, target, society)
	local xPlayer = ESX.GetPlayerFromId(source)
	local Soc = Indexed.Societies[society]

	if Soc.account >= amount then
		if target then
			local tSoc = Indexed.Societies[target]
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

RegisterServerEvent('dd_society:aCreateBill', function(id, amount, target, details)
	local xPlayer = ESX.GetPlayerFromId(id)
	local society = Indexed.Societies[target]

	if not society then
		xTarget = ESX.GetPlayerFromIdentifier(target)
		target = xTarget.identifier
	end

	if xPlayer then
		exports.oxmysql:insertSync('INSERT INTO dd_bills (player, target, amount, details, timestamp) VALUES (?, ?, ?, ?, ?)', {xPlayer.identifier, target, amount, details, os.time() + Config.time.bill})
		xPlayer.showNotification(('You have received an invoice for ~g~$%s'):format(amount))
	end
end)

ServerCallback.Register('aGetPlayerBills', function(source, cb, target)
	local ident

	if target then
		ident = ESX.GetPlayerFromId(target)
	else
		ident = Player(source).state.ident
	end

	local bills = exports.oxmysql:executeSync('SELECT id, target, amount, details, timestamp FROM dd_bills WHERE player = ? ORDER BY timestamp', {ident})

	for i = 1, #bills do
		local bill = bills[i]
		bill.time = math.ceil((bill.timestamp - os.time())/Config.time.day)
		bill.targetName = getName(bill.target)
	end

	cb(bills)
end)

ServerCallback.Register('aGetTargetBills', function(source, cb, target)
	local society = Indexed.Societies[target]

	if not society then
		xTarget = ESX.GetPlayerFromId(target)
		target = xTarget.identifier
	end

	local bills = exports.oxmysql:executeSync('SELECT * FROM dd_bills WHERE target = ? ORDER BY timestamp', {target})

	for i = 1, #bills do
		local bill = bills[i]
		bill.time = math.ceil((bill.timestamp - os.time())/Config.time.day)
		bill.playerName = getName(bill.player)
	end

	cb(bills)
end)

ServerCallback.Register('aPayBill', function(source, cb, billId, cancel)
	local bill = exports.oxmysql:singleSync('SELECT id, player, target, amount FROM dd_bills WHERE id = ?', {billId})

	local xPlayer = ESX.GetPlayerFromIdentifier(bill.player)
	local account = xPlayer.getAccount('bank')

	if account.money >= bill.amount or cancel then
		if not cancel then
			local society = Indexed.Societies[bill.target]
			if society then
				society.acc.addMoney(bill.amount)
				xPlayer.showNotification('Paid bill of ~g~$%s ~w~from bank account to ~y~%s'):format(bill.amount, bill.target)
			else
				local xTarget = ESX.GetPlayerFromIdentifier(bill.target)
				xTarget.addAccountMoney('bank', bill.amount)
				xPlayer.showNotification('Paid bill of ~g~$%s ~w~from bank account to ~y~%s'):format(bill.amount, bill.target)
			end
			xPlayer.removeAccountMoney(account, bill.amount)
		end

		exports.oxmysql:executeSync('DELETE FROM dd_bills WHERE id = ?', {bill.id})

		cb(true)
	else
		cb(false)
	end
end)

ServerCallback.Register('aWashMoney', function(source, cb, amount, propertyId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local acc = xPlayer.getAccount('black_money')

	if acc.money >= amount then
		xPlayer.removeAccountMoney('black_money', amount)
		exports.oxmysql:insertSync('INSERT INTO dd_moneywash (property, amount, timestamp) VALUES (?, ?, ?)', {propertyId, amount, os.time() + Config.time.moneywash})
		cb(true)
	else
		cb(false)
	end
end)

ServerCallback.Register('aGetWashedMoney', function(source, cb, propertyId)
	local money = exports.oxmysql:executeSync('SELECT id, property, amount, timestamp FROM dd_moneywash WHERE property = ?', {propertyId})
	local ready = 0

	for i = 1, #money do
		local wash = money[i]
		if wash.timestamp < os.time() then
			ready += wash.amount
			wash.time = 0
		else
			wash.time = math.ceil((wash.timestamp - os.time())/Config.time.hour)
		end
	end

	cb(money, ready)
end)

ServerCallback.Register('aCollectWashedMoney', function(source, cb, propertyId, money)
	local xPlayer = ESX.GetPlayerFromId(source)
	local amount = 0
	local ids = {}

	for i = 1, #money do
		local wash = money[i]
		if wash.time == 0 then
			ids[#ids + 1] = wash.id
			amount += wash.amount
		end
	end

	xPlayer.addAccountMoney('money', amount)

	exports.oxmysql:executeSync('DELETE FROM dd_moneywash WHERE property = ? AND id IN (?)', {propertyId, ids})

	cb(true)
end)
