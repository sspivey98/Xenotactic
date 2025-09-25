local lib = {}

lib.TILE_SIZE = 20 --size of tile in pixels
lib.map = { --# of tiles
    Width = 29,
    Height = 30
}

lib.SCREEN = {
    WIDTH = love.graphics.getWidth(),
    HEIGHT = love.graphics.getHeight(),
    MAP = {
        WIDTH = lib.map.Width * lib.TILE_SIZE,
        HEIGHT = lib.map.Height * lib.TILE_SIZE
    }
}
lib.SCREEN.UI = {
    WIDTH = lib.SCREEN.WIDTH - lib.SCREEN.MAP.WIDTH,
    HEIGHT = lib.SCREEN.HEIGHT - lib.SCREEN.MAP.HEIGHT
}

return lib