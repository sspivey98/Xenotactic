--level metadata and functions
local lib = {}
local ENUMS = require('enums')
local IMAGES = require('lib.images')
local SOUNDS = require('lib.sounds')
local SETTINGS = require('settings')
local TURRET = require('turret')
local ENEMY = require('enemy')
local UTIL = require('level.util')
local BUTTON = require('lib.button')

--GLOBALS
local TILE_SIZE = SETTINGS.TILE_SIZE --size of tile in pixels
local map = SETTINGS.map
local VISUAL_TILE_MAP
local COLOR = {}
local SCREEN = SETTINGS.SCREEN
local random = love.math.random(15) --!DELETE

local currentTile = {
    inbounds = true, --in map or not
    valid = true, --location is buildable
    x = 0,
    y = 0,
}

--ui buttons load here
---@type {turrets:{[string]:button.image},buttons:{[string]:button.text}}
local UI = {
    turrets = {},
    buttons = {}
}

---initialize level
---@param level_number number level number selected (1-6)
---@param TILES number[][] visual tilemap to use 
function lib.load(level_number, TILES)
    if TILES then
        VISUAL_TILE_MAP = TILES
    end

    --load tiles
    level_number = tonumber(level_number) or 1

    if level_number == 5 then
        COLOR = {0.2, 0.5, 0.2}
    elseif level_number == 6 then
        COLOR = {0.5, 0.2, 0.2}
    else
        COLOR = {1,1,1}
    end

    --create UI
    --turrets icons
    for i=1, 7 do
        local key = ENUMS.TURRET_LOOKUP[i]
        local img = IMAGES.library["icon_"..i]
        local scale = {
            x = 100 / img:getWidth(), --80 / 50
            y = 100 / img:getHeight()
        }
        local width = img:getWidth() * scale.x
        local height = img:getHeight() * scale.y

        --split x into 3 columns
        local x = SCREEN.MAP.WIDTH
        if i % 3 == 1 then
            x = x + (SCREEN.UI.WIDTH / 2) - 3*width / 2
        elseif i % 3 == 2 then
            x = x + (SCREEN.UI.WIDTH / 2) - width / 2
        else
            x = x + (SCREEN.UI.WIDTH / 2) + width / 2
        end
        --split y into 2 rows
        local y = (math.ceil(i / 3) - 1) * height + SCREEN.HEIGHT/6 - height

        ---@type button.image
        local turretButton = BUTTON:new(
            BUTTON.type.IMAGE,
            {
                x = x,
                y = y,
                width = width,
                height = height,
                image = img,
                color = {1,1,1},
                hoveredColor = {1,0.7,0.7},
                scale = {
                    x = scale.x,
                    y = scale.y
                }
            }
        )

        UI.turrets[key] = turretButton
    end

    --sell button
    local padding = 40
    local sell_button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = SCREEN.MAP.WIDTH + padding,
            y = 2 * SCREEN.HEIGHT / 5 + padding,
            width = SCREEN.UI.WIDTH / 2 - padding,
            height = SCREEN.UI.HEIGHT / 8 - padding,
            color = {0.3, 0.3, 0.3},
            text = "SELL"
        }
    )
    ---@cast sell_button button.text
    local upgrade_button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = SCREEN.MAP.WIDTH + padding,
            y = 3*SCREEN.HEIGHT / 5 + padding,
            width = SCREEN.UI.WIDTH / 2 - padding,
            height = SCREEN.UI.HEIGHT / 8 - padding,
            color = {0.3, 0.3, 0.3},
            text = "UPGRADE"
        }
    )
     ---@cast upgrade_button button.text
    UI.buttons["sell"] = sell_button
    UI.buttons["upgrade"] = upgrade_button
    SOUNDS.library["next_menu"]:play()
end

---draw function
---@param gameState GAME.GAMESTATE
function lib.draw(gameState)
    --draw map
    if VISUAL_TILE_MAP then
        local scale = TILE_SIZE / 230
        for y=1, map.Height do
            for x = 1, map.Width do
                local tileType = VISUAL_TILE_MAP[y][x]
                local img = ENUMS.VISUAL_TILES[tileType]
                if tileType == 0 then
                    if (y % 2 == 0) and (x % 2 == 0) then
                        img = ENUMS.VISUAL_TILES[tileType][0]
                    elseif (y % 2 == 0) and (x % 2 == 1) then
                        img = ENUMS.VISUAL_TILES[tileType][1]
                    elseif (y % 2 == 1) and (x % 2 == 0) then
                        img = ENUMS.VISUAL_TILES[tileType][2]
                    elseif (y % 2 == 1) and (x % 2 == 1) then
                        img = ENUMS.VISUAL_TILES[tileType][3]
                    end
                end
                love.graphics.setColor(COLOR)
                love.graphics.draw(
                    img,
                    (x-1) * TILE_SIZE,
                    (y-1) * TILE_SIZE,
                    0,
                    scale,
                    scale
                )
            end
        end
    else
        for y=1, map.Height do
            for x = 1, map.Width do
                local tileType = gameState.map[y][x]
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
    for _,turret in pairs(gameState.turrets) do
        turret:draw()
    end

    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --|          enemies           |
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    for _,enemy in pairs(gameState.enemies) do
        enemy:draw()
    end

    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --|          UI                |
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    --[[
    --TODO for UI
    add current turret/enemy selected info
    add upgrade/sell turret button
    add next wave information
    --]]

    --draw UI turret buttons
    for _,turret in pairs(UI.turrets) do
        turret:draw()
    end

    --draw UI buttons
    for _,button in pairs(UI.buttons) do
        button:draw()
    end

    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --|        placementMode       |
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    --[[
        get current mouse position
        if its in the map
            highlight starting at top left
            draw circle around center of four tiles
    --]]

    if gameState.placementMode then
        if currentTile.inbounds then
            if UTIL:isValidPlacement(currentTile, gameState) then
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

---interact function
---@param gameState GAME.GAMESTATE
---@param x number
---@param y number
---@param mouseButton ENUMS.CLICK
function lib.mousepressed(gameState, x, y, mouseButton)
    if mouseButton == ENUMS.CLICK.LEFT then
        local tile = UTIL.getTileAt(gameState.map, x, y)
        if tile then
            --!print("("..tile.x..", "..tile.y..") :: "..tile.type)
            if gameState.placementMode then
                --check placement is valid
                if UTIL:isValidPlacement(currentTile, gameState) == false then
                    SOUNDS.library["invalid"]:play()
                else --turret is placed
                    TURRET:new(gameState, currentTile.x, currentTile.y)
                    gameState.placementMode = false
                    SOUNDS.library["turret_build"]:play()
                    --update enemy pathing
                    gameState.path1:setBlocked(tile.x, tile.y)
                    gameState.path2:setBlocked(tile.x, tile.y)
                end
            else
                local check = false
                for _,turret in pairs(gameState.turrets) do
                    if turret:select(x, y) then
                        check = true
                        gameState.selectedTurret = turret
                    end
                end
                if not check then
                    gameState.selectedTurret = nil
                end
            end
        else --select from UI
            for name,turret in pairs(UI.turrets) do
                if turret:clicked(x,y,mouseButton) then
                    if gameState.money < ENUMS.TURRET[name].cost then
                        SOUNDS.library["invalid"]:play()
                        --flash icon dark red?
                    else
                        SOUNDS.library["button_press"]:play()
                        --turret build logic
                        gameState.selectedTurretType = ENUMS.TURRET_TYPE[name]
                        gameState.placementMode = true
                    end
                end
            end

            if gameState.selectedTurret then
                for name,button in pairs(UI.buttons) do
                    if button:clicked(x, y, mouseButton) then
                        --* custom logic
                        if name == "upgrade" then
                            --check cost
                            if gameState.selectedTurret:upgrade(gameState) then
                                SOUNDS.library["upgrading"]:play()
                            else
                                SOUNDS.library["invalid"]:play()
                            end
                        elseif name == "sell" then
                            SOUNDS.library["turret_sold"]:play()
                            gameState.selectedTurret:sell(gameState)
                            gameState.selectedTurret = nil
                        end
                        --*custom logic
                    end
                end
            end
        end
    elseif mouseButton == ENUMS.CLICK.RIGHT then
        --deselect whatever
        gameState.selectedTurret = nil
        gameState.placementMode = false
    end
end

---update logic function
---@param gameState GAME.GAMESTATE
---@param dt number
function lib.update(gameState, dt)
    if gameState.lives == 0 then
        SOUNDS.library["mission_failed"]:play()
    end

    local mouse = { x=0, y=0 }
    mouse.x, mouse.y = love.mouse.getPosition()

    --UI selection
    for _,turret in pairs(UI.turrets) do
        turret:isHovered(mouse.x, mouse.y)
    end

    for _,button in pairs(UI.buttons) do
        button:isHovered(mouse.x, mouse.y)
    end

    --updateMap
    local tile = UTIL.getTileAt(gameState.map, mouse.x, mouse.y)
    if tile and tile.type ~= 1 then
        currentTile.inbounds = true
        --do backwards conversion for 'snap' feel
        currentTile.x = (tile.x - 1) * TILE_SIZE
        currentTile.y = (tile.y - 1) * TILE_SIZE
    else
        currentTile.inbounds = false
    end

    --enemies
    for _,enemy in pairs(gameState.enemies) do
        enemy:update(dt, gameState)
    end

    --[[
        1.) Search for enemies within radius of turret
        2.) Select far-most right enemy in radius
        3.) give coordinates to turret
        4.) turn turret to face coordinates
        5.) turret shoot function
        6.) remove health from enemy

        delay search to not be every frame
        ignore search if turret already has a target (and its still in range)
        force research if enemy dies
    --]]
    --turrets
    for _,turret in pairs(gameState.turrets) do
        turret:update(dt)
        turret:target(gameState.enemies)
    end

    if UTIL.tableLength(gameState.turrets) >= 1 and UTIL.tableLength(gameState.enemies) == 0 then
        ENEMY:new(gameState, random, gameState.path1, ENUMS.FLOWFIELD.LONGITUDE)
        ENEMY:new(gameState, random+1, gameState.path1, ENUMS.FLOWFIELD.LONGITUDE)
        ENEMY:new(gameState, 15, gameState.path1, ENUMS.FLOWFIELD.LONGITUDE)
    end
end

return lib