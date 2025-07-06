for name, _ in pairs(mobs.spawning_mobs) do
    if name:sub(1, 12) == "mobs_animal:" then
        table.insert(mobs_redo_to_register, name)
    end
end
