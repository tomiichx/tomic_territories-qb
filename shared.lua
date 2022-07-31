shared = {
    command = 'ter', -- komanda / command (Admin Only) // /ter (create/delete)
    group = 'god', -- grupa ili permisija / group required
    rankings = false, -- rang lista za mafije / rank list and points for gangs? (true/false) (not user-friendly, yet.. but it's translated tho) -- DON'T USE THIS, IT'S BROKEN CURRENTLY
    capturing = 10, -- in minutes / u minutama
    cooldown = 30, -- in minutes / u minutama
    rewards = { -- reward is given only after successfully capturing the territory
        on = true, -- off (false) / on (true)
        item = 'sandwich', -- item name
        count = 15, -- amount
    },
    itemsToBuy = { -- buyable items if territory type is 'market'
        ['sandwich'] = {
            label = '🍞 | Sandwich',
            worth = 30,
            crypto = true, -- true = crypto, false = cash
        },
        ['water'] = {
            label = '💧 | Water',
            worth = 20,
            crypto = true, -- true = crypto, false = cash
        },
    },
    itemsToSell = { -- sellable items if territory type is 'dealer'
        ['sandwich'] = {
            label = '🍞 | Sandwich',
            worth = 30,
            crypto = true, -- true = crypto, false = cash
        },
        ['water'] = {
            label = '💧 | Water',
            worth = 20,
            crypto = true, -- true = crypto, false = cash
        },
    },
}

shared.gangs = { -- https://docs.fivem.net/docs/game-references/blips/ || gangs allowed to territories, aswell as their label (label not in use yet, but planned in future) and blip color
    cartel = { -- posao / job
        label = 'Cartel',
        blipboja = 59, -- boja blipa / blip color
    },
    families = { -- posao / job
        label = 'Families',
        blipboja = 60, -- boja blipa / blip color
    },
}