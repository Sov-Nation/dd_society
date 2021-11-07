RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	TriggerEvent('dd_society:getPlayer', 'self')
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function()
	ESX.PlayerData.dead = true
	ESX.UI.Menu.CloseAll()
	TriggerServerEvent('dd_society:updateDeath', true)

	StartScreenEffect('DeathFailOut', 0, false)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	TriggerServerEvent('dd_society:saveJob', job)
	showBlips()
	refreshBussHUD()
end)

CreateThread(function()
	while true do
		Wait(0)
		if ESX.PlayerLoaded and (ESX.PlayerData.dead or ESX.PlayerData.ko) then
			ESX.UI.Menu.CloseAll()
			DisableAllControlActions(0)
			EnableControlAction(0, 0, true) -- v
			EnableControlAction(0, 1, true) -- pan
			EnableControlAction(0, 2, true) -- tilt
			EnableControlAction(2, 199, true) -- esc
			EnableControlAction(0, 245, true) -- t
		else
			Wait(500)
		end
	end
end)

RegisterNetEvent('dd_society:revive', function(unko)
	TriggerServerEvent('dd_society:updateDeath', false)

	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Wait(50)
	end

	local heading = GetEntityHeading(ESX.PlayerData.ped)

	SetEntityCoordsNoOffset(ESX.PlayerData.ped, pedPos, heading, false, false, false, true)
	NetworkResurrectLocalPlayer(pedPos, heading, true, false)
	SetPlayerInvincible(ESX.PlayerData.ped, false)
	ClearPedBloodDamage(ESX.PlayerData.ped)

	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')

	if unko then
		TriggerEvent('dd_society:unko')
	end

	StopScreenEffect('DeathFailOut')
	DoScreenFadeIn(800)
end)

local unarmed = 0.2
local blunt = 0.3
local sharp = 0.5

CreateThread(function()
	while true do
		Wait(0)
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
end)

local timer

CreateThread(function()
	while true do
		Wait(1000)
		if ESX.PlayerLoaded and ESX.PlayerData.ped then
			if GetEntityHealth(ESX.PlayerData.ped) < 125 or IsPedBeingStunned(ESX.PlayerData.ped, 0) then
				ESX.PlayerData.ko = true
				timer = 30
			end

			if ESX.PlayerData.ko then
				timer -= 1

				local vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
				if vehicle ~= 0 then
					if GetPedInVehicleSeat(vehicle, -1) == ESX.PlayerData.ped then
						TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 4160)
					end
				end

				SetPlayerHealthRechargeMultiplier((ESX.PlayerData.ped), 1.0)
				SetPedToRagdoll(ESX.PlayerData.ped, 2000, 2000, 0, 0, 0, 0)
				ResetPedRagdollTimer(ESX.PlayerData.ped)
				if timer == 0 then
					ESX.PlayerData.ko = false
				end
			end
		end
	end
end)

RegisterNetEvent('dd_society:unko', function(t)
	Wait(t and t*1000 or 0)
	ESX.PlayerData.ko = false
end)

RegisterNetEvent('dd_society:ko', function(t)
	ESX.PlayerData.ko = true
	timer = t or 30
end)
