RegisterKeyMapping('interact', 'Interact', 'keyboard', 'e')
RegisterKeyMapping('lock/unlock', 'Lock/Unlock Door', 'keyboard', 'x')
RegisterKeyMapping('societyMenu', 'Society Menu', 'keyboard', 'f6')
RegisterKeyMapping('billsMenu', 'Bills Menu', 'keyboard', 'f7')
RegisterKeyMapping('+interactionMenu', 'Interaction Menu', 'keyboard', 'lcontrol')
RegisterKeyMapping('bleedOut', 'Bleed Out', 'keyboard', 'e')
RegisterKeyMapping('resuscitate', 'Resuscitate', 'keyboard', 'r')
RegisterKeyMapping('cuff', 'Cuff', 'keyboard', 'e')
RegisterKeyMapping('escort', 'Escort', 'keyboard', 'q')
RegisterKeyMapping('vehicleEscort', 'Vehicle Escort', 'keyboard', 'q')
RegisterKeyMapping('steal', 'Steal', 'keyboard', 'c')
RegisterKeyMapping('repair', 'Repair', 'keyboard', 'e')

CreateThread(function()
	Wait(1000)
	local commands = {
		'interact',
		'lock/unlock',
		'societyMenu',
		'billsMenu',
		'interactionMenu',
		'bleedOut',
		'resuscitate',
		'cuff',
		'escort',
		'steal',
		'repair',
	}
	for i = 1, #commands do
		TriggerEvent('chat:removeSuggestion', '/' .. commands[i])
	end
end)

local RaycastCamera = function(flag)
	local cam = GetGameplayCamCoord()
	local direction = GetGameplayCamRot()
	direction = vec2(math.rad(direction.x), math.rad(direction.z))
	local num = math.abs(math.cos(direction.x))
	direction = vec3((-math.sin(direction.y) * num), (math.cos(direction.y) * num), math.sin(direction.x))
	local rayHandle = StartShapeTestLosProbe(cam.x, cam.y, cam.z, cam.x + direction.x * 30, cam.y + direction.y * 30, cam.z + direction.z * 30, flag or -1, ESX.PlayerData.ped or PlayerPedId(), 0)
	while true do
		Wait(0)
		local result, _, endCoords, _, materialHash, entityHit = GetShapeTestResultIncludingMaterial(rayHandle)
		if result ~= 1 then
			return flag, endCoords, entityHit, entityHit and GetEntityType(entityHit) or 0
		end
	end
end

local curFlag = 30
local switch = function()
	if curFlag == 30 then curFlag = -1 else curFlag = 30 end
	return curFlag
end

local entityTypes = {
	ped = {
		{icon = 'fas fa-lock', name = 'cuffPed'},
		{icon = 'fas fa-medkit', name = 'resuscitatePed'},
		{icon = 'fas fa-mask', name = 'stealPed'},
		{icon = 'fas fa-people-arrows', name = 'escortPed'},
	},
	player = {
		{icon = 'fas fa-lock', name = 'cuff'},
		{icon = 'fas fa-medkit', name = 'resuscitate'},
		{icon = 'fas fa-mask', name = 'steal'},
		{icon = 'fas fa-people-arrows', name = 'escort'},
	},
	vehicle = {
		{icon = 'fas fa-tools', name = 'repair'},
		{icon = 'fas fa-barcode', name = 'vehicleInfo'},
		{icon = 'fas fa-people-arrows', name = 'vehicleEscort'},
	},
}

local validEntity, actions

RegisterCommand('+interactionMenu', function()
	if not targetActive and not IsPedInAnyVehicle(ESX.PlayerData.ped, false) and not isBusy and canInteract() and not PlayerBags.Player.invOpen then
		targetActive = true
		local hit, coords, entity, entityType = RaycastCamera(switch())
		local sleep = 10
		SendNUIMessage({response = 'openTarget'})
		while targetActive do
			if IsPedInAnyVehicle(ESX.PlayerData.ped, false) then
				SendNUIMessage({response = 'closeTarget'})
				targetActive = false
				validEntity = nil
			end
			local distance = #(pedPos - coords)
			if entity == validEntity and distance < 5 then
				sleep = 100
			else
				if validEntity then
					validEntity = nil
					actions = nil
					SendNUIMessage({response = 'leftTarget'})
				end
				if PlayerBags.Player.escorting then
					validEntity = GetPlayerPed(GetPlayerFromServerId(PlayerBags.Player.escorting))
					actions = entityTypes.player
					SendNUIMessage({response = 'validTarget', actions = actions})
				end
				if has_value({1, 2}, entityType) and distance < 5 then
					if entityType == 1 and IsPedAPlayer(entity) then
						actions = entityTypes.player
					-- elseif entityType == 1 then
					-- 	type = 'ped'
					elseif entityType == 2 then
						actions = entityTypes.vehicle
					end
					if next(actions) then
						validEntity = entity
						SendNUIMessage({response = 'validTarget', actions = actions})
					end
				end
			end
			Wait(sleep)
			sleep = 10
			_, coords, entity, entityType = RaycastCamera(hit)
		end
	end
end)

RegisterCommand('-interactionMenu', function()
	if targetActive then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		validEntity = nil
	end
end)

AddStateBagChangeHandler('invOpen', 'player:' .. GetPlayerServerId(PlayerId()), function(bagName, _, value, _, _)
	if targetActive and value then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		validEntity = nil
	end
end)

function validAction(action)
	if actions then
		for i = 1, #actions do
			if actions[i].name == action then
				return true
			end
		end
	end
	return false
end

RegisterCommand('resuscitate', function(source, args, rawCommand)
	if targetActive and not isBusy and validAction(rawCommand) then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		isBusy = true
		local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(validEntity))
		if PlayerBags.targetId.dead then
			ClearPedTasks(ESX.PlayerData.ped)
			TaskGoToEntity(ESX.PlayerData.ped, validEntity, 2000, 1.5, 1.5, 0, 0)
			local count = 0
			while #(pedPos - GetEntityCoords(validEntity)) > 1.5 and not PlayerBags.Player.escorting and count < 20 do
				Wait(100)
				count += 1
			end
			if count < 20 and #(pedPos - GetEntityCoords(validEntity)) < 1.5 then
				exports.ox_inventory:Progress({
					duration = 10000,
					label = 'Reviving',
					useWhileDead = false,
					canCancel = true,
					disable = {
						move = true,
						car = true,
						combat = true,
						mouse = false
					},
					anim = {
						dict = 'mini@cpr@char_a@cpr_str',
						clip = 'cpr_pumpchest',
					},
				},
				function(cancel)
					if not cancel then
						TriggerServerEvent('dd_society:revivePlayer', targetId)
						ESX.ShowNotification('~g~Player resuscitated')
					end
					isBusy = false
					validEntity = nil
				end)
			end
		else
			isBusy = false
			validEntity = nil
		end
	end
end)

RegisterCommand('cuff', function(source, args, rawCommand)
	if targetActive and not isBusy and validAction(rawCommand) then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		isBusy = true
		ClearPedTasks(ESX.PlayerData.ped)
		TaskGoToEntity(ESX.PlayerData.ped, validEntity, 2000, 1.5, 1.5, 0, 0)
		local count = 0
		while #(pedPos - GetEntityCoords(validEntity)) > 1.5 and not PlayerBags.Player.escorting and count < 20 do
			Wait(100)
			count += 1
		end
		if count < 20 and #(pedPos - GetEntityCoords(validEntity)) < 1.5 then
			TriggerServerEvent('dd_society:cuff', GetPlayerServerId(NetworkGetPlayerIndexFromPed(validEntity)))
		end
		isBusy = false
		validEntity = nil
	end
end)

RegisterNetEvent('dd_society:restrainer', function(cuff)
	isBusy = true
	if cuff then
		exports.ox_inventory:Progress({
			duration = 4500,
			label = 'Cuffing',
			useWhileDead = false,
			canCancel = false,
			disable = {
				move = true,
				car = true,
				combat = true,
				mouse = false
			},
			anim = {
				dict = 'mp_arrest_paired',
				clip = 'cop_p2_back_right',
			},
		},
		function(cancel)
			isBusy = false
		end)
	else
		exports.ox_inventory:Progress({
			duration = 4000,
			label = 'Uncuffing',
			useWhileDead = false,
			canCancel = false,
			disable = {
				move = true,
				car = true,
				combat = true,
				mouse = false
			},
			anim = {
				dict = 'mp_arresting',
				clip = 'a_uncuff',
			},
		},
		function(cancel)
			isBusy = false
		end)
	end
end)

RegisterNetEvent('dd_society:cuff', function(control, cuff)
	isBusy = true
	ClearPedTasks(ESX.PlayerData.ped)
	SetPedConfigFlag(ESX.PlayerData.ped, 146, cuff)
	AttachEntityToEntity(ESX.PlayerData.ped, GetPlayerPed(GetPlayerFromServerId(control)), 11816, 0.0, 0.75, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
	if cuff then
		TriggerEvent('ox_inventory:disarm')
		exports.ox_inventory:Progress({
			duration = 4500,
			label = 'Getting Cuffed',
			useWhileDead = true,
			canCancel = false,
			disable = {
				move = true,
				car = true,
				combat = true,
				mouse = false
			},
			anim = {
				dict = 'mp_arrest_paired',
				clip = 'crook_p2_back_right',
			},
		},
		function(cancel)
			isBusy = false
		end)
	else
		exports.ox_inventory:Progress({
			duration = 4000,
			label = 'Getting Uncuffed',
			useWhileDead = true,
			canCancel = false,
			disable = {
				move = true,
				car = true,
				combat = true,
				mouse = false
			},
			anim = {
				dict = 'mp_arresting',
				clip = 'b_uncuff',
			},
		},
		function(cancel)
			DetachEntity(ESX.PlayerData.ped, true, false)
			isBusy = false
		end)
	end
end)

RegisterCommand('escort', function(source, args, rawCommand)
	if targetActive and not isBusy and validAction(rawCommand) then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		isBusy = true
		ClearPedTasks(ESX.PlayerData.ped)
		TaskGoToEntity(ESX.PlayerData.ped, validEntity, 2000, 1.5, 1.5, 0, 0)
		local count = 0
		while #(pedPos - GetEntityCoords(validEntity)) > 1.5 and not PlayerBags.Player.escorting and count < 20 do
			Wait(100)
			count += 1
		end
		if count < 20 and #(pedPos - GetEntityCoords(validEntity)) < 1.5 then
			TriggerServerEvent('dd_society:escort', GetPlayerServerId(NetworkGetPlayerIndexFromPed(validEntity)))
		end
		isBusy = false
		validEntity = nil
	end
end)

RegisterNetEvent('dd_society:escort', function(control, escort, vehicle, seat)
	if escort then
		if vehicle and seat then
			TaskLeaveVehicle(ESX.PlayerData.ped, NetworkGetEntityFromNetworkId(vehicle), 16)
			Wait(10)
		end
		AttachEntityToEntity(ESX.PlayerData.ped, GetPlayerPed(GetPlayerFromServerId(control)), 11816, 0.0, 0.75, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
	else
		DetachEntity(ESX.PlayerData.ped, true, false)
		if vehicle and seat then
			SetPedIntoVehicle(ESX.PlayerData.ped, NetworkGetEntityFromNetworkId(vehicle), seat)
		end
	end
end)

RegisterCommand('steal', function(source, args, rawCommand)
	if targetActive and not isBusy and validAction(rawCommand) then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		TriggerEvent('ox_inventory:openInventory', 'player', GetPlayerServerId(NetworkGetPlayerIndexFromPed(validEntity)))
		validEntity = nil
	end
end)

RegisterCommand('repair', function(source, args, rawCommand)
	if targetActive and not isBusy and validAction(rawCommand) then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		isBusy = true
		ClearPedTasks(ESX.PlayerData.ped)
		TaskTurnPedToFaceEntity(ESX.PlayerData.ped, validEntity, 1000)
		SetVehicleDoorOpen(validEntity, 4, false, false)
		Wait(1000)
		SetVehicleUndriveable(validEntity, true)
		exports.ox_inventory:Progress({
			duration = 15000,
			label = 'Repairing',
			useWhileDead = false,
			canCancel = true,
			disable = {
				move = true,
				car = true,
				combat = true,
				mouse = false
			},
			anim = {
				scenario = 'PROP_HUMAN_BUM_BIN',
			},
		},
		function(cancel)
			if not cancel then
				ClearPedTasks(ESX.PlayerData.ped)
				Wait(2000)
				SetVehicleDoorShut(validEntity, 4, false)
				Wait(450)
				SetVehicleFixed(validEntity)
				SetVehicleDeformationFixed(validEntity)
				SetVehicleUndriveable(validEntity, false)
				ESX.ShowNotification('~g~Vehicle repaired')
			end
			isBusy = false
			validEntity = nil
		end)
	end
end)

RegisterCommand('vehicleEscort', function(source, args, rawCommand)
	if targetActive and not isBusy and validAction(rawCommand) then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		local backSeats = GetVehicleModelNumberOfSeats(GetEntityModel(validEntity)) - 2
		if backSeats < 1 then
			isBusy = false
			validEntity = nil
			return
		end
		if PlayerBags.Player.escorting then
			for i = 1, backSeats do
				if IsVehicleSeatFree(validEntity, i) then
					TriggerServerEvent('dd_society:escort', PlayerBags.Player.escorting, NetworkGetNetworkIdFromEntity(validEntity), i)
					break
				end
			end
		else
			for i = 1, backSeats do
				if not IsVehicleSeatFree(validEntity, i) then
					TriggerServerEvent('dd_society:escort', GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(validEntity, i))), NetworkGetNetworkIdFromEntity(validEntity), i)
					break
				end
			end
		end
		validEntity = nil
	end
end)
