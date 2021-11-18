CreateThread(function()
	dataReady()
	while true do
		Wait(100)
		if Data.Player.Auth and Data.Doors then
			for k, v in pairs(Data.Doors) do
				local distance = #(pedPos - v.coords)
				if #(pedPos - v.coords) < v.distance then
					if has_value(Data.Player.Auth.Doors, k) then
						v.displayText = v.locked and '~r~Locked' or '~g~Unlocked'
						if Config.debugDoor or v.debug then
							v.displayText = v.name .. '\n' .. v.displayText
						end
					end	
				else
					v.displayText = nil
				end
			end
		end
	end
end)

RegisterCommand('lock/unlock', function()
	if LocalPlayer.state.dead or LocalPlayer.state.ko > 0 or LocalPlayer.state.cuffed then
		return
	end
	
	local closeDist = 25
	local closeDoor = {}
	for k, v in pairs(Data.Player.Auth.Doors) do
		local door = Data.Doors[v]
		local distance = #(pedPos - door.coords)
		if distance < door.distance then
			if closeDist > distance then
				closeDist = distance
				closeDoor = door
			end
		end
	end

	if has_value(Data.Player.Auth.Doors, closeDoor.id) then
		closeDoor.locked = not closeDoor.locked
		TriggerServerEvent('dd_society:changeDoorState', closeDoor.id, closeDoor.locked)
	end
end)

CreateThread(function()
	dataReady()
	while true do
		Wait(10)
		pedPos = GetEntityCoords(ESX.PlayerData.ped)
		if Data.Doors then
			for k, v in pairs(Data.Doors) do
				applyDoorState(v)
				if v.displayText then
					if not v.text then
						local x, y, z
						local minVec, maxVec = GetModelDimensions(v.hash)
						local offset = minVec - maxVec
						if maxVec.x > -0.1 and maxVec.x > 0.1 then
							offset = maxVec - minVec
						end
						if v.type == 'door' then
							x = offset.x/2
							z = math.abs(offset.z)/5
						elseif v.type == 'gate' then
							x = offset.x/2
							z = math.abs(offset.z)/1.5
						elseif v.type == 'garage' then
							z = offset.z/10
						elseif v.type == 'lift' then
							z = offset.z/2
						end
						v.text = GetOffsetFromEntityInWorldCoords(v.object, x or 0, y or 0, z or 0)
					end
					ESX.Game.Utils.DrawText3D(v.text, v.displayText, (0.75 + v.distance/10))
				end
			end
		end
	end
end)


function applyDoorState(door)
	dataReady()
	if #(pedPos - door.coords) > 25 then
		return
	end

	if not door.object or door.object == 0 then
		door.object = GetClosestObjectOfType(door.coords, 1.0, door.hash, false, false, false)
	else
		if not IsEntityAtCoord(door.object, door.coords.x, door.coords.y, door.coords.z, 1.0, 1.0, 1.0, 0, 1, 0) then
			door.object = 0
		end
	end

	if door.object == 0 then
		return
	end

	if door.locked then
		if door.axis then
			local doorPos = GetEntityCoords(door.object)
			local distance = math.abs(doorPos[door.axis] - door.coords[door.axis])
			if distance < 0.05 then
				NetworkRequestControlOfEntity(door.object)
				FreezeEntityPosition(door.object, true)
			end
		else
			local locked, heading = GetStateOfClosestDoorOfType(door.hash, door.coords.x, door.coords.y, door.coords.z)
			if heading < 0.01 and heading > -0.01 then
				NetworkRequestControlOfEntity(door.object)
				FreezeEntityPosition(door.object, true)
			end
		end
	else
		NetworkRequestControlOfEntity(door.object)
		FreezeEntityPosition(door.object, false)
	end
end
