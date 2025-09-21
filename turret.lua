--[[
INSTRUCTIONS:

Player clicks UI turret
confirm user has enough $
the left mouse now has the turret in hover
tilemap displays green/red if turret can be placed there
user left clicks a spot
check if spot is okay
turret is placed at location
tilemap changes type at that location
draw function renders new type
    check turret type for specific rendering
--]]

--abstract interface for turret
local lib = {}

function lib:new(o)
    o = o or {}
    setmetatable(self, o)
    self.__index = self
    o.position = {
        x = 0,
        y = 0
    }
    o.cost = o.cost or 0
    o.sell = o.sell or 0
    o.range = o.range or 0
    o.speed = o.speed or 0
    o.damage = o.damage or 0
    o.image = o.image or ""
    return o
end

function lib:set()
    self.name = name
    self.cost = cost
end

function lib:select()
    local x = love.mouse.getX()
    local y = love.mouse.getY()
end

function lib:hover()
    local x = love.mouse.getX()
    local y = love.mouse.getY()

    if x > self.position.x and y < self.position.y then
        return true
    end
    return false
end

return lib