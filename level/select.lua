local lib = {}
local SOUNDS = require('lib.sounds')
local IMAGES = require('lib.images')
local SETTINGS = require('settings')

lib.Levels = {}

function lib.load()
    --add width and heights to level selections
    for i=1, 6 do
        local level = {
            img = IMAGES.library["level_"..i],
            hovered = false,
            wasHovered = false
        }
        level.scaleX = 200 / level.img:getWidth()
        level.scaleY = 200 / level.img:getHeight()
        level.width = level.img:getWidth() * level.scaleX
        level.height = level.img:getHeight() * level.scaleY

        --split x into 3 columns
        if i % 3 == 1 then
            level.x = (SETTINGS.SCREEN.WIDTH / 4) - level.width
        elseif i % 3 == 2 then
            level.x = (2 * SETTINGS.SCREEN.WIDTH / 4) - level.width / 2
        else
            level.x = (3 * SETTINGS.SCREEN.WIDTH / 4)
        end

        --split y into 2 rows
        level.y = (math.ceil(i / 3) - 1) * (SETTINGS.SCREEN.HEIGHT / 3) + level.height / 2
        table.insert(lib.Levels, level)
    end
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
    love.graphics.printf("SELECT LEVEL", SETTINGS.SCREEN.WIDTH / 2 - 200, 50, 200, "center", 0, 2)

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