local QBCore = exports['lng-base']:GetCoreObject()

---@class Player object from core

---@alias source number

---@class PlayerStatus
---@field limbs BodyParts
---@field isBleeding number

---@type table<source, PlayerStatus>
local playerStatus = {}

---@type table<source, number[]> weapon hashes
local playerWeaponWounds = {}

local doctorCalled = false


-- Events

---Compatibility with txAdmin Menu's heal options.
---This is an admin only server side event that will pass the target player id or -1.
---@class EventData
---@field id number
---@param eventData EventData
AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(eventData.id) ~= "number" then
		return
	end
	TriggerClientEvent('visn_are:resetHealthBuffer', eventData.id)
end)

---@param player Player
local function billPlayer(player, amount)
	player.Functions.RemoveMoney("bank", amount, "respawned-at-hospital")
	exports['qbx-management']:AddMoney("ambulance", amount)
	TriggerClientEvent('hospital:client:SendBillEmail', player.PlayerData.source, amount)
end

---@param player Player
local function wipeInventory(player)
	player.Functions.ClearInventory()
	TriggerClientEvent('ox_lib:notify', player.PlayerData.source, { description = Lang:t('error.possessions_taken'), type = 'error' })
end

---@param player Player
---@param bedsKey "beds"|"jailbeds"
---@param i integer
---@param bed Bed
local function respawnAtBed(player, bedsKey, i, bed)
	TriggerClientEvent('hospital:client:SendToBed', player.PlayerData.source, i, bed, true)
	TriggerClientEvent('hospital:client:SetBed', -1, bedsKey, i, true)

	if Config.WipeInventoryOnRespawn then
		wipeInventory(player)
	end

	player.Functions.SetMetaData('hunger', 100)
	player.Functions.SetMetaData('thirst', 100)

	TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, 100, 100)

	billPlayer(player, Config.RespawnCost)

	TriggerClientEvent('ox_lib:notify', player.PlayerData.source, { description = "Your bank has been billed $"..Config.BillCost.." by Mount Zonah Medical.", type = 'error' })

end

---@param player Player
---@param bedsKey "beds"|"jailbeds"
local function respawnAtHospital(player, bedsKey)
	local beds = Config.Locations[bedsKey]
	for i, bed in pairs(beds) do
		if not bed.taken then
			respawnAtBed(player, bedsKey, i, bed)
			return
		end
	end
	respawnAtBed(player, bedsKey)
end

RegisterNetEvent('hospital:server:RespawnAtHospital', function()
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	if player.PlayerData.metadata.injail > 0 then
		respawnAtHospital(player, "jailbeds")
	else
		respawnAtHospital(player, "beds")
	end
end)

---@param bedId integer
---@param isRevive boolean
RegisterNetEvent('hospital:server:SendToBed', function(bedId, isRevive)
	if GetInvokingResource() then return end
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	TriggerClientEvent("visn_are:resetHealthBuffer", src)
	TriggerClientEvent('hospital:client:SendToBed', src, bedId, Config.Locations.beds[bedId], isRevive)
	TriggerClientEvent('hospital:client:SetBed', -1, "beds", bedId, true)
	TriggerClientEvent('hospital:client:Revive', src)

	billPlayer(player, Config.BillCost)
end)

---@param id integer
RegisterNetEvent('hospital:server:LeaveBed', function(id)
	if GetInvokingResource() then return end
	TriggerClientEvent('hospital:client:SetBed', -1, "beds", id, false)
end)


RegisterNetEvent('hospital:server:SendDoctorAlert', function()
	if GetInvokingResource() then return end
	local src = source
	if doctorCalled then
		TriggerClientEvent('ox_lib:notify', src, { description = Lang:t('info.dr_needed'), type = 'inform' })
		return
	end

	doctorCalled = true
	local players = QBCore.Functions.GetQBPlayers()
	for _, v in pairs(players) do
		if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
			TriggerClientEvent('ox_lib:notify', src, { description = Lang:t('info.dr_needed'), type = 'inform' })
		end
	end
	SetTimeout(Config.DocCooldown * 60000, function()
		doctorCalled = false
	end)
end)

---@param isDead boolean
RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
	if GetInvokingResource() then return end
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	if not player then return end
	player.Functions.SetMetaData("isdead", isDead)
end)

---@param bool boolean
RegisterNetEvent('hospital:server:SetLaststandStatus', function(bool)
	if GetInvokingResource() then return end
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	if not player then return end
	player.Functions.SetMetaData("inlaststand", bool)
end)

RegisterNetEvent('hospital:server:resetHungerThirst', function()
	if GetInvokingResource() then return end
	local player = QBCore.Functions.GetPlayer(source)

	if not player then return end

	player.Functions.SetMetaData('hunger', 100)
	player.Functions.SetMetaData('thirst', 100)

	TriggerClientEvent('hud:client:UpdateNeeds', source, 100, 100)
end)

-- Callbacks

lib.callback.register('hospital:GetDoctors', function()
	local amount = 0
	local players = QBCore.Functions.GetQBPlayers()
	for _, v in pairs(players) do
		if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
			amount += 1
		end
	end
	return amount
end)


---Triggers the event on the player or src, if no target is specified
---@param src number playerId of the one triggering the event
---@param event string event name
---@param targetPlayerId? string playerId of the target of the event
local function triggerEventOnPlayer(src, event, targetPlayerId)
	if not targetPlayerId then
		TriggerClientEvent(event, src)
		return
	end

	local player = QBCore.Functions.GetPlayer(tonumber(targetPlayerId))

	if not player then
		TriggerClientEvent('ox_lib:notify', src, { description = Lang:t('error.not_online'), type = 'error' })
		return
	end

	TriggerClientEvent(event, player.PlayerData.source)
end

lib.addCommand('revive', {
    help = Lang:t('info.revive_player_a'),
	restricted = "qbox.admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	triggerEventOnPlayer(source, 'visn_are:resetHealthBuffer', args.id)
	triggerEventOnPlayer(source, 'hospital:client:adminHeal', args.id)
end)

lib.addCommand('kill', {
    help =  Lang:t('info.kill'),
	restricted = "qbox.admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	triggerEventOnPlayer(source, 'hospital:client:KillPlayer', args.id)
end)

lib.addCommand('aheal', {
    help =  Lang:t('info.heal_player_a'),
	restricted = "qbox.admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	triggerEventOnPlayer(source, 'visn_are:resetHealthBuffer', args.id)
	triggerEventOnPlayer(source, 'hospital:client:adminHeal', args.id)
end)


