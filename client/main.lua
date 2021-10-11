Data = {}
DataReady = false

---[[ for dev work
CreateThread(function()
	start()
end)
--]]
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	start()
end)

function start()
	TriggerEvent('dd_society:getSocieties')
	TriggerEvent('dd_society:getPlayer', 'self')
	TriggerEvent('dd_society:getProperties')
	TriggerEvent('dd_society:getKeys')
	TriggerEvent('dd_society:getDoors')
	TriggerEvent('dd_society:getZones')

	while true do
		Wait(100)
		local ready = true
		for k, v in pairs(Data) do
			if not next(v) then
				ready = false
			end
		end
		if ready then
			DataReady = true
			break
		end
	end

	showBlips()
	refreshBussHUD()
end

RegisterNetEvent('dd_society:getSocieties')
AddEventHandler('dd_society:getSocieties', function()
	Data.Societies = {}
	ESX.TriggerServerCallback('dd_society:getSocieties', function(Societies)
		Data.Societies = Societies
	end)
end)

RegisterNetEvent('dd_society:getPlayer')
AddEventHandler('dd_society:getPlayer', function(ident)
	Data.Player = {}
	ESX.TriggerServerCallback('dd_society:getPlayer', function(Player)
		Data.Player = Player
	end, ident)
end)

RegisterNetEvent('dd_society:getProperties')
AddEventHandler('dd_society:getProperties', function()
	Data.Properties = {}
	ESX.TriggerServerCallback('dd_society:getProperties', function(Properties)
		Data.Properties = Properties
	end)
end)

RegisterNetEvent('dd_society:getKeys')
AddEventHandler('dd_society:getKeys', function()
	Data.Keys = {}
	ESX.TriggerServerCallback('dd_society:getKeys', function(Keys)
		Data.Keys = Keys
	end)
end)

RegisterNetEvent('dd_society:getDoors')
AddEventHandler('dd_society:getDoors', function()
	Data.Doors = {}
	ESX.TriggerServerCallback('dd_society:getDoors', function(Doors)
		Data.Doors = Doors
	end)
end)

RegisterNetEvent('dd_society:getZones')
AddEventHandler('dd_society:getZones', function()
	Data.Zones = {}
	ESX.TriggerServerCallback('dd_society:getZones', function(Zones)
		Data.Zones = Zones
	end)
end)

RegisterKeyMapping('interact', 'Interact', 'keyboard', 'e')
TriggerEvent('chat:removeSuggestion', '/interact')

RegisterKeyMapping('lock/unlock', 'Lock/Unlock Door', 'keyboard', 'x')
TriggerEvent('chat:removeSuggestion', '/lock/unlock')

RegisterKeyMapping('societymenu', 'Society Menu', 'keyboard', 'f6')
TriggerEvent('chat:removeSuggestion', '/societymenu')

RegisterKeyMapping('billsmenu', 'Bills Menu', 'keyboard', 'f7')
TriggerEvent('chat:removeSuggestion', '/billsmenu')

function showBlips(target)
	if Blips then
		if target == Blips.target then
			target = nil
		end
		Blips.target = nil
		for k, v in pairs(Blips) do
			RemoveBlip(v)
		end
	end
	Blips = {}
	for k, v in pairs(Data.Properties) do
		local blip = AddBlipForCoord(v.blip)
		SetBlipSprite(blip, Config.PropertyTypes[v.type].sprite)
		if Data.Societies[v.owner] then
			SetBlipDisplay(blip, 2)
			SetBlipCategory(blip, 10)
			SetBlipColour(blip, Data.Societies[v.owner].colour)
			SetBlipShrink(blip, true)

			if v.owner ~= ESX.PlayerData.job.label then
				SetBlipAsShortRange(blip, true)
			end

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString(k .. ' - ' .. Data.Societies[v.owner].label)
			EndTextCommandSetBlipName(blip)
		elseif v.owner == ESX.PlayerData.identifier then
			SetBlipDisplay(blip, 2)
			SetBlipCategory(blip, 11)
			SetBlipShrink(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString(k)
			EndTextCommandSetBlipName(blip)
		else
			SetBlipDisplay(blip, 0)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString(k)
			EndTextCommandSetBlipName(blip)
		end

		if v.id == target then
			SetBlipDisplay(blip, 2)
			SetBlipRoute(blip, true)
			SetBlipAsShortRange(blip, false) --add notification

			Blips.target = target
			-- CreateThread(function() --NFG loops never stop
			--     T = true
			--     while T do
			--         Wait(1000)
			--         print(target)
			--         if #(pedPos.xy - Data.Properties[target].blip.xy) < 50 then
			--             showBlips()
			--             break
			--         elseif not T then
			--             break
			--         end
			--     end
			-- end)
		end

		Blips[v.id] = blip
	end
end

function refreshBussHUD()
	DisableSocietyMoneyHUDElement()
	if ESX.PlayerData.job.grade >= 3 then
		EnableSocietyMoneyHUDElement()
		UpdateSocietyMoneyHUDElement(Data.Societies[ESX.PlayerData.job.label].account)
	end
end

RegisterNetEvent('dd_society:updateSociety')
AddEventHandler('dd_society:updateSociety', function(Society)
	local OldSociety = Data.Societies[Society.label]

	Data.Societies[Society.label] = Society

	if Society.colour ~= OldSociety.colour then
		showBlips()
	end

	if Society.account ~= OldSociety.account and ESX.PlayerData.job.grade >= 3 and ESX.PlayerData.job.label == Society.label then
		UpdateSocietyMoneyHUDElement(Society.account)
	end
end)

function EnableSocietyMoneyHUDElement()
	local societyMoneyHUDElementTpl = '<div><img src="' .. 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFoAAABaCAMAAAAPdrEwAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAMAUExURQAAACmvPCmwPCuwPiywPi2wPy6xQC6xQS+yQTCxQTCyQTCyQjGyQzKyRDOzRTSzRTSzRjW0RjW0Rza0SDe0STi0STm1Sjq1Szq2Szu2TDy2TDy2TT22Tj63Tz+3UEC4UEG4UUG4UkK4U0O5VES5VEW6VUa6Vke6V0i7WEm7WUu8Wku8W0y8W028XE29XU++XlC9X1C+X1G+YFK+YVO/YlW/ZFXAZFfAZVfAZljBZlnBZ1rBaVvCaVvCalzDal7CbF/DbV/EbWHEbmLEb2LEcGTFcWfGdGjHdWrHd2vId2vIeGzIeW3JenHKfXLKfnPLf3TLgHXLgXXMgHXMgXbMgnjNg3nMhHrNhnrOhnzOiH7PiYLQjYPRjoTRjoTRj4XRkIXSkIfSkojSk4rUlYzUlo7VmJDWmpHWm5LXnJTXnZTXnpXYnpbYn5nZopzapJ3bpZ7bpp7bp6DcqKLcqqPcq6Tcq6TdrKberqjfr6jfsKnfsavgs6zgs6zgtK7hta/htrDit7LiuLLiubPjurTjurXju7bkvLbkvbnlv7rlwLrmwLzmwr3nw77nxMDnxcLox8PpyMTpycXpysXqysbqy8fqzMnrzcrrz8vsz8vs0Mzs0c3t0tHu1dHu1tPv19Tv2NXv2dXw2dbw2tfw29jw3Nnx3drx3t7z4d/z4uD04+H05OP15eP15uT15uT15+X16OX26Of26en36+r37Ov37er47Ov47ez47e347u347+758PD58fD68fD68vL69PT79fX79vb79/b89vb89/f8+Pj9+fn9+vr9+/v++/v+/Pz+/P3+/f3+/v7//wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALfZHJgAAAEAdFJOU////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wBT9wclAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGHRFWHRTb2Z0d2FyZQBwYWludC5uZXQgNC4xLjb9TgnoAAAGdUlEQVRoQ7WZ93sURRiAFZO76O1eklt215OgBwqJgmgCRhAhRrAAiogBK4gBJEFEgWAEYiGIYEGp1kjXQECkiF0OWyjJ/k34zcy3db7Zu8fHe3/KTXnzPbPT56orRTEYAhMLUFgNKkeiGH8BNaV1KWSPVXveU9s3LW9pvhdoblm+afspTHZi5Wo1BnzpaOfcnFmWSBv29YBtpBNlZm5u59FLPDsmdJUaxQeXNugZw5IwMnrD0oO8iFKuUHNx/+bGZLWNMgm7Otm4uZ/LsVIEUs3F+Y5a3USNAlOv7cgr5ZSamQffyOnKgH1sPdfFi2PVILKaReEcmKwVIWbY2uQDvApW95HULIb+Ng0rFoXWxppcCjyqZuZjk4oNWWBrk44R7oiamXdkC3w9GTO7Q3aH1cy8OkWFnHtitstM4j/bqdWSO6Rm5nYdS4e5FbKQwxlMC6G3Q1bIHVQz8+IKLBphJLdydlRjWpiKxZAXdAfUPOak4gOO4FZOdxWmhbGTkbh9NTOvoVsDuGmAaxkdlZgWRV8Dub7bV0PyzhQWkqk5z7WMdjpqILUTslEXUEPQJ7Lq7pz9WXiBZ4iZUGBnTwTCdtVgvjgxpj+b3vTvTEteq5KbEy/6blcNVZapR3cmdc9Z4QV6Pnxzdr1GF9aWQQFUohqCPqQc3ZV17X3C6tP31kyL+Jy2dsgLW6jBPDgVc6OkR3XxCV/i9IqRRFedylxc6qk30L3DNF7ikz1Jft0oLOaT2hBSg/l8jmwOo24/amimYzkfOwfdlLtdNT1YjIaf0EFzgGhuNnB8teNcqCWDvs3vzSSLqC9Ze0F0EqaGoDeSQWt7UaHgXA0WDKFvFGEzNRS6mxot6VZhUNJNdm7zbsgSagj6UAKTQ5hnhEHJffRISIi+LdRLyNn9cTSoOExP3FZmiat2nIF66t9Xb0GFz8Df+AenVTEF2vUwAzM1BN1LfsTkcVS4bJs+fnRj84z3joqf+eFYUELvZWFzdSfZHjeeEwqXl6/myWaZ0bSVDf3uJP9NkOn01HPISXIMTJAB/hiB6WBPN+xxBpvxl4wxR6ihll8pSL1QupwLLhR22YL9ysVGrKRcfZJeAu4QSo+1yWA3rla2NGCeZGpoj13lmBJm1F/odDm+fv68phorU0l+miDlu6BFmLqbHDCWdhqVQQb/zPesW1inqxdoRqIb1SvSmBJG+wR1BF+/NkmLWUnTK1DdQq+i5gvoIbn85QPqtdRoQfU0TIgy4h/UKOi+gZ5DgGmonqIoob2CDhXHblE0ij2lgNo2YMcSy7fkhF2E2rIm/IoOFV/Q+78i1JkJheJ+jOzjnlr1GRk18swa4iC9t3U/o6LzCVLTP4dlVM14LBfC63yKIYOYeuMqcRoneZFqEW/IKAY6Q8xumla3YP2+PNnNt1Jqb6Arpifg5kXuHjNTaVi1s5/eJs0r+6gFUkxP6kkV2mKBs8UMZSYMdmAJcpxqTTGpqpcCEO1znCMTwlPFNbuF0uUs1UVwKYAWoRcwGDHsbNS/algwu+J1bvToI9TuAgZqetm1roPVk/FDazbhjaryr0SiSw/R1oFll94sWNnfsLrzS1eTkawyjKrE6HcwyeVtIix3s6Dc4ljzsTbnx74P1na83+uf8ZBn5cb0tjgsbHJjlvoMa8dxWT4XBDZmoCa3k7eH9yE0u4l9jr+dZN2P2ASnVorK8TwoVwxsglnYxNY9852oHMseogMEt+4QtnzgGDoTa8eRH4ulA4QOHCxs6ZhUBdNAIS7NIjp1+JgEaulwZzwsnXCjDDxPzB+Rwx1zS0fSoVZb/Mp4/lFqQxk5kjI1cZDWa179HTUEe8eRW9XoQZq5qeN/5fCFigWmd14VNRXLx3/et8lLC7N8XNtH0VP6mXfvV+z4iEsLFrbqqkXXho2Z8dynwgo8NdZK0SXpqxbmjrsgquhCsXrhgOYgL4h4k8Rca5VvFV7gTkySUVxrsbBjLuOGfMy1jCZFa6gv47hbeYU4ZA/XMmbRy13MFaJwqy4+Ez1cy3iSVsddfGLcdJvo33Ato5VcSeOva4WbvmQ2v+daxkrqfqXQJbNwk1fj9kOPuNwlZxdxNS7c5IW+MdRFMhd3oS/cpXmG4EOnRI8nAAt8sKsETz4AK1yahyqAy0vxvAaU7lEQcJ8yj9BPmUf+81MmR8iB//kBllOyZ2NOqR67XUAVABNjuXLlX2rCcoFjOcGoAAAAAElFTkSuQmCC' .. '" style="width:20px; height:20px; vertical-align:middle;">&nbsp;{{money}}</div>'

	if ESX.GetConfig().EnableHud then
		ESX.UI.HUD.RegisterElement('society_money', 3, 0, societyMoneyHUDElementTpl, {
			money = 0
		})
	end
end

function DisableSocietyMoneyHUDElement()
	if ESX.GetConfig().EnableHud then
		ESX.UI.HUD.RemoveElement('society_money')
	end
end

function UpdateSocietyMoneyHUDElement(money)
	if ESX.GetConfig().EnableHud then
		ESX.UI.HUD.UpdateElement('society_money', {
			money = ESX.Math.GroupDigits(money)
		})
	end
end
