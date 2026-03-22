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
---@type {[string]:button.text}
lib.pause = {}

--padding
lib.padding = SETTINGS.TILE_SIZE

local frames = {
    [0] = IMAGES.library["healthbar_0"],
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

    local yes_button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = (SETTINGS.SCREEN.WIDTH - 300)/2 + self.padding,
            y = (SETTINGS.SCREEN.HEIGHT - 150)/2 + 4*self.padding,
            width = 100,
            height = 40,
            text = "YES",
            color = ENUMS.UPGRADE_COLORS.GREEN
        }
    )
    local no_button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = (SETTINGS.SCREEN.WIDTH - 300)/2 + 7*self.padding,
            y = (SETTINGS.SCREEN.HEIGHT - 150)/2 + 4*self.padding,
            width = 100,
            height = 40,
            text = "NO",
            color = ENUMS.UPGRADE_COLORS.RED
        }
    )

    ---@cast yes_button button.text
    ---@cast no_button button.text
    self.pause["yes_button"] = yes_button
    self.pause["no_button"] = no_button
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

---draw wave timer
---@param gameState GAME.GAMESTATE
function lib:drawTimer(gameState)
    local timer = -1
    if gameState.round > 0 then
        timer = math.floor(gameState.waves.waves[gameState.round].timer)
    end

    local text = "Timer: "..timer.." s"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    local x = SETTINGS.SCREEN.MAP.WIDTH - textWidth - self.padding/2
    local y = self.padding/2

    --background box
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x - 5, y - 5, textWidth + 10, textHeight + 10, 5, 5)

    --draw text
    love.graphics.setColor(ENUMS.UPGRADE_COLORS.CYAN)
    love.graphics.print(text, x, y)

    love.graphics.setColor(1, 1, 1) -- Reset color
end

function lib:drawRound(gameState)
    local text = "Round: "..gameState.round
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    local x = self.padding/2
    local y = self.padding/2

    --background box
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x - 5, y - 5, textWidth + 10, textHeight + 10, 5, 5)

    --draw text
    love.graphics.setColor(ENUMS.UPGRADE_COLORS.CYAN)
    love.graphics.print(text, x, y)

    love.graphics.setColor(1, 1, 1) -- Reset color
end

---@param gameState GAME.GAMESTATE
function lib:drawEnemyCounter(gameState)
    local text = "Enemies: "..UTIL.tableLength(gameState.enemies)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    local x = SETTINGS.SCREEN.MAP.WIDTH - self.padding/2 - textWidth
    local y = SETTINGS.SCREEN.HEIGHT - self.padding

    --background box
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x - 5, y - 5, textWidth + 10, textHeight + 10, 5, 5)

    --draw text
    love.graphics.setColor(ENUMS.UPGRADE_COLORS.RED)
    love.graphics.print(text, x, y)

    love.graphics.setColor(1, 1, 1) -- Reset color
end

---@param gameState GAME.GAMESTATE
function lib:drawSelectedTurret(gameState)
    local box = {
        x = SETTINGS.SCREEN.MAP.WIDTH + self.padding,
        y = SETTINGS.SCREEN.HEIGHT / 2 + self.padding/2,
        width = SETTINGS.SCREEN.UI.WIDTH / 2 - 2*self.padding,
        height = SETTINGS.SCREEN.HEIGHT / 2 - 4*self.padding
    }
    --draw box outline
    love.graphics.setColor{0, 0, 0, 0.8}
    love.graphics.rectangle("fill", box.x, box.y, box.width, box.height, 5, 5)
    love.graphics.setColor{0.5, 0.5, 0.5}
    love.graphics.rectangle("line", box.x, box.y, box.width, box.height, 5, 5)
    if gameState.selectedTurret and gameState.selectedTurretType ~= "WALL" then
        local damage = gameState.selectedTurret.damage
        local range = gameState.selectedTurret.range
        local sell = gameState.selectedTurret.value
        local speed = gameState.selectedTurret.speed

        -- Title
        love.graphics.setColor(ENUMS.UPGRADE_COLORS.CYAN)
        love.graphics.print("Selected: "..gameState.selectedTurretType, box.x + self.padding/2, box.y + self.padding/2)
        love.graphics.setColor(ENUMS.UPGRADE_COLORS.YELLOW)
        love.graphics.print("Damage: "..damage, box.x + self.padding/2, box.y + 2*self.padding)
        love.graphics.print("Speed: "..speed, box.x + self.padding/2, box.y + 3*self.padding)
        love.graphics.print("Range: "..range, box.x + self.padding/2, box.y + 4*self.padding)
        love.graphics.print("Sell: "..sell, box.x + self.padding/2, box.y + 5*self.padding)
    end
    love.graphics.setColor(1, 1, 1) -- Reset color
end

---@param gameState GAME.GAMESTATE
function lib:drawSelectedTurretUpgrade(gameState)
    local box = {
        x = SETTINGS.SCREEN.MAP.WIDTH + SETTINGS.SCREEN.UI.WIDTH / 2 + self.padding,
        y = SETTINGS.SCREEN.HEIGHT / 2 + self.padding/2,
        width = SETTINGS.SCREEN.UI.WIDTH / 2 - 2*self.padding,
        height = SETTINGS.SCREEN.HEIGHT / 2 - 4*self.padding
    }
    --draw box outline
    love.graphics.setColor{0, 0, 0, 0.8}
    love.graphics.rectangle("fill", box.x, box.y, box.width, box.height, 5, 5)
    love.graphics.setColor{0.5, 0.5, 0.5}
    love.graphics.rectangle("line", box.x, box.y, box.width, box.height, 5, 5)

    if gameState.selectedTurret and gameState.selectedTurretType ~= "WALL" then
        local level = gameState.selectedTurret.level + 1
        if level <= 6 then
            love.graphics.setColor(ENUMS.UPGRADE_COLORS.CYAN)
            love.graphics.print("Upgrade: level "..level, box.x + self.padding/2, box.y + self.padding/2)
            love.graphics.setColor(ENUMS.UPGRADE_COLORS.YELLOW)
            local turret = ENUMS.UPGRADE_PATH[gameState.selectedTurretType]["LEVEL"..level]
            love.graphics.print("Cost: "..turret.cost, box.x + self.padding/2, box.y + 2*self.padding)
            love.graphics.print("Damage: "..turret.damage, box.x + self.padding/2, box.y + 3*self.padding)
            love.graphics.print("Range: "..turret.range, box.x + self.padding/2, box.y + 4*self.padding)
            love.graphics.print("Sell: "..turret.value, box.x + self.padding/2, box.y + 5*self.padding)
        end
    end
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function lib:drawPauseMenu()
    --dim background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, SETTINGS.SCREEN.WIDTH, SETTINGS.SCREEN.HEIGHT)

    --menu box
    local boxWidth = 300
    local boxHeight = 150
    local boxX = (SETTINGS.SCREEN.WIDTH - boxWidth) / 2
    local boxY = (SETTINGS.SCREEN.HEIGHT - boxHeight) / 2

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10, 10)

    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 10, 10)

    -- Draw text
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local quitText = "Quit?"
    local textWidth = font:getWidth(quitText)
    love.graphics.print(quitText, boxX + (boxWidth - textWidth) / 2, boxY + 30)

    self.pause["yes_button"]:draw()
    self.pause["no_button"]:draw()

    love.graphics.setColor(1, 1, 1)
end


---for caching purposes
local enemies_sprite_sheet = IMAGES.library["enemies"]
local enemyQuads = {}
local function getEnemyQuad(index)
    if not enemyQuads[index] then
        local spriteSize = 32
        enemyQuads[index] = love.graphics.newQuad(
            (index - 1) * spriteSize, -- x
            0,                        -- y 
            spriteSize,               -- width
            spriteSize,               -- height
            enemies_sprite_sheet:getDimensions()
        )
    end
    return enemyQuads[index]
end

---draw current wave enemy sprite in bottom left
---@param gameState GAME.GAMESTATE
function lib:drawCurrentEnemy(gameState)
    local text = "Current:"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    local x = self.padding/2
    local y = SETTINGS.SCREEN.HEIGHT - self.padding

    --background box
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", x - 5, y - 5, textWidth + 10, textHeight + 10, 5, 5)

    --draw text
    love.graphics.setColor(ENUMS.UPGRADE_COLORS.CYAN)
    love.graphics.print(text, x, y)
    --draw sprite
    if gameState.round > 0 then
        local wave = gameState.waves.waves[gameState.round]

        local index = 0
        for i=1,#ENUMS.ENEMY_TYPE do
            if ENUMS.ENEMY_TYPE[i] == wave.enemyType then
                index = i
                break
            end
        end

        if gameState.round > 0 then

            local spriteSize = 32
            local spriteX = x + textWidth + 5
            local spriteY = SETTINGS.SCREEN.HEIGHT - self.padding - textHeight
            -- Background box for sprite
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill",
                spriteX - 5,
                spriteY - 5,
                spriteSize * SETTINGS.scale*.75 + 10,
                spriteSize * SETTINGS.scale*.75 + 10,
                5, 5
            )

            -- Draw enemy sprite
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(
                enemies_sprite_sheet,
                getEnemyQuad(index),
                spriteX,
                spriteY,
                0,
                SETTINGS.scale*.75,
                SETTINGS.scale*.75
            )
        end
    end

    love.graphics.setColor(1, 1, 1) -- Reset color
end

return lib

