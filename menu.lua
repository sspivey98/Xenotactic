--main menu
local IMAGES = require('lib.images')

local lib = {}

lib.Buttons = {
    Play = {
        width = 150,
        height = 50,
        x = 325,
        y = 300,
        text = "Play",
        hovered = false,
        pressed = false
    },
    Quit = {
        width = 150,
        height = 50,
        x = 325,
        y = 350,
        text = "Quit",
        hovered = false,
        pressed = false
    }

}

function lib.update()
    local mouseX, mouseY = love.mouse.getPosition()
    lib.Buttons.Play.hovered = mouseX >= lib.Buttons.Play.x and mouseX <= (lib.Buttons.Play.x + lib.Buttons.Play.width) and
            mouseY >= lib.Buttons.Play.y and mouseY <= (lib.Buttons.Play.y + lib.Buttons.Play.height)
    lib.Buttons.Quit.hovered = mouseX >= lib.Buttons.Quit.x and mouseX <= (lib.Buttons.Quit.x + lib.Buttons.Quit.width) and
            mouseY >= lib.Buttons.Quit.y and mouseY <= (lib.Buttons.Quit.y + lib.Buttons.Quit.height)
end

function lib.drawMainMenu(game)
    -- Background
    splash_screen = IMAGES.library["title_screen"]
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(splash_screen, 0, 0, 0, 800 / splash_screen:getWidth(), 600 / splash_screen:getHeight())
    
    --draw buttons
    for name,button in pairs(lib.Buttons) do
        -- Draw button rectangle
        local bgColor = {0.5, 0.5, 0.5}

        if button.hovered then
            bgColor = {0.7, 0.7, 0.7}  -- Gray color
        end

        --button background
        love.graphics.setColor(bgColor)  -- Gray color
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        
        -- Draw button border
        love.graphics.setColor(0, 0, 0)  -- Black color
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)

        -- Draw button text
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(button.text)
        local textHeight = font:getHeight()
        love.graphics.print(button.text, 
                        button.x + (button.width - textWidth) / 2, 
                        button.y + (button.height - textHeight) / 2)
    end

end

return lib