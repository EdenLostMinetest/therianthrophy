
-- therianthrophy mod
-- Inspired by OgelGames's "Be a Chicken" LUA command block on pandorabox.io

local priv_name = "therianthrophy"
local transformed_players = {}

local transformations = {
    chicken = {
        model = "mobs_chicken.b3d",
        texture = "mobs_chicken.png",
        register = function(self)
            player_api.register_model(self.model, {
                animation_speed = 24,
                textures = {self.texture},
                collisionbox = {-0.3, -0.75, -0.3, 0.3, 0.1, 0.3},
                eye_height = 0,
                animations = {
                    stand = {x = 1, y = 30},
                    lay = {x = 1, y = 30},
                    walk = {x = 71, y = 90},
                    mine = {x = 31, y = 70},
                    walk_mine = {x = 91, y = 110},
                    sit = {x = 1, y = 30}
                }
            })
        end
    },

    bunny = {
        model = "mobs_bunny.b3d",
        texture = "mobs_bunny_grey.png",
        register = function(self)
            player_api.register_model(self.model, {
                animation_speed = 15,
                textures = {self.texture},
                collisionbox = {-0.268, -0.5, -0.268, 0.268, 0.167, 0.268},
                eye_height = 0,
                animations = {
                    stand = {x = 1, y = 15},
                    lay = {x = 1, y = 15},
                    walk = {x = 16, y = 24},
                    mine = {x = 16, y = 24},
                    walk_mine = {x = 16, y = 24},
                    sit = {x = 1, y = 15}
                }
            })
        end
    }
}

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

minetest.register_chatcommand("human", {
    params = "[<player>]",
    description = "Turns player back into a human",
    func = function(name, target)
        if target ~= "" then
            if not minetest.check_player_privs(name, {[priv_name] = true}) then
                return false, "You don't have permission to transform other players."
            end
            name = target
        end
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player does not exist."
        end

        local name = player:get_player_name()
        transformed_players[name] = nil
        set_model(player, "skinsdb_3d_armor_character_5.b3d")
        skins.update_player_skin(player)
    end
})

for short_name, object in pairs(transformations) do
    core.register_chatcommand(short_name, {
        params = "[<player>]",
        description = "Turns player into a " .. short_name,
        func = function(name, target)
            if target ~= "" then
                if not core.check_player_privs(name, {[priv_name] = true}) then
                    return false, "You don't have permission to transform other players."
                end
                name = target
            end
            local player = core.get_player_by_name(name)
            if not player then
                return false, "Player is not logged in."
            end
            transform(player, object.model, object.texture)
        end
    })
end

core.register_on_mods_loaded(function()
    for short_name, object in pairs(transformations) do
        object:register()
    end
end)

minetest.register_on_leaveplayer(function(player)
    transformed_players[player:get_player_name()] = nil
end)

