-- therianthrophy mod
-- Inspired by OgelGames's "Be a Chicken" LUA command block on pandorabox.io

therianthropy = {
    transformed_players = {},
    mob_data = {}
}

local settings = core.settings
local sound_enabled = settings:get_bool("therianthropy.sounds", true)
local problematic_enabled = settings:get_bool("therianthropy.problematic", false)

-- Animals added in this order
-- If a new animal has the same name as one that is already registered,
-- the new animal is skipped
local animal_mods = {
    {modpack = false, name = "mobs_animal"},
    {modpack = true, name = "mobs_water", mods = {
        "mobs_crocs",
        --"mobs_fish",  Doesn't register any animals
        "mobs_jellyfish"
        --"mobs_sharks",  All rotated by 90 degrees
        -- "mobs_turtles"  Also all rotated by 90 degrees
    }},
    {modpack = false, name = "mob_horse"},
    {modpack = false, name = "mobs_monster"},
    {modpack = false, name = "dmobs"}
}

-- Some mobs clip into the ground too much, some are too large,
-- some are rotated 90 degrees, and some are essentially duplicates
local problematic_animals = (problematic_enabled and {}) or {
    ogre = true,
    orc = true,
    owl = true,
    waterdragon = true,
    waterdragon_2 = true,
    whale = true,
    crocodile_float = true,
    crocodile_swim = true,
    dragon1 = true,
    dragon2 = true,
    dragon3 = true,
    dragon4 = true,
    dragon_great_tame = true,
    wasp = true,
    turtle = true,
    seaturtle = true,
    golem_friendly = true,
    fire_spirit = true
}

local modpath = core.get_modpath("therianthrophy") .. "/"
local settings = core.settings

dofile(modpath .. "register.lua")
dofile(modpath .. "transform.lua")

if sound_enabled then
    dofile(modpath .. "sounds.lua")
end

-- Initialize global data that will be available to the scripts in animals/
-- The scripts insert into `mobs_redo_to_register` and the modpack scripts use
-- `part_of_modpack` to insert their corresponding animals
mobs_redo_to_register = {}
local modpack_items = {}
function part_of_modpack(name)
    for _, mod in ipairs(modpack_items) do
        if name:sub(1, #mod) == mod then
            return true
        end
    end
    return false
end

for _, mod_data in ipairs(animal_mods) do
    local modname = mod_data.name
    modpack_items = {}
    local mod_found = core.get_modpath(modname)
    if mod_data.modpack then
        mod_found = true -- So that the script is run
        for _, mod in ipairs(mod_data.mods) do
            if core.get_modpath(mod) then
                table.insert(modpack_items, mod)
            end
        end
    end

    local settings_enabled = settings:get_bool("therianthropy." .. modname, true)
    if mod_found and settings_enabled then
        dofile(modpath .. "animals/" .. modname .. ".lua")
    end
end

for _, name in ipairs(mobs_redo_to_register) do
    local short_name = name:split(":")[2]
    if not problematic_animals[short_name] then
        core.log("error", "registering " .. name)
        local def = core.registered_entities[name]
        therianthropy.register_from_mobs_redo(short_name, def)
    end
end

-- Clean up after ourselves
mobs_redo_to_register = nil
part_of_modpack = nil
