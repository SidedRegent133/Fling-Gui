-- imageLoader.lua: downloads image.png and returns the custom asset path
-- Returns a function; calling it returns the asset string (or nil + warn on failure)
return function()
    local imageUrl = "https://raw.githubusercontent.com/SidedRegent133/Fling-Gui/main/image.png"
    local fileName = "temp_fling_image.png"

    local ok, result = pcall(function()
        local imageData = game:HttpGet(imageUrl)
        writefile(fileName, imageData)
        return getcustomasset(fileName)
    end)

    if not ok then
        warn("[imageLoader] Failed to load image.png: " .. tostring(result))
        return nil
    end

    return result
end
