SpiritLib = {}

local modules = {"Animation", "Weapons", "Attachment", "Pathfinding"}

for k, v in pairs(modules) do
    local loader = CreatePart(0, newVector3(0, 0, 0), newVector3(0, 0, 0))
    loader.visible = false
    loader.cancollide = false

    -- Load module script
    loader.script = v

    loader.scripts[1].SpiritLib = This.scripts[1]

    print("Loaded " .. v .. " module.")
end