---@class entryBox
---@field protected x integer
---@field protected y integer
---@field protected width integer
---@field protected height integer
---@field private text string
---@field private selected boolean is the box in focus
---@field private cursorPos integer position in text
---@field private cursorBlink number timer
local lib = {}

---@param o {x:integer,y:integer,height:integer,width:integer}
---@return entryBox
function lib:new(o)
    local obj = {
        x = o.x,
        y = o.y,
        width = o.width,
        height = o.height,
        text = "",
        selected = false,
        cursorPos = 0,
        cursorBlink = 0,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function lib:draw()
    local font = love.graphics.getFont()
    local textHeight = font:getHeight()
    -- Draw box background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 3, 3)

    -- Highlight border blue if selected
    if self.selected then
        love.graphics.setColor(0.3, 0.6, 1)
        love.graphics.setLineWidth(2)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 3, 3)
    love.graphics.setLineWidth(1)

    -- Draw text
    love.graphics.setColor(1, 1, 1)
    local padding = 8
    local textY = self.y + (self.height - textHeight) / 2
    love.graphics.print(self.text, self.x + padding, textY)

    -- Draw blinking cursor if selected
    if self.selected and self.cursorBlink < 0.5 then
        local textBeforeCursor = self.text:sub(1, self.cursorPos)
        local cursorX = self.x + padding + font:getWidth(textBeforeCursor)
        love.graphics.line(cursorX, textY, cursorX, textY + textHeight)
    end

    --reset
    love.graphics.setColor(1, 1, 1)
end

function lib:update() end

---@param x integer
---@param y integer
---@param button integer
---@return boolean
function lib:mousePressed(x,y,button)
    if button == 1 then
        if x >= self.x and x <= self.x+self.width and
           y >= self.y and y <= self.y+self.height then
            self.selected = true
            return true
        else
            self.selected = false
        end
    end
    return false
end

---@param key string
function lib:keyPressed(key)
    if not self.selected then return end

    if key == "backspace" then
        if self.cursorPos > 0 then
            self.text = self.text:sub(1, self.cursorPos-1)..self.text:sub(self.cursorPos+1)
            self.cursorPos = self.cursorPos - 1
        end
    elseif key == "delete" then
        if self.cursorPos < #self.text then
            self.text = self.text:sub(1, self.cursorPos-1)..self.text:sub(self.cursorPos+2)
        end
    elseif key == "left" then
        self.cursorPos = math.max(0, self.cursorPos-1)
    elseif key == "right" then
        self.cursorPos = math.min(#self.text, self.cursorPos+1)
    elseif key == "home" then
        self.cursorPos = 0
    elseif key == "end" then
        self.cursorPos = #self.text
    elseif key == "return" or key == "kpenter" then
        self.selected = false
    end

    self.cursorBlink = 0
end

function lib:textInput(text)
    if self.selected then
        self.text = self.text:sub(1,self.cursorPos)..text..self.text:sub(self.cursorPos+1)
        self.cursorPos = self.cursorPos + #text
        self.cursorBlink = 0
    end
end

---@return string
function lib:getText()
    return self.text
end

function lib:clear()
    self.text = ""
    self.cursorPos = 0
end

return lib