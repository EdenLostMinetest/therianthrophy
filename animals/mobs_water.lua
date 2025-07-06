for name, _ in pairs(mobs.spawning_mobs) do
    if part_of_modpack(name) then
        table.insert(mobs_redo_to_register, name)
    end
end
