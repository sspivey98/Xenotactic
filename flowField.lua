--[[
Generate a vector map of what direction (next tile) an enemy should go to next

flowField is a 2D array of directions (up, left, down, right), where the key is the [x][y] coordinate
    If a tile has a turret or wall, it is marked as blocked
When game in is session, there will always be two vector maps
--]]
local ENUMS = require('enums')
local lib = {}

--[[
initialize the grid
@param1 map - 2D array of current map
@param2 direction - ENUMS.FLOWFIELD latitude or longitude
--]]
function lib:new(level, direction)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.level = level or {}  --2D array of map as flowField
    o.map = {}
    o.goal = {x=0,y=0} --goal coordinates
    if direction == ENUMS.FLOWFIELD.LATITUDE then
        o.goal.x = 17
        o.goal.y = 30
    elseif direction == ENUMS.FLOWFIELD.LONGITUDE then
        o.goal.x = 33
        o.goal.y = 15
    end
    return o    --? maybe set in gameState without return o?
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
function lib:calculate()
    --initialize cost map
    local costMap =  {}
    local max = #self.map[1] * #self.map + 1 --l x w
    for x=1, #self.map do
        costMap[x] = {}
        for y=1, #self.map[1] do
            if self.map[x][y] == ENUMS.TILES.EMPTY or
            self.map[x][y] == ENUMS.TILES.SPAWN then
                costMap[x][y] = max
            elseif self.map[x][y] == ENUMS.TILES.FINAL then
                costMap[x][y] = 0
            else
                costMap[x][y] = -1
            end
        end
    end

    --Dijkstra from goal outward

    --[[
    Generate direction vectors from cost maps
    for each tile, find which neighbor has the LOWEST cost
    That neighbor is the "next step" toward the goal
    --]]
end

return lib
