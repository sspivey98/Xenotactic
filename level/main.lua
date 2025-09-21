--level metadata and functions
local lib = {}

local TILE_SIZE = 20 --size of tile in pixels
local map = { --# of tiles
    Width = 29,
    Height = 30
}

local SCREEN = {
    WIDTH = love.graphics.getWidth(),
    HEIGHT = love.graphics.getHeight(),
    MAP = {
        WIDTH = map.Width * TILE_SIZE,
        HEIGHT = map.Height * TILE_SIZE
    }
}
SCREEN.UI = {
    WIDTH = SCREEN.WIDTH - SCREEN.MAP.WIDTH,
    HEIGHT = SCREEN.HEIGHT - SCREEN.MAP.HEIGHT
}

local TILES = {
    EMPTY = 0,
    WALL = 1,
    SPAWN = 2,
    FINAL = 3,
    TURRET = 4
}

local COLORS = {
    [0] = {0.7, 0.8, 0.7}, --green
    [1] = {0.7, 0.7, 0.7}, --grey
    [2] = {0.2, 0.2, 0.8}, --blue
    [3] = {0.8, 0.2, 0.2} --red
}

local maps = require('level.maps')
local mapData = {}
local camera = {x = 0, y = 0}

--create level
function lib.init(level_number)
    --load tiles
    level_number = tonumber(level_number) or 1
    mapData = maps["level_"..level_number]

    if level_number == 5 then
        COLORS[0] = {0.0, 0.2, 0.0}
    elseif level_number == 6 then
        COLORS[0] = {0.2, 0.0, 0.0}
    else
        COLORS[0] = {0.7, 0.8, 0.7}
    end
end

--draw function
function lib.draw()
    --draw map
    for y=1, map.Height do
        for x = 1, map.Width do
            --print(x..", "..y)
            local tileType = mapData[y][x]
            love.graphics.setColor(COLORS[tileType])
            love.graphics.rectangle("fill", 
                (x-1) * TILE_SIZE, 
                (y-1) * TILE_SIZE, 
                TILE_SIZE, 
                TILE_SIZE)
            
            -- Draw grid lines
            love.graphics.setColor(0, 0, 0, 0.3)
            love.graphics.rectangle("line", 
                (x-1) * TILE_SIZE, 
                (y-1) * TILE_SIZE, 
                TILE_SIZE, 
                TILE_SIZE)
        end
    end
    --draw ui box
    love.graphics.setColor{0.1, 0.1, 0.1}
    love.graphics.rectangle("fill",
        SCREEN.MAP.WIDTH,
        0,
        SCREEN.UI.WIDTH,
        SCREEN.HEIGHT
    )

    --draw turret buttons

    --sell menu
    --upgrade menu
end

--translates to in-game coordinates
local function getTileAt(x, y)
    local tileX = math.floor(x / TILE_SIZE) + 1
    local tileY = math.floor(y / TILE_SIZE) + 1

    --do bounds checks
    if (tileX < 1 or tileX > map.Width) or (tileY < 1 or tileY > map.Height) then
        return nil
    end

    local tile = {
        x = tileX,
        y = tileY,
        type = mapData[tileY][tileX]
    }
    return tile
end

--todo create file with all enums
local click = {
    left = 1,
    right = 2
}

--interact function
function lib.interact(game, x, y, mouseButton)
    if mouseButton == click.left then
        local tile = getTileAt(x, y)
        if tile then
            print(tile.x..", "..tile.y)
            print(tile.type)
        --select from UI
        else
        end
    elseif mouseButton == click.right then
    end
end

--update function
function lib.update()
    --camera movement
end

return lib