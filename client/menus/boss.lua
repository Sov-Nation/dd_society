local ServerCallback = import 'callbacks'

function bOpen(zone)
	local property = Indexed.Properties[zone.property]
	local society = Indexed.Societies[property.owner]
	ESX.UI.Menu.Open('default', resName, 'boss', {
		title    = ('%s - %s'):format(zone.property, zone.name),
		align    = 'top-left',
		elements = {
			{label = 'Open stash', value = 'stash'},
			{label = 'Manage finances', value = 'finance'},
			{label = 'Manage properties', value = 'properties'},
			{label = 'Manage vehicles', value = 'vehicles'},
			{label = 'Manage employees', value = 'employees'},
		}
	},
	function(data, menu)
		if data.current.value == 'stash' then
			menu.close()
			TriggerEvent('ox_inventory:openInventory', 'stash', zone.id)
		elseif data.current.value == 'finance' then
			local elements = {
				{label = 'Withdraw cash', value = 'withdraw'},
				{label = 'Deposit cash', value = 'deposit'},
				{label = 'Bills', value = 'bills'},
			}
			for i = 1, #Config.PropertyTypes[property.type].bMenu do
				elements[#elements + 1] = Config.Menus[Config.PropertyTypes[property.type].bMenu[i]]
			end
			ESX.UI.Menu.Open('default', resName, 'finance', {
				title    = ('Manage Finances - %s'):format(property.ownerName),
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				if data2.current.value == 'withdraw' then
					society = Indexed.Societies[society.name]
					exports.dd_menus:amount({
						title = ('Withdraw money from the %s account - (%s), enter value'):format(property.ownerName, society.account),
						min = 1,
						max = society.account
					},
					function(datad, menud)
						ServerCallback.Async('dd_society', 'aPaySocietyMoney', 100, function(valid)
							if valid then
							end
						end, datad.value, 'money', false, property.owner, false)
					end, false)
				elseif data2.current.value == 'deposit' then
					local max
					for i = 1, 3 do
						if ESX.PlayerData.accounts[i].name == 'money' then
							max = ESX.PlayerData.accounts[i].money
							break
						end
					end
					exports.dd_menus:amount({
						title = ('Deposit money into the %s account, enter value (%s)'):format(property.ownerName, max),
						min = 1,
						max = max
					},
					function(datad, menud)
						ServerCallback.Async('dd_society', 'aPayMoney', 100, function(valid)
							if valid then
							end
						end, datad.value, 'money', property.owner, false)
					end, false)
				elseif data2.current.value == 'bills' then
					ServerCallback.Async('dd_society', 'aGetTargetBills', 100, function(bills)
						local elements = {}
						for i = 1, #bills do
							local label
							local bill = bills[i]
							if bill.time > 1 then
								label = colour('green', ('%s - $%s [due %s days] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.time, bill.playerName))
							elseif bill.time == 1 then
								label = colour('yellow', ('%s - $%s [due 1 day] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.playerName))
							elseif bill.time == 0 then
								label = colour('orange', ('%s - $%s [due] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.playerName))
							elseif bill.time == -1 then
								label = colour('red', ('%s - $%s [overdue 1 day] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), bill.playerName))
							elseif bill.time < -1 then
								label = colour('red', ('%s - $%s [overdue %s days] - %s'):format(bill.details, ESX.Math.GroupDigits(bill.amount), math.abs(bill.time), bill.playerName))
							end
							elements[#elements + 1] = {
								label = label,
								value = bill.id
							}
						end
						if not next(elements) then
							elements[1] = {label = 'None'}
						end
						ESX.UI.Menu.Open('default', resName, 'societyBills', {
							title    = ('Cancel %s Bills'):format(property.ownerName),
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							ESX.UI.Menu.CloseAll()
							if data3.current.value then
								ServerCallback.Async('dd_society', 'aPayBill', 100, function()
									bOpen(zone)
								end, data3.current.value, true)
							end
						end,
						function(data3, menu3)
							menu3.close()
						end)
					end, property.owner)
				elseif data2.current.value == 'washedMoney' then
					ServerCallback.Async('dd_society', 'aGetWashedMoney', 100, function(WashedMoney, ready)
						local elements = {}
						if Ready.amount == 0 then
							elements[1] = {label = 'No money ready to collect'}
						else
							elements[1] = {
								label = colour('green', ('There is $%S ready to collect'):format(ESX.Math.GroupDigits(ready))),
								value = 'collect'
							}
						end
						for i = 1, #washedMoney do
							local item = washedMoney[i]
							if item.time ~= 0 then
								local clr = 'red'
								if v.time < 6 then
									clr = 'yellow'
								elseif v.time < 12 then
									clr = 'orange'
								end
								elements[#elements + 1] = {
									label = colour(clr, ('$%s will be ready in %s hours'):format(ESX.Math.GroupDigits(item.amount), item.time))
								}
							end
						end
						ESX.UI.Menu.Open('default', resName, 'washedMoney', {
							title    = ('Collect Washed Money From %s'):format(property.id),
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							if data3.current.value then
								menu3.close()
								if data3.current.value == 'collect' then
									ServerCallback.Async('dd_society', 'aCollectWashedMoney', 100, function(valid)
									end, property.id, washedMoney)
								end
							end
						end,
						function(data3, menu3)
							menu3.close()
						end)
					end, property.id)
				elseif data2.current.value == 'washMoney' then
					local max
					for i = 1, 3 do
						if ESX.PlayerData.accounts[i].name == 'black_money' then
							max = ESX.PlayerData.accounts[i].money
							break
						end
					end
					exports.dd_menus:amount({
						title = ('Wash money at %s, enter value'):format(property.id),
						min = 1,
						max = max
					},
					function(datad, menud)
						menu2.close()
						ServerCallback.Async('dd_society', 'aWashMoney', 100, function(valid)
							if valid then
								ESX.ShowNotification(('Your ~g~$%s ~w~will be washed in 24 hours'):format(datad.value))
							end
						end, datad.value, property.id)
					end, false)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'properties' then
			local elements = {}
			for i = 1, #Data.Properties do
				if Data.Properties[i].owner == property.owner then
					elements[#elements + 1] = {
						label = Data.Properties[i].id,
						value = Data.Properties[i].id
					}
				end
			end
			ESX.UI.Menu.Open('default', resName, 'manageProperties', {
				title    = ('Manage Properties - %s'):format(property.owner),
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				kmProperty(data2.current.value)
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'vehicles' then
			ESX.UI.Menu.Open('default', resName, 'manageVehicles', {
				title    = 'Manage Vehicles',
				align    = 'top-left',
				elements = {
					{label = 'Transfer vehicles', value = 'transfer'},
					{label = 'Vehicles stored or impounded at this property', value = 'property'},
				}
			},
			function(data2, menu2)
				bManageGarage(zone, data2.current.value)
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'employees' then
			society = Indexed.Societies[society.name]
			local elements = {
				{label = 'Recruit nearby player', value = 'recruit'},
				{label = 'Manage grades', value = 'grades'},
			}
			if next(society.employees) then
				for k, v in pairs(society.employees) do
					elements[#elements + 1] = {
						label = ('%s - %s (%s)'):format(v.name, society.grades[v.grade].label, v.grade),
						value = v,
						ident = k
					}
				end
			else
				elements[3] = {label = 'No employees'}
			end
			ESX.UI.Menu.Open('default', resName, 'manageEmployees', {
				title    = ('Manage Employees - %s'):format(property.ownerName),
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				if data2.current.value == 'recruit' then
					exports.dd_menus:nearbyPlayers({
						title = nil,
						self = true,
						distance = nil
					},
					function(datad, menud)
						ESX.UI.Menu.CloseAll()
						ServerCallback.Async('dd_society', 'setJob', 100, function()
							ESX.ShowNotification(('~y~%s ~w~has been ~g~hired'):format(datad.current.name))
							bOpenAfterUpdate(zone)
						end, society.name, datad.current.identifier, 0)
					end, false)
				elseif data2.current.value == 'grades' then
					local elements = {}
					for i = 0, #society.grades do
						local grade = society.grades[i]
						elements[#elements + 1] = {
							label = ('%s (%s) - $%s [edit]'):format(grade.label, grade.grade, grade.salary),
							value = grade
						}
					end
					ESX.UI.Menu.Open('default', resName, 'manageGrades', {
						title    = ('Manage Grades - %s'):format(property.ownerName),
						align    = 'top-left',
						elements = elements
					},
					function(data3, menu3)
						local grade = data3.current.value
						ESX.UI.Menu.Open('default', resName, 'editGrade', {
							title    = ('Manage Grade - %s'):format(grade.label),
							align    = 'top-left',
							elements = {
								{label = 'Change label', value = 'label'},
								{label = 'Change salary', value = 'salary'},
							}
						},
						function(data4, menu4)
							if data4.current.value == 'label' then
								exports.dd_menus:text({
									title = 'New grade label, enter text'
								},
								function(datad, menud)
									if datad.value and datad.value:len() > 1 then
										grade.label = datad.value
										ESX.UI.Menu.CloseAll()
										ServerCallback.Async('dd_society', 'modifyGrade', 100, function()
											ESX.ShowNotification(('Grade ~Y~%s ~w~relabeled to ~g~%s'):format(grade.grade, datad.value))
											bOpenAfterUpdate(zone)
										end, society.name, grade)
									else
										ESX.ShowNotification('~r~Grade label cannot be empty')
									end
								end, false)
							elseif data4.current.value == 'salary' then
								exports.dd_menus:text({
									title = 'New grade salary, enter amount'
								},
								function(datad, menud)
									if datad.value then
										grade.salary = datad.value
										ESX.UI.Menu.CloseAll()
										ServerCallback.Async('dd_society', 'modifyGrade', 100, function()
											ESX.ShowNotification(('~Y~%s ~w~salary is now ~g~$%s'):format(grade.label, datad.value))
											bOpenAfterUpdate(zone)
										end, society.name, grade)
									else
										ESX.ShowNotification('~r~Grade salary cannot be empty')
									end
								end, false)
							end
						end,
						function(data4, menu4)
							menu4.close()
						end)
					end,
					function(data3, menu3)
						menu3.close()
					end)
				elseif data2.current.value then
					local employee = data2.current.value
					employee.ident = data2.current.ident
					ESX.UI.Menu.Open('default', resName, 'manageEmployee', {
						title    = ('Manage Employee - %s'):format(employee.name),
						align    = 'top-left',
						elements = {
							{label = 'Change grade', value = 'changeGrade'},
							{label = 'Fire', value = 'fire'},
						}
					},
					function(data3, menu3)
						if data3.current.value == 'changeGrade' then
							local elements = {}
							for i = 0, #society.grades do
								local grade = society.grades[i]
								if grade.grade ~= employee.grade then
									elements[#elements + 1] = {
										label = ('%s (%s) - $%s [set]'):format(grade.label, grade.grade, grade.salary),
										value = grade
									}
								end
							end
							ESX.UI.Menu.Open('default', resName, 'setEmployeeGrade', {
								title    = ('Set Grade - %s'):format(employee.name),
								align    = 'top-left',
								elements = elements
							},
							function(data4, menu4)
								local grade = data4.current.value
								ESX.UI.Menu.CloseAll()
								ServerCallback.Async('dd_society', 'setJob', 100, function()
									ESX.ShowNotification(('~y~%s ~w~is now ~g~%s'):format(employee.name, grade.label))
									bOpenAfterUpdate(zone)
								end, society.name, employee.ident, grade.grade)
							end,
							function(data4, menu4)
								menu4.close()
							end)
						elseif data3.current.value == 'fire' then
							ESX.UI.Menu.CloseAll()
							ServerCallback.Async('dd_society', 'setJob', 100, function()
								ESX.ShowNotification(('~y~%s ~w~has been ~r~fired'):format(employee.name))
								bOpenAfterUpdate(zone)
							end, 'unemployed', employee.ident, 0)
						end
					end,
					function(data3, menu3)
						menu3.close()
					end)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		end
	end,
	function(data, menu)
		menu.close()
	end)
end

function bManageGarage(zone, view)
	ServerCallback.Async('dd_society', 'vList', 100, function(vehicles)
		local title
		if view == 'transfer' then
			title = 'Transfer Vehicles'
		elseif view == 'property' then
			title = ('%s - Local Vehicles'):format(zone.property)
		end
		local elements = {}
		for i = 1, #vehicles do
			local label, action, price
			local vehicle = vehicles[i]
			local garageId, status = string.strsplit('-', vehicle.garage)
			local garage = Indexed.Zones[garageId]
			local garagePropertyId
			if garage then
				garagePropertyId = string.strsplit(':', garage.id)
			end

			if status == 'stored' then
				if garagePropertyId == zone.property then
					label = colour('green', ('%s is stored here in %s'):format(vehicle.name, garage.name))
				else
					label = colour('yellow', ('%s is stored in %s - %s'):format(vehicle.name, garagePropertyId, garage.name))
				end
			elseif status == 'impounded' then
				if garagePropertyId == zone.property then
					label = colour('red', ('%s is impounded here in %s'):format(vehicle.name, garage.name))
				else
					label = colour('red', ('%s is impounded in %s - %s'):format(vehicle.name, garagePropertyId, garage.name))
				end
			else
				label = colour('orange', ('%s is not stored'):format(vehicle.name))
			end
			label = ('%s [%s]'):format(label, vehicle.ownerName)
			vehicle.props = json.decode(vehicle.vehicle)

			if view == 'transfer' then
				if vehicle.owner == Indexed.Properties[zone.property].owner or vehicle.owner == PlayerBags.Player.ident then
					elements[#elements + 1] = {
						label = label,
						value = vehicle,
						property = garagePropertyId == zone.property,
						status = status
					}
				end
			elseif view == 'property' then
				if garagePropertyId == zone.property then
					elements[#elements + 1] = {
						label = label
					}
				end
			end
		end
		if not next(elements) then
			elements[1] = {label = 'None'}
		end
		ESX.UI.Menu.Open('default', resName, 'bossManageGarage',{
			title    = title,
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			if view == 'transfer' then
				if data.current.property and data.current.status == 'stored' then
					ESX.UI.Menu.CloseAll()
					local society = Indexed.Societies[data.current.value.owner]
					local owner
					if society then
						owner = PlayerBags.Player.ident
					else
						owner = Indexed.Properties[string.strsplit(':', zone.id)].owner
					end
					ServerCallback.Async('dd_society', 'vModify', 100, function(valid)
						bManageGarage(zone, view)
					end, data.current.value, {owner = owner})
				else
					ESX.ShowNotification('~r~You can only transfer vehicles stored at the current property')
				end
			end
		end,
		function(data, menu)
			menu.close()
		end)
	end, zone)
end

function bOpenAfterUpdate(zone)
	bUpdate = false
	repeat Wait(0) until bUpdate
	bOpen(zone)
end