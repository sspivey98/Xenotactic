--Select Level UI
local lib = {}
local IMAGES = require('lib.images')
local BUTTON = require('lib.button')
local SETTINGS = require('settings')

---@type button.image[]
lib.Levels = {}

---load level
function lib.load()
    --add width and heights to level selections
    for i=1, 6 do
        local img = IMAGES.library["level_"..i]
        local scaleX = 200 / img:getWidth()
        local scaleY = 200 / img:getHeight()
        local width = img:getWidth() * scaleX
        local height = img:getHeight() * scaleY
        --split y into 2 rows
        local y = (math.ceil(i / 3) - 1) * (SETTINGS.SCREEN.HEIGHT / 3) + height / 2

        --split x into 3 columns
        local x
        if i % 3 == 1 then
            x = (SETTINGS.SCREEN.WIDTH / 4) - width
        elseif i % 3 == 2 then
            x = (2 * SETTINGS.SCREEN.WIDTH / 4) - width / 2
        else
            x = (3 * SETTINGS.SCREEN.WIDTH / 4)
        end

        ---@type button.image
        local button = BUTTON:new(
            BUTTON.type.IMAGE,
            {
                x = x,
                y = y,
                width = width,
                height = height,
                image = img,
                scale = {x=scaleX,y=scaleY},
                color = {1, 1, 1},
                hoveredColor = {1, 0.7, 0.7}
            }
        )

        lib.Levels[i] = button
    end
end

function lib.update()
    local mouseX, mouseY = love.mouse.getPosition()
    for _,level in pairs(lib.Levels) do
        level:isHovered(mouseX, mouseY)
    end
end

---draw levels
function lib.drawLevelSelect()
    -- Background
    love.graphics.setColor(0.15, 0.25, 0.35)
    love.graphics.rectangle("fill", 0, 0, SETTINGS.SCREEN.WIDTH, SETTINGS.SCREEN.HEIGHT)

    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SELECT LEVEL", SETTINGS.SCREEN.WIDTH / 2 - 200, 50, 200, "center", 0, 2)

    --draw levels
    for _,level in pairs(lib.Levels) do
        level:draw()
    end
end

return lib