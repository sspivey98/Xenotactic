--[[
INSTRUCTIONS:

Player clicks UI turret
confirm user has enough $
the left mouse now has the turret in hover
tilemap displays green/red if turret can be placed there
outline of range is drawn as a red dotted line in a circle
user left clicks a spot (top left)
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
    assert(type(o.position) == "table")
    assert(type(o.position.x) == "number" and type(o.position.y) == "number")
    o.cost = o.cost or 0
    o.sell = o.sell or 0
    o.range = o.range or 0
    o.speed = o.speed or 0
    o.damage = o.damage or 0
    o.image = o.image or ""
    return o
end

function lib:set(name, cost)
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