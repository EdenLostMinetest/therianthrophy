
-- therianthrophy mod
-- Inspired by OgelGames's "Be a Chicken" LUA command block on pandorabox.io

local priv_name = "therianthrophy"

local transformed_players = {}
local mob_data = {}

core.register_on_leaveplayer(function(player)
    transformed_players[player:get_player_name()] = nil
end)

local function register_animal_player_model(short_name, def)
    local init_prop = def.initial_properties
    local model = init_prop.mesh
    local texture = def.texture_list[1][1]
    local box = init_prop.collisionbox
    -- Todo: find a better eye_height calculation
    local eye_height = (box[5] - box[2]) / init_prop.visual_size.y + box[2]

    local anim = def.animation
    local anim_speed, stand_anim, walk_anim, mine_anim, walk_mine_anim
    anim_speed = 15
    if anim then
        anim_speed = anim.speed_normal or anim_speed

        stand_anim = {
            x = anim.stand_start or 1,
            y = anim.stand_end or 1
        }
        walk_anim = {
            x = anim.walk_start or stand_anim.x,
            y = anim.walk_end or stand_anim.y
        }
        mine_anim = {
            x = anim.punch_start or walk_anim.x,
            y = anim.punch_end or walk_anim.y
        }
        walk_mine_anim = {
            x = anim.run_start or mine_anim.x,
            y = anim.run_end or mine_anim.y
        }
    end

    player_api.register_model(model, {
        animation_speed = anim_speed,
        textures = {texture},
        collisionbox = box,
        eye_height = eye_height,
        animations = {
            stand = stand_anim,
            walk = walk_anim,
            mine = mine_anim,
            walk_mine = walk_mine_anim
        }
    })
    mob_data[short_name] = {model, texture}
end

-- Override the skin update function to skip chicken players,
-- so that the custom properties do not get changed
local old_skin_apply = skins.skin_class.apply_skin_to_player
skins.skin_class.apply_skin_to_player = function(self, player)
    local name = player:get_player_name()
    if transformed_players[name] then
        return
    end
    return old_skin_apply(self, player)
end

-- The player_api.set_model function doesn't actually set all properties,
-- so we wrap it in a function that does
local function set_model(player, model_name)
    player_api.set_model(player, model_name)
    local model = player_api.registered_models[model_name]
    if not model then
        return
    end
    local a = model.animations
    local speed = model.animation_speed or 30
    player:set_local_animation(a.stand, a.walk, a.mine, a.walk_mine, speed)
    player:set_properties({
        collisionbox = model.collisionbox,
        eye_height = model.eye_height
    })
end

local function to_human(player)
    local name = player:get_player_name()
    transformed_players[name] = nil
    set_model(player, "skinsdb_3d_armor_character_5.b3d")
    skins.update_player_skin(player)
end

local function transform(player, model, texture)
    local name = player:get_player_name()
    transformed_players[name] = true
    set_model(player, model)
    player_api.set_textures(player, {texture})
    -- Pop the player up a node so they dont fall into the node below
    player:set_pos(vector.add(player:get_pos(), vector.new(0, 1, 0)))
end

minetest.register_privilege(priv_name, {
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

        if animal == "human" then to_human(player) return end
        local data = mob_data[animal]
        if not data then
            return false, "Animal does not exist."
        end

        transform(player, data[1], data[2])
    end
})

core.register_chatcommand("list_animals", {
    description = "List the animals you can turn into with /transform",
    func = function(name)
        local animals = {}
        for short_name, _ in pairs(mob_data) do
            table.insert(animals, short_name)
        end
        table.sort(animals)
        return true, "Human, " .. table.concat(animals, ", ")
    end
})

core.register_on_joinplayer(function()
    for name, _ in pairs(mobs.spawning_mobs) do
        if name:sub(1, 12) == "mobs_animal:" then
            local def = core.registered_entities[name]
            register_animal_player_model(name:sub(13), def)
        end
    end
end)
