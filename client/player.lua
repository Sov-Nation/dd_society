RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	showBlips()
	refreshBussHUD()
end)

AddEventHandler('playerSpawned', function()
	ESX.PlayerData.dead = false
end)

AddEventHandler('esx:onPlayerDeath', function()
	ESX.PlayerData.dead = true
	ESX.UI.Menu.CloseAll()
	TriggerServerEvent('dd_society:pSetDeathStatus', true)

	StartScreenEffect('DeathFailOut', 0, false)
end)

CreateThread(function()
	while true do
		Wait(0)

		if ESX.PlayerData.dead or ESX.PlayerData.ko then
			ESX.UI.Menu.CloseAll()
			DisableAllControlActions(0)
			EnableControlAction(0, 245, true) -- t
			EnableControlAction(0, 38, true) -- e
			EnableControlAction(0, 344, true) -- f11
			EnableControlAction(2, 199, true) -- esc
		else
			Wait(500)
		end
	end
end)

RegisterNetEvent('dd_society:revive')
AddEventHandler('dd_society:revive', function(unko)
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	TriggerServerEvent('dd_society:pSetDeathStatus', false)

	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Wait(50)
	end

	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(playerPed, false)
	ClearPedBloodDamage(playerPed)

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
	end
end)

local timer

CreateThread(function()
	while true do
		Wait(1000)
		local myPed = PlayerPedId()
		local health = GetEntityHealth(myPed)

		if health < 125 then
			ESX.PlayerData.ko = true
			timer = 30
		end

		if ESX.PlayerData.ko then
			timer = timer - 1

			local vehicle = GetVehiclePedIsIn(myPed, false)
			if vehicle ~= 0 then
				local seatPed = GetPedInVehicleSeat(vehicle, -1)
				if seatPed == myPed then
					TaskLeaveVehicle(myPed, vehicle, 4160)
				end
			end

			SetPlayerHealthRechargeMultiplier((myPed), 1.0)
			SetPedToRagdoll(myPed, 2000, 2000, 0, 0, 0, 0)
			ResetPedRagdollTimer(myPed)
			if timer == 0 then
				ESX.PlayerData.ko = false
			end
		end
	end
end)

RegisterNetEvent('dd_society:unko')
AddEventHandler('dd_society:unko', function(t)
	if t == nil then
		ESX.PlayerData.ko = false
	elseif ESX.PlayerData.ko then
		Wait(t*1000)
		ESX.PlayerData.ko = false
	end
end)

RegisterNetEvent('dd_society:ko')
AddEventHandler('dd_society:ko', function()
	ESX.PlayerData.ko = true
	timer = 30
end)
