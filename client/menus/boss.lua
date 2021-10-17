function bOpen(zone)
	local propertyOwner = Data.Properties[zone.property].owner
	ESX.UI.Menu.Open('default', resName, 'boss', {
		title    = string.strjoin(' - ', zone.property, zone.name),
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
			TriggerEvent('ox_inventory:openInventory', 'stash', {
				name = string.strconcat(zone.property, ':', zone.type, '-', zone.designation),
				label = 'Stash',
				owner = false,
				slots = 50,
				weight = 50000
			})
	elseif data.current.value == 'finance' then
			local elements = {
				{label = 'Withdraw cash', value = 'withdraw'},
				{label = 'Deposit cash', value = 'deposit'},
				{label = 'Bills', value = 'bills'},
			}
			for k, v in pairs(Config.PropertyTypes[Data.Properties[zone.property].type].bMenu) do
				table.insert(elements, v)
			end
			ESX.UI.Menu.Open('default', resName, 'finance', {
				title    = 'Manage Finances - ' .. Data.Properties[zone.property].owner,
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				if data2.current.value == 'withdraw' then
					exports.dd_menus:amount({
						title = string.strconcat('Withdraw money from the ', propertyOwner, ' account, enter value (', Data.Societies[propertyOwner].account, ')'),
						min = 1,
						max = Data.Societies[propertyOwner].account
					},
					function(datad, menud)
						ESX.TriggerServerCallback('dd_society:aPaySocietyMoney', function(valid)
							if valid then
							end
						end, datad.value, 'money', false, propertyOwner, false)
					end, false)
				elseif data2.current.value == 'deposit' then
					exports.dd_menus:amount({
						title = string.strconcat('Deposit money into the ', propertyOwner, ' account, enter value (', ESX.PlayerData.accounts[2].money, ')'),
						min = 1,
						max = ESX.PlayerData.accounts[2].money --might not be consistently cash
					},
					function(datad, menud)
						ESX.TriggerServerCallback('dd_society:aPayMoney', function(valid)
							if valid then
							end
						end, datad.value, 'money', propertyOwner, false)
					end, false)
				elseif data2.current.value == 'bills' then
					ESX.TriggerServerCallback('dd_society:aGetTargetBills', function(Bills)
						local elements = {}
						for k, v in pairs(Bills) do
							local label
							if v.time > 1 then
								label = cSpan('green', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [due ', v.time, ' days]'), v.fullname, '[cancel]')
							elseif v.time == 1 then
								label = cSpan('yellow', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [due ', v.time, ' day]'), v.fullname, '[cancel]')
							elseif v.time == 0 then
								label = cSpan('orange', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [due]'), v.fullname, '[cancel]')
							elseif v.time == -1 then
								label = cSpan('red', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [overdue ', math.abs(v.time), ' day]'), v.fullname, '[cancel]')
							elseif v.time < -1 then
								label = cSpan('red', string.strconcat(v.details, ' - $', ESX.Math.GroupDigits(v.amount), ' [overdue ', math.abs(v.time), ' days]'), v.fullname, '[cancel]')
							end
							table.insert(elements, {
								label = label,
								value = v.id
							})
						end
						if not next(elements) then
							elements[1] = {label = 'None'}
						end
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'societybills', {
							title    = 'Cancel ' .. Data.Properties[zone.property].owner .. ' bills',
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							menu3.close()
							if data3.current.value then
								ESX.TriggerServerCallback('dd_society:aPayBill', function()
								end, data3.current.value, true)
							end
						end,
						function(data3, menu3)
							menu3.close()
						end)
					end, ESX.PlayerData.job.label)
				elseif data2.current.value == 'washedMoney' then
					ESX.TriggerServerCallback('dd_society:aGetWashedMoney', function(WashedMoney, Ready)
						local elements = {}
						if Ready.amount == 0 then
							elements[1] = {label = 'No money ready to collect'}
						else
							elements[1] = {
								label = cSpan('green', string.strconcat('There is $', ESX.Math.GroupDigits(Ready.amount), ' ready to collect')),
								value = 'collect'
							}
						end
						for k, v in pairs(WashedMoney) do
							if v.time ~= 0 then
								local colour = 'red'
								if v.time < 6 then
									colour = 'yellow'
								elseif v.time < 12 then
									colour = 'orange'
								end
								table.insert(elements, {
									label = cSpan(colour, string.strconcat('$', ESX.Math.GroupDigits(v.amount), ' will be ready in ', v.time, ' hours'))
								})
							end
						end
						ESX.UI.Menu.Open('default', resName, 'washedMoney', {
							title    = 'Collect Washed Money From ' .. zone.property),
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							if data3.current.value then
								menu3.close()
								if data3.current.value == 'collect' then
									ESX.TriggerServerCallback('dd_society:aCollectWashedMoney', function(valid)
									end, zone.property, WashedMoney)
								end
							end
						end,
						function(data3, menu3)
							menu3.close()
						end)
					end, zone.property)
				elseif data2.current.value == 'washMoney' then
					exports.dd_menus:amount({
						title = 'Wash money here, at ' .. zone.property .. ', enter value',
						min = 1,
						max = nil
					},
					function(datad, menud)
						ESX.TriggerServerCallback('dd_society:aWashMoney', function(valid)
							if valid then
								ESX.ShowNotification('Your ~g~$' .. datad.value .. ' ~w~will be washed in 24 hours')
							end
						end, datad.value, zone.property)
					end, false)
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'properties' then
			local elements = {}
			for k, v in pairs(Data.Properties) do
				if v.owner == propertyOwner then
					table.insert(elements, {
						label = v.id,
						value = v
					})
				end
			end
			ESX.UI.Menu.Open('default', resName, 'manageProperties', {
				title    = 'Manage Properties - ' .. propertyOwner,
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
					{label = 'Society vehicles', value = 'society'},
					{label = 'Personal vehicles', value = 'personal'},
					{label = 'Vehicles stored at this property', value = 'local'},
				}
			},
			function(data2, menu2)
				bManageGarage(zone, data2.current.value)
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'employees' then
			ESX.TriggerServerCallback('dd_society:getEmployees', function(Employees, Grades)
				local elements = {
					{label = 'Recruit nearby player', value = 'recruit'},
					{label = 'Manage grades', value = 'grades'},
				}
				for k, v in pairs(Employees) do
					table.insert(elements, {
						label = v.fullname .. ' - ' .. v.grade.label .. ' (' .. v.grade.grade .. ')',
						value = v
					})
				end
				ESX.UI.Menu.Open('default', resName, 'manageEmployees', {
					title    = 'Manage Employees - ' .. propertyOwner,
					align    = 'top-left',
					elements = elements
				},
				function(data2, menu2)
					if data2.current.value == 'recruit' then
						exports.dd_menus:nearbyPlayers({
							title = nil, 
							self = nil,
							distance = nil
						},
						function(datad, menud)
							ESX.TriggerServerCallback('dd_society:setJob', function()
								menu2.close()
								ESX.ShowNotification('~y~' .. datad.current.name .. ' ~w~has been ~g~hired')
							end, Data.Societies[propertyOwner], datad.current.identifier, 0)
						end, false)
					elseif data2.current.value == 'grades' then
						local elements = {}
						for k, v in pairs(Grades) do
							table.insert(elements, {
								label = v.label .. ' (' .. v.grade .. ') - $' .. v.salary .. ' [edit]',
								value = v
							})
						end
						ESX.UI.Menu.Open('default', resName, 'manageGrades', {
							title    = 'Manage Grades - ' .. propertyOwner,
							align    = 'top-left',
							elements = elements
						},
						function(data3, menu3)
							local grade = data3.current.value
							ESX.UI.Menu.Open('default', resName, 'editGrade', {
								title    = 'Manage Grade - ' .. grade.label,
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
										if datad.value and string.len(datad.value) > 1 then
											ESX.TriggerServerCallback('dd_society:modifyGrade', function()
												menu4.close()
												menu3.close()
												menu2.close()
												ESX.ShowNotification('Grade ~Y~' .. grade.grade .. ' ~w~now labeled to ~g~' .. datad.value)
											end, Data.Societies[propertyOwner], grade.grade, {label = datad.value})
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
											ESX.TriggerServerCallback('dd_society:modifyGrade', function()
												menu4.close()
												menu3.close()
												menu2.close()
												ESX.ShowNotification('~Y~' .. grade.label .. ' ~w~salary is now ~g~$' .. datad.value)
											end, Data.Societies[propertyOwner], grade.grade, {salary = datad.value})
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
					else
						local employee = data2.current.value
						ESX.UI.Menu.Open('default', resName, 'manageEmployee', {
							title    = 'Manage Employee - ' .. employee.fullname,
							align    = 'top-left',
							elements = {
								{label = 'Change grade', value = 'changeGrade'},
								{label = 'Fire', value = 'fire'},
							}
						},
						function(data3, menu3)
							if data3.current.value == 'changeGrade' then
								local elements = {}
								for k, v in pairs(Grades) do
									table.insert(elements, {
										label = v.label .. ' (' .. v.grade .. ') - $' .. v.salary .. ' [set]',
										value = v
									})
								end
								ESX.UI.Menu.Open('default', resName, 'setEmployeeGrade', {
									title    = 'Set Grade - ' .. employee.fullname,
									align    = 'top-left',
									elements = elements
								},
								function(data4, menu4)
									ESX.TriggerServerCallback('dd_society:setJob', function()
										menu4.close()
										menu3.close()
										menu2.close()
										ESX.ShowNotification('~y~' .. employee.fullname .. ' ~w~is now ~g~' .. data4.current.value.label)
									end, Data.Societies[propertyOwner], employee.identifier, data4.current.value.grade)
								end,
								function(data4, menu4)
									menu4.close()
								end)
							elseif data3.current.value == 'fire' then
								ESX.TriggerServerCallback('dd_society:setJob', function()
									menu3.close()
									menu2.close()
									ESX.ShowNotification('~y~' .. employee.fullname .. ' ~w~has been ~r~fired')
								end, {name = 'unemployed'}, employee.identifier, 0)
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
			end, Data.Societies[propertyOwner])
		end
	end,
	function(data, menu)
		menu.close()
	end)
end

function bManageGarage(zone, view)
	local elements = {}
	ESX.TriggerServerCallback('dd_society:vList', function(vehicles)
		if next(vehicles) then
			local title
			if view == 'society' then
				title = 'Society vehicles - transfer to personal'
			elseif view == 'personal' then
				title = 'Personal vehicles - transfer to society'
			elseif view == 'local' then
				title =  zone.property .. ' Local vehicles'
			end
			for k, v in pairs(vehicles) do
				local label
				if v.garage == 0 then
					label = ('<span style="color: orange;">%s</span>'):format(v.name .. ' is not stored')
				elseif v.garage > 0 then
					if Data.Zones[v.garage].property == zone.property then
						label = ('<span style="color: green;">%s</span>'):format(v.name .. ' is stored here in ' .. Data.Zones[v.garage].name)
					else
						label = ('<span style="color: yellow;">%s</span>'):format(v.name .. ' is stored in ' .. Data.Zones[v.garage].property .. ' - ' .. Data.Zones[v.garage].name)
					end
				elseif v.garage < 0 then
					if Data.Zones[math.abs(v.garage)].property == zone.property then
						label = ('<span style="color: red;">%s</span>'):format(v.name .. ' is impounded here in ' .. Data.Zones[math.abs(v.garage)].name)
					else
						label = ('<span style="color: red;">%s</span>'):format(v.name .. ' is impounded in ' .. Data.Zones[math.abs(v.garage)].property .. ' - ' .. Data.Zones[math.abs(v.garage)].name)
					end
				end

				local props = json.decode(v.vehicle)
				if view == 'local' then
					if v.garage ~= 0 and Data.Zones[math.abs(v.garage)].property == c then
						if Data.Societies[v.owner] then
							label = v.owner .. ': ' .. label
						else
							label = v.firstname .. ' ' .. v.lastname .. ': ' .. label
						end
						table.insert(elements, {
							label = label,
							name = v.name,
							garage = v.garage,
							props = props
						})
					end
				elseif view == 'society' and Data.Societies[v.owner] then
					label = v.owner .. ': ' .. label
					table.insert(elements, {
						label = label .. ' [transfer]',
						owner = v.owner,
						name = v.name,
						garage = v.garage,
						props = props
					})
				elseif view == 'personal' and not Data.Societies[v.owner] then
					table.insert(elements, {
						label = label .. ' [transfer]',
						owner = v.owner,
						name = v.name,
						garage = v.garage,
						props = props
					})
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
				menu.close()
				if view == 'society' then
					local change = {
						owner = ESX.PlayerData.identifier
					}
					ESX.TriggerServerCallback('dd_society:vModify', function()
					end, data.current, change)
				elseif view == 'personal' then
					local change = {
						owner = propertyOwner
					}
					ESX.TriggerServerCallback('dd_society:vModify', function()
					end, data.current, change)
				end
			end,
			function(data, menu)
				menu.close()
			end)
		else
			ESX.ShowNotification("~r~You don't have access to any vehicles")
		end
	end, zone)
end
