
-- therianthrophy mod
-- Inspired by OgelGames's "Be a Chicken" LUA command block on pandorabox.io

therianthropy = {mob_data = {}}

local modpath = core.get_modpath("therianthrophy") .. "/"
local settings = core.settings

dofile(modpath .. "transform.lua")

if settings:get_bool("therianthropy.sounds", true) then
    dofile(modpath .. "sounds.lua")
end
