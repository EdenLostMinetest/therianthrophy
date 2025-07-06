local function play_sound(player, sound_name)
    if not sound_name or sound_name == "" then return end

    local player_name = player:get_player_name()
    local transformed_animal = therianthropy.transformed(player_name)
    if not transformed_animal then return end

    local data = therianthropy.mob_data[transformed_animal]
    local sound = data.sounds[sound_name]
    if not sound or sound == "" then return end

    local pitch = 1 + math.random(-10, 10) * 0.005
    core.sound_play({name = sound, gain = 1, pitch = pitch}, {
        object = player, max_hear_distance = data.hear_distance
    }, true)
end

-- Play animal attack noise when punching a player
core.register_on_punchplayer(function(_, hitter, time_from_last_punch)
    if not therianthropy.transformed(hitter:get_player_name()) then return end

    time_from_last_punch = time_from_last_punch or 0
    if time_from_last_punch >= 0.6 then
        play_sound(hitter, "attack")
    end
end)

-- Play random mob noises
local function play_random()
    for _, player in ipairs(core.get_connected_players()) do
        if math.random(100) == 1 then
            play_sound(player, "random")
        end
    end

    core.after(1, play_random)
end
core.after(1, play_random)
