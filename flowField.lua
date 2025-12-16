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
function lib:new(map, direction)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.map = map or {}  --2D array of map as flowField
    if direction == ENUMS.FLOWFIELD.LATITUDE then
        --only take up and down
    elseif direction == ENUMS.FLOWFIELD.LONGITUDE then
        --only take left and right
    end
    return o --? maybe set in gameState without return o?
end

--[[
Mark tile blocked when turret placed. Given top left turret position
@param1 x - x coordinate in tile coordinate
@param2 y - y coordinate in tile coordinate
@param3 direction - ENUMS.FLOWFIELD.TILE type
--]]
function lib:setBlocked(x, y)
    self.map[y][x] = ENUMS.TILES.TURRET
    self.map[y+1][x] = ENUMS.TILES.TURRET
    self.map[y][x+1] = ENUMS.TILES.TURRET
    self.map[y+1][x+1] = ENUMS.TILES.TURRET
    self:calculate()
end

--getter function
function lib:getDirection(x, y)
    return self.map[x][y]
end

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

--main function to calc the flow field
function lib:calculate()
    --initialize cost map
    local costMap = {}
    local goal = {}

    for x = 1, #self.map do
        costMap[x] = {}
        for y = 1, #self.map[1] do
            if self.map[x][y] == ENUMS.TILES.EMPTY or
                self.map[x][y] == ENUMS.TILES.SPAWN or
                self.map[x][y] == ENUMS.TILES.PATHWAY then
                costMap[x][y] = math.huge --inf
            elseif self.map[x][y] == ENUMS.TILES.GOAL then
                costMap[x][y] = ENUMS.FLOWFIELD.TILE.GOAL
                table.insert(goal, { x=x, y=y, cost=0 })
            else
                costMap[x][y] = ENUMS.FLOWFIELD.TILE.BLOCKED
            end
        end
    end

    local DIRS = {
        { x = 0, y = -1 }, --up
        { x = 0, y = 1 }, --down
        { x = -1, y = 0 }, --left
        { x = 1, y = 0 } --right
    }

    --[[
    A: Find the tile with LOWEST cost in open list
    B: Remove it from open list (we're processing it now)
    C: Mark it as closed (so we don't process it again)
    D: Look at all 4 neighbors (DIRS)
    E: Update neighbor costs if we found a better path
    --]]

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
                if nx >= 1 and nx <= #self.map and
                ny >= 1 and ny <= #self.map[1] and
                costMap[nx][ny] ~= ENUMS.FLOWFIELD.TILE.BLOCKED then
                    --add one for new direction explored
                    local newCost = costMap[curr.x][curr.y] + 1

                    if newCost < costMap[nx][ny] then
                        costMap[nx][ny] = newCost
                        table.insert(goal, { x = nx, y = ny, cost = newCost })
                    end
                end
            end
            processed[key] = true
        end
    end
    --printField(costMap, false)
    --[[
    Generate direction vectors from cost maps
    for each tile, find which neighbor has the LOWEST cost
    That neighbor is the "next step" toward the goal
    --]]

    local flowField = {}
    for x=1, #costMap do
        flowField[x] = {}
        for y=1, #costMap[1] do
            if costMap[x][y] == ENUMS.FLOWFIELD.TILE.BLOCKED then
                flowField[x][y] = ENUMS.FLOWFIELD.TILE.BLOCKED
            elseif costMap[x][y] == ENUMS.FLOWFIELD.TILE.GOAL then
                flowField[x][y] = ENUMS.FLOWFIELD.TILE.GOAL
            else
                local MIN_COST = math.huge
                local DIRECTION = {x=0,y=0}
                --check lowest value in each direction
                for _,DIR in ipairs(DIRS) do
                    local nx = x + DIR.x
                    local ny = y + DIR.y

                    if (nx >= 1 and nx <= #costMap) and
                       (ny >= 1 and ny <= #costMap[1]) and
                       costMap[nx][ny] ~= ENUMS.FLOWFIELD.TILE.BLOCKED then
                        if costMap[nx][ny] < MIN_COST then
                            MIN_COST = costMap[nx][ny]
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

    printField(flowField, true)
    return flowField
end

return lib
