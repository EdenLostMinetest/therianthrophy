
-- therianthrophy mod
-- Inspired by OgelGames's "Be a Chicken" LUA command block on pandorabox.io

local priv_name = "therianthrophy"

local chicken_players = {}

player_api.register_model("mobs_chicken.b3d", {
	animation_speed = 24,
	textures = {"mobs_chicken.png"},
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

-- Override the skin update function to skip chicken players,
-- so that the custom properties do not get changed
local old_skin_apply = skins.skin_class.apply_skin_to_player
skins.skin_class.apply_skin_to_player = function(self, player)
	local name = player:get_player_name()
	if chicken_players[name] then
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
	chicken_players[name] = nil
	set_model(player, "skinsdb_3d_armor_character_5.b3d")
	skins.update_player_skin(player)
end

local function to_chicken(player)
	local name = player:get_player_name()
	chicken_players[name] = true
	set_model(player, "mobs_chicken.b3d")
	player_api.set_textures(player, {"mobs_chicken.png"})
	-- Pop the player up a node so they dont fall into the node below
	player:set_pos(vector.add(player:get_pos(), vector.new(0, 1, 0)))
end

minetest.register_privilege(priv_name, {
    description = "Allows player to turn other players into animals."
})

minetest.register_chatcommand("human", {
    params = "[<player>]",
    description = "Turns player back into a human",
	privs = {[priv_name] = true},
    func = function(name, target)
		if target ~= "" then
			name = target
		end
        local player = minetest.get_player_by_name(name)
        if not player then
			return false, "Player does not exist."
		end
		to_human(player)
    end
})

minetest.register_chatcommand("chicken", {
    params = "[<player>]",
    description = "Turns player into a chicken",
    privs = {[priv_name] = true},
    func = function(name, target)
        if target ~= "" then
			name = target
		end
        local player = minetest.get_player_by_name(name)
        if not player then
			return false, "Player does not exist."
		end
		to_chicken(player)
    end
})
