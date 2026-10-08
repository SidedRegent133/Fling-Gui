-- GuiLoader.lua: loads Gui.lua from the repo and runs it
local GUI_URL = "https://raw.githubusercontent.com/SidedRegent133/Fling-Gui/main/Gui.lua"

local ok, err = pcall(function()
    loadstring(game:HttpGet(GUI_URL))()
end)

if not ok then
    warn("[GuiLoader] Failed to load Gui.lua: " .. tostring(err))
end
