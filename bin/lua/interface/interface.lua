-- interface.lua
local log = require("framework.logger")
local talker = require("app.talker")
local game_adapter = require("infra.game_adapter")

local m = {}

-- prototype

function m.register_game_event_near_player(unformatted_description, involved_objects, important)
    local witnesses = game_adapter.get_characters_near_player()
    m.register_game_event(unformatted_description, involved_objects, witnesses, important)
end

local function register_game_event(unformatted_description, event_objects, witnesses, important)
    log.info("Registering game event")
    local new_event = game_adapter.create_game_event(unformatted_description, event_objects, witnesses)
    log.debug("New event: %s", new_event)
    talker.register_event(new_event, important)
end

-- prevents issues later down the line with formatting
local function check_format_sanity(unformatted_description, event_objects)
    -- returns true if the amounts of format strings like %s match the amount of event_objects
    local format_count = select(2, unformatted_description:gsub("%%s", ""))
    if not format_count == #event_objects then
        log.error("Not enough event objects for description: %s", unformatted_description)
        return false
    end
    return true
end

function m.register_game_event(unformatted_description, event_objects, witnesses, important)
    if not check_format_sanity(unformatted_description, event_objects) then return end
    local success, error = pcall(register_game_event, unformatted_description, event_objects, witnesses, important)
    if not success then
        log.error("Failed to register game event: %s", error)
    end
end

----------------------------------------------------------------------------------------------------
-- SEND PLAYER DIALOGUE TO GAME 
----------------------------------------------------------------------------------------------------

-- function recorder.to register the player's dialogue as a game event
function m.player_character_speaks(dialogue)
    log.info("Registering player speak event. Player said: " .. dialogue)
    local player = game_adapter.get_player_character()
    -- register new event
    m.register_game_event_near_player("%s said: %s", {player.name, dialogue}, true )
    -- show dialogue in game UI
    game_adapter.display_dialogue(player.game_id, dialogue)
end

return m
