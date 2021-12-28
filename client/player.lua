local playingDead

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	TriggerEvent('dd_society:getPlayer', 'self')
	lib.requestAnimDict('mp_arresting')
	lib.requestAnimDict('mp_arrest_paired')
	lib.requestAnimDict('mini@cpr@char_a@cpr_str')
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	TriggerServerEvent('dd_society:saveState')
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
	playingDead = false
	SendNUIMessage({response = 'closeDead'})
	AnimpostfxStop('DeathFailOut')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	TriggerServerEvent('dd_society:saveJob', job)
	showBlips()
	refreshBussHUD()
end)

RegisterNetEvent('dd_society:revive', function(full, coords)
	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Wait(50)
	end

	coords = coords or vec(pedPos, GetEntityHeading(ESX.PlayerData.ped))

	SetEntityCoordsNoOffset(ESX.PlayerData.ped, coords.xyz, coords.w, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.xyz, coords.w, true, false)
	SetPlayerInvincible(ESX.PlayerData.ped, false)
	ClearPedBloodDamage(ESX.PlayerData.ped)

	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')

	playingDead = false
	SendNUIMessage({response = 'closeDead'})
	AnimpostfxStop('DeathFailOut')

	LocalPlayer.state:set('dead', false, true)
	if full then
		LocalPlayer.state:set('ko', 0, true)
		LocalPlayer.state:set('cuffed', false, true)
		SetPedConfigFlag(ESX.PlayerData.ped, 146, false)
	else
		Wait(2000)
	end
	DoScreenFadeIn(800)
end)

CreateThread(function()
	local unarmed = 0.2
	local blunt = 0.3
	local sharp = 0.5
	while true do
		Wait(0)
		if ESX.PlayerLoaded then
			SetWeaponDamageModifier(`WEAPON_UNARMED`, unarmed)
			SetWeaponDamageModifier(`WEAPON_FLASHLIGHT`, blunt)
			SetWeaponDamageModifier(`WEAPON_KNUCKLE`, blunt)
			SetWeaponDamageModifier(`WEAPON_HATCHET`, sharp)
			SetWeaponDamageModifier(`WEAPON_MACHETE`, sharp)
			SetWeaponDamageModifier(`WEAPON_SWITCHBLADE`, sharp)
			SetWeaponDamageModifier(`WEAPON_BOTTLE`, sharp)
			SetWeaponDamageModifier(`WEAPON_DAGGER`, sharp)
			SetWeaponDamageModifier(`WEAPON_POOLCUE`, blunt)
			SetWeaponDamageModifier(`WEAPON_WRENCH`, blunt)
			SetWeaponDamageModifier(`WEAPON_BATTLEAXE`, sharp)
			SetWeaponDamageModifier(`WEAPON_KNIFE`, sharp)
			SetWeaponDamageModifier(`WEAPON_NIGHTSTICK`, blunt)
			SetWeaponDamageModifier(`WEAPON_HAMMER`, blunt)
			SetWeaponDamageModifier(`WEAPON_BAT`, blunt)
			SetWeaponDamageModifier(`WEAPON_GOLFCLUB`, blunt)
			SetWeaponDamageModifier(`WEAPON_CROWBAR`, blunt)
			
			DisableControlAction(0, 36, true) -- ctrl
			if LocalPlayer.state.dead or (LocalPlayer.state.ko or 0) > 0 then
				DisableAllControlActions(0)
				EnableControlAction(0, 0, true) -- v
				EnableControlAction(0, 1, true) -- pan
				EnableControlAction(0, 2, true) -- tilt
				EnableControlAction(2, 199, true) -- esc
				EnableControlAction(0, 245, true) -- t
				if not playingDead and LocalPlayer.state.dead then
					SetEntityHealth(ESX.PlayerData.ped, 0)
					AnimpostfxPlay('DeathFailOut', 0, true)
					playingDead = true
					SendNUIMessage({response = 'openDead'})
				end
			else
				if playingDead then
					playingDead = false
					SendNUIMessage({response = 'closeDead'})
				end

				if LocalPlayer.state.cuffed then
					if not isBusy and not (IsEntityPlayingAnim(ESX.PlayerData.ped, 'mp_arresting', 'idle', 3) or IsEntityPlayingAnim(ESX.PlayerData.ped, 'mp_arrest_paired', 'crook_p2_back_right', 3) or IsEntityPlayingAnim(ESX.PlayerData.ped, 'mp_arresting', 'b_cuff', 3)) or IsPedRagdoll(ESX.PlayerData.ped) then
						ClearPedTasks(ESX.PlayerData.ped)
						TaskPlayAnim(ESX.PlayerData.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, 0, 0, 0)
					end
					DisableAllControlActions(0)
					EnableControlAction(0, 0, true) -- v
					EnableControlAction(0, 1, true) -- pan
					EnableControlAction(0, 2, true) -- tilt
					EnableControlAction(0, 21, true) -- sprint
					EnableControlAction(0, 30, true) -- move up/down
					EnableControlAction(0, 31, true) -- move left/right
					EnableControlAction(0, 245, true) -- t
				end

				if targetActive then
					DisableAllControlActions(0)
					EnableControlAction(0, 0, true) -- v
					EnableControlAction(0, 1, true) -- pan
					EnableControlAction(0, 2, true) -- tilt
					EnableControlAction(0, 21, true) -- sprint
					EnableControlAction(0, 24, true) -- attack
					EnableControlAction(0, 25, true) -- aim
					EnableControlAction(0, 30, true) -- move up/down
					EnableControlAction(0, 31, true) -- move left/right
					EnableControlAction(0, 142, true) -- melee attack
				end
			end
		end
	end
end)

CreateThread(function()
	while true do
		Wait(1000)
		if ESX.PlayerLoaded and ESX.PlayerData.ped then
			local health = GetEntityHealth(ESX.PlayerData.ped)
			if health < 125 or IsPedBeingStunned(ESX.PlayerData.ped, 0) then
				if LocalPlayer.state.ko < 30 then
					LocalPlayer.state:set('ko', 30, true)
				end

				if not LocalPlayer.state.dead and health == 0 then
					LocalPlayer.state:set('dead', true, true)
				end
			elseif LocalPlayer.state.ko > 0 then
				LocalPlayer.state:set('ko', LocalPlayer.state.ko - 1, true)
			end
			
			if LocalPlayer.state.ko > 0 then
				local vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
				if vehicle ~= 0 then
					if GetPedInVehicleSeat(vehicle, -1) == ESX.PlayerData.ped then
						TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 4160)
					end
				end

				SetPlayerHealthRechargeMultiplier((ESX.PlayerData.ped), 1.0)
				SetPedToRagdoll(ESX.PlayerData.ped, 2000, 2000, 0, 0, 0, 0)
				ResetPedRagdollTimer(ESX.PlayerData.ped)
			end
		end
	end
end)

RegisterCommand('bleedOut', function()
	if LocalPlayer.state.dead then
		exports.ox_inventory:Progress({
			duration = 5000,
			label = 'Bleeding Out',
			useWhileDead = true,
			canCancel = true,
			disable = {
				move = true,
				car = true,
				combat = true,
				mouse = false
			},
		},
		function(cancel)
			if not cancel then
				TriggerServerEvent('dd_society:revivePlayer', GetPlayerServerId(PlayerId()), pedPos)
			end
		end)
	end
end)
