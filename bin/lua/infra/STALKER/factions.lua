local logger = require('framework.logger')

local factions = {
    killer = {
        name = "Mercenary",
        style = "tactical"
    },
    dolg = {
        name = "Duty",
        style = "authoritative, stern"
    },
    freedom = {
        name = "Freedom",
        style = "relaxed, stoner"
    },
    bandit = {
        name = "Bandit",
        style = "vatnik"
    },
    monolith = {
        name = "Monolith",
        style = "fanatical, cryptic"
    },
    stalker = {
        name = "stalker",
        style = "plain-spoken"
    },
    csky = {
        name = "Clear Sky",
        style = "plain-spoken"
    },
    ecolog = {
        name = "Ecolog",
        style = "ecologist"
    },
    army = {
        name = "Army",
        style = "reluctant, undisciplined"
    },
    renegade = {
        name = "Renegade",
        style = "despicable"
    },
    trader = {
        name = "Trader",
        style = "persuasive, smooth"
    },
    greh = {
        name = "Sin",
        style = "creepy, possessed"
    },
    isg = {
        name = "ISG",
        style = "professional, formal"
    },
    zombied = {
        name = "Zombied",
        style = "incoherent, groaning. Make it barely intelligible or not at all, this character has been zombified by psy emissions. Make it rather sad and tragic."
    },
    monster = {
        name = "Monster",
        style = "incredibly polite"
    }
}
function get_faction_name(technical_name)
    -- Remove 'actor_' prefix if it exists
    local clean_name = technical_name:gsub("^actor_", "")
    local faction = factions[clean_name]
    if faction then
        return faction.name
    else
        return nil
    end
end

function get_faction_speaking_style(natural_name)
    for technical_name, faction in pairs(factions) do
        if faction.name == natural_name then
            return faction.style
        end
    end
    logger.warn("No faction found with name: " .. natural_name)
    return nil
end

return get_faction_name, get_faction_speaking_style