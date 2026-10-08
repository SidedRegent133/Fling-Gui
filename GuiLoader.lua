-- GuiLoader.lua: entry point.
-- Run order: imageLoader.lua first, then Gui.lua (which uses the loaded image).
local IMAGE_LOADER_URL = "https://raw.githubusercontent.com/SidedRegent133/Fling-Gui/main/imageLoader.lua"
local GUI_URL = "https://raw.githubusercontent.com/SidedRegent133/Fling-Gui/main/Gui.lua"

-- Shared state so Gui.lua can pick up the image without re-downloading
local shared = getgenv and getgenv() or _G
shared.FLING_GUI_IMAGE = nil

-- 1) Run imageLoader.lua
local ok, err = pcall(function()
    local loader = loadstring(game:HttpGet(IMAGE_LOADER_URL))()
    if type(loader) == "function" then
        shared.FLING_GUI_IMAGE = loader()
    end
end)

if not ok then
    warn("[GuiLoader] imageLoader failed: " .. tostring(err))
end

-- 2) Run Gui.lua
local ok2, err2 = pcall(function()
    loadstring(game:HttpGet(GUI_URL))()
end)

if not ok2 then
    warn("[GuiLoader] Failed to load Gui.lua: " .. tostring(err2))
end
