-- AntiFlingLoader.lua
-- Executes AntiFling.lua from this repo so your anti-fling survives respawn.
-- Run once; it re-executes itself whenever your character respawns.

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local ANTI_FLING_URL = "https://raw.githubusercontent.com/SidedRegent133/Fling-Gui/main/AntiFling.lua"

local running = false

local function startAntiFling()
    if running then
        return
    end
    running = true

    local ok, result = pcall(function()
        return loadstring(game:HttpGet(ANTI_FLING_URL))()
    end)

    if ok then
        print("[AntiFlingLoader] AntiFling loaded successfully")
    else
        warn("[AntiFlingLoader] Failed to load AntiFling: " .. tostring(result))
    end

    running = false
end

-- Load immediately and re-load on every respawn
startAntiFling()

player.CharacterAdded:Connect(function()
    task.wait(0.5) -- let the character finish assembling
    startAntiFling()
end)

player.CharacterRemoving:Connect(function()
    task.wait(0.5) -- wait for the new character before reloading
    startAntiFling()
end)
