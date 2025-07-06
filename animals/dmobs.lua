local settings = core.settings
local dragons_allowed = settings:get_bool("therianthropy.dmobs_dragon", true)
local problematic_allowed = settings:get_bool("therianthropy.dmobs_problematic", false)

local problematic_animals = {
    ogre = true,
    orc = true,
    owl = true,
    waterdragon = true,
    waterdragon_2 = true,
    whale = true
}

core.register_on_mods_loaded(function()
    for name, _ in pairs(mobs.spawning_mobs) do
        if name:sub(1, 6) == "dmobs:" then
            local short_name = name:sub(7)
            local is_problematic = problematic_animals[short_name]
            local is_dragon = (short_name == "wyvern") or short_name:find("dragon", 1, true)

            if (problematic_allowed or not is_problematic) and (dragons_allowed or not is_dragon) then
                local def = core.registered_entities[name]
                therianthropy.register_from_mobs_redo(short_name, def)
            end
        end
    end
end)
