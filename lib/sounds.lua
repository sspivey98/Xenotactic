local lib = {}

---@type {[string]: love.Source[]}
lib.library = {}
--load all the filepaths
local path = "/assets/sounds"
local files = love.filesystem.getDirectoryItems(path)

for _, file in ipairs(files) do
    local extension = file:match("%.([^%.]+)$")
    if extension then
        extension = extension:lower()
        if extension == "wav" or extension == "ogg" then
            local name = file:match("(.+)%..+")
            --load filepaths as sound objects
            local ok, sound = pcall(love.audio.newSource, path.."/"..file, "static")
            if not ok then
                print("Failed to loud sound '"..name.."'. Error: "..sound)
            else
                lib.library[name] = sound
            end
        end
    end
end

return lib