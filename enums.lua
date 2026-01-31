local IMAGES = require('lib.images')
local SOUNDS = require('lib.sounds')

---@class ENUMS
local lib = {}

---@enum ENUMS.CLICK
lib.CLICK = {
    LEFT = 1,
    RIGHT = 2
}

---tiles meanings for level map 
---@enum ENUMS.TILES
lib.TILES = {
    EMPTY = 0,
    WALL = 1,
    SPAWN = 2,
    GOAL = 3,
    TURRET = 4,
    PATHWAY = 5
}

---visual tiles (230x230) @ 1000%
---@type love.Image[]
lib.VISUAL_TILES = {
    [0] = {
        [0] = IMAGES.library["tile_default_0"],
        [1] = IMAGES.library["tile_default_1"],
        [2] = IMAGES.library["tile_default_2"],
        [3] = IMAGES.library["tile_default_3"],
    },
    [1] = IMAGES.library["tile_default_4"],
    [2] = IMAGES.library["tile_V_entry"],
    [3] = IMAGES.library["tile_H_entry"],
    [4] = IMAGES.library["tile_V_wall_L"],
    [5] = IMAGES.library["tile_V_wall_R"],
    [6] = IMAGES.library["tile_H_wall_U"],
    [7] = IMAGES.library["tile_H_wall_D"],
    [8] = IMAGES.library["tile_wall"],
    [9] = IMAGES.library["tile_corner_BL"],
    [10] = IMAGES.library["tile_corner_BR"],
    [11] = IMAGES.library["tile_corner_TL"],
    [12] = IMAGES.library["tile_corner_TR"],
    [13] = IMAGES.library["tile_corner_wall_DL"],
    [14] = IMAGES.library["tile_corner_wall_UL"],
    [15] = IMAGES.library["tile_corner_wall_DR"],
    [16] = IMAGES.library["tile_corner_wall_UR"],
}

---@alias Color number[] RGB or RGBA color array
---coloring for map tiles
---@type {[number]: Color}
lib.COLORS = {
    [0] = {0.7, 0.8, 0.7}, --green
    [1] = {0.7, 0.7, 0.7}, --grey
    [2] = {0.2, 0.2, 0.8}, --blue
    [3] = {0.8, 0.2, 0.2}, --red
    [4] = {0.7, 0.7, 0.7}, --grey
    [5] = {0.7, 0.75, 0.7}, --green/grey
}

---@class TurretData
---@field cost number
---@field value number
---@field range number
---@field speed number
---@field damage number
---@field image love.Image
---@field sound love.Source|nil
---@field shootImg love.Image|love.Image[]|nil
---@field projectile boolean
---@field slow integer % to slow enemy speed
---@field air boolean target air enemies?
---@field splash integer percent splash damage
---@field targetOne boolean targets specific enemies or not

---@class ENUMS.TURRET
---@field WALL TurretData
---@field GATLING TurretData
---@field PLASMA TurretData
---@field SAM TurretData
---@field DCA TurretData
---@field FREEZE TurretData
---@field TESLA TurretData

---@type love.Image[]
lib.TeslaShootAnimation = {
    [1] = IMAGES.library["tesla_shoot_1"],
    [2] = IMAGES.library["tesla_shoot_2"],
    [3] = IMAGES.library["tesla_shoot_3"],
    [4] = IMAGES.library["tesla_shoot_4"],
    [5] = IMAGES.library["tesla_shoot_5"],
    [6] = IMAGES.library["tesla_shoot_6"],
    [7] = IMAGES.library["tesla_shoot_7"],
    [8] = IMAGES.library["tesla_shoot_8"],
    [9] = IMAGES.library["tesla_shoot_9"],
    [10] = IMAGES.library["tesla_shoot_10"],
    [11] = IMAGES.library["tesla_shoot_11"],
    [12] = IMAGES.library["tesla_shoot_12"],
    [13] = IMAGES.library["tesla_shoot_13"],
    [14] = IMAGES.library["tesla_shoot_14"],
    [15] = IMAGES.library["tesla_shoot_15"],
    [16] = IMAGES.library["tesla_shoot_16"],
    [17] = IMAGES.library["tesla_shoot_17"],
    [18] = IMAGES.library["tesla_shoot_18"],
    [19] = IMAGES.library["tesla_shoot_19"],
    [20] = IMAGES.library["tesla_shoot_20"],
    [21] = IMAGES.library["tesla_shoot_21"],
    [22] = IMAGES.library["tesla_shoot_22"],
    [23] = IMAGES.library["tesla_shoot_23"],
}

---@type ENUMS.TURRET
lib.TURRET = {
    WALL = {
        cost = 2,
        value = 1,
        range = 5,
        speed = 0,
        damage = 0,
        image = IMAGES.library["turret_wall"],
        sound = nil,
        shootImg = nil,
        projectile = false,
        slow = 0,
        air = false,
        splash = 0,
        targetOne = true
    },
    GATLING = {
        cost = 5,
        value = 3,
        range = 90,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_gatling"],
        sound = SOUNDS.library["shoot_gatling"],
        shootImg = IMAGES.library["turret_gatling_shoot"],
        projectile = false,
        slow = 0,
        air = false,
        splash = 0,
        targetOne = true
    },
    PLASMA = {
        cost = 15,
        value = 8,
        range = 100,
        speed = 4,
        damage = 5,
        image = IMAGES.library["turret_plasma"],
        sound = SOUNDS.library["shoot_plasma"],
        shootImg = IMAGES.library["turret_plasma_shoot"],
        projectile = true,
        slow = 0,
        air = false,
        splash = 0,
        targetOne = true
    },
    SAM = {
        cost = 20,
        value = 10,
        range = 120,
        speed = 1,
        damage = 8,
        image = IMAGES.library["turret_sam"],
        sound = SOUNDS.library["shoot_missile"],
        shootImg = IMAGES.library["turret_rocket_shoot"],
        projectile = true,
        slow = 0,
        air = false,
        splash = 20,
        targetOne = true
    },
    DCA = {
        cost = 50,
        value = 25,
        range = 90,
        speed = 3,
        damage = 20,
        image = IMAGES.library["turret_sam"],
        sound = SOUNDS.library["shoot_missile"],
        shootImg = IMAGES.library["turret_rocket_shoot"],
        projectile = true,
        slow = 0,
        air = true,
        splash = 25,
        targetOne = true
    },
    FREEZE = {
        cost = 50,
        value = 25,
        range = 80,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_freeze"],
        sound = SOUNDS.library["shoot_freeze"],
        shootImg = IMAGES.library["turret_freeze_shoot"],
        projectile = true,
        slow = 20,
        air = false,
        splash = 50,
        targetOne = true
    },
    TESLA = {
        cost = 30,
        value = 15,
        range = 70,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_tesla"],
        sound = SOUNDS.library["shoot_tesla"],
        shootImg = lib.TeslaShootAnimation,
        projectile = false,
        slow = 90,
        air = false,
        splash = 0,
        targetOne = false
    }
}

---@class EnemyData
---@field speed number
---@field health number
---@field value number
---@field air boolean

---@enum ENUMS.ENEMY
lib.ENEMY = {
    BOSS1 = {
        speed = 2,
        health = 100,
        value = 20,
        air = false,
    },
    SCORPION = {
        speed = 1,
        health = 10,
        value = 1,
        air = false,
    },
    BOSS2 = {
        speed = 1,
        health = 30,
        value = 1,
        air = false,
    },
    GOBLIN = {
        speed = 1,
        health = 33,
        value = 1,
        air = false,
    },
    TERMITE = {
        speed = 1,
        health = 36,
        value = 1,
        air = false,
    },
    SLIME = {
        speed = 1,
        health = 60,
        value = 3,
        air = false,
    },
    SPIDER = {
        speed = 1,
        health = 40,
        value = 1,
        air = false,
    },
    QUEEN = {
        speed = 1,
        health = 500,
        value = 40,
        air = false,
    },
    WENDIGO = {
        speed = 1,
        health = 58,
        value = 1,
        air = false,
    },
    TURTLE = {
        speed = 1,
        health = 10,
        value = 2,
        air = false,
    },
    REDCYBORG = {
        speed = 1,
        health = 73,
        value = 2,
        air = false,
    },
    REDALIEN = {
        speed = 1,
        health = 10,
        value = 2,
        air = false,
    },
    CYBORG = {
        speed = 1,
        health = 10,
        value = 2,
        air = false,
    },
    ALIEN = {
        speed = 1,
        health = 26,
        value = 1,
        air = false,
    },
    HELICOPTER = {
        speed = 2,
        health = 44,
        value = 3,
        air = true,
    },
}

---@enum TURRET_TYPE
lib.TURRET_TYPE = {
    WALL = 1,
    GATLING = 2,
    PLASMA = 3,
    SAM = 4,
    DCA = 5,
    FREEZE = 6,
    TESLA = 7
}

---reverse lookup match number to turret enum
---@type {[number]: string}
lib.TURRET_LOOKUP = {
    [1] = "WALL",
    [2] = "GATLING",
    [3] = "PLASMA",
    [4] = "SAM",
    [5] = "DCA",
    [6] = "FREEZE",
    [7] = "TESLA",
}

---match number to enemy enum
---@type {[number]: ENUMS.ENEMY}
lib.ENEMY_TYPE = {
    [1] = lib.ENEMY.BOSS1,
    [2] = lib.ENEMY.SCORPION,
    [3] = lib.ENEMY.BOSS2,
    [4] = lib.ENEMY.GOBLIN,
    [5] = lib.ENEMY.TERMITE,
    [6] = lib.ENEMY.SLIME,
    [7] = lib.ENEMY.SPIDER,
    [8] = lib.ENEMY.QUEEN,
    [9] = lib.ENEMY.WENDIGO,
    [10] = lib.ENEMY.TURTLE,
    [11] = lib.ENEMY.REDCYBORG,
    [12] = lib.ENEMY.REDALIEN,
    [13] = lib.ENEMY.CYBORG,
    [14] = lib.ENEMY.ALIEN,
    [15] = lib.ENEMY.HELICOPTER
}

---@enum ENUMS.FLOWFIELD.TILE
local TILE = {
    BLOCKED = -1,
    GOAL = 0,
    UP = 1,
    DOWN = 2,
    LEFT = 3,
    RIGHT = 4
}

---@enum ENUMS.FLOWFIELD
lib.FLOWFIELD = {
    TILE = TILE,
    LONGITUDE = 1, --left -> right
    LATITUDE = 2, --up -> down
}


local DTR = math.pi / 180 --degrees to Radians
---@enum ENUMS.ORIENTATION
lib.ORIENTATION = {
    RIGHT = 0,
    DOWN = 90 * DTR,
    LEFT = 180 * DTR,
    UP = 270 * DTR
}

---upgrade colors
---@enum ENUMS.UPGRADE_COLORS
lib.UPGRADE_COLORS = {
    WHITE = {0.8, 0.8, 0.8},
    PURPLE = {1.0, 0.0, 1.0},
    YELLOW = {0.9, 0.8, 0.1},
    GREEN = {0.3, 0.8, 0.4},
    CYAN = {0, 1.0, 1.0},
    RED = {0.7, 0.1, 0.1}
}

---color lookup table (index correlates to turret level)
---@type {[number]: Color}
lib.UPGRADE = {
    [1] = lib.UPGRADE_COLORS.WHITE,
    [2] = lib.UPGRADE_COLORS.PURPLE,
    [3] = lib.UPGRADE_COLORS.YELLOW,
    [4] = lib.UPGRADE_COLORS.GREEN,
    [5] = lib.UPGRADE_COLORS.CYAN,
    [6] = lib.UPGRADE_COLORS.RED,
}

---upgrade times in seconds; turrets start at level 1, so this is time taken to upgrade to key level
---@enum ENUMS.UPGRADE_TIMES
lib.UPGRADE_TIMES = {
    LEVEL2 = 1,
    LEVEL3 = 2,
    LEVEL4 = 5,
    LEVEL5 = 10,
    LEVEL6 = 15
}

---upgrade cost per turret
---@enum ENUMS.UPGRADE_COST
lib.UPGRADE_COST = {
    ---@enum ENUMS.UPGRADE_COST.GATLING
    GATLING = {
        LEVEL2 = 5,
        LEVEL3 = 10,
        LEVEL4 = 15,
        LEVEL5 = 30,
        LEVEL6 = 60
    },
    ---@enum ENUMS.UPGRADE_COST.PLASMA
    PLASMA = {
        LEVEL2 = 1,
        LEVEL3 = 2,
        LEVEL4 = 5,
        LEVEL5 = 10,
        LEVEL6 = 15
    },
    ---@enum ENUMS.UPGRADE_COST.SAM
    SAM = {
        LEVEL2 = 1,
        LEVEL3 = 2,
        LEVEL4 = 5,
        LEVEL5 = 10,
        LEVEL6 = 15
    },
    ---@enum ENUMS.UPGRADE_COST.DCA
    DCA = {
        LEVEL2 = 1,
        LEVEL3 = 2,
        LEVEL4 = 5,
        LEVEL5 = 10,
        LEVEL6 = 15
    },
    ---@enum ENUMS.UPGRADE_COST.FREEZE
    FREEZE = {
        LEVEL2 = 1,
        LEVEL3 = 2,
        LEVEL4 = 5,
        LEVEL5 = 10,
        LEVEL6 = 15
    },
    ---@enum ENUMS.UPGRADE_COST.TESLA
    TESLA = {
        LEVEL2 = 1,
        LEVEL3 = 2,
        LEVEL4 = 5,
        LEVEL5 = 10,
        LEVEL6 = 15
    }
}

---@type love.Image[]
lib.AlienDeathFrames = {
    [1] = IMAGES.library["alien_death_1"],
    [2] = IMAGES.library["alien_death_2"],
    [3] = IMAGES.library["alien_death_3"],
    [4] = IMAGES.library["alien_death_4"],
    [5] = IMAGES.library["alien_death_5"],
    [6] = IMAGES.library["alien_death_6"],
    [7] = IMAGES.library["alien_death_7"],
    [8] = IMAGES.library["alien_death_8"],
    [9] = IMAGES.library["alien_death_9"],
    [10] = IMAGES.library["alien_death_10"],
    [11] = IMAGES.library["alien_death_11"],
    [12] = IMAGES.library["alien_death_12"]
}

return lib