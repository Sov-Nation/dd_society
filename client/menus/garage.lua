function gOpen(zone)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'g_open', {
		title    =  zone.property .. ' - ' .. zone.name,
		align    = 'top-left',
		elements = {
			{label = 'Store vehicle' , value = 'store_vehicle'},
			{label = 'Open Your Garage' , value = 'open_garage'}
		},
	}, function(data, menu)
		if data.current.value == 'store_vehicle' then
			storeVehicle(zone)
		elseif data.current.value == 'open_garage' then
			gManage(zone)
		end
	end,
	function(data, menu)
		menu.close()
		if next(CurrentZone) then
			ActionMsg = CurrentZone.message
		end
	end)
end

function gManage(zone)
	ESX.TriggerServerCallback('dd_society:vList', function(vehicles)
		local elements = {}
		if next(vehicles) then
			for k, v in pairs(vehicles) do
				local label

				if v.garage == 0 then
					label = ('<span style="color: orange;">%s</span>'):format(v.name .. ' is not stored')
				elseif v.garage > 0 then
					if v.garage == zone.id then
						label = ('<span style="color: green;">%s</span>'):format(v.name .. ' is stored here')
					else
						label = ('<span style="color: yellow;">%s</span>'):format(v.name .. ' is stored in ' .. Data.Zones[v.garage].property .. ' - ' .. Data.Zones[v.garage].name)
					end
				elseif v.garage < 0 then
					if math.abs(v.garage) == zone.id then
						label = ('<span style="color: red;">%s</span>'):format(v.name .. ' is impounded here')
					else
						label = ('<span style="color: red;">%s</span>'):format(v.name .. ' is impounded in ' .. Data.Zones[math.abs(v.garage)].property .. ' - ' .. Data.Zones[math.abs(v.garage)].name)
					end
				end
				if Data.Societies[v.owner] then
					label = v.owner .. ': ' .. label
				end
				v.props = json.decode(v.vehicle)
				table.insert(elements, {
					label = label,
					value = v
				})
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_garage',{
				title    = zone.property .. ' - ' .. zone.name,
				align    = 'top-left',
				elements = elements,
			},
			function(data, menu)
				local elements = {}
				if data.current.value.garage == zone.id then
					elements[1] = {label = 'Retrieve vehicle from this garage', value = 'retrieve'}
				elseif data.current.value.garage == 0 then
					elements[1] = {label = 'Recover vehicle $' .. Config.Garage.Prices.Insurance, value = 'recover'}
				elseif data.current.value.garage > 0 then
					elements[1] = {label = 'Move vehicle to this garage $' .. Config.Garage.Prices.Move, value = 'move'}
				elseif data.current.value.garage < 0 then
					elements[1] = {label = 'Pay impound fee $' .. Config.Garage.Prices.Impound, value = 'impound'}
				end
				elements[2] = {label = 'Rename vehicle' , value = 'rename'}
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {
					title    =  data.current.value.name,
					align    = 'top-left',
					elements = elements,
				}, function(data2, menu2)
					if data2.current.value == 'retrieve' then
						if vehicleInUse(data.current.value.props.plate) then
							ESX.ShowNotification("~r~Someone has your vehicle")
							return
						end
						ESX.UI.Menu.CloseAll()
						local change = {
							garage = 0
						}
						ESX.TriggerServerCallback('dd_society:vModify', function()
							SpawnVehicle(data.current.value, zone)
							if next(CurrentZone) then
								gManage(zone)
							end
						end, data.current.value, change)
					elseif data2.current.value == 'rename' then
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rename_vehicle', {
							title = 'New vehicle name'
						}, function(data3, menu3)
							if data3.value and string.len(data3.value) > 0 then
								local change = {
									name = data3.value
								}
								ESX.TriggerServerCallback('dd_society:vModify', function()
									if next(CurrentZone) then
										gManage(zone)
									end
								end, data.current.value, change)
								menu3.close()
							else
								ESX.ShowNotification('~r~Name cannot be empty')
							end
						end, function(data3, menu3)
							menu3.close()
						end)
					else
						if vehicleInUse(data.current.value.props.plate) then
							ESX.ShowNotification("~r~Someone has your vehicle")
							return
						end

						if data2.current.value == 'recover' then
							price = Config.Garage.Prices.Insurance --change to excess based on vehicle
							garage = zone.id
							owner = Data.Properties[zone.property].owner --insurance company?
							details = 'Vehicle Recovery'
						elseif data2.current.value == 'move' then
							price = Config.Garage.Prices.Move
							garage = zone.id
							owner = Data.Properties[zone.property].owner
							details = 'Vehicle Move'
						elseif data2.current.value == 'impound' then
							price = Config.Garage.Prices.Impound
							garage = zone.id * -1
							owner = Data.Properties[Data.Zones[data.current.value.garage].property].owner
							details = 'Vehicle Impound Fee'
						end
						ESX.TriggerServerCallback('dd_society:aPayMoney', function(valid)
							if valid then
								menu2.close()
								local change = {
									garage = garage
								}
								ESX.TriggerServerCallback('dd_society:vModify', function()
									if next(CurrentZone) then
										gManage(zone)
									end
								end, data.current.value, change)
							end
						end, price, 'bank', owner, details) --pay owner
					end
				end,
				function(data2, menu2)
					menu2.close()
				end)
			end,
			function(data, menu)
				menu.close()
				if next(CurrentZone) then
					gOpen(zone)
				end
			end)
		else
			ESX.ShowNotification("~r~You don't have access to any vehicles")
		end
	end, zone)
end
