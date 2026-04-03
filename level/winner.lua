local SETTINGS = require('settings')
local IMAGES = require('lib.images')
local ENUMS  = require('enums')
local lib = {}


lib.text = "Congratulations!"
lib.body = ""
lib.password = ""
function lib:load() end
function lib:draw()
    --Background
    local splash_screen = IMAGES.library["default_background"]
    love.graphics.setColor(1, 1, 1)

    --center image
    local scaled = {
        x = SETTINGS.SCREEN.WIDTH / splash_screen:getWidth(),
        y = SETTINGS.SCREEN.HEIGHT / splash_screen:getHeight()
    }
    local scale = math.min(scaled.x, scaled.y)
    scaled.width = splash_screen:getWidth() * scale
    scaled.height = splash_screen:getHeight() * scale
    local x = (SETTINGS.SCREEN.WIDTH - scaled.width) / 2
    local y = (SETTINGS.SCREEN.HEIGHT - scaled.height) / 2

    love.graphics.draw(splash_screen, x, y, 0, scale, scale)
    love.graphics.setColor(1,1,1)

    local largeFont = love.graphics.newFont("assets/fonts/11_Visitor_TT1_BRK.ttf", 72)
    local mediumFont = love.graphics.newFont("assets/fonts/11_Visitor_TT1_BRK.ttf", 32)
    local smallFont = love.graphics.newFont("assets/fonts/11_Visitor_TT1_BRK.ttf", 24)

    local startY = SETTINGS.SCREEN.HEIGHT / 2 - 120

    -- Background box
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill",
        SETTINGS.SCREEN.WIDTH / 4,
        startY - 40,
        SETTINGS.SCREEN.WIDTH / 2,
        300,
        10, 10
    )

    --title
    love.graphics.setFont(largeFont)
    love.graphics.setColor(ENUMS.UPGRADE_COLORS.GREEN)
    love.graphics.printf(lib.text, 0, startY, SETTINGS.SCREEN.WIDTH, "center")

    --body
    love.graphics.setFont(mediumFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(lib.body, 0, startY + 100, SETTINGS.SCREEN.WIDTH, "center")

    --password
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 0.84, 0)
    love.graphics.printf(lib.password, 0, startY + 180, SETTINGS.SCREEN.WIDTH, "center")

    --reset
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont("assets/fonts/11_Visitor_TT1_BRK.ttf", 16))
end

---@param game GAME
function lib:update(game)
    if game.gameState.level == 6 then
        self.body = "THANKS FOR PLAYING!"
        self.password = ":)"
    end
    if self.password == "" then
        local unlock = game.gameState.level + 1
        self.body = "To unlock level "..unlock..", use the following password:"
        self.password = ENUMS.Passwords[unlock]
        game.unlocked = game.gameState.level + 1
    end
end

return lib