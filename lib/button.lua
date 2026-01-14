---@class button
---@field protected x number
---@field protected y number
---@field protected width number
---@field protected height number
---@field protected color number[]
---@field hovered boolean
---@field protected wasHovered boolean
---@field protected hoveredColor number[]
local IButton = {}

local ENUMS = require('enums')
local SOUNDS = require('lib.sounds')

---button object constructor parameters
---@class button.options
---@field x number
---@field y number
---@field height number
---@field width number
---@field color? number[]
---@field hoveredColor? number[]

---button object constructor parameters
---@class button.image.options : button.options
---@field image any for image buttons only
---@field scale? {x?:number,y?:number} for image buttons only

---button object constructor parameters
---@class button.text.options : button.options
---@field text string
---@field textColor? number[]

---button constructor
---@param o button.options
---@return button
function IButton:new(o)
    assert(o.x and o.y and o.height and o.width)
    ---@type button
    local obj = {
        x = o.x,
        y = o.y,
        width = o.width,
        height = o.height,
        color = o.color or {0.3, 0.3, 0.3},
        hoveredColor = o.hoveredColor or {0.7,0.7,0.7},
        hovered = false,
        wasHovered = false
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---render button; abstract
function IButton:draw() end

---return if mouse is currently hovering
---@return boolean
function IButton:isHovered(x, y)
    self.wasHovered = self.hovered
    if x >= self.x and x <= self.x + self.width and
        y >= self.y and y <= self.y + self.height then
            self.hovered = true
            if not self.wasHovered then
                SOUNDS.library["button_hover"]:play()
            end
    else
        self.hovered = false
    end

    return self.hovered
end

---return if mouse has been left clicked
function IButton:clicked(x, y, button)
    if self:isHovered(x,y) then
        if button == ENUMS.CLICK.LEFT then
            return true
        end
    end
    return false
end

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--|       button.image         |
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

---@class button.image : button
---@field image any
---@field scale {x:number,y:number}
local IButtonImage = {}

---@param o button.image.options
---@return button.image
function IButtonImage:new(o)
    self.__index = self
    setmetatable(self, {__index = IButton})
    local obj = IButton:new(o)
    ---@cast obj button.image
    setmetatable(obj, self)
    obj.image = o.image
    obj.scale = {
        x = o.scale.x or 1,
        y = o.scale.y or 1
    }
    return obj
end

---override
function IButtonImage:draw()
    if self.hovered then
       love.graphics.setColor(self.hoveredColor)
    else
        love.graphics.setColor(self.color)
    end
    love.graphics.draw(
        self.image,
        self.x,
        self.y,
        0,
        self.scale.x,
        self.scale.y
    )
    --border
    love.graphics.setColor(0, 0, 0)  -- Black color
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--|        button.text         |
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

---@class button.text : button
---@field text string
---@field textColor number[]
---@field private textY number
local IButtonText = {}

---button with text constructor
---@param o button.text.options
---@return button.text
function IButtonText:new(o)
    self.__index = self
    setmetatable(self, {__index = IButton})
    local obj = IButton:new(o)
    ---@cast obj button.text
    setmetatable(obj, self)

    obj.text = o.text
    obj.textColor = o.textColor or {1,1,1}

    --center text anchor
    local font = love.graphics.getFont()
    local textHeight = font:getHeight()
    obj["textY"] = obj.y + (obj.height - textHeight) / 2
    return obj
end

---override
function IButtonText:draw()
    if self.hovered then
        love.graphics.setColor(self.hoveredColor)
    else
        love.graphics.setColor(self.color)
    end

    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.width,
        self.height
    )

    love.graphics.setColor(self.textColor)
    love.graphics.printf(
        self.text,
        self.x,
        self.textY,
        self.width,
        "center"
    )

    --border
    love.graphics.setColor(0, 0, 0)  -- Black color
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

---button constructor
---@class button.class

local lib = {}
---@enum button.type
lib.type = {
    TEXT = 0,
    IMAGE = 1
}

---@overload fun(self: button.class, t: 0, o: button.text.options): button.text
---@overload fun(self: button.class, t: 1, o: button.image.options): button.image
---@param t button.type type: `text` or `image`
---@param o button.text.options|button.image.options
---@return button
function lib:new(t, o)
    if t == self.type.TEXT then
        ---@cast o button.text.options 
        return IButtonText:new(o)
    elseif t == self.type.IMAGE then
        ---@cast o button.image.options
        return IButtonImage:new(o)
    else
        error("incorrect calling")
    end
end

return lib