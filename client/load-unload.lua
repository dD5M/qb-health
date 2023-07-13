--initialize settings from player object
local function onPlayerLoaded()
    exports.spawnmanager:setAutoSpawn(false)
end

---reset player settings that the server is storing
local function onPlayerUnloaded()
    local ped = PlayerPedId()
    if BedOccupying then
        TriggerServerEvent("hospital:server:LeaveBed", BedOccupying)
    end
    SetPedArmour(ped, 0)
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', onPlayerLoaded)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', onPlayerUnloaded)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    onPlayerLoaded()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    onPlayerUnloaded()
end)