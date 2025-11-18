local lib = {}

lib.STATES = {
    MENU = 0,
    LEVEL_SELECT = 1,
    GAME = 2,
    GAME_OVER = 3
}

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

function lib.newGame(o)
    local game = {
        money = o.money or 30,
        lives = 10,
        level = o.level or 1,
        round = 0,
        turrets = {},
        enemies = {},
        selected = {0, 0},
        selectedTurretType = nil,
        placementMode = false
    }

    return game
end

return lib
