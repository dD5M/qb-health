Config = {}
Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add setr UseTarget true)
Config.MinimalDoctors = 1 -- How many players with the ambulance job to prevent the hospital check-in system from being used
Config.DocCooldown = 1 -- Cooldown between doctor calls allowed, in minutes
Config.BillCost = 500 -- Price that players are charged for using the hospital check-in system
Config.RespawnCost = 2000
Config.DeathTime = 300 -- How long the timer is for players to bleed out completely and respawn at the hospital
Config.MessageTimer = 12 -- How long it will take to display limb/bleed message
Config.AIHealTimer = 20 -- How long it will take to be healed after checking in, in seconds
Config.WipeInventoryOnRespawn = true

Config.Locations = { -- Edit the various interaction points for players or create new ones
    checking = {
        [1] = vec3(308.19, -595.35, 43.29),
        [2] = vec3(-254.54, 6331.78, 32.43),
    },
    nancy = vector4(-435.3, -324.14, 34.91, 156.03),
    ---@class Bed
    ---@field coords vector4
    ---@field taken boolean
    ---@field model number

    ---@type Bed[]
    beds = {
        [1] = { coords = vec4(-448.37, -283.77, 35.47, 21.4), taken = false, model = 2117668672 },
        [2] = { coords = vec4(-451.53, -285.08, 35.47, 21.4), taken = false, model = 2117668672 },
        [3] = { coords = vec4(-454.91, -286.47, 35.47, 21.4), taken = false, model = 2117668672 },
        [4] = { coords = vec4(-460.28, -288.66, 35.47, 21.4), taken = false, model = 2117668672 },
        [5] = { coords = vec4(-463.68, -290.07, 35.47, 21.4), taken = false, model = 2117668672 },
        [6] = { coords = vec4(-466.99, -291.40, 35.47, 21.4), taken = false, model = 2117668672 },
        [7] = { coords = vec4(-469.91, -284.18, 35.47, 205.0), taken = false, model = 2117668672 },
        [8] = { coords = vec4(-466.50, -282.75, 35.47, 205.0), taken = false, model = 2117668672 },
        [9] = { coords = vec4(-462.75, -281.23, 35.47, 205.0), taken = false, model = 2117668672 },
        [10] = { coords = vec4(-459.00, -279.65, 35.47, 205.0), taken = false, model = 2117668672 },
        [11] = { coords = vec4(-455.11, -278.04, 35.47, 205.0), taken = false, model = 2117668672 },
    },
    jailbeds = {
        [1] = { coords = vec4(1761.87, 2591.56, 45.3, 270.0), taken = false, model = 2117668672 },
        [2] = { coords = vec4(1761.87, 2594.64, 45.3, 270.0), taken = false, model = 2117668672 },
        [3] = { coords = vec4(1761.87, 2597.73, 45.3, 270.0), taken = false, model = 2117668672 },
        [4] = { coords = vec4(1771.98, 2597.95, 45.3, 90.0), taken = false, model = 2117668672 },
        [5] = { coords = vec4(1771.98, 2594.88, 45.3, 90.0), taken = false, model = 2117668672 },
        [6] = { coords = vec4(1771.98, 2591.80, 45.3, 90.0), taken = false, model = 2117668672 },
    },
    stations = {
        [1] = { label = Lang:t('info.mz_hospital'), coords = vec4(-434.21, -322.22, 35.62, 156.81) }
    }
}