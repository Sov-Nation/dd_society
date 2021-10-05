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
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_actions_' .. PropertyOwner.id, {
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
				if data2.current.value == 'withdraw_money' then
					exports['dd_menus']:amount({
						title = 'Withdraw society money, enter amount', 
						min = 1, 
						max = nil
					},
					function(datad, menud)
						TriggerServerEvent('dd_society:withdrawMoney', PropertyOwner.id, datad.value) --replace with transfer
					end, false)
				elseif data2.current.value == 'deposit_money' then
					exports['dd_menus']:amount({
						title = 'Deposit society money, enter amount', 
						min = 1, 
						max = nil
					},
					function(datad, menud)
						TriggerServerEvent('dd_society:depositMoney', PropertyOwner.id, datad.value)
					end, false)
				elseif data2.current.value == 'employee_list' then
					local elements = {}
					for k, v in pairs(PropertyOwner.employees) do
						local employee = Data.Players[v]
						table.insert(elements,{
							label = employee.fullname .. ' - ' .. PropertyOwner.grades[employee.job_grade].label .. ' [manage]',
							value = employee
						})
					end
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'employee_list_' .. PropertyOwner.id, {
						title    = 'Employee list',
						align    = 'top-left',
						elements = elements
					}, 
					function(data3, menu3)
						local elements = {}
						for i = 0, 4, 1 do
							local label = '(' .. i .. ') ' .. PropertyOwner.grades[i].label
							local value = 'set'
							if i == data3.current.value.job_grade then
								label = label .. ' [fire]'
								value = 'fire'
							else
								label = label .. ' [set]'
							end
							table.insert(elements, {
								label = label,
								value = value,
								grade = i
							})
						end
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_employee', {
							title    = 'Manage ' .. data3.current.value.fullname,
							align    = 'top-left',
							elements = elements
						}, 
						function(data4, menu4)
							if data4.current.value == 'set' then
								TriggerServerEvent('dd_society:setGrade', data3.current.value.identifier, data4.current.grade)
							elseif data4.current.value == 'fire' then
								TriggerServerEvent('dd_society:setGrade', data3.current.value.identifier, -1)
							end
						end, function(data4, menu4)
							menu4.close()
						end)
					end, function(data3, menu3)
						menu3.close()
					end)
				elseif data2.current.value == 'manage_pay' then
					function OpenManageGradesMenu(society)
						ESX.TriggerServerCallback('dd_society:getJob', function(job)
							local elements = {}
					
							for i=1, #job.grades, 1 do
								local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)
					
								table.insert(elements, {
									label = ('%s - <span style="color:green;">%s</span>'):format(gradeLabel, _U('money_generic', ESX.Math.GroupDigits(job.grades[i].salary))),
									value = job.grades[i].grade
								})
							end
					
							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_' .. society, {
								title    = _U('salary_management'),
								align    = 'top-left',
								elements = elements
							}, function(data, menu)
								ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'manage_grades_amount_' .. society, {
									title = _U('salary_amount')
								}, function(data2, menu2)
					
									local amount = tonumber(data2.value)
					
									if amount == nil then
										ESX.ShowNotification(_U('invalid_amount'))
									elseif amount > Config.MaxSalary then
										ESX.ShowNotification(_U('invalid_amount_max'))
									else
										menu2.close()
					
										ESX.TriggerServerCallback('dd_society:setJobSalary', function()
											OpenManageGradesMenu(society)
										end, society, data.current.value, amount)
									end
								end, function(data2, menu2)
									menu2.close()
								end)
							end, function(data, menu)
								menu.close()
							end)
						end, society)
					end
				end
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
                local elements = {}
				menu.close()
				if next(CurrentZone) then
					bOpen(zone)
				end
                -- if data.current.garage == 0 then
                --     table.insert(elements, {label = 'Recover vehicle'})
                -- elseif data.current.garage > 0 then
                -- 	table.insert(elements, {label = 'Get vehicle from garage'})
                -- elseif data.current.garage < 0 then
                --     table.insert(elements, {label = 'Retrieve from impound'})
                -- end
                table.insert(elements, {label = 'Rename vehicle' , value = 'rename_vehicle'})
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {
                    title    =  data.current.name,
                    align    = 'top-left',
                    elements = elements,
                }, function(data2, menu2)
                    if data2.current.value == 'rename_vehicle' then
                        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rename_vehicle', {
                            title = 'New vehicle name'
                        }, function(data3, menu3)
                            if string.len(data3.value) >= 1 then
								local change = {
									name = data3.value
								}
								ESX.TriggerServerCallback('dd_society:gModify',function()
									if next(CurrentZone) then
										gManage(zone)
									end
								end, data.current, zone, change)
                            else
                                ESX.ShowNotification('~r~The vehicle name cannot be empty')
                                menu3.close()
                            end
                        end, function(data3, menu3)
                            menu3.close()
                        end)
                    else
						getVehicle(data.current, zone)
					end
                end,
                function(data2, menu2)
                    menu2.close()
                end)
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
