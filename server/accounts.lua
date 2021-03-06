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

ServerCallback.Register('aPayMoney', function(source, amount, account, target, details, cut)
	local xPlayer = ESX.GetPlayerFromId(source)
	local acc = xPlayer.getAccount(account)

	if acc.money >= amount then
		if target then
			local Society = Indexed.Societies[target]
			if Society then
				Society.acc.addMoney(amount)
				xPlayer.showNotification('Paid ~g~$' .. amount .. ' ~w~from ' .. account .. ' account to ~y~' .. target)
			else
				local xTarget = ESX.GetPlayerFromIdentifier(target)
				xTarget.addAccountMoney('bank', amount)
				xPlayer.showNotification('Paid ~g~$' .. amount .. ' ~w~from ' .. account .. ' account to ~y~' .. target)
			end
		else
			xPlayer.showNotification('Paid ~g~$' .. amount .. ' ~w~from ' .. account .. ' account into the void')
		end
		xPlayer.removeAccountMoney(account, amount)
	elseif account == 'bank' and amount <= Config.MaxCredit and target then
		TriggerEvent('dd_society:aCreateBill', source, amount, target, details)
		xPlayer.showNotification('~r~There is not enough money in your bank account, bill added instead')
	else
		xPlayer.showNotification("~r~You don't have enough money")
		return false
	end
	return true
end)

ServerCallback.Register('aPaySocietyMoney', function(source, amount, account, target, society)
	local xPlayer = ESX.GetPlayerFromId(source)
	local Soc = Indexed.Societies[society]

	if Soc.account >= amount then
		if target then
			local tSoc = Indexed.Societies[target]
			if tSoc then
				tSoc.acc.addMoney(amount)
				xPlayer.showNotification('~y~' .. target .. ' ~w~received ~g~$' .. amount .. ' ~w~from ~y~' .. society)
			else
				local xTarget = ESX.GetPlayerFromIdentifier(target)
				xTarget.addAccountMoney(account, amount)
				xPlayer.showNotification('~y~' .. target .. ' ~w~received ~g~$' .. amount .. ' ~w~from ~y~' .. society)
			end
		else
			xPlayer.addAccountMoney(account, amount)
			xPlayer.showNotification('You ~w~received ~g~$' .. amount .. ' ~w~from ~y~' .. society)
		end
		Soc.acc.removeMoney(amount)
	else
		xPlayer.showNotification("~r~You don't have enough money")
		return false
	end
	return true
end)

RegisterServerEvent('dd_society:aCreateBill', function(id, amount, target, details)
	local xPlayer = ESX.GetPlayerFromId(id)
	local society = Indexed.Societies[target]

	if not society then
		xTarget = ESX.GetPlayerFromIdentifier(target)
		target = xTarget.identifier
	end

	if xPlayer then
		MySQL.insert('INSERT INTO dd_bills (player, target, amount, details, timestamp) VALUES (?, ?, ?, ?, ?)', {xPlayer.identifier, target, amount, details, os.time() + Config.time.bill})
		xPlayer.showNotification(('You have received an invoice for ~g~$%s'):format(amount))
	end
end)

ServerCallback.Register('aGetPlayerBills', function(source, target)
	local ident

	if target then
		ident = ESX.GetPlayerFromId(target)
	else
		ident = Player(source).state.ident
	end

	local bills = MySQL.query.await('SELECT id, target, amount, details, timestamp FROM dd_bills WHERE player = ? ORDER BY timestamp', {ident})

	for i = 1, #bills do
		local bill = bills[i]
		bill.time = math.ceil((bill.timestamp - os.time())/Config.time.day)
		bill.targetName = getName(bill.target)
	end

	return bills
end)

ServerCallback.Register('aGetTargetBills', function(source, target)
	local society = Indexed.Societies[target]

	if not society then
		xTarget = ESX.GetPlayerFromId(target)
		target = xTarget.identifier
	end

	local bills = MySQL.query.await('SELECT * FROM dd_bills WHERE target = ? ORDER BY timestamp', {target})

	for i = 1, #bills do
		local bill = bills[i]
		bill.time = math.ceil((bill.timestamp - os.time())/Config.time.day)
		bill.playerName = getName(bill.player)
	end

	return bills
end)

ServerCallback.Register('aPayBill', function(source, billId, cancel)
	local bill = MySQL.single.await('SELECT id, player, target, amount FROM dd_bills WHERE id = ?', {billId})

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

		MySQL.query.await('DELETE FROM dd_bills WHERE id = ?', {bill.id})
	else
		return false
	end
	return true
end)

ServerCallback.Register('aWashMoney', function(source, amount, propertyId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local acc = xPlayer.getAccount('black_money')

	if acc.money >= amount then
		xPlayer.removeAccountMoney('black_money', amount)
		MySQL.insert.await('INSERT INTO dd_moneywash (property, amount, timestamp) VALUES (?, ?, ?)', {propertyId, amount, os.time() + Config.time.moneywash})
	else
		return false
	end
	return true
end)

ServerCallback.Register('aGetWashedMoney', function(source, propertyId)
	local money = MySQL.query.await('SELECT id, property, amount, timestamp FROM dd_moneywash WHERE property = ?', {propertyId})
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

	return money, ready
end)

ServerCallback.Register('aCollectWashedMoney', function(source, propertyId, money)
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

	MySQL.query.await('DELETE FROM dd_moneywash WHERE property = ? AND id IN (?)', {propertyId, ids})

	return true
end)
