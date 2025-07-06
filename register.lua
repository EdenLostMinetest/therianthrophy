local priv_name = "therianthropy"

function therianthropy.register_animal(short_name, def)
    if therianthropy.mob_data[short_name] then return end

    -- Required fields
    local model = def.model
    local texture = def.texture

    -- Optional fields
    local collisionbox = def.collisionbox or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
    local visual_size = def.visual_size or {x = 1, y = 1}
    local eye_height = def.eye_height or 1
    local hear_distance = def.hear_distance or 10
    local sounds = def.sounds or {}

    -- Animation
    local def_anim = def.animations
    local anim_speed, stand_anim, walk_anim, mine_anim, walk_mine_anim
    anim_speed = 15
    if def_anim then
        anim_speed = def_anim.anim_speed or anim_speed

        stand_anim = {
            x = def_anim.stand_start or 1,
            y = def_anim.stand_end or 1}
        walk_anim = {
            x = def_anim.walk_start or stand_anim.x,
            y = def_anim.walk_end or stand_anim.y
        }
        mine_anim = {
            x = def_anim.mine_start or walk_anim.x,
            y = def_anim.mine_end or walk_anim.y
        }
        walk_mine_anim = {
            x = def_anim.walk_mine_start or mine_anim.x,
            y = def_anim.walk_mine_end or mine_anim.y
        }
    end

    player_api.register_model(model, {
        textures = {texture},
        collisionbox = collisionbox,
        visual_size = visual_size,
        eye_height = eye_height,
        animation_speed = anim_speed,
        animations = {
            stand = stand_anim,
            walk = walk_anim,
            mine = mine_anim,
            walk_mine = walk_mine_anim
        }
    })
    therianthropy.mob_data[short_name] = {
        model = model,
        texture = texture,
        hear_distance = hear_distance,
        sounds = sounds
    }
end

core.register_privilege(priv_name, {
    description = "Allows player to turn other players into animals.",
    give_to_singleplayer = false
})

core.register_chatcommand("transform", {
    params = "[<player>] <animal>",
    description = "Turns yourself or another player into an animal",
    func = function(name, param)
        local args = param:split(" ")
        local target, animal = name, args[1]
        if #args > 1 then
            if not core.check_player_privs(name, {[priv_name] = true}) then
                return false, "You don't have permission to transform other players."
            end
            target, animal = args[1], args[2]
        end

        local player = core.get_player_by_name(target)
        if not player then
            return false, "Target is not logged in."
        end

        if not therianthropy.transform(player, animal) then
            return false, "Animal does not exist."
        end
    end
})

core.register_chatcommand("list_animals", {
    description = "List the animals you can turn into with /transform",
    func = function(name)
        local animals = {}
        for short_name, _ in pairs(therianthropy.mob_data) do
            table.insert(animals, short_name)
        end
        table.sort(animals)
        return true, "Human, " .. table.concat(animals, ", ")
    end
})

core.register_on_leaveplayer(function(player)
    therianthropy.transformed_players[player:get_player_name()] = nil
end)

-- Register all mobs from mobs_animal
core.register_on_joinplayer(function()
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
