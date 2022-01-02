local playingDead

function canInteract()
	if not PlayerBags.Player.ped or PlayerBags.Player.invOpen or PlayerBags.Player.dead or PlayerBags.Player.ko > 0 or PlayerBags.Player.cuffed then
		return false
	end
	return true
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	LocalPlayer.state:set('ped', PlayerPedId(), true)
	lib.requestAnimDict('mp_arresting')
	lib.requestAnimDict('mp_arrest_paired')
	lib.requestAnimDict('mini@cpr@char_a@cpr_str')
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	TriggerServerEvent('dd_society:saveJob', job)
end)

RegisterNetEvent('dd_society:revive', function(full, coords)
	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Wait(50)
	end

	coords = coords or vec(pedPos, GetEntityHeading(PlayerBags.Player.ped))

	SetEntityCoordsNoOffset(PlayerBags.Player.ped, coords.xyz, coords.w, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.xyz, coords.w, true, false)
	SetPlayerInvincible(PlayerBags.Player.ped, false)
	ClearPedBloodDamage(PlayerBags.Player.ped)

	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')

	playingDead = false
	SendNUIMessage({response = 'closeDead'})
	AnimpostfxStop('DeathFailOut')

	LocalPlayer.state:set('dead', false, true)
	if full then
		LocalPlayer.state:set('ko', 0, true)
		LocalPlayer.state:set('cuffed', false, true)
		SetPedConfigFlag(PlayerBags.Player.ped, 146, false)
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
		if PlayerBags.Player.ped then
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
			if PlayerBags.Player.dead or PlayerBags.Player.ko > 0 then
				DisableAllControlActions(0)
				EnableControlAction(0, 0, true) -- v
				EnableControlAction(0, 1, true) -- pan
				EnableControlAction(0, 2, true) -- tilt
				EnableControlAction(2, 199, true) -- esc
				EnableControlAction(0, 245, true) -- t
				if not playingDead and PlayerBags.Player.dead then
					SetEntityHealth(PlayerBags.Player.ped, 0)
					playingDead = true
					SendNUIMessage({response = 'openDead'})
					AnimpostfxPlay('DeathFailOut', 0, true)
				end
			else
				if PlayerBags.Player.cuffed then
					if not isBusy and not (IsEntityPlayingAnim(PlayerBags.Player.ped, 'mp_arresting', 'idle', 3) or IsEntityPlayingAnim(PlayerBags.Player.ped, 'mp_arrest_paired', 'crook_p2_back_right', 3) or IsEntityPlayingAnim(PlayerBags.Player.ped, 'mp_arresting', 'b_cuff', 3)) or IsPedRagdoll(PlayerBags.Player.ped) then
						ClearPedTasks(PlayerBags.Player.ped)
						TaskPlayAnim(PlayerBags.Player.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, 0, 0, 0)
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
		elseif playingDead then
			playingDead = false
			SendNUIMessage({response = 'closeDead'})
			AnimpostfxStop('DeathFailOut')
		end
	end
end)

CreateThread(function()
	while true do
		Wait(1000)
		if PlayerBags.Player.ped then
			if GetEntityType(PlayerBags.Player.ped) == 1 then
				local health = GetEntityHealth(PlayerBags.Player.ped)
				if health < 125 or IsPedBeingStunned(PlayerBags.Player.ped, 0) then
					if PlayerBags.Player.ko < 30 then
						LocalPlayer.state:set('ko', 30, true)
					end

					if not PlayerBags.Player.dead and health == 0 then
						LocalPlayer.state:set('dead', true, true)
					end
				elseif PlayerBags.Player.ko > 0 then
					LocalPlayer.state:set('ko', PlayerBags.Player.ko - 1, true)
				end

				if PlayerBags.Player.ko > 0 then
					local vehicle = GetVehiclePedIsIn(PlayerBags.Player.ped, false)
					if vehicle ~= 0 then
						if GetPedInVehicleSeat(vehicle, -1) == PlayerBags.Player.ped then
							TaskLeaveVehicle(PlayerBags.Player.ped, vehicle, 4160)
						end
					end

					SetPlayerHealthRechargeMultiplier((PlayerBags.Player.ped), 1.0)
					SetPedToRagdoll(PlayerBags.Player.ped, 2000, 2000, 0, 0, 0, 0)
					ResetPedRagdollTimer(PlayerBags.Player.ped)
				end
			else
				LocalPlayer.state:set('ped', false, true)
			end
		end
	end
end)

RegisterCommand('bleedOut', function()
	if PlayerBags.Player.dead then
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
