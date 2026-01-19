local lib = {}

---@type {[string]: love.Image[]}
lib.library = {}
--load all the filepaths
local path = "/assets/images"
local files = love.filesystem.getDirectoryItems(path)

for _, file in ipairs(files) do
    local extension = file:match("%.([^%.]+)$")
    if extension then
        extension = extension:lower()
        if extension == "png" or extension == "jpg" then
            local name = file:match("(.+)%..+")
            --load filepaths as sound objects
            lib.library[name] = love.graphics.newImage(path.."/"..file)
        end
    end
end


lib.icons = {}

return lib