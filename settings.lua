---@alias dimension {WIDTH:number,HEIGHT:number}
---@class SETTINGS
---@field TILE_SIZE number size of a side of square tile in pixels
---@field map {Width:number, Height:number} dimension in tiles
---@field SCREEN {MAP:dimension,UI:dimension,WIDTH:number,HEIGHT:number}
local lib = {}

--[[
4:3 
    - 800x600
    - 1024x768
16:9
    - 1280x720 
    - 1366x768
    - 1600x900 
    - 1920x1080
--]]

lib.TILE_SIZE = 24
lib.map = {
    Width = 33,
    Height = 30
}

lib.SCREEN = {
    MAP = {
        WIDTH = lib.map.Width * lib.TILE_SIZE,
        HEIGHT = lib.map.Height * lib.TILE_SIZE
    }
}

---load default window settings
function lib.load()
    lib.SCREEN.WIDTH = love.graphics.getWidth()
    lib.SCREEN.HEIGHT = love.graphics.getHeight()
    lib.SCREEN.UI = {
        WIDTH = lib.SCREEN.WIDTH - lib.SCREEN.MAP.WIDTH,
        HEIGHT = lib.SCREEN.HEIGHT
    }
end

return lib