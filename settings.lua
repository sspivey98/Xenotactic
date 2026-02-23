---@alias dimension {WIDTH:number,HEIGHT:number}
---@class SETTINGS
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
---@type dimension[]
lib.resolution = {
    [1] = {WIDTH=800, HEIGHT=600},
    [2] = {WIDTH=1024, HEIGHT=768},
    [3] = {WIDTH=1280, HEIGHT=720},
    [4] = {WIDTH=1366, HEIGHT=768},
    [5] = {WIDTH=1600, HEIGHT=900},
    [6] = {WIDTH=1920, HEIGHT=1080},
}

---@type number size of a side of square tile in pixels
lib.TILE_SIZE = 24

---@type {Width:number, Height:number} dimension in tiles
lib.map = {
    Width = 33,
    Height = 30
}

---@type {MAP:dimension,UI:dimension,WIDTH:number,HEIGHT:number}
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