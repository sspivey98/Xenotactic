--level metadata and functions
local lib = {}

local TILE_SIZE = 20 --size of tile in pixels
local map = { --# of tiles
    Width = 29,
    Height = 29
}

local TILES = {
    EMPTY = 0,
    WALL = 1,
    SPAWN = 2,
    FINAL = 3
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
    --mapData = require('levels.level1')
    level_number = tonumber(level_number) or 1
    mapData = maps["level_"..level_number]

    --initialize map
end

--draw function
function lib.draw()
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
end

--update function
function lib.update()
    --camera movement
end

return lib