local DROPDOWN = require('lib.dropdown')
local BUTTON = require('lib.button')
local ENTRYBOX = require('lib.entryBox')
local SETTINGS = require('settings')
local IMAGES = require('lib.images')
local ENUMS = require('enums')
local MENU = require('menu')

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

--print password success vars
lib.unlockMessage = ""
lib.unlockMessageTimer = 0

function lib:load()
    --reset password ack on load
    self.unlockMessage = ""
    self.unlockMessageTimer = 0

    local x = SETTINGS.SCREEN.WIDTH / 2
    local y = 100
    local w = 300
    local h = 50
    local padding = 120

    self.backButton = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = 20,
            y = 20,
            width = 100,
            height = 40,
            text = "< Back"
        }
    )

    ---resolution
    local resolutionOptions = {"1280x720", "1600x900", "1920x1080"}
    local currentRes = SETTINGS.SCREEN.WIDTH .. "x" .. SETTINGS.SCREEN.HEIGHT
    local resolutionIndex = 1
    for i, res in ipairs(resolutionOptions) do
        if res == currentRes then
            resolutionIndex = i
            break
        end
    end
    self.dropdown = DROPDOWN:new({
        x = x - w/2,
        y = y,
        width = w,
        height = h,   -- height per item
        options = resolutionOptions,
        selectedIndex = resolutionIndex
    })

    ---audio
    local volumeOptions = {"100%", "80%", "60%", "40%", "20%", "0%"}
    local currentVolume = love.audio.getVolume()
    local volumeIndex = 1
    for i, vol in ipairs(volumeOptions) do
        local volNum = tonumber(vol:sub(1, -2)) / 100
        if math.abs(volNum - currentVolume) < 0.01 then -- Small tolerance for floating point
            volumeIndex = i
            break
        end
    end
    self.audio = DROPDOWN:new({
        x = x - w/2,
        y = y+padding,
        width = w,
        height = h,   -- height per item
        options = volumeOptions,
        selectedIndex = volumeIndex
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

    self.labels = {
        {text = "Resolution:", y = y - 30},
        {text = "Volume:", y = y + padding - 30},
        {text = "Password:", y = y + 2*padding - 30}
    }
end
function lib:update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    self.button:isHovered(mouseX, mouseY)
    self.backButton:isHovered(mouseX, mouseY)
    self.entryBox:update()

    --fade ack text after 3s
    if self.unlockMessageTimer > 0 then
        self.unlockMessageTimer = self.unlockMessageTimer - dt
        if self.unlockMessageTimer <= 0 then
            self.unlockMessage = ""
        end
    end
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

    --Draw labels
    love.graphics.setColor(1, 1, 1)
    for _, label in ipairs(self.labels) do
        love.graphics.printf(label.text, 0, label.y, SETTINGS.SCREEN.WIDTH, "center")
    end

    --Draw UI elements
    love.graphics.setColor(1,1,1)
    self.button:draw()
    self.backButton:draw()
    self.entryBox:draw()
    self.audio:draw()
    self.dropdown:draw()

    --password unlock text
    if self.unlockMessage ~= "" then
        local messageY = self.entryBox.y + self.entryBox.height + 10
        --green if success; red is invalid
        if string.find(string.lower(self.unlockMessage), "unlocked") then
            love.graphics.setColor(0.2, 1, 0.2)
        else
            love.graphics.setColor(1, 0.4, 0.4)
        end
        love.graphics.printf(self.unlockMessage, 0, messageY, SETTINGS.SCREEN.WIDTH, "center")
    end
    love.graphics.setColor(1, 1, 1)
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
        ---check password
        if self.entryBox:getText() then
            local password = string.lower(self.entryBox:getText())
            local found = false
            for num,pass in ipairs(ENUMS.Passwords) do
                if password == pass then
                    print("LEVEL "..num.." unlocked!")
                    self.unlockMessage = "LEVEL " .. num .. " UNLOCKED!"
                    self.unlockMessageTimer = 3
                    game.unlocked = num
                    found = true
                    break
                end
            end
            if not found and password ~= "" then
                self.unlockMessage = "Invalid password"
                self.unlockMessageTimer = 3
            end
        end

        ---change resolution, if applicable
        local res = self.dropdown.options[self.dropdown.selectedIndex]
        local i = res:find('x')
        local width = tonumber(res:sub(1,i-1))
        local height = tonumber(res:sub(i+1))
        if width and height then
            ---don't update when no change
            if width ~= SETTINGS.SCREEN.WIDTH or height ~= SETTINGS.SCREEN.HEIGHT then
                SETTINGS:setResolution(width,height)
                MENU.load()
                self:load()
            end
        end
    end
    if self.backButton:clicked(x,y,mouseButton) then
        game.state = ENUMS.STATES.MENU
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