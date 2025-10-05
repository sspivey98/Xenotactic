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

function lib.load()
    lib.SCREEN.WIDTH = love.graphics.getWidth()
    lib.SCREEN.HEIGHT = love.graphics.getHeight()
    lib.SCREEN.UI = {
        WIDTH = lib.SCREEN.WIDTH - lib.SCREEN.MAP.WIDTH,
        HEIGHT = lib.SCREEN.HEIGHT - lib.SCREEN.MAP.HEIGHT
    }
end

lib.TILE_SIZE = 24 --size of tile in pixels
lib.map = { --# of tiles
    Width = 33,
    Height = 30
}

lib.SCREEN = {
    MAP = {
        WIDTH = lib.map.Width * lib.TILE_SIZE,
        HEIGHT = lib.map.Height * lib.TILE_SIZE
    }
}

return lib