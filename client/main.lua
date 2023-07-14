QBCore = exports['lng-base']:GetCoreObject()

InBedDict = "anim@gangops@morgue@table@"
InBedAnim = "body_search"
IsInHospitalBed = false
IsDead = false
EmsNotified = false
CanLeaveBed = true
BedOccupying = nil
Laststand = {
    ReviveInterval = 360,
    MinimumRevive = 300,
}
InLaststand = false
DoctorCount = 0
PlayerData = {
    job = nil
}


RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    if GetInvokingResource() then return end
    PlayerData = data
end)

---Revives player, healing all injuries
---Intended to be called from client or server.
RegisterNetEvent('hospital:client:Revive', function()
    local ped = cache.ped

    if IsDead or InLaststand then
        local pos = GetEntityCoords(ped, true)
        NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(ped), true, false)
        IsDead = false
        SetEntityInvincible(ped, false)
    end

    if IsInHospitalBed then
        lib.requestAnimDict(InBedDict)
        TaskPlayAnim(ped, InBedDict, InBedAnim, 8.0, 1.0, -1, 1, 0, 0, 0, 0)
        SetEntityInvincible(ped, true)
        CanLeaveBed = true
    end
    TriggerServerEvent("hospital:server:resetHungerThirst")
    SetEntityMaxHealth(ped, 200)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    SetPlayerSprint(cache.playerId, true)
    ResetPedMovementClipset(ped, 0.0)
    TriggerServerEvent('hud:server:RelieveStress', 100)
    TriggerServerEvent("hospital:server:SetDeathStatus", false)
    TriggerServerEvent("hospital:server:SetLaststandStatus", false)
    EmsNotified = false
    lib.notify({ description = Lang:t('info.healthy'), type = 'inform' })
end)

RegisterNetEvent('hospital:client:KillPlayer', function()
    if GetInvokingResource() then return end
    SetEntityHealth(cache.ped, 0)
end)

---@param bedsKey "jailbeds"|"beds"
---@param id number
---@param isTaken boolean
RegisterNetEvent('hospital:client:SetBed', function(bedsKey, id, isTaken)
    if GetInvokingResource() then return end
    Config.Locations[bedsKey][id].taken = isTaken
end)

---sends player phone email with hospital bill.
---@param amount number
RegisterNetEvent('hospital:client:SendBillEmail', function(amount)
    if GetInvokingResource() then return end
    SetTimeout(math.random(2500, 4000), function()
        local charInfo = PlayerData.charinfo
        local gender = charInfo.gender == 1 and Lang:t('info.mrs') or Lang:t('info.mr')
        TriggerServerEvent("lb_messager:server:SelfSendEmail", {
            sender = Lang:t('mail.sender'),
            subject = Lang:t('mail.subject'),
            message = Lang:t('mail.message', { gender = gender, lastname = charInfo.lastname, costs = amount }),
            attachments = {} -- Table of image links
        })
    end)
end)

RegisterNetEvent('hospital:client:adminHeal', function()
    if GetInvokingResource() then return end
    TriggerServerEvent("hospital:server:resetHungerThirst")
end)

-- Threads

---sets blips for stations on map
Citizen.CreateThread(function()
    for _, station in pairs(Config.Locations.stations) do
        local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
        SetBlipSprite(blip, 61)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 25)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(station.label)
        EndTextCommandSetBlipName(blip)
    end
end)

---fetch and cache DoctorCount every minute from server.
local NancyOffline = true

Citizen.CreateThread(function()
    while true do
        DoctorCount = lib.callback.await('hospital:GetDoctors', false)
        if DoctorCount < Config.MinimalDoctors and NancyOffline then
            NancyOffline = false

            RequestModel('s_f_y_scrubs_01')
            while not HasModelLoaded('s_f_y_scrubs_01') do
                Citizen.Wait(0)
            end

            nancy = CreatePed(2, 's_f_y_scrubs_01', Config.Locations.nancy.x, Config.Locations.nancy.y, Config.Locations.nancy.z-1, Config.Locations.nancy.w, false, false) -- change here the cords for the ped
            SetPedFleeAttributes(nancy, 0, 0)
            SetPedDiesWhenInjured(nancy, false)
            TaskStartScenarioInPlace(nancy, WORLD_HUMAN_STAND_IMPATIENT, 0, true)
            SetPedKeepTask(nancy, true)
            SetBlockingOfNonTemporaryEvents(nancy, true)
            SetEntityInvincible(nancy, true)
            FreezeEntityPosition(nancy, true)

            exports.ox_target:addLocalEntity(nancy, { {
                name = 'health_checkin',
                icon = "fas fa-user-doctor",
                label = 'Check-in',
                distance = 2.5,
                debug = true,
                onSelect = function()
                    checkIn()
                end
            } })

        elseif DoctorCount >= Config.MinimalDoctors and not NancyOffline then
            NancyOffline = true
            DeletePed(nancy)
            exports.ox_target:removeEntity(nancy, 'lng-health:checkin')
        end

        Citizen.Wait(60000)
    end
end)
