CreateThread(function()
	while true do
		Wait(100)
		if PlayerBags.Player.ped then
			for i = 1, #Data.Doors do
				local door = Data.Doors[i]
				if #(pedPos - vectorize(door.coords)) < door.distance then
					if PlayerBags.Player.auth.doors[door.id] then
						door.displayText = door.locked and '~r~Locked' or '~g~Unlocked'
						if Config.debugDoor or door.debug then
							door.displayText = ('%s\n%s'):format(door.name, door.displayText)
						end
					end
				else
					door.displayText = nil
				end
			end
		end
	end
end)

RegisterCommand('lock/unlock', function()
	if not canInteract() then
		return
	end

	local closeDist, closeDoor = 25
	for k, v in pairs(PlayerBags.Player.auth.doors) do
		local door = Indexed.Doors[k]
		local distance = #(pedPos - vectorize(door.coords))
		if distance < door.distance then
			if closeDist > distance then
				closeDist = distance
				closeDoor = door
			end
		end
	end

	if not closeDoor then
		return
	end

	for i = 1, #Data.Doors do
		if Data.Doors[i].id == closeDoor.id then
			closeDoor = Data.Doors[i]
			break
		end
	end

	closeDoor.locked = not closeDoor.locked
	closeDoor.displayText = closeDoor.locked and '~r~Locked' or '~g~Unlocked'

	TriggerServerEvent('dd_society:pModifyDoor', closeDoor)
end)

CreateThread(function()
	while true do
		pedPos = GetEntityCoords(PlayerBags.Player.ped)
		Wait(0)
		if PlayerBags.Player.ped then
			for i = 1, #Data.Doors do
				local door = Data.Doors[i]
				applyDoorState(door)
				if door.displayText then
					if not door.text then
						local x, y, z
						local minVec, maxVec = GetModelDimensions(door.hash)
						local offset = minVec - maxVec
						if maxVec.x > -0.1 and maxVec.x > 0.1 then
							offset = maxVec - minVec
						end
						if door.type == 'door' then
							x = offset.x/2
							z = math.abs(offset.z)/5
						elseif door.type == 'gate' then
							x = offset.x/2
							z = math.abs(offset.z)/1.5
						elseif door.type == 'garage' then
							z = offset.z/10
						elseif door.type == 'lift' then
							z = offset.z/2
						end
						door.text = GetOffsetFromEntityInWorldCoords(door.object, x or 0, y or 0, z or 0)
					end
					ESX.Game.Utils.DrawText3D(door.text, door.displayText, (0.75 + door.distance/10))
				end
			end
		end
	end
end)


function applyDoorState(door)
	if #(pedPos - vectorize(door.coords)) > 25 then
		return
	end

	if not door.object or door.object == 0 then
		door.object = GetClosestObjectOfType(vectorize(door.coords), 1.0, door.hash, false, false, false)
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
