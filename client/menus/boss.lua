function bOpen(zone)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss',{
		title    = zone.property .. ' - ' .. zone.name,
		align    = 'top-left',
		elements = {
			{label = 'Open stash', value = 'stash'},
			{label = 'Finance manager', value = 'finance'},
			--add/take money -- done
			--view and cancel bills -- done
			--wash money, based on config, money will take time too wash and then be collected all at once
			{label = 'Manage properties', value = 'properties'},
			--keys, create, delete, add and remove all in society, tweak exemptions
			--doors, name, locked, distance
			--zones, public, name
			{label = 'Manage vehicles', value = 'vehicles'},
			----see society, personal and local vehicles
			--transfer ownership of vehicles
			--change society vehicle state
			{label = 'Manage employees', value = 'employees'},
			--recruit,
			--fire,
			--change grade label and salary,
			--see and add or remove keys
		}
	},
	function(data, menu)
		if data.current.value == 'stash' then
			menu.close()

			TriggerEvent('ox_inventory:openInventory', 'stash', {name = zone.property .. zone.type .. zone.designation, label = 'Boss Stash', owner = false, slots = 100, weight = 100000})
		elseif data.current.value == 'finance' then
			local elements = {
				{label = 'Withdraw cash', value = 'withdraw'},
				{label = 'Deposit cash', value = 'deposit'},
				{label = 'Bills', value = 'bills'},
			}
			for k, v in pairs(Config.PropertyTypes[Data.Properties[zone.property].type].bMenu) do
				table.insert(elements, v)
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'finance', {
				title    = 'Finance Manager' .. ' - ' .. Data.Properties[zone.property].owner,
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				if data2.current.value == 'withdraw' then
					exports.dd_menus:amount({
						title = 'Withdraw money from the ' .. Data.Properties[zone.property].owner .. ' account, enter value (' .. Data.Societies[Data.Properties[zone.property].owner].account .. ')',
						min = 1,
						max = Data.Societies[Data.Properties[zone.property].owner].account
					},
					function(datad, menud)
						ESX.TriggerServerCallback('dd_society:aPaySocietyMoney', function(valid)
							if valid then
							end
						end, datad.value, 'money', false, Data.Properties[zone.property].owner, false)
					end, false)
				elseif data2.current.value == 'deposit' then
					exports.dd_menus:amount({
						title = 'Deposit money into the ' .. Data.Properties[zone.property].owner .. ' account, enter value (' .. ESX.PlayerData.accounts[2].money .. ')',
						min = 1,
						max = ESX.PlayerData.accounts[2].money --might not be consistently cash
					},
					function(datad, menud)
						ESX.TriggerServerCallback('dd_society:aPayMoney', function(valid)
							if valid then
							end
						end, datad.value, 'money', Data.Properties[zone.property].owner, false)
					end, false)
				elseif data2.current.value == 'bills' then
					ESX.TriggerServerCallback('dd_society:aGetTargetBills', function(Bills)
						local elements = {}
						for k, v in pairs(Bills) do
							local label
							if v.time > 1 then
								label = ('<span style="color: green;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [due ' .. v.time .. ' days]')
							elseif v.time == 1 then
								label = ('<span style="color: yellow;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [due ' .. v.time .. ' day]')
							elseif v.time == 0 then
								label = ('<span style="color: orange;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [due]')
							elseif v.time == -1 then
								label = ('<span style="color: red;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [overdue ' .. math.abs(v.time) .. ' day]')
							elseif v.time < -1 then
								label = ('<span style="color: red;">%s</span>'):format(v.details .. ' - $' .. ESX.Math.GroupDigits(v.amount) .. ' [overdue ' .. math.abs(v.time) .. ' days]')
							end
							table.insert(elements, {
								label = v.firstname .. ' ' .. v.lastname .. ': ' .. label .. ' [cancel]',
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
								ESX.TriggerServerCallback('dd_society:aPayBill', function(valid)
								end, data3.current.value, true)
							end
						end, function(data3, menu3)
							menu3.close()
						end)
					end, ESX.PlayerData.job.label)
				elseif data2.current.value == 'washedmoney' then
				elseif data2.current.value == 'washmoney' then
					--make in property menu maybe
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'vehicles' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'managevehicles', {
				title    = 'Manage Vehicles',
				align    = 'top-left',
				elements = {
					{label = 'Company vehicles', value = 'company'},
					{label = 'Personal vehicles', value = 'personal'},
					{label = 'Vehicles stored at this property', value = 'local'},
				}
			},
			function(data2, menu2)
				bManageGarage(zone, data2.current.value)
			end, function(data2, menu2)
				menu2.close()
			end)
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
			for k, v in pairs(vehicles) do
				local props = json.decode(v.vehicle)
				local name, label

				if v.garage == 0 then
					label = ('<span style="color: orange;">%s</span>'):format(v.name .. ' is not stored')
				elseif v.garage > 0 then
					label = ('<span style="color: yellow;">%s</span>'):format(v.name .. ' is stored in ' .. Data.Zones[v.garage].property .. ' - ' .. Data.Zones[v.garage].name)
				elseif v.garage < 0 then
					label = ('<span style="color: red;">%s</span>'):format(v.name .. ' is impounded in ' .. Data.Zones[v.garage].property .. ' - ' .. Data.Zones[v.garage].name)
				end
				if view == 'local' then
					if Data.Societies[v.owner] then
						label = v.owner .. ': ' .. label
					else
						label = v.owner .. ': ' .. label --change owner to owner name
					end
					table.insert(elements, {
						label = label,
						name = v.name,
						garage = v.garage,
						props = props
					})
				elseif view == 'company' and Data.Societies[v.owner] then
					label = v.owner .. ': ' .. label
					table.insert(elements, {
						label = label,
						name = v.name,
						garage = v.garage,
						props = props
					})
				elseif view == 'personal' and not Data.Societies[v.owner] then
					table.insert(elements, {
						label = label,
						name = v.name,
						garage = v.garage,
						props = props
					})
				end
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_garage',{
				title    = zone.property .. ' - ' .. zone.name,
				align    = 'top-left',
				elements = elements,
			},
			function(data, menu)
				-- if data.current.garage == 0 then -- haven't decided what to do here yet
				--     table.insert(elements, {label = 'Recover vehicle'})
				-- elseif data.current.garage > 0 then
				-- 	table.insert(elements, {label = 'Get vehicle from garage'})
				-- elseif data.current.garage < 0 then
				--     table.insert(elements, {label = 'Retrieve from impound'})
				-- end
			end,
			function(data, menu)
				menu.close()
				if next(CurrentZone) then
					bOpen(zone)
				end
			end)
		else
			ESX.ShowNotification("~r~You don't have access to any vehicles")
		end
	end, zone)
end
