function gOpen(zone)
	ESX.UI.Menu.Open('default', resName, 'garage', {
		title    =  string.strjoin(' - ', zone.property, zone.name),
		align    = 'top-left',
		elements = {
			{label = 'Store vehicle' , value = 'storeVehicle'},
			{label = 'Open Your Garage' , value = 'openGarage'}
		},
	}, function(data, menu)
		if data.current.value == 'storeVehicle' then
			storeVehicle(zone)
		elseif data.current.value == 'openGarage' then
			gManage(zone)
		end
	end,
	function(data, menu)
		menu.close()
	end)
end

function gManage(zone)
	ESX.TriggerServerCallback('dd_society:vList', function(vehicles)
		local elements = {}
		for k, v in pairs(vehicles) do
			local garage, society, label = Data.Zones[math.abs(v.garage)], Data.Societies[v.owner]?.label

			if v.garage == 0 then
				label = cSpan('orange', string.strconcat(v.name, ' is not stored'), society)
			elseif v.garage > 0 then
				if v.garage == zone.id then
					label = cSpan('green', string.strconcat(v.name, ' is stored here'), society)
				else
					label = cSpan('yellow', string.strconcat(v.name, ' is stored in ', garage.property, ' - ', garage.name), society)
				end
			elseif v.garage < 0 then
				if math.abs(v.garage) == zone.id then
					label = cSpan('red', string.strconcat(v.name, ' is impounded here'), society)
				else
					label = cSpan('red', string.strconcat(v.name, ' is impounded in ', garage.property, ' - ', garage.name), society)
				end
			end
			v.props = json.decode(v.vehicle)
			table.insert(elements, {
				label = label,
				value = v
			})
		end
		if not next(elements) then
			elements[1] = {label = 'None'}
		end
		ESX.UI.Menu.Open('default', resName, 'manageGarage',{
			title    = string.strjoin(' - ', zone.property, zone.name),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			local elements = {}
			local vehicle = data.current.value
			if vehicle.garage == zone.id then
				elements[1] = {label = 'Retrieve vehicle from this garage', value = 'retrieve'}
			elseif vehicle.garage == 0 then
				elements[1] = {label = 'Recover vehicle $' .. Config.Garage.Prices.Insurance, value = 'recover'}
			elseif vehicle.garage > 0 then
				elements[1] = {label = 'Move vehicle to this garage $' .. Config.Garage.Prices.Move, value = 'move'}
			elseif vehicle.garage < 0 then
				elements[1] = {label = 'Pay impound fee $' .. Config.Garage.Prices.Impound, value = 'impound'}
			end
			elements[2] = {label = 'Rename vehicle' , value = 'rename'}
			ESX.UI.Menu.Open('default', resName, 'manageVehicle', {
				title    =  vehicle.name,
				align    = 'top-left',
				elements = elements,
			}, function(data2, menu2)
				if data2.current.value == 'retrieve' then
					if vehicleInUse(vehicle.props.plate) then
						ESX.ShowNotification("~r~Someone has your vehicle")
						return
					end
					ESX.TriggerServerCallback('dd_society:vModify', function()
						pickSpawn(vehicle, zone)
						menu2.close()
						menu.close()
					end, vehicle, {garage = 0})
				elseif data2.current.value == 'rename' then
					ESX.UI.Menu.Open('dialog', resName, 'renameVehicle', {
						title = 'New vehicle name'
					}, function(data3, menu3)
						if data3.value and string.len(data3.value) > 0 then
							ESX.TriggerServerCallback('dd_society:vModify', function()
								menu3.close()
								menu2.close()
								menu.close()
							end, vehicle, {name = data3.value})
						else
							ESX.ShowNotification('~r~Name cannot be empty')
						end
					end, function(data3, menu3)
						menu3.close()
					end)
				else
					if vehicleInUse(vehicle.props.plate) then
						ESX.ShowNotification("~r~Someone has your vehicle")
						return
					end
					local price, garage, owner, details
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
						owner = Data.Properties[Data.Zones[vehicle.garage].property].owner
						details = 'Vehicle Impound Fee'
					end
					ESX.TriggerServerCallback('dd_society:aPayMoney', function(valid)
						if valid then
							ESX.TriggerServerCallback('dd_society:vModify', function()
								menu2.close()
								menu.close()
							end, vehicle, {garage = garage})
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
		end)
	end, zone)
end
