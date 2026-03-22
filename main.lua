if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then require("lldebugger").start() end
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

local game

---initialize function
function love.load(arg)
    love.window.setTitle("Xeno Tactic Remastered")
    love.window.setVSync(1)
    local resolution = SETTINGS.resolution
    love.window.setMode(resolution.WIDTH, resolution.HEIGHT)

    --enforce 60 FPS for now
    TICK.framerate = 60

    game = GAME.initGame()
    love.graphics.setNewFont("/assets/fonts/11_Visitor_TT1_BRK.ttf", 16)
    SETTINGS.load()
    MENU.load()
end

---update the state of the game every frame
---@param dt number delta between last frame and current
function love.update(dt)
    if game.state == ENUMS.STATES.MENU then
        MENU.update()
    elseif game.state == ENUMS.STATES.LEVEL_SELECT then
        LEVEL_SELECT.update()
    elseif game.state == ENUMS.STATES.GAME then
        LEVEL.update(game, dt)
    elseif game.state == ENUMS.STATES.SETTINGS then
        SETTINGSMENU:update()
    elseif game.state == ENUMS.STATES.GAME_OVER then
        GAMEOVER:update()
    elseif game.state == ENUMS.STATES.LEVEL_WIN then
        WINNER:update(game)
    end
end

---left or right mouse button is clicked
---@param x number x coordinate
---@param y number y coordinate
---@param mouseButton ENUMS.CLICK
function love.mousepressed(x, y, mouseButton)
    if game.state == ENUMS.STATES.MENU then
        if mouseButton == ENUMS.CLICK.LEFT then
            for key,button in pairs(MENU.Buttons) do
                if button:clicked(x, y, mouseButton) then
                    if key == "PLAY" then
                        (SOUNDS.library["button_press"]):play()
                        LEVEL_SELECT.load()
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
                if level:clicked(x, y, mouseButton) then
                    --load level
                    (SOUNDS.library["button_press2"]):play()
                    local map = MAPS["level_"..index]
                    local waves = require('level.waves')["level"..index]
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
                end
            end
        end
    elseif game.state == ENUMS.STATES.SETTINGS then
        SETTINGSMENU:mousepressed(x, y, mouseButton, game)
    elseif game.state == ENUMS.STATES.GAME then
        --game logic
        LEVEL.mousepressed(game, x, y, mouseButton)
    elseif game.state == ENUMS.STATES.LEVEL_WIN then
        WINNER:mousepressed(x, y, mouseButton, game)
    end
end

---draw on the screen every frame
function love.draw()
    if game.state == ENUMS.STATES.MENU then
        MENU.draw()
    elseif game.state == ENUMS.STATES.LEVEL_SELECT then
        LEVEL_SELECT.drawLevelSelect()
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
        end
    elseif game.state == ENUMS.STATES.LEVEL_WIN then
        if key == "escape" then
            game.state = ENUMS.STATES.LEVEL_SELECT
        end
    end
end