--main menu
local IMAGES = require('lib.images')
local SETTINGS = require('settings')
local lib = {}

lib.Buttons = {
    Play = {
        text = "Play",
        hovered = false,
        pressed = false
    },
    Quit = {
        text = "Quit",
        hovered = false,
        pressed = false
    }

}

--initialize buttons
function lib.load()
    for _,button in pairs(lib.Buttons) do
        button.width = 150
        button.height = 50
        button.x = SETTINGS.SCREEN.WIDTH / 2 - button.width / 2 
        button.y = SETTINGS.SCREEN.HEIGHT / 2
        if button.text == "Quit" then
            button.y = button.y + button.height + 5   
        end
    end
end

function lib.update()
    local mouseX, mouseY = love.mouse.getPosition()
    lib.Buttons.Play.hovered = mouseX >= lib.Buttons.Play.x and mouseX <= (lib.Buttons.Play.x + lib.Buttons.Play.width) and
            mouseY >= lib.Buttons.Play.y and mouseY <= (lib.Buttons.Play.y + lib.Buttons.Play.height)
    lib.Buttons.Quit.hovered = mouseX >= lib.Buttons.Quit.x and mouseX <= (lib.Buttons.Quit.x + lib.Buttons.Quit.width) and
            mouseY >= lib.Buttons.Quit.y and mouseY <= (lib.Buttons.Quit.y + lib.Buttons.Quit.height)
end

function lib.draw(game)
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