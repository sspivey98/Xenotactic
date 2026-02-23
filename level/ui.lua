---@class level.UI
local lib = {}

local IMAGES = require('lib.images')
local ENUMS = require('enums')
local SETTINGS = require('settings')
local BUTTON = require('lib.button')
local UTIL = require('level.util')

--ui buttons load here
---@type {[string]:button.image}
lib.turrets = {}
---@type {[string]:button.text}
lib.buttons = {}

--padding
lib.padding = SETTINGS.TILE_SIZE

local frames = {
    [1] = IMAGES.library["healthbar_1"],
    [2] = IMAGES.library["healthbar_2"],
    [3] = IMAGES.library["healthbar_3"],
    [4] = IMAGES.library["healthbar_4"],
    [5] = IMAGES.library["healthbar_5"],
    [6] = IMAGES.library["healthbar_6"],
    [7] = IMAGES.library["healthbar_7"],
    [8] = IMAGES.library["healthbar_8"],
    [9] = IMAGES.library["healthbar_9"],
    [10] = IMAGES.library["healthbar_10"],
    [11] = IMAGES.library["healthbar_11"],
    [12] = IMAGES.library["healthbar_12"],
    [13] = IMAGES.library["healthbar_13"],
    [14] = IMAGES.library["healthbar_14"],
    [15] = IMAGES.library["healthbar_15"],
    [16] = IMAGES.library["healthbar_16"],
    [17] = IMAGES.library["healthbar_17"],
    [18] = IMAGES.library["healthbar_18"],
    [19] = IMAGES.library["healthbar_19"],
    [20] = IMAGES.library["healthbar_20"],
}

function lib:load()
    --create UI
    --turrets icons
    for i=1, 7 do
        local key = ENUMS.TURRET_TYPE[i]
        local img = IMAGES.library["icon_"..i]
        local scale = {
            x = 100 / img:getWidth(), --80 / 50
            y = 100 / img:getHeight()
        }
        local width = img:getWidth() * scale.x
        local height = img:getHeight() * scale.y

        --split x into 3 columns
        local x = SETTINGS.SCREEN.MAP.WIDTH
        if i % 3 == 1 then
            x = x + (SETTINGS.SCREEN.UI.WIDTH / 2) - 3*width / 2
        elseif i % 3 == 2 then
            x = x + (SETTINGS.SCREEN.UI.WIDTH / 2) - width / 2
        else
            x = x + (SETTINGS.SCREEN.UI.WIDTH / 2) + width / 2
        end
        --split y into 2 rows
        local y = 20 + (math.ceil(i / 3) - 1) * height + SETTINGS.SCREEN.HEIGHT/6 - height

        local turretButton = BUTTON:new(
            BUTTON.type.IMAGE,
            {
                x = x,
                y = y,
                width = width,
                height = height,
                image = img,
                color = {1,1,1},
                hoveredColor = {1,0.7,0.7},
                scale = {
                    x = scale.x,
                    y = scale.y
                }
            }
        )

        ---@cast turretButton button.image
        self.turrets[key] = turretButton
    end

    local sell_button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = SETTINGS.SCREEN.MAP.WIDTH + SETTINGS.SCREEN.UI.WIDTH/2 + self.padding,
            y = SETTINGS.SCREEN.HEIGHT - 3*self.padding,
            width = SETTINGS.SCREEN.UI.WIDTH / 2 - 2*self.padding,
            height = 2*self.padding,
            color = {0.3, 0.3, 0.3},
            text = "SELL"
        }
    )

    local upgrade_button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = SETTINGS.SCREEN.MAP.WIDTH + self.padding,
            y = SETTINGS.SCREEN.HEIGHT - 3*self.padding,
            width = SETTINGS.SCREEN.UI.WIDTH / 2 - 2*self.padding,
            height = 2*self.padding,
            color = {0.3, 0.3, 0.3},
            text = "UPGRADE"
        }
    )

    local send_wave = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = SETTINGS.SCREEN.MAP.WIDTH + SETTINGS.SCREEN.UI.WIDTH/2 + self.padding,
            y = SETTINGS.SCREEN.HEIGHT/2 - 2*self.padding,
            width = SETTINGS.SCREEN.UI.WIDTH / 2 - 2*self.padding,
            height = 2*self.padding,
            color = {0.3, 0.3, 0.3},
            textColor = ENUMS.UPGRADE_COLORS.CYAN,
            text = "SEND WAVE"
        }
    )

    ---@cast sell_button button.text
    ---@cast upgrade_button button.text
    ---@cast send_wave button.text

    self.buttons["sell"] = sell_button
    self.buttons["upgrade"] = upgrade_button
    self.buttons["send_wave"] = send_wave
end

---draw health bar frame
---@param health integer 1-20
function lib:drawHealthBar(health, x, y)
    love.graphics.setColor{1,1,1}
    love.graphics.draw(
        frames[health],
        x,
        y,
        0,
        1.5,
        1.5
    )
end

---draw current money
---@param money integer
function lib:drawMoney(money)
    local text = "Money: $"..money
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    local x = SETTINGS.SCREEN.WIDTH - textWidth - self.padding/2
    local y = self.padding/2

    --background box
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x - 5, y - 5, textWidth + 10, textHeight + 10, 5, 5)

    --draw money
    love.graphics.setColor(1, 0.84, 0)
    love.graphics.print(text, x, y)

    love.graphics.setColor(1, 1, 1) -- Reset color
end

---@param gameState GAME.GAMESTATE
function lib:drawCurrentWaveInfo(gameState)
    --draw box outline
    love.graphics.setColor{0, 0, 0, 0.7}
    love.graphics.rectangle(
        "fill",
        SETTINGS.SCREEN.MAP.WIDTH + self.padding,
        SETTINGS.SCREEN.HEIGHT / 2 + self.padding,
        SETTINGS.SCREEN.UI.WIDTH / 2 - 2*self.padding,
        SETTINGS.SCREEN.HEIGHT / 4 - 2*self.padding,
        5,
        5
    )
    if gameState.round > 0 then
        local enemiesAmount = UTIL.tableLength(gameState.enemies)
        local enemyValue = gameState.waves.waves[gameState.round].value
        local enemyType = gameState.waves.waves[gameState.round].enemies
        local enemyHealth = gameState.waves.waves[gameState.round].health
    end
end

---@param gameState GAME.GAMESTATE
function lib:drawNextWaveInfo(gameState)
    --draw box outline
    love.graphics.setColor{0, 0, 0, 0.7}
    love.graphics.rectangle(
        "fill",
        SETTINGS.SCREEN.MAP.WIDTH + SETTINGS.SCREEN.UI.WIDTH / 2 + self.padding,
        SETTINGS.SCREEN.HEIGHT / 2 + self.padding,
        SETTINGS.SCREEN.UI.WIDTH / 2 - 2*self.padding,
        SETTINGS.SCREEN.HEIGHT / 4 - 2*self.padding,
        5,
        5
    )
end

---@param gameState GAME.GAMESTATE
function lib:drawSelectedTurret(gameState)
    --draw box outline
    love.graphics.setColor{0, 0, 0, 0.8}
    love.graphics.rectangle(
        "fill",
        SETTINGS.SCREEN.MAP.WIDTH + self.padding,
        3*SETTINGS.SCREEN.HEIGHT / 4 - self.padding/2,
        SETTINGS.SCREEN.UI.WIDTH / 2 - 2*self.padding,
        SETTINGS.SCREEN.HEIGHT / 4 - 2*self.padding,
        5,
        5
    )
end

---@param gameState GAME.GAMESTATE
function lib:drawSelectedTurretUpgrade(gameState)
    --draw box outline
    love.graphics.setColor{0, 0, 0, 0.8}
    love.graphics.rectangle(
        "fill",
        SETTINGS.SCREEN.MAP.WIDTH + SETTINGS.SCREEN.UI.WIDTH / 2 + self.padding,
        3*SETTINGS.SCREEN.HEIGHT / 4 - self.padding/2,
        SETTINGS.SCREEN.UI.WIDTH / 2 - 2*self.padding,
        SETTINGS.SCREEN.HEIGHT / 4 - 2*self.padding,
        5,
        5
    )
end

return lib

