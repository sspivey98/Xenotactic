local ENUMS = require('enums')
local SETTINGS = require('settings')
local IMAGES = require('lib.images')
local UTIL = require('level.util')

---turret class
---@class TURRET : TurretData
---@field orientation number
---@field upgrading boolean
---@field upgradeTimer number
---@field position {x:number,y:number} top left coordinate
---@field protected buildAnimation {frames:table,currentFrame:number,frameTime:number,timer:number,built:boolean}
---@field index string uuid key for game.gameState.turrets
---@field width number
---@field height number
---@field level number turret upgrade level
---@field selected boolean
---@field upgradeCost integer cost of next upgrade
---@field private scale number scale of sprite based on resolution 
---@field protected targetsInRange ENEMY[] all targets in range
---@field protected targeting ENEMY|nil current selected target
---@field protected shootAnimation {cooldown:number, muzzle:number, currentFrame:integer, timer:number, frameTime:number}
---@field protected bullets {target:ENEMY,x:number,y:number,angle:number}[] array of bullets. Plasma can have 2-3 bullets active, SAM only 1, DCA 4
---@field protected upgradeBar {width:number,height:number,x:number,y:number,value:number}
---@field turretType ENUMS.TURRET_TYPE
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
---@param scale? number
function lib:new(gameState, x, y, scale)
    --copy selected turret metadata
    local o = {}
    o.turretType = gameState.selectedTurretType
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
    o.index = UTIL.uuid()
    o.orientation = 0
    o.upgrading = false
    o.upgradeCost = 5
    o.upgradeTimer = 0
    o.targeting = nil
    o.targetsInRange = {}
    o.level = 1 --upgrade level
    o.selected = false
    o.shootAnimation = {
        cooldown = 0,
        muzzle = 0,
        currentFrame = 1, --only needed for tesla
        frameTime = 0.1, --only needed for tesla
        timer = 0 --only needed for tesla
    }
    local w,h = o.image:getDimensions()
    o.scale = scale or 1.5
    o.range = o.range*scale
    o.upgradeBar = {
        width = w*o.scale,
        height = h/6,
        x = o.position.x,
        y = o.position.y+h,
        value = 0
    }
    o.bullets = {} --created when shooting
    gameState.turrets[o.index] = o
    gameState.money = gameState.money - o.cost
end

---turret logic
---@param dt number delta between last frame and current in seconds
---@param gameState GAME.GAMESTATE
function lib:update(dt, gameState)
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

    --updating traveling bullets
    if #self.bullets > 0 then
        for i,bullet in ipairs(self.bullets) do
            --stop if target is already dead
            if bullet.target.health <= 0 then
                table.remove(self.bullets, i)
            end

            local dx = bullet.target.position.x - bullet.x
            local dy = bullet.target.position.y - bullet.y
            local distance = math.sqrt(dx*dx + dy*dy)

            if distance < 4*self.scale then --consider it a hit
                self:doDamage(bullet.target)
                table.remove(self.bullets, i)
            else --move
                local speed = 400
                bullet.x = bullet.x + (dx / distance) * speed * dt
                bullet.y = bullet.y + (dy / distance) * speed * dt
                bullet.angle = math.atan2(dy, dx)
            end
        end
    end

    --upgrade animation
    if self.upgrading then
        --auto upgrade if on round 0
        if gameState.round == 0 then
            self.upgradeTimer = ENUMS.UPGRADE_TIMES["LEVEL"..self.level+1]
        end
        --upgrade progress bar
        self.upgradeBar.value = self.upgradeTimer / ENUMS.UPGRADE_TIMES["LEVEL"..self.level+1]
        self.upgradeTimer = self.upgradeTimer + dt

        if self.upgradeTimer >= ENUMS.UPGRADE_TIMES["LEVEL"..self.level+1] then
            self.level = self.level + 1
            self.upgrading = false
            self.upgradeTimer = 0
        end
    else

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

        --turret targeting, reloading, firing
        if self.targeting then
            --shooting logic
            if self.targetOne or (self.turretType == "DCA") then
                if #self.bullets == 0 or (self.turretType == "PLASMA") then
                    --update turret angle
                    if self.turretType ~= "DCA" then
                        --center of turret
                        local turretCenter = {
                            x = self.position.x + SETTINGS.TILE_SIZE / 2,
                            y = self.position.y + SETTINGS.TILE_SIZE / 2
                        }

                        --targeting logic
                        local dx = self.targeting.position.x - turretCenter.x
                        local dy = self.targeting.position.y - turretCenter.y
                        self.orientation = math.atan2(dy, dx) + math.pi / 2
                    end

                    self.shootAnimation.cooldown = self.shootAnimation.cooldown - dt
                    if self.shootAnimation.muzzle > 0 then
                        self.shootAnimation.muzzle = self.shootAnimation.muzzle - dt
                    end

                    if self.shootAnimation.cooldown <= 0 then
                        self:shoot()
                        self.shootAnimation.cooldown = 2 / self.speed
                        self.shootAnimation.muzzle = 0.1
                    end
                end
            else
                --animation from turret center, hit everyone in ranges
                self.shootAnimation.cooldown = self.shootAnimation.cooldown - dt

                if self.shootAnimation.muzzle > 0 then
                    self.shootAnimation.timer = self.shootAnimation.timer + dt

                    if self.shootAnimation.timer >= self.shootAnimation.frameTime then
                        self.shootAnimation.timer = self.shootAnimation.timer - self.shootAnimation.frameTime
                        self.shootAnimation.currentFrame = self.shootAnimation.currentFrame + 1

                        --loop if frames finish
                        if self.shootAnimation.currentFrame > #self.shootImg then
                            self.shootAnimation.muzzle = 0
                            self.shootAnimation.currentFrame = 1
                            self.shootAnimation.timer = 0
                        end
                    end
                end

                if self.shootAnimation.cooldown <= 0 then
                    self:shoot()
                    self.shootAnimation.cooldown = self.speed
                    self.shootAnimation.muzzle = 1
                    self.shootAnimation.currentFrame = 1
                    self.shootAnimation.timer = 0
                end
            end
        else
            self.bullets = {}
        end
    end
end

----------------------------
--- Helper draw functions  |
----------------------------
---@private
function lib:drawBuildAnimation()
    love.graphics.setColor{0.7, 0.7, 0.7}
    love.graphics.draw(
        build_turret_sprite_sheet,
        self.buildAnimation.frames[self.buildAnimation.currentFrame],
        self.position.x,
        self.position.y,
        0,
        self.scale, --x scale
        self.scale  --y scale
    )
    love.graphics.setColor{1,1,1}
end

---@private
function lib:drawSelected()
    --draw red circle
    love.graphics.setColor{1, 0, 0.3} --bright red
    love.graphics.circle("line",
        self.position.x + SETTINGS.TILE_SIZE,
        self.position.y + SETTINGS.TILE_SIZE,
        self.range, --radius, should come from turret?
        20
    )
    love.graphics.setColor{1,1,1}
end

---@private
function lib:drawUpgradeBar()
    --Draw progress (green)
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", self.upgradeBar.x, self.upgradeBar.y, self.upgradeBar.width * self.upgradeBar.value, self.upgradeBar.height)

    --Draw bar border
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", self.upgradeBar.x, self.upgradeBar.y, self.upgradeBar.width, self.upgradeBar.height)
end

---@private
function lib:drawRank()
    local rank = IMAGES.library["turret_rank_"..self.level-1]
    love.graphics.setColor{1,1,1}
    love.graphics.draw(
        rank,
        self.position.x + SETTINGS.TILE_SIZE/2,
        self.position.y - SETTINGS.TILE_SIZE/2,
        0,
        self.scale,
        self.scale
    )
end

---main draw turret function
function lib:draw()
    --build animation
    if not self.buildAnimation.built then
        self:drawBuildAnimation()
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
            self.scale, --x scale
            self.scale  --y scale
        )

        --draw turret sprite
        if not self.upgrading then
            love.graphics.setColor(ENUMS.UPGRADE[self.level])
            love.graphics.draw(
                self.image,
                self.position.x + (ox * self.scale),
                self.position.y + (oy * self.scale),
                self.orientation, --r
                self.scale, --x scale
                self.scale, --y scale
                ox,
                oy
            )
            --shooting projectile at enemy

            love.graphics.setColor{1,1,1}
            for _,bullet in ipairs(self.bullets) do
                local projW, projH = self.shootImg:getDimensions()
                love.graphics.draw(
                    self.shootImg,
                    bullet.x,
                    bullet.y,
                    bullet.angle,
                    self.scale, -- Scale
                    self.scale,
                    projW / 2,
                    projH / 2
                )
            end

            --shoot immediately
            if self.projectile == false then
                if (self.shootAnimation.muzzle > 0) and self.targeting then
                    if self.targetOne then
                        local flash_distance = oy * self.scale
                        local flash = {
                            x = self.position.x + (ox*self.scale) + math.cos(self.orientation - math.pi/2) * flash_distance,
                            y = self.position.y + (oy*self.scale) + math.sin(self.orientation - math.pi/2) * flash_distance
                        }
                        local flashW, flashH = self.shootImg:getDimensions()

                        love.graphics.setColor{1, 1, 1, self.shootAnimation.muzzle / 0.1}

                        if self.turretType == "GATLING" then --draw double muzzle
                            local offset = w/2
                            local perpendicular = {
                                x = -math.sin(self.orientation - math.pi/2) * offset,
                                y = math.cos(self.orientation - math.pi/2) * offset
                            }
                            --left
                            love.graphics.draw(
                                self.shootImg,
                                flash.x + perpendicular.x,
                                flash.y + perpendicular.y,
                                self.orientation - math.pi/2,
                                self.scale,
                                self.scale,
                                flashW / 2,
                                flashH / 2
                            )
                            --right
                            love.graphics.draw(
                                self.shootImg,
                                flash.x - perpendicular.x,
                                flash.y - perpendicular.y,
                                self.orientation - math.pi/2,
                                self.scale,
                                self.scale,
                                flashW / 2,
                                flashH / 2
                            )
                        else --single barrel
                            love.graphics.draw(
                                self.shootImg,
                                flash.x,
                                flash.y,
                                self.orientation - math.pi/2,
                                self.scale,
                                self.scale,
                                flashW / 2,
                                flashH / 2
                            )
                        end
                    else
                        --shoot all in range
                        local flashW, flashH = self.shootImg[1]:getDimensions()
                        love.graphics.draw(
                            self.shootImg[self.shootAnimation.currentFrame],
                            self.position.x + SETTINGS.TILE_SIZE,
                            self.position.y + SETTINGS.TILE_SIZE,
                            0,
                            self.scale,
                            self.scale,
                            flashW / 2,
                            flashH / 2
                        )
                    end
                end
            end
            love.graphics.setColor(1, 1, 1)
        else
            self:drawUpgradeBar()
        end

        --draw selected range range
        if self.selected then self:drawSelected() end

        --draw rank, if upgraded
        if self.level > 1 then self:drawRank() end
    end
    love.graphics.setColor{1,1,1}
end

--selling logic and animation
---@param gameState GAME.GAMESTATE
function lib:sell(gameState)
    --unblock from map
    gameState.path1:setEmpty(self.position.x, self.position.y, true)
    if gameState.path2 then
        gameState.path2:setEmpty(self.position.x, self.position.y, true)
    end
    --refund money
    gameState.money = gameState.money + self.value
    --remove from game state turrets
    gameState.turrets[self.index] = nil
end

---find enemy to target. Always returns an array of enemies in range
---The first enemy in the array is the closest to the goal 
---@param gameState GAME.GAMESTATE
function lib:target(gameState)
    -- 1.) Search for enemies within radius of turret -> target()
    -- 2.) Select enemy closest to goal in radius -> target()
    -- 3.) updated targeting coordinates for turret -> target() -> self.targeting

    --ignore wall pieces
    if self.turretType == "WALL" then return end

    local center = {
        x = self.position.x + SETTINGS.TILE_SIZE,
        y = self.position.y + SETTINGS.TILE_SIZE
    }
    local target = nil
    local closest = math.huge

    local ret = {}

    --if target dies, goes out of range, or is not the selected enemy, then don't update
    if self.targeting then
        if
            self.targeting.health <= 0
            or self:inRange(self.targeting) == false
            or self.targeting.dying
            or (gameState.selectedEnemy and self:inRange(gameState.selectedEnemy) and self.targeting ~= gameState.selectedEnemy)
        then
            self.targeting = nil
        end
    end

    --if not targeting, find next target
    local selectedEnemyInRange = false
    local inRange = {}
    for guid,enemy in pairs(gameState.enemies) do
        local dx = enemy.position.x - center.x
        local dy = enemy.position.y - center.y
        local distance = math.sqrt(dx*dx + dy*dy)
        if (distance <= self.range) and ((self.air == enemy.air) or self.turretType == "PLASMA") then
            --its in range
            table.insert(inRange, enemy)

            --it is selected
            if gameState.selectedEnemy and enemy == gameState.selectedEnemy then
                selectedEnemyInRange = true
            end

            --find enemy closest to goal
            local progress = enemy.flowField.costMap[enemy.coords.y][enemy.coords.x]
            if progress < closest then
                closest = progress
                target = guid
            end
        end
    end

    --add the enemy closest to the goal first
    if not self.targeting then
        --if enemy is selected and in range, prioritize
        if selectedEnemyInRange and gameState.selectedEnemy.health > 0 and not gameState.selectedEnemy.dying then
                self.targeting = gameState.selectedEnemy
                table.insert(ret, gameState.selectedEnemy)
        else
            if target and gameState.enemies[target] then
                self.targeting = gameState.enemies[target]
                table.insert(ret, gameState.enemies[target])
            end
        end
    end

    --add other enemies in the list later
    for _,enemy in pairs(inRange) do
        if self.targeting ~= enemy then
            table.insert(ret, enemy)
        end
    end

    self.targetsInRange = ret
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

---check if enemies are within 1 tile of each other
---@param enemy1 ENEMY
---@param enemy2 ENEMY
---@return boolean
function lib:inProximity(enemy1, enemy2)
    local dx = enemy1.position.x - enemy2.position.x
    local dy = enemy1.position.y - enemy2.position.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance <= self.splash*SETTINGS.TILE_SIZE
end

---shoot at enemy
function lib:shoot()
    if self.targeting then
        if self.targetOne then
            self.sound:play()
            --spawn projectile
            if self.projectile then
                if self.turretType == "PLASMA" then
                    table.insert(self.bullets, {
                        target = self.targeting,
                        x = self.position.x + SETTINGS.TILE_SIZE,
                        y = self.position.y + SETTINGS.TILE_SIZE,
                        angle = self.orientation - math.pi/2
                    })
                else
                    self.bullets[1] = {
                        target = self.targeting,
                        x = self.position.x + SETTINGS.TILE_SIZE,
                        y = self.position.y + SETTINGS.TILE_SIZE,
                        angle = self.orientation - math.pi/2
                    }
                end
            else
                --instant damage
                self:doDamage(self.targeting)
            end
        else
            self.sound:play()
            --shoot 4 enemies at once
            if self.turretType == "DCA" then
                --shoot target first
                self.bullets[1] =  {
                    target = self.targeting,
                    x = self.position.x + SETTINGS.TILE_SIZE,
                    y = self.position.y + SETTINGS.TILE_SIZE,
                    angle = self.orientation - math.pi/2
                }
                local max_bullets = 4
                local counter = 1
                for i=2,#self.targetsInRange do
                    if self.targetsInRange[i] ~= self.targeting then
                        counter = counter + 1
                        self.bullets[counter] =  {
                            target = self.targetsInRange[i],
                            x = self.position.x + SETTINGS.TILE_SIZE,
                            y = self.position.y + SETTINGS.TILE_SIZE,
                            angle = self.orientation - math.pi/2
                        }
                    end
                    if counter >= max_bullets then break end
                end
            --blindly shoot all enemies in range
            else
                self.targeting.health = self.targeting.health - self.damage
                for _,enemy in pairs(self.targetsInRange) do
                    enemy.health = enemy.health - self.damage
                    if self.stun_chance > 0 then
                        if love.math.random() < self.stun_chance/100 then
                            enemy:stun(1)
                        end
                    end
                end
            end
        end
    end
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
    if self.turretType == "WALL" then return false end

    --max level
    if self.level == 6 then return false end

    if gameState.money < ENUMS.UPGRADE_PATH[self.turretType]["LEVEL"..self.level+1].cost then 
        return false
    end

    --do upgrade logic
    self.upgrading = true

    --upgrade stats
    local upgrade = ENUMS.UPGRADE_PATH[self.turretType]["LEVEL"..self.level+1]
    for k,v in pairs(upgrade) do
        self[k] = v
    end

    gameState.money = gameState.money - self.cost

    self.range = self.range * self.scale
    return true
end

---inflict damage on enemy/enemies
---@param enemy ENEMY
function lib:doDamage(enemy)
    --damage
    enemy.health = enemy.health - self.damage

    --slow, if applicable
    if self.slow > 0 then
        enemy:slow(self.slow)
    end

    --stun, if applicable
    if self.stun_chance > 0 then
        if love.math.random() < self.stun_chance/100 then
            enemy:stun(1)
        end
    end

    --splash damage
    if self.splash > 0 then
        for _,enemyInRange in ipairs(self.targetsInRange) do
            if enemyInRange ~= enemy then
                if self:inProximity(enemyInRange, enemy) then
                    enemyInRange.health = enemyInRange.health - (0.33)*self.damage
                    enemyInRange:slow(self.slow)
                end
            end
        end
    end
end

return lib
