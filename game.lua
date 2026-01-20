---@class GAME.GAMESTATE
---@field money number
---@field map ENUMS.TILES[][]
---@field path1 FLOWFIELD
---@field path2 FLOWFIELD
---@field lives number
---@field level number
---@field round number
---@field turrets {[string]:TURRET}
---@field enemies {[string]:ENEMY}
---@field selected number[]
---@field selectedTurret TURRET|nil index of selected turret in turrets array
---@field selectedTurretType number
---@field placementMode boolean

---@alias game {state:GAME.STATES,screen:{x:number,y:number},gameState:GAME.GAMESTATE}
---@class GAME
---@field gameState GAME.GAMESTATE
local lib = {}

---@enum GAME.STATES
lib.STATES = {
    MENU = 0,
    LEVEL_SELECT = 1,
    GAME = 2,
    GAME_OVER = 3
}


---initialize the menu
---@return game
function lib.initGame()
    local game = {
        state = lib.STATES.MENU,
        screen = {
            w = love.graphics.getWidth(),
            h = love.graphics.getHeight()
        },
        gameState = nil --newGame() goes here on level load
    }

    return game
end

---create a new game state
---@param money? number
---@param level number level number
---@param map {}[]
---@param path1 FLOWFIELD
---@param path2? FLOWFIELD
---@return GAME.GAMESTATE
function lib.newGame(money, level, map, path1, path2)
    local game = {
        money = money or 30,
        map = map or {},
        path1 = path1 or {}, --flowField left -> right
        path2 = path2 or {}, --flowField up -> down
        lives = 10,
        level = level or 1,
        round = 0,
        turrets = {},
        enemies = {},
        selected = {0, 0},
        selectedTurret = nil,
        selectedTurretType = nil,
        placementMode = false,
    }

    return game
end

return lib
