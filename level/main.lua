--level metadata and functions
local lib = {}
local ENUMS = require('enums')
local IMAGES = require('lib.images')
local SOUNDS = require('lib.sounds')
local SETTINGS = require('settings')
local ENUMS = require('enums')

local TILE_SIZE = SETTINGS.TILE_SIZE --size of tile in pixels
local map = SETTINGS.map
local SCREEN = SETTINGS.SCREEN

local maps = require('level.maps')
local mapData = {} --tile map loads here
local camera = {x = 0, y = 0}

--ui buttons load here
local UI = {
    turrets = {},
    sell = {},
    upgrade = {},
}

--initialize level
function lib.load(level_number)
    --load tiles
    level_number = tonumber(level_number) or 1
    mapData = maps["level_"..level_number]

    if level_number == 5 then
        ENUMS.COLORS[0] = {0.0, 0.2, 0.0}
    elseif level_number == 6 then
        ENUMS.COLORS[0] = {0.2, 0.0, 0.0}
    else
        ENUMS.COLORS[0] = {0.7, 0.8, 0.7}
    end

    --create UI
    --turrets icons
    for i=1, 6 do
        local turret = {
            img = IMAGES.library["icon_"..i],
            hovered = false,
            wasHovered = false,
            cost = 10
        }
        turret.scale = {
            x = 100 / turret.img:getWidth(), --80 / 50
            y = 100 / turret.img:getHeight()
        }
        turret.width = turret.img:getWidth() * turret.scale.x
        turret.height = turret.img:getHeight() * turret.scale.y

        --split x into 3 columns
        turret.x = SCREEN.MAP.WIDTH
        if i % 3 == 1 then
            turret.x = turret.x + (SCREEN.UI.WIDTH / 2) - 3*turret.width / 2
        elseif i % 3 == 2 then
            turret.x = turret.x + (SCREEN.UI.WIDTH / 2) - turret.width / 2
        else
            turret.x = turret.x + (SCREEN.UI.WIDTH / 2) + turret.width / 2
            turret.cost = turret.cost*4
        end
        --split y into 2 rows
        turret.y = (math.ceil(i / 3) - 1) * turret.height + SCREEN.HEIGHT/6 - turret.height
        table.insert(UI.turrets, turret)
    end

    --sell/upgrade menus
end

--draw function
function lib.draw()
    --draw map
    for y=1, map.Height do
        for x = 1, map.Width do
            --print(x..", "..y)
            local tileType = mapData[y][x]
            love.graphics.setColor(ENUMS.COLORS[tileType])
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

    --[[
    --TODO
    add enemy properties section
    add next wave information
    --]]

    --separate into thirds
    local third = SCREEN.HEIGHT / 3
    local padding = 40

    --draw turret buttons
    local grid = {
        size = 64,
        spacing = 8,
        start_x = SCREEN.MAP.WIDTH + padding,
        start_y = 0 + padding
    }

    for _,turret in pairs(UI.turrets) do
        local bgColor = {1,1,1}
        if turret.hovered then
            bgColor = {1,0.7,0.7}
        end
        love.graphics.setColor(bgColor)
        love.graphics.draw(turret.img, turret.x, turret.y, 0, turret.scale.x, turret.scale.y)
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

--interact function
function lib.mousepressed(game, x, y, mouseButton)
    if mouseButton == ENUMS.CLICK.LEFT then
        local tile = getTileAt(x, y)
        if tile then
            print(tile.x..", "..tile.y)
            print(tile.type)
        --select from UI
        else
            for _,turret in ipairs(UI.turrets) do
                if x >= turret.x and x <= turret.x + turret.width and
                    y >= turret.y and y <= turret.y + turret.height then
                    if game.money < turret.cost then
                        SOUNDS.library["invalid"]:play()
                    else
                        SOUNDS.library["button_press"]:play()
                        --TODO turret build logic
                    end
                end
            end
        end
    elseif mouseButton == ENUMS.CLICK.RIGHT then
    end
end

--update function
function lib.update()
    --TODO camera movement?
    local mouse = { x=0, y=0 }
    mouse.x, mouse.y = love.mouse.getPosition()
    for _,turret in ipairs(UI.turrets) do
        turret.wasHovered = turret.hovered
        turret.hovered = mouse.x >= turret.x and mouse.x <= (turret.x + turret.width) and
            mouse.y >= turret.y and mouse.y <= (turret.y + turret.height)
        if turret.hovered and not turret.wasHovered then
            (SOUNDS.library["button_hover"]):play()
        end
    end

end

return lib