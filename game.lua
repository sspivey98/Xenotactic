---@alias GAME.GAMESTATE {money:number,map:ENUMS.TILES[][],path1:FLOWFIELD,path2:FLOWFIELD,lives:number,level:number,round:number,turrets:table,enemies:table,selected:number[],selectedTurretType:number,placementMode:boolean}
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
---@param o GAME.GAMESTATE
---@return GAME.GAMESTATE
function lib.newGame(o)
    local game = {
        money = o.money or 30,
        map = o.map or {},
        path1 = o.path1 or {}, --flowField left -> right
        path2 = o.path2 or {}, --flowField up -> down
        lives = 10,
        level = o.level or 1,
        round = 0,
        turrets = {},
        enemies = {},
        selected = {0, 0},
        selectedTurretType = nil,
        placementMode = false,
    }

    return game
end

return lib
