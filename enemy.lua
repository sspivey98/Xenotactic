local ENUMS = require('enums')
local IMAGES = require('lib.images')

--[[
*ENEMY PATHING NOTES

pathing only updates on turret buy/sell
enemies will have different paths based on position and final

--]]

---enemy class
---@class ENEMY
---@field position {x:number,y:number}
---@field moveAnimation {frames:table[],currentFrame:number,frameTime:number,timer:number,loop:boolean,death:boolean,dead:boolean}

local lib = {}

local SETTINGS = require('settings')
local enemies_sprite_sheet = IMAGES.library["enemies"]

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


---@param gameState state from game.gameState, contains array of enemy objects
---@param enemyType ENUMS.ENEMY enums.ENEMY_TYPE specific enemy static variables to get
---@param direction ENUMS.FLOWFIELD which flowField for the enemy to follow
function lib:new(gameState, enemyType, direction)
    --copy turret
    local o = {}
    for k, v in pairs(ENUMS.ENEMY_TYPE[enemyType]) do o[k] = v end
    setmetatable(o, self)
    self.__index = self
    --between {0,12} and {0,20}
    o.position = {x=0, y=SETTINGS.TILE_SIZE*love.math.random(12, 20) - SETTINGS.TILE_SIZE/2}

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
    o.flowField = direction--!which flowField to follow
    table.insert(gameState.enemies, o)
    return o
end

---draw the enemy frame
function lib:draw()
    --love.graphics.setColor{0.7, 0.7, 0.7}
    love.graphics.draw(
        enemies_sprite_sheet,
        self.moveAnimation.frames[self.moveAnimation.currentFrame],
        self.position.x,
        self.position.y,
        0,
        1.5, --x scale
        1.5  --y scale
    )
    love.graphics.setColor{1,1,1}
end

---update the enemy state
---@param dt number delta time between last frame and current frame
function lib:update(dt)
    --check health
    if self.health <= 0 then
        self.moveAnimation.death = true
    end

    --move direction
    --TODO implement to calc pathing() and rotate()
    self.position.x = self.position.x + self.speed / 4

    --move animation
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
---@param gameState state
function lib:kill(gameState)
    gameState.money = gameState.money + self.value
    table.remove(gameState.enemies, self.index)
end

return lib