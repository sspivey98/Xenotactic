---game over screen
local SETTINGS = require('settings')
local IMAGES = require('lib.images')
local SOUNDS = require('lib.sounds')
local ENUMS = require('enums')
local lib = {}

function lib:load()
    SOUNDS.library["mission_failure_screen"]:play()
end
function lib:draw()
    --Background
    local splash_screen = IMAGES.library["game_over"]
    love.graphics.setColor(1, 1, 1)

    --center image
    local scaled = {
        x = SETTINGS.SCREEN.WIDTH / splash_screen:getWidth(),
        y = SETTINGS.SCREEN.HEIGHT / splash_screen:getHeight()
    }
    local scale = math.min(scaled.x, scaled.y)
    scaled.width = splash_screen:getWidth() * scale
    scaled.height = splash_screen:getHeight() * scale
    local imgX = (SETTINGS.SCREEN.WIDTH - scaled.width) / 2
    local imgY = (SETTINGS.SCREEN.HEIGHT - scaled.height) / 2

    love.graphics.draw(splash_screen, imgX, imgY, 0, scale, scale)
    love.graphics.setColor(1,1,1)

    local largeFont = love.graphics.newFont("/assets/fonts/11_Visitor_TT1_BRK.ttf", 72)
    love.graphics.setFont(largeFont)
    local text = "GAME OVER"
    local textWidth = largeFont:getWidth(text)
    local textHeight = largeFont:getHeight()

    local textX = (SETTINGS.SCREEN.WIDTH - textWidth) / 2
    local textY = (SETTINGS.SCREEN.HEIGHT - textHeight) / 2

    --background box
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle(
        "fill",
        textX - 20,
        textY - 20,
        textWidth + 40,
        textHeight + 40,
        10,
        10
    )
    love.graphics.setColor(ENUMS.UPGRADE_COLORS.YELLOW)
    love.graphics.print("GAME OVER", textX, textY)

    --reset
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(love.graphics.newFont("/assets/fonts/11_Visitor_TT1_BRK.ttf", 16))
end
function lib:update() end

return lib