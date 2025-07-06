core.register_on_mods_loaded(function()
    for name, _ in pairs(mobs.spawning_mobs) do
        if name:sub(1, 12) == "mobs_animal:" then
            local def = core.registered_entities[name]
            therianthropy.register_from_mobs_redo(name:sub(13), def)
        end
    end
end)
