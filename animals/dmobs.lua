local dragons_allowed = core.settings:get_bool("therianthropy.dmobs_dragon", true)

core.register_on_mods_loaded(function()
    for name, _ in pairs(mobs.spawning_mobs) do
        if name:sub(1, 6) == "dmobs:" then
            local short_name = name:sub(7)
            local is_dragon = short_name:find("dragon", 1, true)
            if is_dragon and not dragons_allowed then return end

            local def = core.registered_entities[name]
            therianthropy.register_from_mobs_redo(short_name, def)
        end
    end
end)
