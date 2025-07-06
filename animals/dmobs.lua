local dragons_allowed = core.settings:get_bool("therianthropy.dmobs_dragon", true)

core.register_on_mods_loaded(function()
    for name, _ in pairs(mobs.spawning_mobs) do
        if name:sub(1, 6) == "dmobs:" then
            local short_name = name:sub(7)
            local is_dragon = short_name:find("dragon", 1, true)

            if is_dragon and dragons_allowed or not is_dragon then
                local def = core.registered_entities[name]
                local initial_properties = def.initial_properties
                local def_anim = def.animation or {}

                therianthropy.register_animal(short_name, {
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
    end
end)
