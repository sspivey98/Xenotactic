local lib = {}

lib.STATES = {
    MENU = 0,
    LEVEL_SELECT = 1,
    GAME = 2,
    GAME_OVER = 3
}

function lib.newGame()
    local game = {
        money = 100,
        lives = 20,
        level = 0,
        round = 1,
        state = lib.STATES.MENU,
        turrets = {},
        deployed = {},
        selected = {0, 0},
        gridShow = false,
        grid = {},
        screen = {
			w = love.graphics.getWidth(),
			h = love.graphics.getHeight()
		}	
    }

    return game
end

return lib
