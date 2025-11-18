local IMAGES = require('lib.images')

local lib = {}

lib.CLICK = {
    LEFT = 1,
    RIGHT = 2
}

lib.TILES = {
    EMPTY = 0,
    WALL = 1,
    SPAWN = 2,
    FINAL = 3,
    TURRET = 4
}

lib.COLORS = {
    [0] = {0.7, 0.8, 0.7}, --green
    [1] = {0.7, 0.7, 0.7}, --grey
    [2] = {0.2, 0.2, 0.8}, --blue
    [3] = {0.8, 0.2, 0.2} --red
}

lib.TURRET = {
    WALL = {
        cost = 2,
        sell = 1,
        range = 0,
        speed = 0,
        damage = 0,
        image = IMAGES.library["turret_wall"]
    },
    GATLING = {
        cost = 5,
        sell = 3,
        range = 60,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_gatling"]
    },
    PLASMA = {
        cost = 15,
        sell = 8,
        range = 70,
        speed = 4,
        damage = 5,
        image = IMAGES.library["turret_plasma"]
    },
    SAM = {
        cost = 20,
        sell = 10,
        range = 90,
        speed = 1,
        damage = 8,
        image = IMAGES.library["turret_sam"]
    },
    DCA = {
        cost = 50,
        sell = 25,
        range = 60,
        speed = 3,
        damage = 20,
        image = IMAGES.library["turret_sam"]
    },
    FREEZE = {
        cost = 50,
        sell = 25,
        range = 50,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_freeze"]
    },
    TESLA = {
        cost = 30,
        sell = 15,
        range = 40,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_tesla"]
    }
}

lib.ENEMY = {
    BOSS1 = {
        speed = 20,
        health = 100,
        value = 20
    },
    SCORPION = {
        speed = 1,
        health = 10,
        value = 1,
    },
    BOSS2 = {
        speed = 1,
        health = 30,
        value = 1,
    },
    GOBLIN = {
        speed = 1,
        health = 33,
        value = 1,
    },
    TERMITE = {
        speed = 1,
        health = 36,
        value = 1,
    },
    SLIME = {
        speed = 1,
        health = 60,
        value = 3,
    },
    SPIDER = {
        speed = 1,
        health = 40,
        value = 1,
    },
    QUEEN = {
        speed = 1,
        health = 500,
        value = 40,
    },
    WENDIGO = {
        speed = 1,
        health = 58,
        value = 1,
    },
    TURTLE = {},
    REDCYBORG = {
        speed = 1,
        health = 73,
        value = 2,
    },
    REDALIEN = {},
    CYBORG = {},
    ALIEN = {
        speed = 1,
        health = 26,
        value = 1
    },
    HELICOPTER = {
        speed = 2,
        health = 44,
        value = 3,
    },
}

--match number to enum
lib.TURRET_TYPE = {
    [1] = lib.TURRET.WALL,
    [2] = lib.TURRET.GATLING,
    [3] = lib.TURRET.PLASMA,
    [4] = lib.TURRET.SAM,
    [5] = lib.TURRET.DCA,
    [6] = lib.TURRET.FREEZE,
    [7] = lib.TURRET.TESLA,
}

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

return lib