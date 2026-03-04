local DROPDOWN = require('lib.dropdown')
local BUTTON = require('lib.button')
local ENTRYBOX = require('lib.entryBox')
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
    love.graphics.setColor(1,1,1)
    self.button:draw()
    self.dropdown:draw()
    self.entryBox:draw()
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

        if self.entryBox:getText() then
            local password = string.lower(self.entryBox:getText())
            if password == "7loopz" then
                print("LEVEL 2 unlocked!")
                --unlock level 1
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