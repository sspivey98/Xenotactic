--Select Level UI
local lib = {}
local IMAGES = require('lib.images')
local SOUNDS = require('lib.sounds')
local BUTTON = require('lib.button')
local MAPS = require('level.maps')
local SETTINGS = require('settings')

---@type button.image[]
lib.Levels = {}
lib.Level_MetaData = {}

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
            x = (SETTINGS.SCREEN.WIDTH / 4) - 1.5*width
        elseif i % 3 == 2 then
            x = (2 * SETTINGS.SCREEN.WIDTH / 4) - width
        else
            x = (3 * SETTINGS.SCREEN.WIDTH / 4) - 0.5*width
        end

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
        ---@cast button button.image
        lib.Levels[i] = button

        --level descriptions
        local metadata = MAPS.METADATA["level_"..i]
        local pad = 20
        local level_metadata = {
            [1] = {
                text = metadata.CATEGORY,
                x = x + width + pad,
                y = y + height/2,
            },
            [2] = {
                text = metadata.DESCRIPTION,
                x = x + width + pad,
                y = y  + height/2 + pad,
            },
            [3] = {
                text = metadata.LENGTH,
                x = x + width + pad,
                y = y  + height/2 + pad*2,
            }
        }
        lib.Level_MetaData[i] = level_metadata
    end
    SOUNDS.library["next_menu"]:play()
end

function lib.update()
    local mouseX, mouseY = love.mouse.getPosition()
    for _,level in pairs(lib.Levels) do
        level:isHovered(mouseX, mouseY)
    end
end

---draw levels
---@param game GAME
function lib:draw(game)
    --Background
    love.graphics.setColor(0.15, 0.25, 0.35)
    love.graphics.rectangle("fill", 0, 0, SETTINGS.SCREEN.WIDTH, SETTINGS.SCREEN.HEIGHT)

    --Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SELECT LEVEL", SETTINGS.SCREEN.WIDTH / 2 - 200, 50, 200, "center", 0, 2)

    --draw levels & metadata
    for i=1,6 do
        lib.Levels[i]:draw()

        local metadata = lib.Level_MetaData[i]
        love.graphics.setColor{0.9, 0.8, 0.1}
        love.graphics.printf(metadata[1].text, metadata[1].x, metadata[1].y, 200, "left")

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(metadata[2].text, metadata[2].x, metadata[2].y, 200, "left")

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(metadata[3].text, metadata[3].x, metadata[3].y, 200, "left")
    end

    --draw locks
    for i=1,6 do
        if i > game.unlocked then
            local level = lib.Levels[i]
            local lockX = level.x + level.width / 2
            local lockY = level.y + level.height / 2

            --draw simple padlock
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.setLineWidth(3)

            --shackle (top arc)
            love.graphics.arc("line", "open", lockX, lockY - 8, 12, math.pi, 0)

            --body (rounded rectangle)
            love.graphics.rectangle("fill", lockX - 15, lockY - 8, 30, 25, 4, 4)

            --keyhole
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.circle("fill", lockX, lockY + 2, 4)
            love.graphics.rectangle("fill", lockX - 2, lockY + 2, 4, 8)

            love.graphics.setLineWidth(1)
            level.color = {0.5,0.5,0.5}
            level.disabled = true
        end
    end
end

return lib