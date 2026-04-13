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
---@field selectedEnemy ENEMY|nil
---@field selectedTurret TURRET|nil index of selected turret in turrets array
---@field selectedTurretType ENUMS.TURRET_TYPE
---@field placementMode boolean
---@field paused boolean game state is paused
---@field waves WAVES

---@alias game {state:GAME.STATES,screen:{x:number,y:number},gameState:GAME.GAMESTATE}
---@class GAME
---@field gameState GAME.GAMESTATE
---@field state GAME.STATES
---@field unlocked integer
local lib = {}

---initialize the menu
---@return GAME
function lib.initGame()
    local ENUMS = require('enums')
    local game = {
        state = ENUMS.STATES.MENU,
        screen = {
            w = love.graphics.getWidth(),
            h = love.graphics.getHeight()
        },
        gameState = nil, --newGame() goes here on level load
        unlocked = 1
    }

    return game
end

---create a new game state
---@param money? number
---@param level number level number
---@param map {}[]
---@param waves WAVES
---@param path1 FLOWFIELD
---@param path2? FLOWFIELD
---@return GAME.GAMESTATE
function lib.newGame(money, level, map, waves, path1, path2)
    local game = {
        money = money or 60,
        map = map or {},
        path1 = path1, --flowField left -> right
        path2 = path2, --flowField up -> down
        lives = 20,
        level = level or 1,
        round = 0,
        turrets = {},
        enemies = {},
        selectedTurret = nil,
        selectedTurretType = nil,
        selectedEnemy = nil,
        placementMode = false,
        paused = false,
        waves = waves,
    }

    return game
end

return lib
