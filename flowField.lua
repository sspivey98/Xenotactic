--[[
Generate a vector map of what direction (next tile) an enemy should go to next

flowField is a KV object of directions (up, left, down, right), where the key is the xy coordinate
    If a tile has a turret, it is marked as blocked
When game in is session, there will always be two vector maps
--]]

local lib = {}

--initialize the grid
function lib:new(gameState)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.map = {}
    o.goal = {}
    return o
end

--Mark tiles as blocked/unblocked when turrets placed/sold
function lib.setBlocked(x, y) end

--getter function
function lib.getDirection(x, y) end

--main function to calc the flow field
function lib.calculate()
    --get goal position
    --initialize cost map
    --set goal cost to 0
    --Dijkstra from goal outward
    --Generate direction vectors from cost maps
end

return lib