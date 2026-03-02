--main menu
local IMAGES = require('lib.images')
local BUTTON = require('lib.button')
local SETTINGS = require('settings')

---@alias MENU.button {text:string,hovered:boolean,pressed:boolean,x:number,y:number,width:number,height:number}
---@class MENU
local lib = {}

---@type button.text[]
lib.Buttons = {}

---initialize buttons
function lib.load()
    local width = 150
    local height = 50

    local play_button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = SETTINGS.SCREEN.WIDTH / 2 - width / 2,
            y = SETTINGS.SCREEN.HEIGHT / 2,
            width = width,
            height = height,
            text = "PLAY"
        }
    )
    local settings_button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = SETTINGS.SCREEN.WIDTH / 2 - width / 2,
            y = SETTINGS.SCREEN.HEIGHT / 2 + height,
            width = width,
            height = height,
            text = "SETTINGS"
        }
    )
    local quit_button = BUTTON:new(
        BUTTON.type.TEXT,
        {
            x = SETTINGS.SCREEN.WIDTH / 2 - width / 2,
            y = SETTINGS.SCREEN.HEIGHT / 2 + 2*height,
            width = width,
            height = height,
            text = "QUIT"
        }
    )

    lib.Buttons["PLAY"] = play_button
    lib.Buttons["SETTINGS"] = settings_button
    lib.Buttons["QUIT"] = quit_button
end

---update state logic
function lib.update()
    local mouseX, mouseY = love.mouse.getPosition()
    for _,button in pairs(lib.Buttons) do
        button:isHovered(mouseX, mouseY)
    end
end

---draw
function lib.draw()
    -- Background
    local splash_screen = IMAGES.library["title_screen"]
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

    --draw buttons
    for _,button in pairs(lib.Buttons) do
        button:draw()
    end
end

return lib