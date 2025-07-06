
-- therianthrophy mod
-- Inspired by OgelGames's "Be a Chicken" LUA command block on pandorabox.io

therianthropy = {
    transformed_players = {},
    mob_data = {}
}

local animal_mods = {
    "mobs_animal"
}

local modpath = core.get_modpath("therianthrophy") .. "/"
local settings = core.settings

dofile(modpath .. "register.lua")
dofile(modpath .. "transform.lua")

for modname in pairs(animal_mods) do
    local settings_enabled = settings:get_bool("therianthropy." .. modname, true)
    if core.get_modpath(modname) and settings_enabled then
        dofile(modpath .. "animals/" .. modname .. ".lua")
    end
end

if settings:get_bool("therianthropy.sounds", true) then
    dofile(modpath .. "sounds.lua")
end
