local UTIL = require('level.util')
local JSON = require('lib.json')

local lib = {}

local saveFile = "save.xeno"

---@class saveFile
---@field level integer `1-6`
---@field volume number `0-1`
---@field width integer
---@field height integer
---@field easyPlacementMode boolean

---@type saveFile
local defaults = {
    level = 1,
    volume = 1.0,
    width = 1280,
    height = 720,
    easyPlacementMode = false
}

---save file
---@param data {level?:integer,volume?:number,width?:number,height?:number,easyPlacementMode?:boolean}
function lib:save(data)
    --keep existing settings that were not modified
    local save = self:load()
    for k,v in pairs(data) do
        save[k] = v
    end
    local success, err = pcall(function()
        local encoded = JSON.encode(save)
        love.filesystem.write(saveFile, encoded)
    end)

    if not success then
        print("Failed to save: " .. tostring(err))
    end
end

---Delete save file
function lib:delete()
    if love.filesystem.getInfo(saveFile) then
        love.filesystem.remove(saveFile)
        print("Save file deleted")
    end
end

---return save file data; if DNE, returns defaults
---@return saveFile
function lib:load()
        -- Return defaults if no save file exists
    if not love.filesystem.getInfo(saveFile) then
        print("No save file found, using defaults")
        return UTIL:deepCopy(defaults)
    end

    local success, data = pcall(function()
        local contents = love.filesystem.read(saveFile)
        local decoded = JSON.decode(contents)

        -- Merge with defaults (in case new fields were added)
        local result = UTIL:deepCopy(defaults)
        for k, v in pairs(decoded) do
            result[k] = v
        end

        return result
    end)

    if not success then
        print("Failed to load save: " .. tostring(data))
        return UTIL:deepCopy(defaults)
    end

    return data
end


return lib