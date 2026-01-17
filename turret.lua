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
---@field upgradeCost integer cost of next upgrade
---@field targeting ENEMY|nil
---@field protected turretType string
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
    o.turretType = ENUMS.TURRET_LOOKUP[gameState.selectedTurretType]
    for k, v in pairs(ENUMS.TURRET[o.turretType]) do o[k] = v end
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
    o.upgradeCost = 5
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
    else
    --turret targeting, reloading, firing
        --[[
        LOGIC
            1.) Search for enemies within radius of turret -> target()
            2.) Select enemy closest to goal in radius -> target()
            3.) updated targeting coordinates for turret -> target() -> self.targeting
            4.) turn turret to face coordinates -> draw() <- self.targeting
            5.) turret shoot function -> update()
            6.) remove health from enemy

        delay search to not be every frame
        ignore search if turret already has a target (and its still in range)
        force research if enemy dies
        --]]
        --targeting logic
        if self.targeting then
            -- Calculate center of turret
            local turretCenter = {
                x = self.position.x + SETTINGS.TILE_SIZE / 2,
                y = self.position.y + SETTINGS.TILE_SIZE / 2
            }

            -- Calculate angle to target
            local dx = self.targeting.position.x - turretCenter.x
            local dy = self.targeting.position.y - turretCenter.y
            self.orientation = math.atan2(dy, dx) + math.pi / 2
        end
    end

    
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
        if not self.upgrading then
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
        else
            --Progress bar
            local barWidth = w * 1.5
            local barHeight = 6
            local barX = self.position.x
            local barY = self.position.y + (h * 1.5) - 5 -- Below the turret

            --Calculate progress (0 to 100)
            local progress = self.upgradeTimer / ENUMS.UPGRADE_TIMES["LEVEL"..self.level+1]

             --Draw progress (green)
            love.graphics.setColor(0.2, 0.8, 0.2)
            love.graphics.rectangle("fill", barX, barY, barWidth * progress, barHeight)

            --Draw bar border
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
        end

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
function lib:target(enemies)
    -- 1.) Search for enemies within radius of turret -> target()
    -- 2.) Select enemy closest to goal in radius -> target()
    -- 3.) updated targeting coordinates for turret -> target() -> self.targeting

    local center = {
        x = self.position.x + SETTINGS.TILE_SIZE,
        y = self.position.y + SETTINGS.TILE_SIZE
    }
    local target = nil
    local closest = math.huge

    for _,enemy in ipairs(enemies) do
        local dx = enemy.position.x - center.x
        local dy = enemy.position.y - center.y
        local distance = math.sqrt(dx*dx + dy*dy)
        if distance <= self.range then
            local progress = enemy.flowField.costMap[enemy.coords.y][enemy.coords.x]
            if progress < closest then
                closest = progress
                target = enemy
            end
        end
    end

    self.targeting = target
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
---@param gameState GAME.GAMESTATE
---@return boolean
function lib:upgrade(gameState)
    --max level
    if self.level == 6 then
        return false
    end

    if gameState.money < self.cost then
        return false
    end

    --do upgrade logic
    gameState.money = gameState.money - self.cost
    self.upgrading = true
    self.upgradeCost = ENUMS.UPGRADE_COST[self.turretType]["LEVEL"..self.level]
    return true
end

return lib
