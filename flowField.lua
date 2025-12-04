--[[
Generate a vector map of what direction (next tile) an enemy should go to next

flowField is a 2D array of directions (up, left, down, right), where the key is the [x][y] coordinate
    If a tile has a turret, it is marked as blocked
When game in is session, there will always be two vector maps
--]]
local ENUMS = require('enums')
local lib = {}

--initialize the grid
function lib:new(gameState)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.map = {} --2D array of map as flowField
    o.goal = {} --goal coordinates
    return o --? maybe set in gameState without return o?
end

--[[
Mark tile direction or blocking
@param1 x - x coordinate in tile coordinate
@param2 y - y coordinate in tile coordinate
@param3 direction - ENUMS.FLOWFIELD.TILE type
--]]
function lib:setDirection(x, y, direction)
    self.map[x][y] = direction
end

--getter function
function lib:getDirection(x, y)
    return self.map[x][y]
end

--main function to calc the flow field
function lib.calculate()
    --get goal position
    --initialize cost map
    --set goal cost to 0
    --Dijkstra from goal outward
    --Generate direction vectors from cost maps
end

return lib