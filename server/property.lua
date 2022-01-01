local ServerCallback = import 'callbacks'

ServerCallback.Register('pTransferProperty', function(source, cb, propertyId, target, targetName)
	local property = json.decode(GetResourceKvpString(propertyId))
	if property.owner == target then
		return
	end

	property.owner = target
	property.ownerName = targetName
	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)

	cb()
end)

ServerCallback.Register('pRevokeAllKeys', function(source, cb, propertyId)
	local property = json.decode(GetResourceKvpString(propertyId))

	property.keys = revokeKeys(property.keys, false)

	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)

	cb()
end)

ServerCallback.Register('pNewKey', function(source, cb, propertyId, name)
	local property = json.decode(GetResourceKvpString(propertyId))

	property.keys[#property.keys + 1] = {
		name = name,
		id = property.id .. ':' .. #property.keys,
		holders = {},
		exempt = {
			doors = {},
			zones = {}
		}
	}
	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)

	cb(property.keys[#property.keys].id)
end)

ServerCallback.Register('pRenameKey', function(source, cb, keyId, name)
	local propertyId, id = string.strsplit(':', keyId)
	local property = json.decode(GetResourceKvpString(propertyId))

	for i = 1, #property.keys do
		if property.keys[i].id == keyId then
			property.keys[i].name = name
			break
		end
	end
	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)

	cb()
end)

ServerCallback.Register('pDeleteKey', function(source, cb, keyId)
	local propertyId, id = string.strsplit(':', keyId)
	if id == 0 then
		cb(false)
		return
	end

	local property = json.decode(GetResourceKvpString(propertyId))

	for i = 1, #property.keys do
		if property.keys[i].id == keyId then
			revokeKeys({property.keys[i]}, false)
			property.keys[i] = false
			break
		end
	end
	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)

	cb(true)
end)

ServerCallback.Register('pAddKey', function(source, cb, keyId, target)
	local propertyId, id = string.strsplit(':', keyId)
	local property = json.decode(GetResourceKvpString(propertyId))

	for i = 1, #property.keys do
		if property.keys[i].id == keyId then
			property.keys[i].holders[target] = GetResourceKvpString(('%s:name'):format(target))
			break
		end
	end

	local keys = json.decode(GetResourceKvpString(('%s:keys'):format(target))) or {}

	keys[keyId] = true

	updateHolders({[target] = keys})

	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)

	cb()
end)

ServerCallback.Register('pRemoveKey', function(source, cb, keyId, target)
	local propertyId, id = string.strsplit(':', keyId)
	local property = json.decode(GetResourceKvpString(propertyId))

	property.keys = revokeKeys(property.keys, target)

	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)

	cb()
end)

ServerCallback.Register('pSwitchKeyExemption', function(source, cb, keyId, itemType, itemId)
	local propertyId, id = string.strsplit(':', keyId)
	if id == 0 then
		cb(false)
		return
	end

	local property = json.decode(GetResourceKvpString(propertyId))

	local holders
	for i = 1, #property.keys do
		if property.keys[i].id == keyId then
			holders = property.keys[i].holders
			if property.keys[i].exempt[itemType][itemId] then
				property.keys[i].exempt[itemType][itemId] = nil
			else
				property.keys[i].exempt[itemType][itemId] = true
			end
			break
		end
	end

	updateHolders(holders)

	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)

	cb(true)
end)

function updateHolders(holders)
	for k, v in pairs(holders) do
		local keys, auth = setAuth(k, v)
		local xPlayer = ESX.GetPlayerFromIdentifier(k)
		if xPlayer then
			local plyState = Player(xPlayer.source).state
			plyState.keys = keys
			plyState.auth = auth
		end
	end
end

function revokeKeys(keys, holder)
	local holders = {}
	for i = 1, #keys do
		local key = keys[i]
		if holder then
			if not holders[holder] then
				holders[holder] = json.decode(GetResourceKvpString(('%s:keys'):format(holder)))
			end
			holders[holder][key.id] = nil
			key.holders[holder] = nil
		else
			for k, v in pairs(key.holders) do
				if not holders[k] then
					holders[k] = json.decode(GetResourceKvpString(('%s:keys'):format(k)))
				end
				holders[k][key.id] = nil
				key.holders[k] = nil
			end
		end
	end
	updateHolders(holders)

	return keys
end

RegisterServerEvent('dd_society:pModifyDoor', function(door)
	local propertyId, id = string.strsplit(':', door.id)
	local property = json.decode(GetResourceKvpString(propertyId))

	for i = 1, #property.doors do
		if property.doors[i].id == door.id then
			property.doors[i] = door
			break
		end
	end
	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)
	saveTables('Doors', door)
end)

ServerCallback.Register('pModifyZone', function(source, cb, zone)
	local propertyId, id = string.strsplit(':', zone.id)
	local property = json.decode(GetResourceKvpString(propertyId))

	for i = 1, #property.zones do
		if property.zones[i].id == zone.id then
			property.zones[i] = zone
			break
		end
	end
	SetResourceKvp(property.id, json.encode(property))

	saveTables('Properties', property)
	saveTables('Zones', zone)

	cb()
end)
