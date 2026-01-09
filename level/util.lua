local SETTINGS = require('settings')

---@class UTIL
local lib = {}

---translates pixels to in-game coordinates
---@param map ENUMS.TILES[][]
---@param x number
---@param y number
---@return {x:number,y:number,type:number}|nil
function lib.getTileAt(map, x, y)
    local tileX = math.floor(x / SETTINGS.TILE_SIZE) + 1
    local tileY = math.floor(y / SETTINGS.TILE_SIZE) + 1

    --do bounds checks for inside map
    if (tileX < 1 or tileX > SETTINGS.map.Width) or (tileY < 1 or tileY > SETTINGS.map.Height) then
        return nil
    end

    local tile = {
        x = tileX,
        y = tileY,
        type = map[tileY][tileX]
    }
    return tile
end

---convert map tile coordinate to center pixel
function lib.getPixelAt(map, x, y) end

---check if tile is buildable, if there is a turret already, or if it blocks the enemy pathing
---currentTile needs {x,y}
---@param currentTile {x:number,y:number}
---@param gameState any
---@return boolean valid
function lib:isValidPlacement(currentTile, gameState)
    local tiles = {
        [1] = self.getTileAt(gameState.map, currentTile.x, currentTile.y),
        [2] = self.getTileAt(gameState.map, currentTile.x + SETTINGS.TILE_SIZE, currentTile.y),
        [3] = self.getTileAt(gameState.map, currentTile.x, currentTile.y + SETTINGS.TILE_SIZE),
        [4] = self.getTileAt(gameState.map, currentTile.x + SETTINGS.TILE_SIZE, currentTile.y + SETTINGS.TILE_SIZE)
    }

    --check four tiles -> tile type '0' is valid; make sure none are off the tilemap (returns nil)
    --check if tile is of default type
    for _, tile in ipairs(tiles) do
        if tile == nil then return false end
        if tile.type ~= 0 then return false end
    end

    --check if tile already has turret
    for _,turret in ipairs(gameState.turrets) do
        if not (currentTile.x + SETTINGS.TILE_SIZE < turret.position.x or  -- new turret is completely to the left
                currentTile.x > turret.position.x + SETTINGS.TILE_SIZE or  -- new turret is completely to the right
                currentTile.y + SETTINGS.TILE_SIZE < turret.position.y or  -- new turret is completely above
                currentTile.y > turret.position.y + SETTINGS.TILE_SIZE) then -- new turret is completely below
            return false
        end
    end

    --check to make sure Dijkstra's doesn't fail
    if gameState.path1:checkPath(tiles[1].x, tiles[1].y) and
    gameState.path2:checkPath(tiles[1].x, tiles[1].y)
    then
        return true
    else
        return false
    end
end

---make a deep copy of a table
---!WARNING! Does not handle circular references
---@param original table
---@return table copy 
function lib:deepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[self:deepCopy(key)] = self:deepCopy(value)
        end
        setmetatable(copy, self:deepCopy(getmetatable(original)))
    else
        -- for non-tables (numbers, strings, booleans, etc.)
        copy = original
    end
    return copy
end

return lib