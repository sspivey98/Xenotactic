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
local SETTINGS = require('settings')

--abstract interface for turret
local lib = {}

--match number to enum
local turretType = {
    [1] = ENUMS.TURRET.WALL,
    [2] = ENUMS.TURRET.GATLING,
    [3] = ENUMS.TURRET.PLASMA,
    [4] = ENUMS.TURRET.SAM,
    [5] = ENUMS.TURRET.DCA,
    [6] = ENUMS.TURRET.FREEZE,
    [7] = ENUMS.TURRET.TESLA,
}

local build_turret_sprite_sheet = IMAGES.library["turret_build"]

--return stack of frames as quads
local function turretBuildFrames()
    local frames = {}
    for i=1,8 do
        frames[i] = love.graphics.newQuad(
            i*SETTINGS.TILE_SIZE, --start x
            0, --start y
            SETTINGS.TILE_SIZE, SETTINGS.TILE_SIZE, --width height
            build_turret_sprite_sheet
        )
    end
    --add final turret sprite to stack?
    return frames
end

function lib:new(id, x, y)
    local o = turretType[id]
    setmetatable(o, self)
    self.__index = self
    o.position = {x=x, y=y}
    assert(type(o.position) == "table")
    assert(type(o.position.x) == "number" and type(o.position.y) == "number")
    o.buildAnimation = {
        frames = turretBuildFrames(),
        currentFrame = 1,
        frameTime = 0.08,
        timer = 0,
        built = false
    }
    return o
end

--building logic 
function lib:updateBuild(dt)
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
end

--building animation
function lib:drawBuild()
    if self.buildAnimation.built then return end

    love.graphics.draw(
        build_turret_sprite_sheet,
        self.buildAnimation.frames[self.buildAnimation.currentFrame],
        self.position.x,
        self.position.y
    )
end

--selling logic and animation
function lib:sell()
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