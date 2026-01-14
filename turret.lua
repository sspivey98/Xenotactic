local ENUMS = require('enums')
local SETTINGS = require('settings')
local IMAGES = require('lib.images')

---turret class
---@class TURRET : TurretData
---@field orientation number
---@field upgrading boolean
---@field upgradeTimer number
---@field position {x:number,y:number} top left coordinate
---@field buildAnimation {frames:table,currentFrame:number,frameTime:number,timer:number,built:boolean}
---@field index number index in game.gameState.turrets
---@field width number
---@field height number
---@field level number turret upgrade level
---@field selected boolean
---@overload fun(gameState: GAME.GAMESTATE, x:number, y:number): TURRET
local lib = setmetatable({},
    {
        _call = function(class, gameState, x, y)
            ---@cast class TURRET
            return class:new(gameState, x, y)
        end
    }
)

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
    return frames
end

---create new turret constructor
---@param gameState GAME.GAMESTATE
---@param x number
---@param y number
---@return TURRET
function lib:new(gameState, x, y)
    --copy selected turret metadata
    local o = {}
    local turretType = ENUMS.TURRET_LOOKUP[gameState.selectedTurretType]
    for k, v in pairs(ENUMS.TURRET[turretType]) do o[k] = v end
    setmetatable(o, self)
    self.__index = self
    o.position = {x=x, y=y} --top left
    o.width = SETTINGS.TILE_SIZE * 2
    o.height = SETTINGS.TILE_SIZE * 2
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
    o.orientation = 0
    o.upgrading = false
    o.upgradeTimer = 0
    o.level = 1 --upgrade level
    o.selected = false
    table.insert(gameState.turrets, o)
    gameState.money = gameState.money - o.cost
    return o
end

---turret logic
---@param dt number delta between last frame and current in seconds
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
    end

    --upgrade animation
    if self.upgrading then
        self.upgradeTimer = self.upgradeTimer + dt

        if self.upgradeTimer >= ENUMS.UPGRADE_TIMES["LEVEL"..self.level+1] then
            self.level = self.level + 1
            self.upgrading = false
            self.upgradeTimer = 0
        end
    end

    --turret targeting, reloading, firing
end

---draw turret
function lib:draw()
    --build animation
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
    --other animations
    else
        love.graphics.setColor{0.8, 0.8, 0.8}
        --calculate center of turret
        local w,h = self.image:getDimensions()
        local ox = w / 2
        local oy = h / 2

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
        love.graphics.setColor(ENUMS.UPGRADE[self.level])
        love.graphics.draw(
            self.image,
            self.position.x + (ox * 1.5),
            self.position.y + (oy * 1.5),
            self.orientation, --r
            1.5, --x scale
            1.5, --y scale
            ox,
            oy
        )

        --draw selected range range
        if self.selected then
            --draw red circle
            love.graphics.setColor{1, 0, 0.3} --bright red
            love.graphics.circle("line",
                self.position.x + SETTINGS.TILE_SIZE,
                self.position.y + SETTINGS.TILE_SIZE,
                self.range, --radius, should come from turret?
                20
            )
        end
    end
end

--selling logic and animation
---@param gameState GAME.GAMESTATE
function lib:sell(gameState)
    --unblock from map
    gameState.path1:setEmpty(self.position.x, self.position.y, true)
    gameState.path2:setEmpty(self.position.x, self.position.y, true)
    --refund money
    gameState.money = gameState.money + self.value
    --remove from game state turrets
    table.remove(gameState.turrets, self.index)
end

---find enemy to target
---@param enemies ENEMY[]
---@return ENEMY
function lib:target(enemies)
    --TODO
    return enemies[1]
end

---Check if enemy is in range
---@param enemy ENEMY
---@return boolean
function lib:inRange(enemy)
    local dx = enemy.position.x - self.position.x
    local dy = enemy.position.y - self.position.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance <= self.range
end

---turret clicked on check
---@param x number x mouse coordinate
---@param y number y mouse coordinate
---@return boolean
function lib:select(x,y)
    if x >= self.position.x and x <= self.position.x + self.width and
        y >= self.position.y and y <= self.position.y + self.height then
            self.selected = true
            return true
    end
    self.selected = false
    return false
end

---upgrade turret setter
---@param money number
---@return boolean
function lib:upgrade(money)
    if money < self.cost then
        return false
    end

    --do upgrade logic
    money = money - self.cost
    self.upgrading = true
    return true
end

return lib
