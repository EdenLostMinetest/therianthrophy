-- Override the skin update function to skip transformed players,
-- so that the custom properties do not get changed
local old_skin_apply = skins.skin_class.apply_skin_to_player
skins.skin_class.apply_skin_to_player = function(self, player)
    if therianthropy.transformed(player:get_player_name()) then return end
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

-- API function to transform a player, returns boolean indicating success
function therianthropy.transform(player, short_name)
    local name = player:get_player_name()
    if not name or name == "" then return end

    if short_name == "human" then
        therianthropy.transformed_players[name] = nil
        set_model(player, "skinsdb_3d_armor_character_5.b3d")
        skins.update_player_skin(player)
        return true
    end

    local data = therianthropy.mob_data[short_name]
    if not data then return false end

    therianthropy.transformed_players[name] = short_name
    set_model(player, data.model)
    player_api.set_textures(player, {data.texture})
    -- Pop the player up a node so they dont fall into the node below
    player:set_pos(vector.add(player:get_pos(), vector.new(0, 1, 0)))

    return true
end

function therianthropy.transformed(player_name)
    return therianthropy.transformed_players[player_name] or false
end
