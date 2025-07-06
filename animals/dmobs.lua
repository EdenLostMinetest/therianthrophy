local settings = core.settings
local dragons_allowed = settings:get_bool("therianthropy.dmobs_dragon", true)

for name, _ in pairs(mobs.spawning_mobs) do
    if name:sub(1, 6) == "dmobs:" then
        local short_name = name:sub(7)
        local is_dragon = (short_name == "wyvern") or short_name:find("dragon", 1, true)

        if dragons_allowed or not is_dragon then
            table.insert(mobs_redo_to_register, name)
        end
    end
end
