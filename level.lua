--level metadata and functions
local lib = {}

local tileSize = 32 --size of tile in pixels
local map = { --# of tiles
    Width = 30,
    Height = 30
}

local TILES = {
    EMPTY = 0,
    SPACE = 1,
    WALL = 2
}

local mapData = {}
local camera = {x = 0, y = 0}

--create level
function lib.new()
    --load tiles
    --initialize map
    for y=1, map.Height do
        mapData[y] = {}
        for x = 1, map.Width do
            --cover borders
            if (x == 1 or x == map.Width) or (y == 1 or y == map.Height) then
                mapData[y][x] = TILES.WALL
            else
                mapData[y][x] = TILES.SPACE
            end
        end
    end
end

--draw function
function lib.draw()
    --calculate tiles on screen
    local startX = math.floor(camera.x / tileSize) + 1
    local startY = math.floor(camera.y / tileSize) + 1
    local endX = math.min(startX + math.ceil(love.graphics.getWidth() / tileSize), map.Width)
    local endY = math.min(startY + math.ceil(love.graphics.getHeight() / tileSize), map.Height)

    --draw visible tiles
    love.graphics.setColor{1,1,1}
    for y = startY, endY do
        for x = startX, endX do
            --local tileType = mapData[y][x] or TILES.EMPTY
            --if tileType ~= TILES.EMPTY then end
        end
    end
    --draw grid lines when debug
end

--update function
function lib.update()
    --camera movement
end

return lib