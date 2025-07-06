for name, _ in pairs(mobs.spawning_mobs) do
    if name:sub(1, 13) == "mobs_monster:" then
        table.insert(mobs_redo_to_register, name)
    end
end
