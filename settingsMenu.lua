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
    local x = SETTINGS.SCREEN.WIDTH / 2
    local y = 100
    local w = 300
    local h = 50
    local padding = 120

    self.dropdown = DROPDOWN:new({
        x = x - w/2,
        y = y,
        width = w,
        height = h,   -- height per item
        options = {"1280x720", "1600x900", "1920x1080"},
    })

    self.audio = DROPDOWN:new({
        x = x - w/2,
        y = y+padding,
        width = w,
        height = h,   -- height per item
        options = {"100%", "80%", "60%", "40%", "20%", "0%"},
    })

    self.entryBox = ENTRYBOX:new({
        x = x - w/2,
        y = y+2*padding,
        width = w,
        height = h,   -- height per item
    })

    self.button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = x - w/2,
            y = y+3*padding,
            width = w,
            height = h,
            text = "Confirm"
        }
    )
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
    self.entryBox:draw()
    self.audio:draw()
    self.dropdown:draw()
end

---@param x integer
---@param y integer
---@param mouseButton integer
---@param game GAME
function lib:mousepressed(x,y,mouseButton, game)
    self.dropdown:mousePressed(x,y,mouseButton)
    if self.audio:mousePressed(x,y,mouseButton) then
        local res = self.audio.options[self.audio.selectedIndex]
        local sub = res:sub(1, -2)
        local num = tonumber(sub)/100
        love.audio.setVolume(num)
    end
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