local ENUMS = require('enums')
local IMAGES = require('lib.images')

--enemy class
local lib = {}

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

function lib:new(gameState, enemyType)
    --copy turret
    local o = {}
    for k, v in pairs(ENUMS.ENEMY_TYPE[enemyType]) do o[k] = v end
    setmetatable(o, self)
    self.__index = self
    o.position = {x=0, y=400} --TODO generate in starting zone

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
    o.nextNode = 0 --next turn to make
    table.insert(gameState.enemies, o)
    return o
end

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

--Remove Entity
function lib:kill(gameState)
    gameState.money = gameState.money + self.value
    table.remove(gameState.enemies, self.index)
end

return lib