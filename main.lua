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

local game

---initialize function
function love.load()
    love.window.setTitle("Tower Defense")
    love.window.setMode(1280, 720)

    game = GAME.initGame()
    love.graphics.setNewFont("/assets/fonts/11_Visitor_TT1_BRK.ttf", 16)
    SETTINGS.load()
    MENU.load()
end

---update the state of the game every frame
---@param dt number delta between last frame and current
function love.update(dt)
    if game.state == GAME.STATES.MENU then
        MENU.update()
    elseif game.state == GAME.STATES.LEVEL_SELECT then
        if love.keyboard.isDown("escape") then
            game.state = GAME.STATES.MENU
        end
        LEVEL_SELECT.update()
    elseif game.state == GAME.STATES.GAME then
        if love.keyboard.isDown("escape") then
            game.state = GAME.STATES.MENU
        end
        LEVEL.update(game.gameState, dt)
    elseif game.state == GAME.STATES.GAME_OVER then
    end
end

---left or right mouse button is clicked
---@param x number x coordinate
---@param y number y coordinate
---@param mouseButton ENUMS.CLICK
function love.mousepressed(x, y, mouseButton)
    if game.state == GAME.STATES.MENU then
        if mouseButton == ENUMS.CLICK.LEFT then
            for key,button in pairs(MENU.Buttons) do
                if button:clicked(x, y, mouseButton) then
                    if key == "PLAY" then
                        (SOUNDS.library["button_press"]):play()
                        LEVEL_SELECT.load()
                        game.state = GAME.STATES.LEVEL_SELECT
                        print("Moving game state to level select")
                    elseif key == "QUIT" then
                        love.event.quit()
                    end
                end
            end
        end
    elseif game.state == GAME.STATES.LEVEL_SELECT then
        if mouseButton == ENUMS.CLICK.LEFT then
            for index, level in pairs(LEVEL_SELECT.Levels) do
                if level:clicked(x, y, mouseButton) then
                    --load level
                    (SOUNDS.library["button_press2"]):play()
                    local map = MAPS["level_"..index]
                    local map_copy = UTIL:deepCopy(map)
                    game.gameState = GAME.newGame(
                        30,
                        index,
                        map_copy,
                        FLOWFIELD:new(map_copy, ENUMS.FLOWFIELD.LONGITUDE),
                        FLOWFIELD:new(map_copy, ENUMS.FLOWFIELD.LATITUDE)
                    )
                    LEVEL.load(index)
                    game.state = GAME.STATES.GAME
                    print("Selected level: " .. index)
                    break
                end
            end
        end
    elseif game.state == GAME.STATES.GAME then
        --game logic
        LEVEL.mousepressed(game.gameState, x, y, mouseButton)
    end
end

---draw on the screen every frame
function love.draw()
    if game.state == GAME.STATES.MENU then
        MENU.draw()
    elseif game.state == GAME.STATES.LEVEL_SELECT then
        LEVEL_SELECT.drawLevelSelect()
    elseif game.state == GAME.STATES.GAME then
        LEVEL.draw(game.gameState)
    elseif game.state == GAME.STATES.GAME_OVER then
    else
        --error
    end
end
