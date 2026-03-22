local IMAGES = require('lib.images')
local SOUNDS = require('lib.sounds')

---@class ENUMS
local lib = {}

---@enum GAME.STATES
lib.STATES = {
    MENU = 0,
    LEVEL_SELECT = 1,
    GAME = 2,
    SETTINGS = 3,
    GAME_OVER = 4,
    LEVEL_WIN = 5
}

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
---@field splash number splash radius
---@field stun_chance integer chance to stun
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
        range = 1,
        speed = 0,
        damage = 0,
        image = IMAGES.library["turret_wall"],
        sound = nil,
        shootImg = nil,
        projectile = false,
        slow = 0,
        air = false,
        splash = 0,
        stun_chance = 0,
        targetOne = true
    },
    GATLING = {
        cost = 5,
        value = 3,
        range = 60,
        speed = 1,
        damage = 10,
        image = IMAGES.library["turret_gatling"],
        sound = SOUNDS.library["shoot_gatling"],
        shootImg = IMAGES.library["turret_gatling_shoot"],
        projectile = false,
        slow = 0,
        air = false,
        splash = 0,
        stun_chance = 0,
        targetOne = true
    },
    PLASMA = {
        cost = 15,
        value = 8,
        range = 66,
        speed = 8,
        damage = 5,
        image = IMAGES.library["turret_plasma"],
        sound = SOUNDS.library["shoot_plasma"],
        shootImg = IMAGES.library["turret_plasma_shoot"],
        projectile = true,
        slow = 0,
        air = false,
        splash = 0,
        stun_chance = 0,
        targetOne = true
    },
    SAM = {
        cost = 20,
        value = 10,
        range = 80,
        speed = 1,
        damage = 8,
        image = IMAGES.library["turret_sam"],
        sound = SOUNDS.library["shoot_missile"],
        shootImg = IMAGES.library["turret_rocket_shoot"],
        projectile = true,
        slow = 0,
        air = false,
        splash = 1.5,
        stun_chance = 0,
        targetOne = true
    },
    DCA = {
        cost = 50,
        value = 25,
        range = 60,
        speed = 2,
        damage = 20,
        image = IMAGES.library["turret_sam"],
        sound = SOUNDS.library["shoot_missile"],
        shootImg = IMAGES.library["turret_rocket_shoot"],
        projectile = true,
        slow = 0,
        air = true,
        splash = 1.5,
        stun_chance = 0,
        targetOne = false
    },
    FREEZE = {
        cost = 50,
        value = 25,
        range = 54,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_freeze"],
        sound = SOUNDS.library["shoot_freeze"],
        shootImg = IMAGES.library["turret_freeze_shoot"],
        projectile = true,
        slow = 20,
        air = false,
        splash = 1.5,
        stun_chance = 0,
        targetOne = true
    },
    TESLA = {
        cost = 30,
        value = 15,
        range = 47,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_tesla"],
        sound = SOUNDS.library["shoot_tesla"],
        shootImg = lib.TeslaShootAnimation,
        projectile = false,
        slow = 0,
        air = false,
        splash = 0,
        stun_chance = 5,
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
        speed = 1,
        health = 26,
        value = 20,
        air = false,
    },
    SCORPION = {
        speed = 1,
        health = 20,
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
        health = 528,
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
        speed = 0.8,
        health = 44,
        value = 3,
        air = true,
    },
}

-- ---@enum TURRET_TYPE
-- lib.TURRET_TYPE = {
--     WALL = 1,
--     GATLING = 2,
--     PLASMA = 3,
--     SAM = 4,
--     DCA = 5,
--     FREEZE = 6,
--     TESLA = 7
-- }

---@alias ENUMS.TURRET_TYPE "WALL"|"GATLING"|"PLASMA"|"SAM"|"DCA"|"FREEZE"|"TESLA"

---reverse lookup match number to turret enum
---@type {[number]: string}
lib.TURRET_TYPE = {
    [1] = "WALL",
    [2] = "GATLING",
    [3] = "PLASMA",
    [4] = "SAM",
    [5] = "DCA",
    [6] = "FREEZE",
    [7] = "TESLA",
}

---@alias ENUMS.ENEMY_TYPE "BOSS1"|"SCORPION"|"BOSS2"|"GOBLIN"|"TERMITE"|"SLIME"|"SPIDER"|"QUEEN"|"WENDIGO"|"TURTLE"|"REDCYBORG"|"REDALIEN"|"CYBORG"|"ALIEN"|"HELICOPTER"

---reverse lookup for enemy
---@type {[number]: string}
lib.ENEMY_TYPE = {
    [1] = "BOSS1",
    [2] = "SCORPION",
    [3] = "BOSS2",
    [4] = "GOBLIN",
    [5] = "TERMITE",
    [6] = "SLIME",
    [7] = "SPIDER",
    [8] = "QUEEN",
    [9] = "WENDIGO",
    [10] = "TURTLE",
    [11] = "REDCYBORG",
    [12] = "REDALIEN",
    [13] = "CYBORG",
    [14] = "ALIEN",
    [15] = "HELICOPTER"
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

---general color pallet
---@enum ENUMS.COLORS
lib.COLORS = {
    BLACK = {0, 0, 0},
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

---@class ENUMS.TURRET_UPGRADE
---@field cost integer
---@field damage integer
---@field range integer
---@field value integer sell value
---@field slow integer
---@field splash number
---@field stun_chance integer

---@class ENUMS.TURRET_LEVELS
---@field LEVEL2 ENUMS.TURRET_UPGRADE
---@field LEVEL3 ENUMS.TURRET_UPGRADE
---@field LEVEL4 ENUMS.TURRET_UPGRADE
---@field LEVEL5 ENUMS.TURRET_UPGRADE
---@field LEVEL6 ENUMS.TURRET_UPGRADE

---upgrade path per turret
---@type {[ENUMS.TURRET_TYPE]: ENUMS.TURRET_LEVELS}
lib.UPGRADE_PATH = {
    GATLING = {
        LEVEL2 = {
            cost = 5,
            damage = 20,
            range = 60,
            value = 7,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL3 = {
            cost = 10,
            damage = 40,
            range = 60,
            value = 15,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL4 = {
            cost = 20,
            damage = 80,
            range = 60,
            value = 30,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL5 = {
            cost = 40,
            damage = 160,
            range = 60,
            value = 60,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL6 = {
            cost = 120,
            damage = 400,
            range = 180,
            value = 150,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        }
    },
    ---@enum ENUMS.UPGRADE_COST.PLASMA
    PLASMA = {
        LEVEL2 = {
            cost = 15,
            damage = 10,
            range = 66,
            value = 22,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL3 = {
            cost = 20,
            damage = 18,
            range = 66,
            value = 37,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL4 = {
            cost = 40,
            damage = 34,
            range = 66,
            value = 67,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL5 = {
            cost = 70,
            damage = 65,
            range = 66,
            value = 120,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL6 = {
            cost = 290,
            damage = 320,
            range = 85,
            value = 337,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
    },
    ---@enum ENUMS.UPGRADE_COST.SAM
    SAM = {
        LEVEL2 = {
            cost = 15,
            damage = 16,
            range = 90,
            value = 15,
            slow = 0,
            splash = 1.5,
            stun_chance = 0,
        },
        LEVEL3 = {
            cost = 35,
            damage = 32,
            range = 100,
            value = 26,
            slow = 0,
            splash = 2,
            stun_chance = 0,
        },
        LEVEL4 = {
            cost = 60,
            damage = 64,
            range = 110,
            value = 52,
            slow = 0,
            splash = 2,
            stun_chance = 0,
        },
        LEVEL5 = {
            cost = 110,
            damage = 128,
            range = 120,
            value = 97,
            slow = 0,
            splash = 2.5,
            stun_chance = 0,
        },
        LEVEL6 = {
            cost = 260,
            damage = 256,
            range = 130,
            value = 180,
            slow = 0,
            splash = 3,
            stun_chance = 0,
        }
    },
    ---@enum ENUMS.UPGRADE_COST.DCA
    DCA = {
        LEVEL2 = {
            cost = 30,
            damage = 40,
            range = 60,
            value = 37,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL3 = {
            cost = 50,
            damage = 80,
            range = 60,
            value = 60,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL4 = {
            cost = 75,
            damage = 160,
            range = 60,
            value = 97,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL5 = {
            cost = 125,
            damage = 320,
            range = 60,
            value = 153,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        },
        LEVEL6 = {
            cost = 310,
            damage = 480,
            range = 80,
            value = 247,
            slow = 0,
            splash = 0,
            stun_chance = 0,
        }
    },
    ---@enum ENUMS.UPGRADE_COST.FREEZE
    FREEZE = {
        LEVEL2 = {
            cost = 25,
            damage = 15,
            range = 54,
            value = 56,
            slow = 25,
            splash = 1.5,
            stun_chance = 0,
        },
        LEVEL3 = {
            cost = 25,
            damage = 20,
            range = 54,
            value = 75,
            slow = 30,
            splash = 2,
            stun_chance = 0,
        },
        LEVEL4 = {
            cost = 25,
            damage = 25,
            range = 54,
            value = 93,
            slow = 40,
            splash = 2,
            stun_chance = 0,
        },
        LEVEL5 = {
            cost = 25,
            damage = 30,
            range = 54,
            value = 112,
            slow = 50,
            splash = 2.5,
            stun_chance = 0,
        },
        LEVEL6 = {
            cost = 50,
            damage = 50,
            range = 90,
            value = 150,
            slow = 75,
            splash = 3,
            stun_chance = 0,
        }
    },
    ---@enum ENUMS.UPGRADE_COST.TESLA
    TESLA = {
        LEVEL2 = {
            cost = 25,
            damage = 20,
            range = 47,
            value = 41,
            slow = 0,
            splash = 0,
            stun_chance = 7,
        },
        LEVEL3 = {
            cost = 50,
            damage = 40,
            range = 47,
            value = 79,
            slow = 0,
            splash = 0,
            stun_chance = 10,
        },
        LEVEL4 = {
            cost = 100,
            damage = 60,
            range = 47,
            value = 153,
            slow = 0,
            splash = 0,
            stun_chance = 13,
        },
        LEVEL5 = {
            cost = 185,
            damage = 180,
            range = 47,
            value = 292,
            slow = 0,
            splash = 0,
            stun_chance = 15,
        },
        LEVEL6 = {
            cost = 355,
            damage = 320,
            range = 47,
            value = 558,
            slow = 0,
            splash = 0,
            stun_chance = 20,
        }
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

---@type string[]
lib.Passwords = {
    [1] = "", --no password to unlock level 1
    [2] = "4loopz",
    [3] = "nowe1",
    [4] = "reginald2",
    [5] = "newgrounds07",
    [6] = "impossible6"
}

return lib