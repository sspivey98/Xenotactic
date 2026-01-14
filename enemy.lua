local ENUMS = require('enums')
local IMAGES = require('lib.images')

--[[
*ENEMY PATHING NOTES

pathing only updates on turret buy/sell
enemies will have different paths based on position and final

--]]

---enemy class
---@class ENEMY : EnemyData inherit properties of EnemyData
---@field position {x:number,y:number} absolute coordinates
---@field coords {x:number,y:number} tile coordinates
---@field moveAnimation {frames:table[],currentFrame:number,frameTime:number,timer:number,loop:boolean,death:boolean,dead:boolean}
---@field index number index in game.gameState.turrets
---@field orientation ENUMS.FLOWFIELD.TILE orientation of current sprite
---@field lastDirection ENUMS.FLOWFIELD.TILE
---@field flowField FLOWFIELD which flowField for the enemy to follow
---@field goal boolean mark enemy got to goal
---@overload fun(gameState: GAME.GAMESTATE, enemyType: number, flowField: FLOWFIELD, direction: ENUMS.FLOWFIELD): ENEMY
local lib = setmetatable({},
    {
        __call = function(class, gameState, enemyType, flowField, direction)
            ---@cast class ENEMY
            return class:new(gameState, enemyType, flowField, direction)
        end
    }
)

local SETTINGS = require('settings')
local enemies_sprite_sheet = IMAGES.library["enemies"]

---creates array of sprites for the enemy
---@private
local function enemyMoveFrames(enemyType)
    --480x128 -> 32x32
    local frames = {}
    local spriteSize = 32
    local frameCounter = enemyType > 3 and 4 or 3

    for i=1,frameCounter do
        frames[i] = love.graphics.newQuad(
            (enemyType-1)*spriteSize, --start x
            (i-1)*spriteSize, --start y
            spriteSize,--width
            spriteSize,--height
            enemies_sprite_sheet:getDimensions()
        )
    end
    return frames
end

---@param gameState GAME.GAMESTATE from game.gameState, contains array of enemy objects
---@param enemyType number enums.ENEMY_TYPE specific enemy static variables to get
---@param flowField FLOWFIELD pointer to flowField for the enemy to follow
---@param direction ENUMS.FLOWFIELD
function lib:new(gameState, enemyType, flowField, direction)
    --copy turret
    local o = {}
    for k, v in pairs(ENUMS.ENEMY_TYPE[enemyType]) do o[k] = v end
    setmetatable(o, self)
    self.__index = self

    local rand = 0
    if direction == ENUMS.FLOWFIELD.LONGITUDE then
        rand = love.math.random(12, 19)
        o.position = {x=0, y=SETTINGS.TILE_SIZE*rand - SETTINGS.TILE_SIZE/2}
        o.coords = {x=1, y=rand}
        o.lastDirection = ENUMS.FLOWFIELD.TILE.RIGHT
    elseif direction == ENUMS.FLOWFIELD.LATITUDE then
        rand = love.math.random(13, 21)
        o.position = {x=SETTINGS.TILE_SIZE*rand - SETTINGS.TILE_SIZE/2, y=0}
        o.coords = {x=rand, y=1}
        o.lastDirection = ENUMS.FLOWFIELD.TILE.DOWN
    end
    o.moveAnimation = {
        frames = enemyMoveFrames(enemyType),
        currentFrame = 1,
        frameTime = 0.1,
        timer = 0,
        loop = true,
        death = false,
        dead = false,
    }
    o.index = #gameState.enemies + 1 --index in game.gameState.turrets
    o.flowField = flowField
    o.orientation = 0
    o.turning = false
    o.goal = false
    table.insert(gameState.enemies, o)
    return o
end

---draw the enemy frame
function lib:draw()
    --calc origin of monster frame
    local frame = self.moveAnimation.frames[self.moveAnimation.currentFrame]
    local _,_,w,h = frame:getViewport()
    local ox = w / 2
    local oy = h / 2

    love.graphics.draw(
        enemies_sprite_sheet,
        frame,
        self.position.x,
        self.position.y,
        self.orientation, --orientation (radians)
        1.5, --x scale
        1.5,  --y scale
        ox, --origin x for rotation
        oy --origin y for rotation
    )
    love.graphics.setColor{1,1,1}
end

---logic to turn enemy from one direction to another
---@private
---@param dt number delta time between last frame and current frame
---@param newDirection ENUMS.FLOWFIELD.TILE
function lib:turn(dt, newDirection)
    --get radians of new direction
    local radians = 0
    if newDirection == ENUMS.FLOWFIELD.TILE.UP then
        radians = ENUMS.ORIENTATION.UP
    elseif newDirection == ENUMS.FLOWFIELD.TILE.LEFT then
        radians = ENUMS.ORIENTATION.LEFT
    elseif newDirection == ENUMS.FLOWFIELD.TILE.DOWN then
        radians = ENUMS.ORIENTATION.DOWN
    elseif newDirection == ENUMS.FLOWFIELD.TILE.RIGHT then
        radians = ENUMS.ORIENTATION.RIGHT
    else
        error(newDirection..": Enemy pathing did not choose valid direction after turning.")
    end

    -- +/- diff of final - current
    local diff = radians - self.orientation

    --Normalize the difference to be between -pi and pi
    while diff > math.pi do diff = diff - 2 * math.pi end
    while diff < -math.pi do diff = diff + 2 * math.pi end

    local turnAmount = math.pi * dt

    --snap to direction if next frame gets us to right direction
    if math.abs(diff) <= turnAmount then
        self.orientation = radians
        self.turning = false
        self.lastDirection = newDirection
    else
        self.orientation = self.orientation + turnAmount * (diff > 0 and 1 or -1)
    end
end

---update the enemy state
---@param dt number delta time between last frame and current frame
function lib:update(dt)
    local slow_rate = 4

    --check health
    if self.health <= 0 then
        self.moveAnimation.death = true
    end

    --direction logic
    local direction = self.flowField:getDirection(self.coords.x, self.coords.y)

    --check if at goal
    if direction == ENUMS.FLOWFIELD.TILE.GOAL then
        self.goal = true
    end

    --get to center of current tile before new direction logic
    local center = {
        x = (self.coords.x - 0.5) * SETTINGS.TILE_SIZE,
        y = (self.coords.y - 0.5) * SETTINGS.TILE_SIZE
    }
    --check if we're close to center
    local threshold = (self.speed / slow_rate) * 3 -- Make threshold larger to catch the center
    local centerCheck = {
        x = math.abs(self.position.x - center.x) <= threshold,
        y = math.abs(self.position.y - center.y) <= threshold
    }
    local atCenter = centerCheck.x and centerCheck.y

    --turning state machine
    if not self.turning then
        --move enemy
        if self.lastDirection == ENUMS.FLOWFIELD.TILE.UP then
            self.position.y = self.position.y - self.speed / slow_rate
            self.orientation = ENUMS.ORIENTATION.UP
        elseif self.lastDirection == ENUMS.FLOWFIELD.TILE.DOWN then
            self.position.y = self.position.y + self.speed / slow_rate
            self.orientation = ENUMS.ORIENTATION.DOWN
        elseif self.lastDirection == ENUMS.FLOWFIELD.TILE.LEFT then
            self.position.x = self.position.x - self.speed / slow_rate
            self.orientation = ENUMS.ORIENTATION.LEFT
        elseif self.lastDirection == ENUMS.FLOWFIELD.TILE.RIGHT then
            self.position.x = self.position.x + self.speed / slow_rate
            self.orientation = ENUMS.ORIENTATION.RIGHT
        end

        if atCenter and direction ~= self.lastDirection then
            self.position.x = center.x
            self.position.y = center.y
            self.turning = true
        end
    else
        self:turn(dt, direction)
    end

    --calc tile position
    self.coords.x = math.floor(self.position.x / SETTINGS.TILE_SIZE)+1
    self.coords.y = math.floor(self.position.y / SETTINGS.TILE_SIZE)+1

    --sprite moving animation
    local animate = self.moveAnimation
    if not animate.death then
        animate.timer = animate.timer + dt

        if animate.timer >= animate.frameTime then
            animate.timer = animate.timer - animate.frameTime
            animate.currentFrame = animate.currentFrame + 1

            if animate.currentFrame > #animate.frames then
                if animate.loop then
                    animate.currentFrame = 1
                else
                    animate.currentFrame = #animate.frames
                end
            end
        end
    else --death animation
        --reset animation timers
        if animate.timer >= animate.frameTime then
            if animate.currentFrame > #animate.frames then
                self.moveAnimation.dead = true
            end
        end
    end
end

---Remove entity from game state
---@param gameState GAME.GAMESTATE
function lib:kill(gameState)
    gameState.money = gameState.money + self.value
    table.remove(gameState.enemies, self.index)
end

return lib