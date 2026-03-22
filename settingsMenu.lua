local DROPDOWN = require('lib.dropdown')
local BUTTON = require('lib.button')
local ENTRYBOX = require('lib.entryBox')
local SETTINGS = require('settings')
local IMAGES = require('lib.images')
local ENUMS = require('enums')

---@class settingsMenu
local lib = {}

--[[
4:3 
    - 800x600
    - 1024x768
16:9
    - 1280x720 
    - 1366x768
    - 1600x900 
    - 1920x1080
--]]
function lib:load()
    self.button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = 50,
            y = 200,
            width = 200,
            height = 40,
            text = "Confirm"
        }
    )
    self.dropdown = DROPDOWN:new({
        x = 250,
        y = 100,
        width = 200,
        height = 40,   -- height per item
        options = {"1280x720", "1600x900", "1920x1080"},
    })

    self.entryBox = ENTRYBOX:new({
        x = 450,
        y = 400,
        width = 200,
        height = 40,   -- height per item
    })
end
function lib:update()
    local mouseX, mouseY = love.mouse.getPosition()
    self.button:isHovered(mouseX, mouseY)
    self.entryBox:update()
end
function lib:draw()
    -- Background
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
    self.button:draw()
    self.dropdown:draw()
    self.entryBox:draw()
end

---@param x integer
---@param y integer
---@param mouseButton integer
---@param game GAME
function lib:mousepressed(x,y,mouseButton, game)
    self.dropdown:mousePressed(x,y,mouseButton)
    if self.button:clicked(x,y,mouseButton) then
        --change window
        local res = self.dropdown.options[self.dropdown.selectedIndex]
        local i = res:find('x')
        local width = tonumber(res:sub(1,i-1))
        local height = tonumber(res:sub(i+1))

        if width and height then
            SETTINGS:setResolution(width,height)
        end

        if self.entryBox:getText() then
            local password = string.lower(self.entryBox:getText())
            for num,pass in ipairs(ENUMS.Passwords) do
                if password == pass then
                    print("LEVEL "..num.." unlocked!")
                    game.unlocked = num
                end
            end
        end
    end
    self.entryBox:mousePressed(x,y,mouseButton)
end

function lib:textinput(text)
    self.entryBox:textInput(text)
end

function lib:keyPressed(key)
    self.entryBox:keyPressed(key)
end

return lib