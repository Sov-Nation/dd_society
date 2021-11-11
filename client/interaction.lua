RegisterKeyMapping('interact', 'Interact', 'keyboard', 'e')
RegisterKeyMapping('lock/unlock', 'Lock/Unlock Door', 'keyboard', 'x')
RegisterKeyMapping('societyMenu', 'Society Menu', 'keyboard', 'f6')
RegisterKeyMapping('billsMenu', 'Bills Menu', 'keyboard', 'f7')
RegisterKeyMapping('interactionMenu', 'Interaction Menu', 'keyboard', 'lcontrol')
RegisterKeyMapping('bleedOut', 'Bleed Out', 'keyboard', 'e')
RegisterKeyMapping('revive', 'Revive', 'keyboard', 'e')
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
		'revive',
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
		{icon = 'fas fa-lock-open', name = 'uncuffPed'},
		{icon = 'fas fa-medkit', name = 'revivePed'},
		{icon = 'fas fa-people-arrows', name = 'escortPed'},
	},
	player = {
		{icon = 'fas fa-lock', name = 'cuff'},
		{icon = 'fas fa-lock-open', name = 'uncuff'},
		{icon = 'fas fa-medkit', name = 'revive'},
		{icon = 'fas fa-mask', name = 'steal'},
		{icon = 'fas fa-people-arrows', name = 'escort'},
	},
	vehicle = {
		{icon = 'fas fa-tools', name = 'repair'},
		{icon = 'fas fa-barcode', name = 'vehicleInfo'},
		{icon = 'fas fa-sign-in-alt', name = 'escortInVehicle'},
		{icon = 'fas fa-sign-out-alt', name = 'escortOutVehicle'},
	},
}

local isBusy, validEntity, actions, entityCoords

RegisterCommand('+interactionMenu', function()
	if not targetActive and not IsPedInAnyVehicle(ESX.PlayerData.ped, false) and not isBusy and not (ESX.PlayerData.dead or ESX.PlayerData.ko) then 
		targetActive = true
		local hit, coords, entity, entityType = RaycastCamera(switch())
		entityCoords = coords
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
				if has_value({1, 2}, entityType) and distance < 5 then
					if entityType == 1 and IsPedAPlayer(entity) then
						type = 'player'
					-- elseif entityType == 1 then
					-- 	type = 'ped'
					elseif entityType == 2 then
						type = 'vehicle'
					end
					if type then
						validEntity = entity
						actions = entityTypes[type]
						SendNUIMessage({response = 'validTarget', actions = actions})
					end
				end
			end
			Wait(sleep)
			sleep = 10
			_, coords, entity, entityType = RaycastCamera(hit)
			entityCoords = coords
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

RegisterCommand('revive', function(source, args, rawCommand)
	if targetActive and not isBusy and validAction(rawCommand) then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		isBusy = true
		if IsPedDeadOrDying(validEntity, 1) then
			ClearPedTasks(ESX.PlayerData.ped)
			TaskGoToEntity(ESX.PlayerData.ped, validEntity, -1, 1.5, 1.0, 0, 0)
			repeat Wait(1000) until #(pedPos - entityCoords) < 1.5
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
					TriggerServerEvent('dd_society:revivePlayer', GetPlayerServerId(NetworkGetPlayerIndexFromPed(validEntity)))
					ESX.ShowNotification('~g~Player revived')
				end
				isBusy = false
				validEntity = nil
			end)
		else
			isBusy = false
			validEntity = nil
		end
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
