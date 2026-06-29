--level metadata and functions
local lib = {}
local ENUMS = require('enums')
local SOUNDS = require('lib.sounds')
local SETTINGS = require('settings')
local TURRET = require('turret')
local UTIL = require('level.util')
local UI = require('level.ui')

--GLOBALS
local VISUAL_TILE_MAP
local PAUSE = false
local SHIFT = false
local COLOR = {}
local EASY_PLACEMENT = {
    dragging = false
}

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
        local scale = SETTINGS.TILE_SIZE / 230
        for y=1, SETTINGS.map.Height do
            for x = 1, SETTINGS.map.Width do
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
                    (x-1) * SETTINGS.TILE_SIZE,
                    (y-1) * SETTINGS.TILE_SIZE,
                    0,
                    scale,
                    scale
                )
            end
        end
    else
        for y=1, SETTINGS.map.Height do
            for x=1, SETTINGS.map.Width do
                local tileType = gameState.map[y][x]
                love.graphics.setColor(ENUMS.COLORS[tileType])
                love.graphics.rectangle("fill",
                    (x-1) * SETTINGS.TILE_SIZE,
                    (y-1) * SETTINGS.TILE_SIZE,
                    SETTINGS.TILE_SIZE,
                    SETTINGS.TILE_SIZE)

                -- Draw grid lines
                love.graphics.setColor{0, 0, 0, 0.3}
                love.graphics.rectangle("line",
                    (x-1) * SETTINGS.TILE_SIZE,
                    (y-1) * SETTINGS.TILE_SIZE,
                    SETTINGS.TILE_SIZE,
                    SETTINGS.TILE_SIZE)
            end
        end
    end
    --draw ui box
    love.graphics.setColor{0.1, 0.1, 0.1}
    love.graphics.rectangle("fill",
        SETTINGS.SCREEN.MAP.WIDTH,
        0,
        SETTINGS.SCREEN.UI.WIDTH,
        SETTINGS.SCREEN.HEIGHT
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
                    SETTINGS.TILE_SIZE*2,
                    SETTINGS.TILE_SIZE*2
                )
                --draw circle
                love.graphics.setColor{1, 0, 0.3} --bright red
                love.graphics.circle("line",
                    currentTile.x + SETTINGS.TILE_SIZE,
                    currentTile.y + SETTINGS.TILE_SIZE,
                    ENUMS.TURRET[gameState.selectedTurretType].range * SETTINGS.scale,
                    20
                )
            else
                love.graphics.setColor{1, 0.3, 0.3, 0.5}
                love.graphics.rectangle("fill",
                    currentTile.x,
                    currentTile.y,
                    SETTINGS.TILE_SIZE*2,
                    SETTINGS.TILE_SIZE*2
                )
            end

            -- Easy placement mode hint text
            if SETTINGS.easyPlacementMode then
                love.graphics.setColor(1, 1, 1, 0.8)
                local hintText = "Hold and drag to position"
                local font = love.graphics.getFont()
                local textWidth = font:getWidth(hintText)
                love.graphics.print(
                    hintText,
                    currentTile.x + SETTINGS.TILE_SIZE - textWidth / 2,
                    currentTile.y - 20
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

    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --|          UI                |
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    UI:drawSelectedTurret(gameState)
    UI:drawSelectedTurretUpgrade(gameState)
    UI:drawMoney(gameState.money)
    UI:drawHealthBar(gameState.lives)
    UI:drawTimer(gameState)
    UI:drawRound(gameState)
    UI:drawEnemyCounter(gameState)
    --UI:drawCurrentEnemy(gameState)
    UI:drawPauseButton()
    UI:drawPlaceTurretButton()

    --draw UI turret buttons
    for _,turret in pairs(UI.turrets) do
        turret:draw()
    end

    --draw UI buttons
    for _,button in pairs(UI.buttons) do
        button:draw()
    end

    if PAUSE then
        UI:drawPauseMenu()
    end

    if gameState.selectedEnemy then
        UI:drawHealth(gameState.selectedEnemy)
    end

    --tooltips
    for _,button in pairs(UI.turrets) do
        if button.hovered and button.tooltip then
            button:drawTooltip()
        end
    end
end

---@param gameState GAME.GAMESTATE
local function attemptPlaceTurret(gameState)
    --check placement is valid
    if UTIL:isValidPlacement(currentTile, gameState) == false then
        blockedAnimation.show = true
        SOUNDS.library["invalid"]:play()
    else --turret is placed
        TURRET:new(gameState, currentTile.x, currentTile.y, SETTINGS.scale)
        if not SHIFT or (gameState.money < ENUMS.TURRET[gameState.selectedTurretType].cost) then
            gameState.placementMode = false
        end
        SOUNDS.library["turret_build"]:play()
        --update enemy pathing
        gameState.path1:setBlocked(currentTile.x, currentTile.y, true)
        if gameState.path2 then
            gameState.path2:setBlocked(currentTile.x, currentTile.y, true)
        end

        --reset easy placement state
        EASY_PLACEMENT.dragging = false
    end
end

---interact function
---@param game GAME
---@param x number
---@param y number
---@param mouseButton ENUMS.CLICK
function lib.mousepressed(game, x, y, mouseButton)
    if UI.pauseButton:clicked(x, y, mouseButton) then
        PAUSE = not PAUSE
    end
    if not PAUSE then
        if mouseButton == ENUMS.CLICK.LEFT then
            if
                game.gameState.placementMode
                and SETTINGS.easyPlacementMode
                and UI.placeTurret:clicked(x,y,mouseButton)
            then
                attemptPlaceTurret(game.gameState)
                return
            end
            local tile = UTIL.getTileAt(game.gameState.map, x, y)
            if tile then
                if game.gameState.placementMode then
                    if SETTINGS.easyPlacementMode then
                        EASY_PLACEMENT.dragging = true
                    else
                        attemptPlaceTurret(game.gameState)
                    end
                else
                    local checkTurret = false
                    for _,turret in pairs(game.gameState.turrets) do
                        if turret:select(x, y) then
                            checkTurret = true
                            game.gameState.selectedTurret = turret
                            game.gameState.selectedTurretType = turret.turretType
                        end
                    end
                    if not checkTurret then game.gameState.selectedTurret = nil end
                    local checkEnemy = false
                    for _,enemy in pairs(game.gameState.enemies) do
                        if enemy:select(x, y) then
                            checkEnemy = true
                            game.gameState.selectedEnemy = enemy
                            break
                        end
                    end
                    if not checkEnemy then game.gameState.selectedEnemy = nil end
                end
            else --select from UI
                --deselect selectedTurret if in placementMode and left-click the UI
                if game.gameState.placementMode then
                    game.gameState.placementMode = false
                end
                for name,turret in pairs(UI.turrets) do
                    if turret:clicked(x,y,mouseButton) then
                        if game.gameState.money < ENUMS.TURRET[name].cost then
                            if not SETTINGS.easyPlacementMode then
                                SOUNDS.library["invalid"]:play()
                            end
                            --flash icon dark red?
                        else
                            SOUNDS.library["button_press"]:play()
                            --turret build logic
                            game.gameState.selectedTurretType = name
                            game.gameState.placementMode = true

                            --reset placement metadata
                            EASY_PLACEMENT.dragging = false
                        end
                    end
                end

                if game.gameState.selectedTurret then
                    for name,button in pairs(UI.buttons) do
                        if button:clicked(x, y, mouseButton) then
                            if name == "upgrade" then
                                --check cost
                                if game.gameState.selectedTurret:upgrade(game.gameState) then
                                    SOUNDS.library["upgrading"]:play()
                                elseif not SETTINGS.easyPlacementMode then
                                    SOUNDS.library["invalid"]:play()
                                end
                            elseif name == "sell" then
                                SOUNDS.library["turret_sold"]:play()
                                game.gameState.selectedTurret:sell(game.gameState)
                                game.gameState.selectedTurret = nil
                            end
                        end
                    end
                end
            end
        if UI.buttons["send_wave"]:clicked(x, y, mouseButton) then
            game.gameState.waves:next(game.gameState)
        end
        elseif mouseButton == ENUMS.CLICK.RIGHT then
            --deselect whatever
            game.gameState.selectedTurret = nil
            game.gameState.placementMode = false
        end
    else
        if UI.pause["yes_button"]:clicked(x, y, mouseButton) then
            PAUSE = not PAUSE
            game.state = ENUMS.STATES.MENU
        end
        if UI.pause["no_button"]:clicked(x, y, mouseButton) then
            PAUSE = not PAUSE
        end
    end
end

---update logic function
---@param game game
---@param dt number
function lib.update(game, dt)
    if game.gameState.lives <= 0 then
        game.state = ENUMS.STATES.GAME_OVER
    end
    if game.gameState.round == game.gameState.waves.amount --last wave in mission
        and UTIL.tableLength(game.gameState.enemies) == 0 --no more enemies
        and #game.gameState.waves.waves[game.gameState.round].enemies <= 0 --no more enemies to spawn
    then
        game.state = ENUMS.STATES.LEVEL_WIN
    end

    local mouse = { x=0, y=0 }
    local mx, my = love.mouse.getPosition()
    --transpose if canvas
    if SETTINGS.CANVAS.GAME then
        mouse.x = (mx - SETTINGS.CANVAS.OFFSET.x) / SETTINGS.CANVAS.SCALE
        mouse.y = (my - SETTINGS.CANVAS.OFFSET.y) / SETTINGS.CANVAS.SCALE
    else
        mouse.x, mouse.y = mx, my
    end

    if not PAUSE then
        if game.gameState.lives == 0 then
            SOUNDS.library["mission_failed"]:play()
        end

        --UI selection
        for name,turret in pairs(UI.turrets) do
            if ENUMS.TURRET[name].cost > game.gameState.money then
                turret.disabled = true
                turret.color = {0.5, 0.5, 0.5}
            else
                turret.disabled = false
                turret.color = {1,1,1}
            end
            turret:isHovered(mouse.x, mouse.y)
        end

        for key,button in pairs(UI.buttons) do
            if key == "upgrade" and game.gameState.selectedTurret then
                if game.gameState.selectedTurret.turretType ~= "WALL" and game.gameState.selectedTurret.level ~= 6 then
                    local cost = ENUMS.UPGRADE_PATH[game.gameState.selectedTurret.turretType]["LEVEL"..game.gameState.selectedTurret.level+1].cost
                    if cost > game.gameState.money then
                        button.disabled = true
                        button.color = {0.1, 0.1, 0.1}
                        button.hovered = false
                    else
                        button.disabled = false
                        button.color = {0.3, 0.3, 0.3}
                    end
                else
                    button.disabled = true
                    button.color = {0.1, 0.1, 0.1}
                end
            else
                button.disabled = false
                button.color = {0.3, 0.3, 0.3}
            end
            button:isHovered(mouse.x, mouse.y)
        end
        UI.pauseButton:isHovered(mouse.x, mouse.y)
        if SETTINGS.easyPlacementMode then
            UI.placeTurret:isHovered(mouse.x, mouse.y)
        end
        --updateMap
        local tile = UTIL.getTileAt(game.gameState.map, mouse.x, mouse.y)
        if tile and tile.type ~= 1 then
            currentTile.inbounds = true
            --do backwards conversion for 'snap' feel
            currentTile.x = (tile.x - 1) * SETTINGS.TILE_SIZE
            currentTile.y = (tile.y - 1) * SETTINGS.TILE_SIZE
        else
            currentTile.inbounds = false
        end

        --enemies
        for _,enemy in pairs(game.gameState.enemies) do
            enemy:update(dt, game.gameState)
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
        for _,turret in pairs(game.gameState.turrets) do
            turret:update(dt, game.gameState)
            turret:target(game.gameState)
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
        game.gameState.waves:update(dt, game.gameState)
    else
        for _,button in pairs(UI.pause) do
            button:isHovered(mouse.x, mouse.y)
        end
    end
end

function lib:keypressed(key)
    if key == "lshift" then
        SHIFT = true
    end

    if key == "escape" then
       PAUSE = not PAUSE
    end
end

function lib:keyreleased(key)
    if key == "lshift" then
        SHIFT = false
    end
end


function lib:mousereleased(x,y,button)
    if button ~= ENUMS.CLICK.LEFT then return end

    if SETTINGS.easyPlacementMode and EASY_PLACEMENT.dragging then
        EASY_PLACEMENT.dragging = false
    end
end

---@param gameState GAME.GAMESTATE
---@param x any
---@param y any
---@param dx any
---@param dy any
function lib:mousemoved(gameState, x, y, dx, dy)
    ---sanity check for inside map?
    -- if SETTINGS.easyPlacementMode and gameState.placementMode then
    -- end
end
---touch support
function lib:touchpressed(game, id, x, y, dx, dy, pressure)
    self.mousepressed(game, x, y, 1)
end
function lib:touchreleased(id, x, y, dx, dy, pressure)
    self:mousereleased(x, y, 1)
end
function lib:touchmoved(id, x, y, dx, dy, pressure)
    self:mousemoved(x, y, dx, dy)
end

return lib