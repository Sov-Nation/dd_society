function gOpen(zone)
	ESX.UI.Menu.Open('default', resName, 'garage', {
		title    = ('%s - %s'):format(zone.property, zone.name),
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
		for i = 1, #vehicles do
			local label, action, price
			local vehicle = vehicles[i]
			local garageId, status = string.strsplit('-', vehicle.garage)
			local garage = Indexed.Zones[garageId]
			local society = Indexed.Societies[vehicle.owner]

			if status == 'stored' then
				if garage.id == zone.id then
					label = colour('green', ('%s is stored here'):format(vehicle.name))
					menu = {label = 'Retrieve vehicle from this garage', value = 'retrieve'}
				else
					label = colour('yellow', ('%s is stored in %s - %s'):format(vehicle.name, garage.property, garage.name))
					price = Config.Garage.Prices.Move
					menu = {label = ('Move vehicle to this garage $%s'):format(price), value = 'move'}
				end
			elseif status == 'impounded' then
				if garage.id == zone.id then
					label = colour('red', ('%s is impounded here'):format(vehicle.name))
				else
					label = colour('red', ('%s is impounded in %s - %s'):format(vehicle.name, garage.property, garage.name))
				end
				price = Config.Garage.Prices.Impound
				menu = {label = ('Pay impound fee $%s'):format(price), value = 'impound'}
			else
				label = colour('orange', ('%s is not stored'):format(vehicle.name))
				price = Config.Garage.Prices.Insurance
				menu = {label = ('Recover vehicle $%s'):format(price), value = 'recover'}
			end
			if society then
				label = ('%s [%s]'):format(label, society.label)
			end
			vehicle.props = json.decode(vehicle.vehicle)
			elements[#elements + 1] = {
				label = label,
				value = vehicle,
				menu = menu,
				price = price
			}
		end
		if not next(elements) then
			elements[1] = {label = 'None'}
		end
		ESX.UI.Menu.Open('default', resName, 'manageGarage',{
			title    = ('%s - %s'):format(zone.property, zone.name),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			local vehicle = data.current.value
			ESX.UI.Menu.Open('default', resName, 'manageVehicle', {
				title    = vehicle.name,
				align    = 'top-left',
				elements = {
					data.current.menu,
					{label = 'Rename vehicle' , value = 'rename'}
				}
			}, function(data2, menu2)
				if data2.current.value == 'retrieve' then
					if vehicleInUse(vehicle.props.plate) then
						ESX.ShowNotification('~r~Someone has your vehicle')
						return
					end
					ESX.UI.Menu.CloseAll()
					local spot = pickSpot(zone)
					if spot then
						ESX.TriggerServerCallback('dd_society:vModify', function()
							spawnAtSpot(vehicle, spot)
						end, vehicle, {garage = ''})
					else
						ESX.ShowNotification('~r~There was no spot found for your vehicle')
					end
				elseif data2.current.value == 'rename' then
					exports.dd_menus:text({
						title = 'New vehicle name, enter text'
					},
					function(datad, menud)
						if datad.value and datad.value:len() > 1 then
							ESX.UI.Menu.CloseAll()
							ESX.TriggerServerCallback('dd_society:vModify', function()
								ESX.ShowNotification(('Vehicle renamed to ~y~%s'):format(datad.value))
								gOpen(zone)
							end, vehicle, {name = datad.value})
						else
							ESX.ShowNotification('~r~Name cannot be empty')
						end
					end, false)
				else
					if vehicleInUse(vehicle.props.plate) then
						ESX.ShowNotification("~r~Someone has your vehicle")
						return
					end
					local price, garage, owner, details
					if data2.current.value == 'recover' then
						garage = ('%s-stored'):format(zone.id)
						owner = Indexed.Properties[zone.property].owner
						details = 'Vehicle Recovery'
					elseif data2.current.value == 'move' then
						garage = ('%s-stored'):format(zone.id)
						owner = Indexed.Properties[zone.property].owner
						details = 'Vehicle Move'
					elseif data2.current.value == 'impound' then
						garage = ('%s-impounded'):format(zone.id)
						owner = Indexed.Properties[Data.Zones[vehicle.garage].property].owner
						details = 'Vehicle Impound Fee'
					end
					ESX.UI.Menu.CloseAll()
					ESX.TriggerServerCallback('dd_society:aPayMoney', function(valid)
						if valid then
							ESX.TriggerServerCallback('dd_society:vModify', function()
							end, vehicle, {garage = garage})
						end
					end, data.current.price, 'bank', owner, details)
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
