--[[    $Id$    ]]

local _, oUF_Caellian = ...

oUF_Caellian.config = {{}}

local config = {
    noPlayerAuras   = false, -- true to disable oUF buffs/debuffs on the player frame and enable default
    noPetAuras      = false, -- true to disable oUF buffs/debuffs on the pet frame
    noTargetAuras   = false, -- true to disable oUF buffs/debuffs on the target frame
    noToTAuras      = false, -- true to disable oUF buffs/debuffs on the ToT frame

    noParty         = false, -- true to disable party frames
    noRaid          = false, -- true to disable raid frames
    noArena         = false, -- true to disable arena frames

    scale           = 1, -- scale of the unitframes (1 being 100%)

    manaThreshold   = 20, -- low mana threshold for all mana classes

    noClassDebuffs  = false, -- true to show all debuffs

    coords = {
        playerX = -278.5, -- horizontal offset for the player block frames
        playerY = 269.5, -- vertical offset for the player block frames

        targetX = 278.5, -- horizontal offset for the target block frames
        targetY = 269.5, -- vertical offset for the target block frames

        ["healing"] = {
            arenaX = 1250, -- horizontal offset for the arena frames
            arenaY = -500, -- vertical offset for the arena frames

            partyX = 1250, -- horizontal offset for the party frames
            partyY = -500, -- vertical offset for the party frames

            raidX = 1250, -- horizontal offset for the raid frames
            raidY = -500, -- vertical offset for the raid frames
        },

        ["other"] = {
            arenaX = -5, -- horizontal offset for the arena frames
            arenaY = -5, -- vertical offset for the arena frames

            partyX = 5, -- horizontal offset for the party frames
            partyY = -5, -- vertical offset for the party frames

            raidX = 5, -- horizontal offset for the raid frames
            raidY = -5, -- vertical offset for the raid frames
        },
    },
}

oUF_Caellian.config = config
_G["oUF_Caellian"] = oUF_Caellian.config
