-- therianthrophy mod
-- Inspired by LGA's "Be a Chicken" LUA command block on pandorabox.io
local priv_name = "therianthrophy"

-- Returns target palyer name if action is allowed, nil if not.
-- Players may change themselves, but to change others requires a privlege.
-- target defaults to invoking player if not specified.
local function priv_check(name_invoker, name_target)
    if name_invoker == name_target then return name_target end
    if (name_target == nil) or (name_target == "") then return name_invoker end
    if minetest.check_player_privs(name_invoker, {[priv_name] = true}) then
        return name_target
    end
    return nil
end

local function to_human(name)
    local player = minetest.get_player_by_name(name)
    if player ~= nil then
        player_api.set_model(player, nil)
        armor:update_player_visuals(player)
        -- TODO: Need to restore player's walking animation.
        -- It is messed up on the restored player's GUI, but looks ok to other
        -- players.
    end
end

local function to_chicken(name)
    local player = minetest.get_player_by_name(name)
    if player == nil then
        minetest.log("error", "Player " .. name .. " does not exist?")
        return
    end
    player_api.register_model("mobs_chicken.b3d", {
        animation_speed = 24,
        textures = {"mobs_chicken.png"},
        collisionbox = {-0.3, -0.75, -0.3, 0.3, 0.1, 0.3},
        eye_height = 0,
        animations = {
            stand = {x = 1, y = 30},
            lay = {x = 1, y = 30},
            walk = {x = 71, y = 90, override_local = true, eye_height = 0.001},
            mine = {x = 31, y = 70},
            walk_mine = {x = 91, y = 110},
            sit = {x = 1, y = 30}
        }
    })
    player_api.set_model(player, "mobs_chicken.b3d")
    player_api.set_textures(player, {"mobs_chicken.png"})
    player_api.set_animation(player, "walk")
    player:set_pos(vector.add(player:get_pos(), vector.new(0, 1, 0)))
    armor.update_player_visuals = function(self, b)
        if not b then return end
        local c = b:get_properties()
        if c and c.textures and c.textures[1] == "mobs_chicken.png" then
            return
        end
        local d = skins.get_player_skin(b)
        d:apply_skin_to_player(b)
        armor:run_callbacks("on_update", b)
    end
end

minetest.register_privilege(priv_name, {
    description = "Allows player to turn other players into animals."
})

minetest.register_chatcommand("human", {
    params = "[<player>]",
    description = "Turns player into a chicken",
    func = function(name_invoker, name_target)
        name_target = priv_check(name_invoker, name_target)
        if name_target ~= nil then to_human(name_target) end
    end
})

minetest.register_chatcommand("chicken", {
    params = "[<player>]",
    description = "Turns player into a chicken",
    func = function(name_invoker, name_target)
        name_target = priv_check(name_invoker, name_target)
        if name_target ~= nil then to_chicken(name_target) end
    end
})
