#Discord
http://discord.daddydubz.com

# Bed spawn/revive and other functions for use with visn_are Advanced Roleplay Environment


# Credit to qb-ambulancejob where these functions were pulled from.

# Installation
-Load into your resources folder
-Follow the instructions below to enable qb-health bed spawning functionality.

# Identify the following function in visn_are/helpers/c_events

    RegisterNetEvent(ENUM_EVENT_TYPES.EVENT_RESPAWN_PLAYER, function(authToken)
        if authToken ~= TempAuthToken then return end
        if not ClientHealthBuffer then return end
    
        local nearestLocation, nearestDistance = nil, 9000000
        for _, v in pairs(ClientConfig.m_respawnConfiguration.m_respawnLocations) do
            local distance = #(ClientData.coords - vector3(v.x, v.y, v.z))
            if distance < nearestDistance then
                nearestLocation = v
                nearestDistance = distance
            end
        end
    
        RespawnPed(ClientData.ped, { x = nearestLocation.x, y = nearestLocation.y, z = nearestLocation.z }, nearestLocation.hospital)
    
        RemoveAllPedWeapons(ClientData.ped, true)
    
        SetUnconsciousState(false)
        ResetHealthBuffer()
    
        if CarryAnimationData ~= nil then
            ClearPedTasks(ClientData.ped)
            DetachEntity(ClientData.ped, true, false)
            CarryAnimationData = nil
        end
    end)


# Replace the function above with this

    RegisterNetEvent(ENUM_EVENT_TYPES.EVENT_RESPAWN_PLAYER, function(authToken)
        if authToken ~= TempAuthToken then return end
        if not ClientHealthBuffer then return end
        
        -- local nearestLocation, nearestDistance = nil, 9000000
        -- for _, v in pairs(ClientConfig.m_respawnConfiguration.m_respawnLocations) do
        --     local distance = #(ClientData.coords - vector3(v.x, v.y, v.z))
        --     if distance < nearestDistance then
        --         nearestLocation = v
        --         nearestDistance = distance
        --     end
        -- end
    
        -- RespawnPed(ClientData.ped, { x = nearestLocation.x, y = nearestLocation.y, z = nearestLocation.z }, nearestLocation.hospital)
    
        TriggerServerEvent("hospital:server:RespawnAtHospital")
    
        RemoveAllPedWeapons(ClientData.ped, true)
    
        SetUnconsciousState(false)
        ResetHealthBuffer()
    
        if CarryAnimationData ~= nil then
            ClearPedTasks(ClientData.ped)
            DetachEntity(ClientData.ped, true, false)
            CarryAnimationData = nil
        end
    end)
