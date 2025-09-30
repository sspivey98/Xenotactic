--level metadata and functions
local SETTINGS = require('settings')
local lib = {}

local TILE_SIZE = SETTINGS.TILE_SIZE --size of tile in pixels
local map = SETTINGS.map
local SCREEN = SETTINGS.SCREEN

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
            love.graphics.setColor{0, 0, 0, 0.3}
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

    --separate into thirds
    local third = SCREEN.HEIGHT / 3
    local padding = 20

    --draw turret buttons
    local grid = {
        size = 48,
        spacing = 8,
        start_x = SCREEN.MAP.WIDTH + padding,
        start_y = 0 + padding
    }
    for row = 1, 3 do
        for col = 1, 3 do
            local x = grid.start_x + (col - 1) * (grid.size + grid.spacing)
            local y = grid.start_y + (row - 1) * (grid.size + grid.spacing)

            --draw button background
            love.graphics.setColor{0.3, 0.3, 0.3}
            love.graphics.rectangle("fill", x, y, grid.size, grid.size)

            --draw button border
            love.graphics.setColor{0.6, 0.6, 0.6}
            love.graphics.rectangle("line", x, y, grid.size, grid.size)

            --icons
            love.graphics.setColor{1, 1, 1}
            local text = "T" .. ((row-1) * 3 + col)
            love.graphics.print(text, x + grid.size/2 - 8, y + grid.size/2 - 6)
        end
    end

    --sell menu
    local sellStartY = third + padding
    love.graphics.setColor{1, 1, 1}
    love.graphics.print("SELL", grid.start_x, sellStartY)
    
    --upgrade menu
    local upgradeStartY = third*2 + padding
    love.graphics.setColor{1, 1, 1}
    love.graphics.print("Upgrade", grid.start_x, upgradeStartY)
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