--level metadata and functions
local lib = {}
local ENUMS = require('enums')
local IMAGES = require('lib.images')
local SOUNDS = require('lib.sounds')
local SETTINGS = require('settings')
local TURRET = require('turret')
local UTIL = require('level.util')
local UI = require('level.ui')

--GLOBALS
local TILE_SIZE = SETTINGS.TILE_SIZE --size of tile in pixels
local map = SETTINGS.map
local VISUAL_TILE_MAP
local COLOR = {}
local SCREEN = SETTINGS.SCREEN

local blockedAnimation = {
    timer = 1,
    timerValue = 0,
    text = {},
    show = false,
}
do
    local text = "BLOCKED"
    local font = love.graphics.getFont()
    blockedAnimation.text = {
        value = text,
        width = font:getWidth(text),
        height = font:getHeight()
    }
end

local currentTile = {
    inbounds = true, --in map or not
    valid = true, --location is buildable
    x = 0,
    y = 0,
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
    UI:load()
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
            for x=1, map.Width do
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
    UI:drawCurrentWaveInfo(gameState)
    UI:drawNextWaveInfo(gameState)
    UI:drawSelectedTurret(gameState)
    UI:drawSelectedTurretUpgrade(gameState)
    UI:drawMoney(gameState.money)
    UI:drawHealthBar(gameState.lives, SCREEN.MAP.WIDTH, 0)

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
        if blockedAnimation.show then
            love.graphics.setColor(ENUMS.UPGRADE_COLORS.RED)
            love.graphics.print(
                blockedAnimation.text.value,
                currentTile.x,
                currentTile.y
            )
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
                    blockedAnimation.show = true
                    SOUNDS.library["invalid"]:play()
                else --turret is placed
                    TURRET:new(gameState, currentTile.x, currentTile.y)
                    gameState.placementMode = false
                    SOUNDS.library["turret_build"]:play()
                    --update enemy pathing
                    gameState.path1:setBlocked(tile.x, tile.y)
                    if gameState.path2 then
                        gameState.path2:setBlocked(tile.x, tile.y)
                    end
                end
            else
                local checkTurret = false
                for _,turret in pairs(gameState.turrets) do
                    if turret:select(x, y) then
                        checkTurret = true
                        gameState.selectedTurret = turret
                    end
                end
                if not checkTurret then gameState.selectedTurret = nil end
                local checkEnemy = false
                for _,enemy in pairs(gameState.enemies) do
                    if enemy:select(x, y) then
                        checkEnemy = true
                        gameState.selectedEnemy = enemy
                    end
                end
                if not checkEnemy then gameState.selectedEnemy = nil end
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
                        gameState.selectedTurretType = name
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

            if UI.buttons["send_wave"]:clicked(x, y, mouseButton) then
                gameState.waves:next(gameState)
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
        turret:update(dt, gameState)
        turret:target(gameState.enemies)
    end

    --blocked animation
    if blockedAnimation.show then
        blockedAnimation.timerValue = blockedAnimation.timerValue + dt
        if blockedAnimation.timerValue >= blockedAnimation.timer then
            blockedAnimation.timerValue = 0
            blockedAnimation.show = false
        end
    end

    --waves
    gameState.waves:update(dt, gameState)
end

return lib