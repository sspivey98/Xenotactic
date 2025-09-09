local lib = {}

function lib:new()
    local o = {
        position = {
            x = 0,
            y = 0
        },
        image = nil
    }
    setmetatable(self, o)
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