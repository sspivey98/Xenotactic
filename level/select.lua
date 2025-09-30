local lib = {}
local SOUNDS = require('lib.sounds')
local IMAGES = require('lib.images')
local SETTINGS = require('settings')

lib.Levels = {
    [1] = {
        x = 100,
        y = 50,
        width = 0,
        height = 0,
        img = IMAGES.library["level_1"],
        hovered = false,
        wasHovered = false
    },
    [2] = {
        x = 500,
        y = 50,
        width = 0,
        height = 0,
        img = IMAGES.library["level_2"],
        hovered = false,
        wasHovered = false
    },
    [3] = {
        x = 100,
        y = 250,
        width = 0,
        height = 0,
        img = IMAGES.library["level_3"],
        hovered = false,
        wasHovered = false
    },
    [4] = {
        x = 500,
        y = 250,
        width = 0,
        height = 0,
        img = IMAGES.library["level_4"],
        hovered = false,
        wasHovered = false
    },
    [5] = {
        x = 100,
        y = 450,
        width = 0,
        height = 0,
        img = IMAGES.library["level_5"],
        hovered = false,
        wasHovered = false
    },
    [6] = {
        x = 500,
        y = 450,
        width = 0,
        height = 0,
        img = IMAGES.library["level_6"],
        hovered = false,
        wasHovered = false
    }
}
--add width and heights
for _, level in pairs(lib.Levels) do
    level.scaleX = 150 / level.img:getWidth()
    level.scaleY = 150 / level.img:getHeight()
    level.width = level.img:getWidth()
    level.height = level.img:getHeight()
end

function lib.update()
    local mouseX, mouseY = love.mouse.getPosition()
    for _,level in pairs(lib.Levels) do
        level.wasHovered = level.hovered
        level.hovered = mouseX >= level.x and mouseX <= (level.x + level.width) and
            mouseY >= level.y and mouseY <= (level.y + level.height)
        if level.hovered and not level.wasHovered then
            (SOUNDS.library["button_hover"]):play()
        end
    end
end

function lib.drawLevelSelect()
    -- Background
    love.graphics.setColor(0.15, 0.25, 0.35)
    love.graphics.rectangle("fill", 0, 0, SETTINGS.SCREEN.WIDTH, SETTINGS.SCREEN.HEIGHT)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SELECT LEVEL", 0, 50, 800, "center")

    --draw levels
    for key,level in pairs(lib.Levels) do
        -- Draw button rectangle
        local bgColor = {1, 1, 1} --white

        if level.hovered then
            bgColor = {1, 0.7, 0.7}  -- red/pink color tint
        end

        --button background
        love.graphics.setColor(bgColor)
        love.graphics.draw(level.img, level.x, level.y, 0, level.scaleX, level.scaleY)
    end
end

return lib