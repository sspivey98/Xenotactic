local GAME = require('game')
local DRAW = require('draw')
local TURRET = require('turret')
local NAV = require('nav')
local MENU = require('menu')
local LEVEL_SELECT = require('level.select')
local LEVEL = require('level.main')
local SOUNDS = require('lib.sounds')
local IMAGES = require('lib.images')

local game

function love.load()
    love.window.setTitle("Tower Defense")
    love.window.setMode(800, 600)

    game = GAME.newGame()

    love.graphics.setNewFont("/assets/fonts/11_Visitor_TT1_BRK.ttf", 16)
end

function love.update()
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
        LEVEL.update()
    elseif game.state == GAME.STATES.GAME_OVER then
    end

end

local click = {
    left = 1,
    right = 2
}

--left or right mouse button is clicked
function love.mousepressed(x, y, mouseButton)
    if game.state == GAME.STATES.MENU then
        if mouseButton == click.left then
            --print("You left clicked at: ("..x..", "..y..")")
            if x >= MENU.Buttons.Play.x and x <= (MENU.Buttons.Play.x + MENU.Buttons.Play.width) and
                y >= MENU.Buttons.Play.y and y <= (MENU.Buttons.Play.y + MENU.Buttons.Play.height) then
                    (SOUNDS.library["button_press"]):play()
                    game.state = GAME.STATES.LEVEL_SELECT
                    print("Moving game state to level select")
            end
            if x >= MENU.Buttons.Quit.x and x <= (MENU.Buttons.Quit.x + MENU.Buttons.Quit.width) and
                y >= MENU.Buttons.Quit.y and y <= (MENU.Buttons.Quit.y + MENU.Buttons.Quit.height) then
                    love.event.quit()
            end
        end
    elseif game.state == GAME.STATES.LEVEL_SELECT then
        if mouseButton == click.left then
            for index,level in pairs(LEVEL_SELECT.Levels) do
                if x >= level.x and x <= (level.x + level.width) and
                    y >= level.y and y <= (level.y + level.height) then
                        --load level
                        (SOUNDS.library["button_press2"]):play()
                        game.level = index
                        game.state = GAME.STATES.GAME
                        LEVEL.init(index)
                        print("Selected level: "..index)
                end
            end
        end
    elseif game.state == GAME.STATES.GAME then
        --game logic
    end
end

function love.draw()
    if game.state == GAME.STATES.MENU then
        MENU.drawMainMenu(game)
    elseif game.state == GAME.STATES.LEVEL_SELECT then
        LEVEL_SELECT.drawLevelSelect()
    elseif game.state == GAME.STATES.GAME then
        NAV.drawNav(game)
        LEVEL.draw()
    elseif game.state == GAME.STATES.GAME_OVER then
    else
        --error
    end
end