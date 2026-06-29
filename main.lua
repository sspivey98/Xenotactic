if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then require("lldebugger").start() end
local VERSION = require('version')
local GAME = require('game')
local ENUMS = require('enums')
local MENU = require('menu')
local LEVEL_SELECT = require('level.select')
local LEVEL = require('level.main')
local SOUNDS = require('lib.sounds')
local SETTINGS = require('settings')
local MAPS = require('level.maps')
local FLOWFIELD = require('flowField')
local UTIL = require('level.util')
local TICK = require('lib.tick')
local SETTINGSMENU = require('settingsMenu')
local GAMEOVER = require('level.gameover')
local WINNER = require('level.winner')
local WAVES = require('level.waves')
local SAVE = require('lib.save')

local game

---initialize function
function love.load(arg)
    local saveData = SAVE:load()
    love.window.setTitle("Xenotactic v"..VERSION)
    love.window.setVSync(1)

    if SETTINGS.isMobile() then
        SETTINGS.easyPlacementMode = true
        local nativeWidth, nativeHeight = love.window.getDesktopDimensions()
        love.window.setMode(nativeWidth, nativeHeight, {
            fullscreen = true,
            fullscreentype = "desktop",
            resizable = false,
            highdpi = true
        })

        --figure best resolution for current size 20:9
        for _,resolution in ipairs(ENUMS.Resolutions) do
            if nativeWidth >= resolution.w and nativeHeight >= resolution.h then
                saveData.width = resolution.w
                saveData.height = resolution.h
                break
            end
        end

        --create canvas with smaller resolution 16:9
        SETTINGS.CANVAS.GAME = love.graphics.newCanvas(saveData.width, saveData.height)
        SETTINGS:setResolution(saveData.width, saveData.height)

        --offset to fit canvas into native screen
        local renderWidth, renderHeight = love.graphics.getDimensions()
        SETTINGS.CANVAS.SCALE = math.min(renderWidth / saveData.width, renderHeight / saveData.height)
        SETTINGS.CANVAS.OFFSET.x = (renderWidth - saveData.width * SETTINGS.CANVAS.SCALE) / 2
        SETTINGS.CANVAS.OFFSET.y = (renderHeight - saveData.height * SETTINGS.CANVAS.SCALE) / 2
    else
        love.window.setMode(saveData.width, saveData.height)
        SETTINGS:setResolution(saveData.width, saveData.height)
        SETTINGS.CANVAS.GAME = nil
    end

    --enforce 60 FPS for now
    TICK.framerate = 60
    love.audio.setVolume(saveData.volume)

    game = GAME.initGame(saveData.level)
    love.graphics.setNewFont("/assets/fonts/11_Visitor_TT1_BRK.ttf", 20)
    MENU.load()
end

---update the state of the game every frame
---@param dt number delta between last frame and current
function love.update(dt)
    if game.state == ENUMS.STATES.MENU then
        MENU.update()
    elseif game.state == ENUMS.STATES.LEVEL_SELECT then
        LEVEL_SELECT:update()
    elseif game.state == ENUMS.STATES.GAME then
        LEVEL.update(game, dt)
    elseif game.state == ENUMS.STATES.SETTINGS then
        SETTINGSMENU:update(dt)
    elseif game.state == ENUMS.STATES.GAME_OVER then
        GAMEOVER:update()
    elseif game.state == ENUMS.STATES.LEVEL_WIN then
        WINNER:update(game)
    end
end

---transpose canvas coordinates
local function screenToCanvasCoords(x,y)
    if not SETTINGS.CANVAS.GAME then
        return x,y
    end

    local cx = (x - SETTINGS.CANVAS.OFFSET.x) / SETTINGS.CANVAS.SCALE
    local cy = (y - SETTINGS.CANVAS.OFFSET.y) / SETTINGS.CANVAS.SCALE
    return cx, cy
end

---left or right mouse button is clicked
---@param x number x coordinate
---@param y number y coordinate
---@param mouseButton ENUMS.CLICK
function love.mousepressed(x, y, mouseButton)
    local cx, cy = screenToCanvasCoords(x,y)
    if game.state == ENUMS.STATES.MENU then
        if mouseButton == ENUMS.CLICK.LEFT then
            for key,button in pairs(MENU.Buttons) do
                if button:clicked(cx, cy, mouseButton) then
                    if key == "PLAY" then
                        (SOUNDS.library["button_press"]):play()
                        LEVEL_SELECT:load()
                        game.state = ENUMS.STATES.LEVEL_SELECT
                        print("Moving game state to level select")
                    elseif key == "SETTINGS" then
                        SOUNDS.library["button_press"]:play()
                        SETTINGSMENU:load()
                        game.state = ENUMS.STATES.SETTINGS
                    elseif key == "QUIT" then
                        love.event.quit()
                    end
                end
            end
        end
    elseif game.state == ENUMS.STATES.LEVEL_SELECT then
        if mouseButton == ENUMS.CLICK.LEFT then
            for index, level in pairs(LEVEL_SELECT.Levels) do
                if level:clicked(cx, cy, mouseButton) then
                    --load level
                    (SOUNDS.library["button_press2"]):play()
                    local map = MAPS["level_"..index]
                    WAVES:load()
                    local waves = WAVES["level"..index]
                    if index == 1 then
                        game.gameState = GAME.newGame(
                            60,
                            index,
                            UTIL:deepCopy(map),
                            waves,
                            FLOWFIELD:new(UTIL:deepCopy(map), ENUMS.FLOWFIELD.LONGITUDE)
                        )
                    else
                        game.gameState = GAME.newGame(
                            60,
                            index,
                            UTIL:deepCopy(map),
                            waves,
                            FLOWFIELD:new(UTIL:deepCopy(map), ENUMS.FLOWFIELD.LONGITUDE),
                            FLOWFIELD:new(UTIL:deepCopy(map), ENUMS.FLOWFIELD.LATITUDE)
                        )
                    end
                    local TILE_SET = MAPS.VISUAL_MAP["level_"..index]
                    LEVEL.load(index, TILE_SET)
                    game.state = ENUMS.STATES.GAME
                    print("Selected level: " .. index)
                    break
                else
                    LEVEL_SELECT:mousepressed(cx, cy, mouseButton, game)
                end
            end
        end
    elseif game.state == ENUMS.STATES.SETTINGS then
        SETTINGSMENU:mousepressed(cx, cy, mouseButton, game)
    elseif game.state == ENUMS.STATES.GAME then
        --game logic
        LEVEL.mousepressed(game, cx, cy, mouseButton)
    elseif game.state == ENUMS.STATES.LEVEL_WIN then
        if mouseButton == ENUMS.CLICK.LEFT then
            game.state = ENUMS.STATES.LEVEL_SELECT
            LEVEL_SELECT:load()
        end
    elseif game.state == ENUMS.STATES.GAME_OVER then
        if mouseButton == ENUMS.CLICK.LEFT then
            game.state = ENUMS.STATES.LEVEL_SELECT
            LEVEL_SELECT:load()
        end
    end
end

---draw on the screen every frame
function love.draw()
    if SETTINGS.CANVAS.GAME then
        love.graphics.setCanvas(SETTINGS.CANVAS.GAME)
        love.graphics.clear()
    end

    if game.state == ENUMS.STATES.MENU then
        MENU.draw()
    elseif game.state == ENUMS.STATES.LEVEL_SELECT then
        LEVEL_SELECT:draw(game)
    elseif game.state == ENUMS.STATES.GAME then
        LEVEL.draw(game.gameState)
    elseif game.state == ENUMS.STATES.SETTINGS then
        SETTINGSMENU:draw()
    elseif game.state == ENUMS.STATES.GAME_OVER then
        GAMEOVER:draw()
    elseif game.state == ENUMS.STATES.LEVEL_WIN then
        WINNER:draw()
    else
        --error
    end

    if SETTINGS.CANVAS.GAME then
        love.graphics.setCanvas()
        love.graphics.clear(0,0,0,1)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(SETTINGS.CANVAS.GAME, SETTINGS.CANVAS.OFFSET.x, SETTINGS.CANVAS.OFFSET.y, 0, SETTINGS.CANVAS.SCALE, SETTINGS.CANVAS.SCALE)
    end
end

function love.textinput(text)
    if game.state == ENUMS.STATES.SETTINGS then
        SETTINGSMENU:textinput(text)
    end
end

function love.keypressed(key)
    if game.state == ENUMS.STATES.GAME then
        LEVEL:keypressed(key)
    elseif game.state == ENUMS.STATES.LEVEL_SELECT then
        if key == "escape" then
            game.state = ENUMS.STATES.MENU
        end
    elseif game.state == ENUMS.STATES.SETTINGS then
        if key == "escape" then
            MENU.load()
            game.state = ENUMS.STATES.MENU
        end
        SETTINGSMENU:keyPressed(key)
    elseif game.state == ENUMS.STATES.GAME_OVER then
        if key == "escape" then
            game.state = ENUMS.STATES.LEVEL_SELECT
            LEVEL_SELECT:load()
        end
    elseif game.state == ENUMS.STATES.LEVEL_WIN then
        if key == "escape" then
            game.state = ENUMS.STATES.LEVEL_SELECT
            LEVEL_SELECT:load()
        end
    end
end

function love.keyreleased(key)
    if game.state == ENUMS.STATES.GAME then
        LEVEL:keyreleased(key)
    end
end

function love.mousereleased(x,y,button)
    local cx, cy = screenToCanvasCoords(x, y)
    if game.state == ENUMS.STATES.GAME then
        LEVEL:mousereleased(cx,cy,button)
    end
end

function love.mousemoved(x,y,dx,dy)
    local cx, cy = screenToCanvasCoords(x, y)
    local cdx = (1/SETTINGS.CANVAS.SCALE) * dx
    local cdy = (1/SETTINGS.CANVAS.SCALE) * dy
    if game.state == ENUMS.STATES.GAME then
        LEVEL:mousemoved(game.gameState,cx,cy,cdx,cdy)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    local cx, cy = screenToCanvasCoords(x, y)
    local cdx = (1/SETTINGS.CANVAS.SCALE) * dx
    local cdy = (1/SETTINGS.CANVAS.SCALE) * dy
    if game.state == ENUMS.STATES.GAME then
        LEVEL:touchpressed(game, id, cx, cy, cdx, cdy, pressure)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    local cx, cy = screenToCanvasCoords(x, y)
    local cdx = (1/SETTINGS.CANVAS.SCALE) * dx
    local cdy = (1/SETTINGS.CANVAS.SCALE) * dy
    if game.state == ENUMS.STATES.GAME then
        LEVEL:touchreleased(id, cx, cy, cdx, cdy, pressure)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    local cx, cy = screenToCanvasCoords(x, y)
    local cdx = (1/SETTINGS.CANVAS.SCALE) * dx
    local cdy = (1/SETTINGS.CANVAS.SCALE) * dy
    if game.state == ENUMS.STATES.GAME then
        LEVEL:touchmoved(id, cx, cy, cdx, cdy, pressure)
    end
end