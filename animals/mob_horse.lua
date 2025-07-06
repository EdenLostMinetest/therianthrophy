for name, _ in pairs(mobs.spawning_mobs) do
    if name:sub(1, 10) == "mob_horse:" then
        table.insert(mobs_redo_to_register, name)
    end
end
