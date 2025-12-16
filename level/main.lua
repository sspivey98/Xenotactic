--level metadata and functions
local lib = {}
local ENUMS = require('enums')
local IMAGES = require('lib.images')
local SOUNDS = require('lib.sounds')
local SETTINGS = require('settings')
local TURRET = require('turret')
local ENEMY = require('enemy')
local UTIL = require('level.util')

--GLOBALS
local TILE_SIZE = SETTINGS.TILE_SIZE --size of tile in pixels
local map = SETTINGS.map
local SCREEN = SETTINGS.SCREEN
local random = love.math.random(15) --!DELETE

local currentTile = {
    inbounds = true, --in map or not
    valid = true, --location is buildable
    x = 0,
    y = 0,
}

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

    if level_number == 5 then
        ENUMS.COLORS[0] = {0.0, 0.2, 0.0}
    elseif level_number == 6 then
        ENUMS.COLORS[0] = {0.2, 0.0, 0.0}
    else
        ENUMS.COLORS[0] = {0.7, 0.8, 0.7}
    end

    --create UI
    --turrets icons
    for i=1, 7 do
        local turret = {
            id = i,
            img = IMAGES.library["icon_"..i],
            hovered = false,
            wasHovered = false,
            cost = ENUMS.TURRET_TYPE[i].cost
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
        end
        --split y into 2 rows
        turret.y = (math.ceil(i / 3) - 1) * turret.height + SCREEN.HEIGHT/6 - turret.height
        UI.turrets[i] = turret
    end

    --sell/upgrade menus
end

--draw function
function lib.draw(game)
    --draw map
    for y=1, map.Height do
        for x = 1, map.Width do
            --print(x..", "..y)
            local tileType = game.gameState.map[y][x]
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
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --|          turrets           |
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    for _,turret in ipairs(game.gameState.turrets) do
        turret:draw()
    end

    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --|          enemies           |
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    for _,enemy in ipairs(game.gameState.enemies) do
        enemy:draw()
    end
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --|          UI                |
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    --[[
    --TODO for UI
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

    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --|        placementMode       |
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    --[[
        get current mouse position
        if its in the map
            highlight starting at top left
            draw circle around center of four tiles
    --]]

    if game.gameState.placementMode then
        if currentTile.inbounds then
            if UTIL:isValidPlacement(currentTile, game.gameState) then
                love.graphics.setColor{0.3, 1, 0.3, 0.5}
                love.graphics.rectangle("fill",
                    currentTile.x,
                    currentTile.y,
                    TILE_SIZE*2,
                    TILE_SIZE*2
                )
                --draw circle
                love.graphics.setColor{1, 0, 0.3} --bright red
                love.graphics.circle("line",
                    currentTile.x + TILE_SIZE,
                    currentTile.y + TILE_SIZE,
                    100, --radius, should come from turret?
                    20
                )
            else
                love.graphics.setColor{1, 0.3, 0.3, 0.5}
                love.graphics.rectangle("fill",
                    currentTile.x,
                    currentTile.y,
                    TILE_SIZE*2,
                    TILE_SIZE*2
                )
            end
        end
    end
end

--interact function
function lib.mousepressed(game, x, y, mouseButton)
    if mouseButton == ENUMS.CLICK.LEFT then
        local tile = UTIL.getTileAt(game.gameState.map, x, y)

        if tile then
            print("("..tile.x..", "..tile.y..") :: "..tile.type)
            if game.gameState.placementMode then--TODO
                --check placement is valid
                if UTIL:isValidPlacement(currentTile, game.gameState) == false then
                    SOUNDS.library["invalid"]:play()
                --turret is placed
                else
                    TURRET:new(game.gameState, currentTile.x, currentTile.y)
                    game.gameState.placementMode = false
                    SOUNDS.library["turret_build"]:play()
                    --update enemy pathing
                    game.gameState.path1:setBlocked(tile.x, tile.y)
                    game.gameState.path2:setBlocked(tile.x, tile.y)
                end
            end
        --select from UI
        else
            for _,turret in ipairs(UI.turrets) do
                if x >= turret.x and x <= turret.x + turret.width and
                    y >= turret.y and y <= turret.y + turret.height then
                    if game.gameState.money < turret.cost then
                        SOUNDS.library["invalid"]:play()
                        --flash icon dark red?
                    else
                        SOUNDS.library["button_press"]:play()
                        --turret build logic
                        game.gameState.selectedTurretType = turret.id
                        game.gameState.placementMode = true
                    end
                end
            end
        end
    elseif mouseButton == ENUMS.CLICK.RIGHT then
        --deselect whatever
        game.gameState.placementMode = false
    end
end

--update function
function lib.update(game, dt)
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

    --updateMap
    local tile = UTIL.getTileAt(game.gameState.map, mouse.x, mouse.y)
    if tile and tile.type ~= 1 then
        currentTile.inbounds = true
        --do backwards conversion for 'snap' feel
        currentTile.x = (tile.x - 1) * TILE_SIZE
        currentTile.y = (tile.y - 1) * TILE_SIZE
    else
        currentTile.inbounds = false
    end

    --turrets
    for _,turret in ipairs(game.gameState.turrets) do
        turret:update(dt)
    end

    --enemies
    for _,enemy in ipairs(game.gameState.enemies) do
        enemy:update(dt)
    end

    if #game.gameState.turrets == 1 and #game.gameState.enemies == 0 then
        ENEMY:new(game.gameState, random, ENUMS.FLOWFIELD.LONGITUDE)
    end
end

return lib