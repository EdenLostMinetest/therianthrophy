core.register_on_mods_loaded(function()
    for name, _ in pairs(mobs.spawning_mobs) do
        if name:sub(1, 12) == "mobs_animal:" then
            local def = core.registered_entities[name]
            local initial_properties = def.initial_properties
            local def_anim = def.animation or {}

            therianthropy.register_animal(name:sub(13), {
                model = initial_properties.mesh,
                texture = def.texture_list[1][1],
                collisionbox = initial_properties.collisionbox,
                visual_size = initial_properties.visual_size,
                eye_height = initial_properties.collisionbox[5],
                hear_distance = (def.sounds and def.sounds.distance) or 10,
                sounds = def.sounds,
                animations = {
                    anim_speed = def_anim.speed_normal,
                    stand_start = def_anim.stand_start,   stand_end = def_anim.stand_end,
                    walk_start = def_anim.walk_start,     walk_end = def_anim.walk_end,
                    mine_start = def_anim.punch_start,    mine_end = def_anim.punch_end,
                    walk_mine_start = def_anim.run_start, walk_mine_end = def_anim.run_end
                }
            })
        end
    end
end)
