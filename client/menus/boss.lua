function bOpen(zone)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss',{
		title    = zone.property .. ' - ' .. zone.property,
		align    = 'top-left',
		elements = {
			{label = 'Boss options', value = 'boss'},
			{label = 'Open stash', value = 'stash'},
			{label = 'Manage vehicles', value = 'vehicles'},
		}
	},
	function(data, menu)
		local PropertyOwner = Data.Societies[Data.Properties[zone.property].owner]
		if data.current.value == 'boss' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bossactions', {
				title    = 'Boss Options',
				align    = 'top-left',
				elements = {
					{label = 'Withdraw Money', value = 'withdraw_money'},
					{label = 'Deposit Money', value = 'deposit_money'},
					{label = 'Manage Keys[TODO]', value = 'manage_keys'},
					{label = 'Employee list', value = 'employee_list'},
					{label = 'Recruit', value = 'recruit'},
					{label = 'Manage Wages', value = 'manage_wages'},
				}
			}, 
			function(data2, menu2)
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'stash' then
			menu.close()
			
			TriggerEvent('ox_inventory:openInventory', 'stash', {name = zone.property .. zone.type .. zone.designation, label = 'Boss Stash', owner = false, slots = 100, weight = 100000})
		elseif data.current.value == 'vehicles' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_actions_' .. PropertyOwner.id, {
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
	ESX.TriggerServerCallback('dd_society:gList', function(vehicles)
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
