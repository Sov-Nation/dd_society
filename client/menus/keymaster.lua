function kmOpen()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymaster',{
		title    = 'Keymaster',
		align    = 'top-left',
		elements = {
			{label = 'Societies', value = 'societies'},
			{label = 'Players', value = 'players'},
			{label = 'Properties', value = 'properties'},
		}
	},
	function(data, menu)
		if data.current.value == 'societies' then
			local elements = {}
			for k, v in pairs(Data.Societies) do
				v.props = {}
				for k2, v2 in pairs(Data.Properties) do
					if v.id == v2.owner then
						table.insert(v.props, v2)
					end
				end
				table.insert(elements, {
					label = v.id .. ' - (' .. #v.props .. ')',
					value = v
				})
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymastersocieties',{
				title    = 'Keymaster - Societies',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				elements = {}
				for k, v in pairs(data2.current.value.props) do
					table.insert(elements, {
						label = v.id,
						value = v
					})
				end
				if not next(elements) then
					table.insert(elements, {label = 'None'})
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymastersocietyproperties',{
					title    = 'Keymaster - ' .. data2.current.value.id .. ' - Properties',
					align    = 'top-left',
					elements = elements
				},
				function(data3, menu3)
					kmProperty(data3.current.value)
				end,
				function(data3, menu3)
					menu3.close()
				end)
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'players' then
		elseif data.current.value == 'properties' then
			local elements = {}
			for k, v in pairs(Data.Properties) do
				table.insert(elements, {
					label = v.id .. ' - (' .. v.owner .. ')',
					value = v
				})
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterproperties',{
				title    = 'Keymaster - Properties',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				kmProperty(data2.current.value)
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

function kmProperty(property)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'propertymanager',{
		title    = 'Manage Property - ' .. property.id,
		align    = 'top-left',
		elements = {
			{label = 'Toggle blip', value = 'blip'},
			{label = 'Owner: ' .. property.owner, value = 'owner'},
			{label = 'Keys', value = 'keys'},
			{label = 'Doors ', value = 'doors'},
			{label = 'Zones ', value = 'zones'},
		}
	},
	function(data, menu)
		if data.current.value == 'blip' then
			showBlips(property.id)
		elseif data.current.value == 'owner' then
		elseif data.current.value == 'keys' then
			local elements = {
				{label = 'New key', value = 'newkey'},
				{label = 'Master', value = 0},
			}
			for k, v in pairs(Data.Keys) do
				if v.property == property.id and v.name ~= 'Master' then
					table.insert(elements, {
						label = v.name,
						value = v.designation
					})
				end
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keymasterproperties',{
				title    = property.id .. ' - Keys',
				align    = 'top-left',
				elements = elements
			},
			function(data2, menu2)
				if data2.current.value == 'newkey' then
					kmNewKey(property) --todo
				else

				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'doors' then
		elseif data.current.value == 'zones' then
		end
	end,
	function(data, menu)
		menu.close()
	end)
end