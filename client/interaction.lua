RegisterKeyMapping('interact', 'Interact', 'keyboard', 'e')
RegisterKeyMapping('lock/unlock', 'Lock/Unlock Door', 'keyboard', 'x')
RegisterKeyMapping('societyMenu', 'Society Menu', 'keyboard', 'f6')
RegisterKeyMapping('billsMenu', 'Bills Menu', 'keyboard', 'f7')
RegisterKeyMapping('+interactionMenu', 'Interaction Menu', 'keyboard', 'lcontrol')
RegisterKeyMapping('bleedOut', 'Bleed Out', 'keyboard', 'e')
RegisterKeyMapping('resuscitate', 'Resuscitate', 'keyboard', 'e')
RegisterKeyMapping('cuff', 'Cuff', 'keyboard', 'r')
RegisterKeyMapping('escort', 'Escort', 'keyboard', 'q')
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
		{icon = 'fas fa-sign-in-alt', name = 'escortInVehicle'},
		{icon = 'fas fa-sign-out-alt', name = 'escortOutVehicle'},
	},
}

local validEntity, actions, entityCoords

RegisterCommand('+interactionMenu', function()
	if not targetActive and not IsPedInAnyVehicle(ESX.PlayerData.ped, false) and not isBusy and not (LocalPlayer.state.dead or LocalPlayer.state.ko > 0 or LocalPlayer.state.cuffed) and not LocalPlayer.state.invOpen then 
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
				if LocalPlayer.state.escorting then
					validEntity = GetPlayerPed(GetPlayerFromServerId(LocalPlayer.state.escorting))
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
		local bag = 'Player:' .. targetId
		if bag.state.dead then
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
					TriggerServerEvent('dd_society:revivePlayer', targetId)
					ESX.ShowNotification('~g~Player resuscitated')
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

RegisterCommand('cuff', function(source, args, rawCommand)
	if targetActive and not isBusy and validAction(rawCommand) then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		isBusy = true
		ClearPedTasks(ESX.PlayerData.ped)
		TaskGoToEntity(ESX.PlayerData.ped, validEntity, -1, 1.5, 1.0, 0, 0)
		repeat Wait(1000) until #(pedPos - entityCoords) < 1.5
		TriggerServerEvent('dd_society:cuffPlayer', GetPlayerServerId(NetworkGetPlayerIndexFromPed(validEntity)))
	end
end)

RegisterNetEvent('dd_society:Cuffer', function(target, cuffed, escorted)
	if cuffed == escorted or cuffed and escorted then
		TriggerServerEvent('dd_society:escortPlayer', target)
	end
	if cuffed then
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
	else
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
	end
end)

RegisterNetEvent('dd_society:Cuffee', function()
	isBusy = true
	TriggerEvent('esx_policejob:handcuff')
	LocalPlayer.state.cuffed = not LocalPlayer.state.cuffed
	ClearPedTasks(ESX.PlayerData.ped)
	SetPedConfigFlag(ESX.PlayerData.ped, 146, LocalPlayer.state.cuffed)
	if LocalPlayer.state.cuffed then
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
			isBusy = false
		end)
	end
end)

RegisterCommand('escort', function(source, args, rawCommand)
	if targetActive and not isBusy and validAction(rawCommand) then
		SendNUIMessage({response = 'closeTarget'})
		targetActive = false
		ClearPedTasks(ESX.PlayerData.ped)
		TaskGoToEntity(ESX.PlayerData.ped, validEntity, -1, 1.5, 1.0, 0, 0)
		-- repeat Wait(1000) until #(pedPos - entityCoords) < 1.5
		TriggerServerEvent('dd_society:escortPlayer', GetPlayerServerId(NetworkGetPlayerIndexFromPed(validEntity)))
	end
end)

RegisterNetEvent('dd_society:escort', function(id)
	if id == LocalPlayer.state.escorted then
		return
	end
	LocalPlayer.state:set('escorted', id, true)
	if LocalPlayer.state.escorted then
		local entity = GetPlayerPed(GetPlayerFromServerId(id))
		AttachEntityToEntity(ESX.PlayerData.ped, entity, 11816, 0.0, 0.75, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
	else
		DetachEntity(ESX.PlayerData.ped, true, false)
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
