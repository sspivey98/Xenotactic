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
    o.image = nil
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