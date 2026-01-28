local ENUMS = require('enums')
local IMAGES = require('lib.images')
local SOUNDS = require('lib.sounds')
local UTIL = require('level.util')

--[[
*ENEMY PATHING NOTES

pathing only updates on turret buy/sell
enemies will have different paths based on position and final

--]]

---enemy class
---@class ENEMY : EnemyData inherit properties of EnemyData
---@field position {x:number,y:number} absolute coordinates
---@field coords {x:number,y:number} tile coordinates
---@field protected moveAnimation {frames:table[],currentFrame:number,frameTime:number,timer:number,loop:boolean,death:boolean,dead:boolean}
---@field protected deathAnimation {frames:table[],currentFrame:number,frameTime:number,timer:number,origin:{x:number,y:number}}
---@field index string uuid key for game.gameState.enemies
---@field orientation ENUMS.FLOWFIELD.TILE orientation of current sprite
---@field slow_rate number `Range: 0-1` slow % (0.21) caused by turret with slow attribute
---@field protected lastDirection ENUMS.FLOWFIELD.TILE
---@field flowField FLOWFIELD which flowField for the enemy to follow
---@field protected dying boolean mark enemy is dying or not
---@field protected fullHealth number enemy's health when full
---@field protected healthBar {width:number,height:number,x:number,y:number,value:number}
---@field protected origin {x:number,y:number} origin x,y for rotation
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
---@return love.Quad[]
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
    }
    o.deathAnimation = {
        frames = ENUMS.AlienDeathFrames,
        currentFrame = 1,
        frameTime = 0.03,
        timer = 0,
    }
    local frameW, frameH = o.deathAnimation.frames[o.deathAnimation.currentFrame]:getDimensions()
    o.deathAnimation.origin = {x = frameW / 2, y = frameH / 2}
    o.dying = false
    o.index = UTIL.uuid()
    o.flowField = flowField
    o.orientation = 0
    o.slow_rate = 1
    local _,_,w,h = o.moveAnimation.frames[o.moveAnimation.currentFrame]:getViewport()
    o.origin = {
        x = w/2,
        y = h/2
    }
    o.turning = false
    o.goal = false
    o.fullHealth = o.health
    o.healthBar = {
        width = 2*w/3,
        height = h/5,
        x = 0,
        y = 0,
        value = o.fullHealth
    }
    gameState.enemies[o.index] = o
    return o
end

---draw the enemy frame
function lib:draw()
    if self.dying then
        love.graphics.draw(
            self.deathAnimation.frames[self.deathAnimation.currentFrame],
            self.position.x,
            self.position.y,
            0, --orientation (radians)
            0.5, --x scale
            0.5,  --y scale
            self.deathAnimation.origin.x,
            self.deathAnimation.origin.y
        )
    else
        love.graphics.draw(
            enemies_sprite_sheet,
            self.moveAnimation.frames[self.moveAnimation.currentFrame],
            self.position.x,
            self.position.y,
            self.orientation, --orientation (radians)
            1.5, --x scale
            1.5,  --y scale
            self.origin.x, --origin x for rotation
            self.origin.y --origin y for rotation
        )

        --%
        love.graphics.setColor{0.2, 0.8, 0.2}
        love.graphics.rectangle("fill", self.healthBar.x, self.healthBar.y, self.healthBar.width*self.healthBar.value, self.healthBar.height)

        --bar border
        love.graphics.setColor{0,0,0}
        love.graphics.rectangle("line", self.healthBar.x, self.healthBar.y, self.healthBar.width, self.healthBar.height)

        --reset color
        love.graphics.setColor{1,1,1}
    end
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
        --TODO snap to the middle of the closest tile? perhaps just kill?
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
---@param gameState GAME.GAMESTATE
function lib:update(dt, gameState)
    --check health
    if self.health <= 0 and not self.dying then
        self.dying = true
    end

    --update healthBar position & health
    self.healthBar.x = self.position.x
    self.healthBar.y = self.position.y
    self.healthBar.value = self.health / self.fullHealth

    --direction logic
    local direction = self.flowField:getDirection(self.coords.x, self.coords.y)

    --check if at goal
    if direction == ENUMS.FLOWFIELD.TILE.GOAL then
        return self:finished(gameState)
    end

    --get to center of current tile before new direction logic
    local center = {
        x = (self.coords.x - 0.5) * SETTINGS.TILE_SIZE,
        y = (self.coords.y - 0.5) * SETTINGS.TILE_SIZE
    }
    --check if we're close to center of tile
    local threshold = (self.slow_rate*(self.speed / 4)) * 3 -- Make threshold larger to catch the center
    local centerCheck = {
        x = math.abs(self.position.x - center.x) <= threshold,
        y = math.abs(self.position.y - center.y) <= threshold
    }
    local atCenter = centerCheck.x and centerCheck.y

    --reduce slow rate
    if self.slow_rate < 1 then
        self.slow_rate = self.slow_rate + dt
        if self.slow_rate > 1 then self.slow_rate = 1 end
    end

    --turning state machine
    if (not self.turning and not self.dying) or self.air then
        --move enemy
        if self.lastDirection == ENUMS.FLOWFIELD.TILE.UP then
            self.position.y = self.position.y - self.slow_rate*(self.speed / 4)
            self.orientation = ENUMS.ORIENTATION.UP
        elseif self.lastDirection == ENUMS.FLOWFIELD.TILE.DOWN then
            self.position.y = self.position.y + self.slow_rate*(self.speed / 4)
            self.orientation = ENUMS.ORIENTATION.DOWN
        elseif self.lastDirection == ENUMS.FLOWFIELD.TILE.LEFT then
            self.position.x = self.position.x - self.slow_rate*(self.speed / 4)
            self.orientation = ENUMS.ORIENTATION.LEFT
        elseif self.lastDirection == ENUMS.FLOWFIELD.TILE.RIGHT then
            self.position.x = self.position.x + self.slow_rate*(self.speed / 4)
            self.orientation = ENUMS.ORIENTATION.RIGHT
        end

        if (atCenter) and (direction ~= self.lastDirection) and (not self.air) then
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
    if not self.dying then
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
        self.deathAnimation.timer = self.deathAnimation.timer + dt
        --reset animation timers
        if self.deathAnimation.timer >= self.deathAnimation.frameTime then
            self.deathAnimation.timer = self.deathAnimation.timer - self.deathAnimation.frameTime
            self.deathAnimation.currentFrame = self.deathAnimation.currentFrame + 1

            if self.deathAnimation.currentFrame > #self.deathAnimation.frames then
                self.deathAnimation.currentFrame = #self.deathAnimation.frames
                return self:kill(gameState)
            end
        end
    end
end

---Remove entity from game state and award money
---@param gameState GAME.GAMESTATE
function lib:kill(gameState)
    SOUNDS.library["enemy_kill"]:play()
    gameState.money = gameState.money + self.value
    gameState.enemies[self.index] = nil
end

---Remove entity from game state and lose life
---@param gameState GAME.GAMESTATE
function lib:finished(gameState)
    SOUNDS.library["lose_life"]:play()
    gameState.lives = gameState.lives - 1
    gameState.enemies[self.index] = nil
end

---slow down movement for a time period
---@param percent integer
function lib:slow(percent)
    self.slow_rate = 1 - percent/100
end

return lib