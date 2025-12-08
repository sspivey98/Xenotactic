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

local game

--initialize function
function love.load()
    love.window.setTitle("Tower Defense")
    love.window.setMode(1280, 720)

    game = GAME.initGame()
    love.graphics.setNewFont("/assets/fonts/11_Visitor_TT1_BRK.ttf", 16)
    SETTINGS.load()
    MENU.load()
end

--update the state of the game every frame
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
        LEVEL.update(game, dt)
    elseif game.state == GAME.STATES.GAME_OVER then
    end
end

--left or right mouse button is clicked
function love.mousepressed(x, y, mouseButton)
    if game.state == GAME.STATES.MENU then
        if mouseButton == ENUMS.CLICK.LEFT then
            --print("You left clicked at: ("..x..", "..y..")")
            if x >= MENU.Buttons.Play.x and x <= (MENU.Buttons.Play.x + MENU.Buttons.Play.width) and
                y >= MENU.Buttons.Play.y and y <= (MENU.Buttons.Play.y + MENU.Buttons.Play.height) then
                (SOUNDS.library["button_press"]):play()
                LEVEL_SELECT.load()
                game.state = GAME.STATES.LEVEL_SELECT
                print("Moving game state to level select")
            end
            if x >= MENU.Buttons.Quit.x and x <= (MENU.Buttons.Quit.x + MENU.Buttons.Quit.width) and
                y >= MENU.Buttons.Quit.y and y <= (MENU.Buttons.Quit.y + MENU.Buttons.Quit.height) then
                love.event.quit()
            end
        end
    elseif game.state == GAME.STATES.LEVEL_SELECT then
        if mouseButton == ENUMS.CLICK.LEFT then
            for index, level in pairs(LEVEL_SELECT.Levels) do
                if x >= level.x and x <= (level.x + level.width) and
                    y >= level.y and y <= (level.y + level.height) then
                    --load level
                    (SOUNDS.library["button_press2"]):play()
                    local map = MAPS["level_"..index]
                    game.gameState = GAME.newGame{
                        level = index,
                        map = map,
                        path1 = FLOWFIELD:new(map, ENUMS.FLOWFIELD.LONGITUDE),
                        path2 = FLOWFIELD:new(map, ENUMS.FLOWFIELD.LATITUDE)
                    }
                    LEVEL.load(index)
                    game.state = GAME.STATES.GAME
                    print("Selected level: " .. index)
                    break
                end
            end
        end
    elseif game.state == GAME.STATES.GAME then
        --game logic
        LEVEL.mousepressed(game, x, y, mouseButton)
    end
end

--draw on the screen every frame
function love.draw()
    if game.state == GAME.STATES.MENU then
        MENU.draw(game)
    elseif game.state == GAME.STATES.LEVEL_SELECT then
        LEVEL_SELECT.drawLevelSelect()
    elseif game.state == GAME.STATES.GAME then
        LEVEL.draw(game)
    elseif game.state == GAME.STATES.GAME_OVER then
    else
        --error
    end
end
