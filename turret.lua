--[[
INSTRUCTIONS:

Player clicks UI turret
confirm user has enough $
the left mouse now has the turret in hover
tilemap displays green/red if turret can be placed there
outline of range is drawn as a red dotted line in a circle
user left clicks a spot (top left)
check if spot is okay
turret is placed at location
tilemap changes type at that location
draw function renders new type
    check turret type for specific rendering
--]]
local ENUMS = require('enums')
local IMAGES = require('lib.images')

---turret class
---@class TURRET
---@field cost number
---@field sell number
---@field range number
---@field speed number
---@field damage number
---@field image any
---@field position {x:number,y:number}
---@field buildAnimation {frames:table,currentFrame:number,frameTime:number,timer:number,built:boolean}
---@field index number index in game.gameState.turrets
local lib = {}

local build_turret_sprite_sheet = IMAGES.library["turret_build"]

--return stack of frames as quads
local function turretBuildFrames()
    local frames = {}
    local spriteSize = 32
    for i=1,8 do
        frames[i] = love.graphics.newQuad(
            (i-1)*spriteSize, --start x
            0, --start y
            spriteSize,--width
            spriteSize,--height
            build_turret_sprite_sheet:getDimensions()
        )
    end
    --add final turret sprite to stack?
    return frames
end

function lib:new(gameState, x, y)
    --copy turret
    local o = {}
    for k, v in pairs(ENUMS.TURRET_TYPE[gameState.selectedTurretType]) do o[k] = v end
    setmetatable(o, self)
    self.__index = self
    o.position = {x=x, y=y} --top left
    assert(type(o.position) == "table")
    assert(type(o.position.x) == "number" and type(o.position.y) == "number")
    o.buildAnimation = {
        frames = turretBuildFrames(),
        currentFrame = 1,
        frameTime = 0.1,
        timer = 0,
        built = false
    }
    o.index = #gameState.turrets + 1 --index in game.gameState.turrets
    table.insert(gameState.turrets, o)
    gameState.money = gameState.money - o.cost
    return o
end

--turret logic
function lib:update(dt)
    --build animation
    if not self.buildAnimation.built then
        local animate = self.buildAnimation
        if animate.built then return end

        animate.timer = animate.timer + dt

        if animate.timer >= animate.frameTime then
            animate.timer = animate.timer - animate.frameTime
            animate.currentFrame = animate.currentFrame + 1

            if animate.currentFrame > #animate.frames then
                animate.currentFrame = #animate.frames
                animate.built = true
            end
        end
    else
        --turret targeting, reloading, and firing logic
    end
end

--draw turret
function lib:draw()
    if not self.buildAnimation.built then
        love.graphics.setColor{0.7, 0.7, 0.7}
        love.graphics.draw(
            build_turret_sprite_sheet,
            self.buildAnimation.frames[self.buildAnimation.currentFrame],
            self.position.x,
            self.position.y,
            0,
            1.5, --x scale
            1.5  --y scale
        )
    else
        love.graphics.setColor{0.8, 0.8, 0.8}
        --draw turret foundation
        love.graphics.draw(
            IMAGES.library["turret_action"],
            self.position.x,
            self.position.y,
            0,
            1.5, --x scale
            1.5  --y scale
        )
        --draw turret sprite
        --TODO more logic on rotation
        love.graphics.draw(
            self.image,
            self.position.x,
            self.position.y,
            0,
            1.5, --x scale
            1.5  --y scale
        )
    end
end

--selling logic and animation
---@param game game
function lib:delete(game)
    --refund money
    game.gameState.money = game.gameState.money + self.sell
    --remove from game state turrets
    table.remove(game.gameState.turrets, self.index)
end

function lib:select()
    local x = love.mouse.getX()
    local y = love.mouse.getY()
end

function lib:hover()
    local x = love.mouse.getX()
    local y = love.mouse.getY()

    if x > self.position.x and y < self.position.y then
        return true
    end
    return false
end

return lib