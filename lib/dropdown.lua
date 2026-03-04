---@class dropdown
---@field protected x integer
---@field protected y integer
---@field protected width integer
---@field protected height integer
---@field options string[]
---@field selectedIndex? integer item in dropdown list selected
---@field hoveredIndex? integer|nil
---@field isOpen boolean dropdown is showing options
---@field colors dropdown.colors
local lib = {}

---@alias color number[]
---@class dropdown.colors
---@field button color
---@field buttonHover color
---@field dropdown color
---@field optionHover color
---@field text color
---@field border color

---dropdown constructor
---@param o {x:integer,y:integer,height:integer,width:integer,options:string[]}
---@param colors? dropdown.colors
---@return dropdown
function lib:new(o, colors)
    assert(o.options[1])
    if not colors then
        colors = {
            button = {0.3, 0.3, 0.3},
            buttonHover = {0.4, 0.4, 0.4},
            dropdown = {0.25, 0.25, 0.25},
            optionHover = {0.4, 0.4, 0.5},
            text = {1, 1, 1},
            border = {0.6, 0.6, 0.6}
        }
    end
    ---@type dropdown
    local obj = {
        x = o.x,
        y = o.y,
        width = o.width,
        height = o.height,
        options = o.options,
        selectedIndex = 1,
        hoveredIndex = nil,
        isOpen = false,
        colors = colors
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function lib:draw()
    local font = love.graphics.getFont()
    local textHeight = font:getHeight()

    --draw main
    if self.isOpen then
        love.graphics.setColor(self.colors.buttonHover)
    else
        love.graphics.setColor(self.colors.button)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 3, 3)

    --border
    love.graphics.setColor(self.colors.border)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 3, 3)

    --selected text
    love.graphics.setColor(self.colors.text)
    local selectedText = self.options[self.selectedIndex]
    love.graphics.print(selectedText, self.x+8, self.y + (self.height - textHeight)/2)

    --draw dropdown arrow
    local arrowX = self.x + self.width - 20
    local arrowY = self.y + self.height / 2
    if self.isOpen then
        -- Up arrow
        love.graphics.polygon("fill",
            arrowX, arrowY + 3,
            arrowX + 5, arrowY - 3,
            arrowX + 10, arrowY + 3
        )
    else
        -- Down arrow
        love.graphics.polygon("fill",
            arrowX, arrowY - 3,
            arrowX + 5, arrowY + 3,
            arrowX + 10, arrowY - 3
        )
    end

    --draw dropdown options
    if self.isOpen then
        local dropdownY = self.y + self.height

        for i, option in ipairs(self.options) do
            local optionY = dropdownY + (i-1)*self.height

            -- Option background
            if i == self.hoveredIndex then
                love.graphics.setColor(self.colors.optionHover)
            else
                love.graphics.setColor(self.colors.dropdown)
            end
            love.graphics.rectangle("fill", self.x, optionY, self.width, self.height)

            -- Option border
            love.graphics.setColor(self.colors.border)
            love.graphics.rectangle("line", self.x, optionY, self.width, self.height)

            -- Option text
            love.graphics.setColor(self.colors.text)
            love.graphics.print(
                option,
                self.x + 8,
                optionY + (self.height - textHeight) / 2
            )

            -- check mark for selected option
            if i == self.selectedIndex then
                love.graphics.setColor(0.4, 1, 0.4)
                love.graphics.circle("fill", self.x + self.width - 15, optionY + self.height / 2, 3)
            end
        end
    end
    love.graphics.setColor(1, 1, 1) -- Reset
end

---@param x integer
---@param y integer
---@param button integer
---@return boolean
function lib:mousePressed(x, y, button)
    if button ~= 1 then return false end

    --check if clicked
    if x >= self.x and x <= self.x + self.width and
       y >= self.y and y <= self.y + self.height then
        self.isOpen = not self.isOpen
        return true
    end

    if self.isOpen then
        local dropdownY = self.y + self.height

        for i,option in ipairs(self.options) do
            local optionY = dropdownY + (i-1)*self.height

            if x >= self.x and x <= self.x + self.width and
               y >= optionY and y <= optionY + self.height then
                self.selectedIndex = i
                self.isOpen = false
                return true
            end
        end

        self.isOpen = false
    end
    return false
end

---@param x integer
---@param y integer
function lib:mouseMoved(x, y)
    if not self.isOpen then
        self.hoveredIndex = nil
        return
    end

    local dropdownY = self.y + self.height
    self.hoveredIndex = nil

    for i,_ in ipairs(self.options) do
        local optionY = dropdownY + (i-1)*self.height

        if x >= self.x and x <= self.x + self.width and
           y >= optionY and y <= optionY + self.height then
            self.hoveredIndex = i
            break
        end
    end
end

return lib