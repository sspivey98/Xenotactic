local DROPDOWN = require('lib.dropdown')
local BUTTON = require('lib.button')
local SETTINGS = require('settings')

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
    local o = {
        x = 250,
        y = 100,
        width = 200,
        height = 40,   -- height per item
        options = {"1280x720", "1600x900", "1920x1080"},
    }
    local button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = 50,
            y = 200,
            width = 200,
            height = 40,
            text = "Confirm"
        }
    )
    self.dropdown = DROPDOWN:new(o)
    self.button = button
end
function lib:update()
    local mouseX, mouseY = love.mouse.getPosition()
    self.button:isHovered(mouseX, mouseY)
end
function lib:draw()
    love.graphics.setColor(1,1,1)
    self.button:draw()
    self.dropdown:draw()
end

function lib:mousepressed(x,y,mouseButton)
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
    end
end

return lib