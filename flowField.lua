--[[
Generate a vector map of what direction (next tile) an enemy should go to next

flowField is a 2D array of directions (up, left, down, right), where the key is the [x][y] coordinate
    If a tile has a turret or wall, it is marked as blocked
When game in is session, there will always be two vector maps
--]]
local ENUMS = require('enums')
local UTIL = require('level.util')
---@class FLOWFIELD
---@field direction ENUMS.FLOWFIELD
---@field level table[]
---@field map table[]
---@field costMap table[]
---@field enabled boolean
---@overload fun(level: table[], direction: ENUMS.FLOWFIELD): FLOWFIELD
local lib = setmetatable({},
    {
        __call = function(class, level, direction)
            ---@cast class FLOWFIELD
            return class:new(level, direction)
        end
    }
)

---initialize the grid
---@param level number[][] - 2D array of current map
---@param direction ENUMS.FLOWFIELD - ENUMS.FLOWFIELD latitude or longitude
---@param enabled? boolean
function lib:new(level, direction, enabled)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.level = level  --2D array of map as flowField
    o.direction = direction
    o.enabled = enabled or true
    if direction == ENUMS.FLOWFIELD.LATITUDE then
        --only take up and down (place X's along all left/right side)
        for y=1, #level do
            o.level[y][1] = 1 --left
            o.level[y][#level[y]] = 1 --right
        end
    elseif direction == ENUMS.FLOWFIELD.LONGITUDE then
        --only take left and right (place X's along all top/bottom side)
        for x=1, #level[1] do
            o.level[1][x] = 1
            o.level[#level][x] = 1
        end
    end
    o.costMap = {}
    return o --? maybe set in gameState without return o?
end


---Mark tile blocked when turret placed. Given top left turret position
---@param x number x coordinate in tile coordinate
---@param y number y coordinate in tile coordinate
---@param isCoordinate? boolean optional flag to convert x,y into tile coordinates
function lib:setBlocked(x, y, isCoordinate)
    if isCoordinate then
        local pos = UTIL.getTileAt(self.map, x,y)
        if pos then
            x = pos.x
            y = pos.y
        end
    end

    self.level[y][x] = ENUMS.TILES.TURRET
    self.level[y+1][x] = ENUMS.TILES.TURRET
    self.level[y][x+1] = ENUMS.TILES.TURRET
    self.level[y+1][x+1] = ENUMS.TILES.TURRET
    self:calculate()
end

---Mark tile unused after a turret is sold - given top left turret position
---@param x number x coordinate in tile coordinate
---@param y number y coordinate in tile coordinate
---@param isCoordinate? boolean optional flag to convert x,y into tile coordinates
function lib:setEmpty(x, y, isCoordinate)
    if isCoordinate then
        local pos = UTIL.getTileAt(self.map, x,y)
        if pos then
            x = pos.x
            y = pos.y
        end
    end

    self.level[y][x] = ENUMS.TILES.EMPTY
    self.level[y+1][x] = ENUMS.TILES.EMPTY
    self.level[y][x+1] = ENUMS.TILES.EMPTY
    self.level[y+1][x+1] = ENUMS.TILES.EMPTY
    self:calculate()
end

---getter function
---@param x number x coordinate in tile coordinates
---@param y number y coordinate in tile coordinates
---@return ENUMS.FLOWFIELD.TILE
function lib:getDirection(x, y)
    return self.map[y][x]
end

---debug function
---@param map ENUMS.FLOWFIELD.TILE[][]
---@param vector boolean If true print vector map, else print cost map
local function printField(map, vector)
    local DIRS = {
        BLOCKED = "X",
        GOAL = "O",
        LEFT = "<",
        RIGHT = ">",
        UP = "^",
        DOWN = "V"
    }

    if vector then
        print("=== VECTOR MAP ===")
        for x=1,#map do
            local row = ""
            for y=1,#map[1] do
                if map[x][y] == ENUMS.FLOWFIELD.TILE.BLOCKED then
                    row = row..DIRS.BLOCKED.." "
                elseif map[x][y] == ENUMS.FLOWFIELD.TILE.GOAL then
                    row = row..DIRS.GOAL.." "
                elseif map[x][y] == ENUMS.FLOWFIELD.TILE.UP then
                    row = row..DIRS.UP.." "
                elseif map[x][y] == ENUMS.FLOWFIELD.TILE.DOWN then
                    row = row..DIRS.DOWN.." "
                elseif map[x][y] == ENUMS.FLOWFIELD.TILE.LEFT then
                    row = row..DIRS.LEFT.." "
                elseif map[x][y] == ENUMS.FLOWFIELD.TILE.RIGHT then
                    row = row..DIRS.RIGHT.." "
                end
            end
            print(row)
        end
    else
        print("=== COST MAP ===")
        for x=1,#map do
            local row = ""
            for y=1,#map[1] do
                if map[x][y] == ENUMS.FLOWFIELD.TILE.BLOCKED then
                    row = row.." X "
                elseif map[x][y] == ENUMS.FLOWFIELD.TILE.GOAL then
                    row = row.." O "
                elseif map[x][y] == math.huge then
                    row = row.. " # "
                else
                    row = row..string.format("%3d", map[x][y])
                end
            end
            print(row)
        end
    end
end

local DIRS = {
    { x = 0, y = -1 }, --up
    { x = 0, y = 1 }, --down
    { x = -1, y = 0 }, --left
    { x = 1, y = 0 } --right
}
---Dijkstra's algorithm
---A: Find the tile with LOWEST cost in open list
---B: Remove it from open list (we're processing it now)
---C: Mark it as closed (so we don't process it again)
---D: Look at all 4 neighbors (DIRS)
---E: Update neighbor costs if we found a better path
---@param level number[][] 2D array of map; return value overwrites this
---@return table costMap 2D array of each tile's cost
local function Dijkstra(level)
    local map = {}
    local goal = {}

    for x = 1, #level do
        map[x] = {}
        for y = 1, #level[1] do
            if level[x][y] == ENUMS.TILES.EMPTY or
                level[x][y] == ENUMS.TILES.SPAWN or
                level[x][y] == ENUMS.TILES.PATHWAY then
                map[x][y] = math.huge --inf
            elseif level[x][y] == ENUMS.TILES.GOAL then
                map[x][y] = ENUMS.FLOWFIELD.TILE.GOAL
                table.insert(goal, { x=x, y=y, cost=0 })
            else
                map[x][y] = ENUMS.FLOWFIELD.TILE.BLOCKED
            end
        end
    end

    local processed = {} --hashmap for completed tiles
    --Dijkstra from goal outward
    while #goal > 0 do
        local min = 1
        for i = 2, #goal do
            if goal[i].cost < goal[min].cost then
                min = i
            end
        end
        --remove lowest code node off of goal list
        local curr = table.remove(goal, min)

        local key = curr.y * 10000 + curr.x
        if not processed[key] then
            --check neighbors
            for _, DIR in ipairs(DIRS) do
                local nx = curr.x + DIR.x
                local ny = curr.y + DIR.y
                --bounds check
                if nx >= 1 and nx <= #map and
                ny >= 1 and ny <= #map[1] and
                map[nx][ny] ~= ENUMS.FLOWFIELD.TILE.BLOCKED then
                    --add one for new direction explored
                    local newCost = map[curr.x][curr.y] + 1

                    if newCost < map[nx][ny] then
                        map[nx][ny] = newCost
                        table.insert(goal, { x = nx, y = ny, cost = newCost })
                    end
                end
            end
            processed[key] = true
        end
    end

    --printField(costMap, false)
    return map
end

---check to make sure turret to be added doesn't block pathing
---@param x number x coordinate in tile coordinates
---@param y number y coordinate in tile coordinates
---@return boolean
function lib:checkPath(x,y)
    --copy self.level
    local map = UTIL:deepCopy(self.level)

    --place new turret down on copy
    map[y][x] = ENUMS.TILES.TURRET
    map[y+1][x] = ENUMS.TILES.TURRET
    map[y][x+1] = ENUMS.TILES.TURRET
    map[y+1][x+1] = ENUMS.TILES.TURRET

    --run Dijkstra's
    local costMap = Dijkstra(map)

    --if any tiles contain infinity, return false.
    for x1=1,#costMap do
        for y1=1,#costMap[1] do
            if costMap[x1][y1] == math.huge then
                return false
            end
        end
    end
    return true
end

---calc the flow field and save to self.map. Takes the self.level description and uses Dijkstra's to create a cost map.
---From the cost map, we create a flow field map which is saved in self.map.
function lib:calculate()
    --generate costMap
    self.costMap = Dijkstra(self.level)

    --[[
    Generate direction vectors from cost maps
    for each tile, find which neighbor has the LOWEST cost
    That neighbor is the "next step" toward the goal
    --]]

    local flowField = {}
    for x=1, #self.costMap do
        flowField[x] = {}
        for y=1, #self.costMap[1] do
            if self.costMap[x][y] == ENUMS.FLOWFIELD.TILE.BLOCKED then
                flowField[x][y] = ENUMS.FLOWFIELD.TILE.BLOCKED
            elseif self.costMap[x][y] == ENUMS.FLOWFIELD.TILE.GOAL then
                flowField[x][y] = ENUMS.FLOWFIELD.TILE.GOAL
            else
                local MIN_COST = math.huge
                local DIRECTION = {x=0,y=0}
                --check lowest value in each direction
                for _,DIR in ipairs(DIRS) do
                    local nx = x + DIR.x
                    local ny = y + DIR.y

                    if (nx >= 1 and nx <= #self.costMap) and
                       (ny >= 1 and ny <= #self.costMap[1]) and
                       self.costMap[nx][ny] ~= ENUMS.FLOWFIELD.TILE.BLOCKED then
                        if self.costMap[nx][ny] < MIN_COST then
                            MIN_COST = self.costMap[nx][ny]
                            DIRECTION = {x=DIR.x, y=DIR.y}
                        end
                    end
                end

                --normalize direction
                if DIRECTION.x == 0 and DIRECTION.y == 0 then
                   flowField[x][y] = ENUMS.FLOWFIELD.TILE.BLOCKED
                elseif DIRECTION.y == -1 then
                    flowField[x][y] = ENUMS.FLOWFIELD.TILE.LEFT
                elseif DIRECTION.y == 1 then
                    flowField[x][y] = ENUMS.FLOWFIELD.TILE.RIGHT
                elseif DIRECTION.x == -1 then
                    flowField[x][y] = ENUMS.FLOWFIELD.TILE.UP
                elseif DIRECTION.x == 1 then
                    flowField[x][y] = ENUMS.FLOWFIELD.TILE.DOWN
                end
            end
        end
    end

    --printField(flowField, true)
    self.map = flowField
end

return lib
