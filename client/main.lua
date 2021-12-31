resName = GetCurrentResourceName()
PlayerBags = {Player = json.decode(GetResourceKvpString('Player')) or {loaded = false}}

Data = {
	Societies = GlobalState.Data_Societies,
	Properties = GlobalState.Data_Properties,
	Doors = GlobalState.Data_Doors,
	Zones = GlobalState.Data_Zones
}

Indexed = {
	Societies = GlobalState.Indexed_Societies,
	Properties = GlobalState.Indexed_Properties,
	Doors = GlobalState.Indexed_Doors,
	Zones = GlobalState.Indexed_Zones
}

CreateThread(function()
	showBlips()
	refreshBussHUD()
end)

local Blips = {}
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

	if not PlayerBags.Player.loaded then
		return
	end

	Blips = {}
	for i = 1, #Data.Properties do
		local property = Data.Properties[i]
		local blip = AddBlipForCoord(vectorize(property.blip))
		SetBlipSprite(blip, Config.PropertyTypes[property.type].sprite)
		if Indexed.Societies[property.owner] then
			local society = Indexed.Societies[property.owner]
			SetBlipDisplay(blip, 2)
			SetBlipCategory(blip, 10)
			SetBlipColour(blip, society.colour)
			SetBlipShrink(blip, true)

			if property.owner ~= PlayerBags.Player.job then
				SetBlipAsShortRange(blip, true)
			end

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString(('%s - %s'):format(property.id, society.label))
			EndTextCommandSetBlipName(blip)
		elseif property.owner == PlayerBags.Player.ident then
			SetBlipDisplay(blip, 2)
			SetBlipCategory(blip, 11)
			SetBlipShrink(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString(property.id)
			EndTextCommandSetBlipName(blip)
		else
			SetBlipDisplay(blip, 0)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString(property.id)
			EndTextCommandSetBlipName(blip)
		end

		if property.id == target then
			SetBlipDisplay(blip, 2)
			SetBlipRoute(blip, true)
			SetBlipAsShortRange(blip, false)

			Blips.target = target
		end

		Blips[property.id] = blip
	end
end

AddStateBagChangeHandler(nil, 'global', function(bagName, key, value, reserved, replicated)
	local tab, subTable = string.strsplit('_', key)
	if tab == 'Data' then
		Data[subTable] = value
	elseif tab == 'Indexed' then
		Indexed[subTable] = value
	end

	if subTable == 'Properties' then
		showBlips()
		kmUpdate = true
	elseif subTable == 'Societies' then
		refreshBussHUD()
		bUpdate = true
	end
end)

local Player = GetPlayerServerId(PlayerId())
AddStateBagChangeHandler(nil, nil, function(bagName, key, value, reserved, replicated)
	print(bagName, key, value, reserved, replicated)
	if bagName:find(':') then
		local _, id = string.strsplit(':', bagName)
		if tonumber(id) == Player then
			PlayerBags.Player[key] = value
			SetResourceKvp('Player', json.encode(PlayerBags.Player))
			if key == 'loaded' then
				showBlips()
			end
		else
			if not PlayerBags[tonumber(id)] then
				PlayerBags[tonumber(id)] = {}
			end
			PlayerBags[tonumber(id)][key] = value
		end
	end
end)

function refreshBussHUD()
	if not PlayerBags.Player.loaded then
		return
	end
	DisableSocietyMoneyHUDElement()

	local society = Indexed.Societies[PlayerBags.Player.job]
	local gradeNo

	for i = 0, #society.grades do
		local grade = society.grades[i]
		if grade.name == PlayerBags.Player.grade then
			gradeNo = grade.grade
			break
		end
	end

	if gradeNo >= 3 then
		EnableSocietyMoneyHUDElement()
		UpdateSocietyMoneyHUDElement(society.account)
	end
end

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
