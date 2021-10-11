CreateThread(function()
	while true do
		Wait(100)
		pedPos = GetEntityCoords(ESX.PlayerData.ped)
		if Data.Player.Auth then
			for k, v in pairs(Data.Doors) do
				local distance = #(pedPos - v.object)
				applyDoorState(v, distance)
				if distance < v.distance then
					local auth = has_value(Data.Player.Auth.Doors, k)
					v.displayText = '~g~Unlocked'

					if v.state then
						v.displayText = '~r~Locked'
					end

					if auth then
						v.displayText = '[X] ' .. v.displayText
					end
				else
					v.displayText = nil
				end
			end
		end
	end
end)

RegisterCommand('lock/unlock', function()
	local closeDist = 25
	local closeDoor = {}
	for k, v in pairs(Data.Doors) do
		local distance = #(pedPos - v.object)
		if distance < v.distance then
			if closeDist > distance then
				closeDist = distance
				closeDoor = v
			end
		end
	end

	if has_value(Data.Player.Auth.Doors, closeDoor.id) then
		closeDoor.state = not closeDoor.state
		TriggerServerEvent('dd_society:updateDoorState', closeDoor)
	end
end)

CreateThread(function()
	while true do
		Wait(10)
		for k, v in pairs(Data.Doors) do
			if v.displayText then
				ESX.Game.Utils.DrawText3D(v.text, v.displayText, (0.75 + v.distance/10))
			end
		end
	end
end)

function applyDoorState(Door, distance)
	if distance > 25 then
		return
	end

	if not Door.closeDoor or Door.closeDoor == 0 then
		Door.closeDoor = GetClosestObjectOfType(Door.object, 1.0, Door.hash, false, false, false)
	else
		if not IsEntityAtCoord(Door.closeDoor, Door.object.x, Door.object.y, Door.object.z, 1.0, 1.0, 1.0, 0, 1, 0) then
			Door.closeDoor = nil
		end
	end

	if not Door.closeDoor or Door.closeDoor == 0 then
		return
	end

	if Door.state then
		if Door.axis ~= nil then
			local pos = GetEntityCoords(Door.closeDoor)
			local distance = math.abs(pos[Door.axis] - Door.object[Door.axis])
			if distance < 0.02 then
				NetworkRequestControlOfEntity(Door.closeDoor)
				FreezeEntityPosition(Door.closeDoor, true)
			end
		else
			local locked, heading = GetStateOfClosestDoorOfType(Door.hash,  Door.object.x, Door.object.y, Door.object.z)
			if heading < 0.02 and heading > -0.02 then
				NetworkRequestControlOfEntity(Door.closeDoor)
				FreezeEntityPosition(Door.closeDoor, true)
			end
		end
	else
		NetworkRequestControlOfEntity(Door.closeDoor)
		FreezeEntityPosition(Door.closeDoor, false)
	end
end

RegisterNetEvent('dd_society:updateDoor')
AddEventHandler('dd_society:updateDoor', function(Door)
	local OldDoor = Data.Societies[Door.name]

	Data.Doors[Door.id] = Door
end)
