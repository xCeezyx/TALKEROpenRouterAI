-- the purpose of this module is to turn game objects into natural language descriptions
local prompt_builder = {}

-- imports
package.path = package.path .. ";./bin/lua/?.lua;"
local logger = require("framework.logger")
local Event  = require("domain.model.event")
local Character = require("domain.model.character")
local config = require("interface.config")
local game_adapter = require('infra.game_adapter')
require("infra.STALKER.factions")

local ToolsStrings = [[
List of tool actions, If you wanna interact with other people in the world then YOU MUST USE THESE.
When you want to invoke one, say them in text with this pattern:

    ExecuteAICommand(COMMAND_NAME, JSON_ARGUMENTS)

COMMAND LIST:
  • AttackIDs: {"ENTITYIDS":[integer_array]}
    – Description: MUST USE if you want to attack the entity with the given ID, only use if you want to kill the ENTITYID ALWAY USE to defend yourself or when threatened don't randomly use this.
    – Example:
          ExecuteAICommand(AttackIDs, {"ENTITYIDS":[42,7,1337]})

• GiveItem: {"ENTITYID": <integer>, "ITEMNAME": <text>, "AMOUNT": <integer>}
    – MUST USE if you want to give items to ENTITY ID.

End of command list.
]]

local function describe_characters_with_ids(characters)
    local descriptions = {}
    for _, character in ipairs(characters) do
        local desc = string.format("%s (ID: %d)", Character.describe(character), character.game_id)
        table.insert(descriptions, desc)
    end
    return table.concat(descriptions, ", ")
end

local function system_message(content)
    return {role = "system", content = content}
end

local function user_message(content)
    return {role = "user", content = content}
end

--------------------------------------------------------------------------------
-- create_pick_speaker_prompt: keep only the 5 most recent (oldest first)
--------------------------------------------------------------------------------
function prompt_builder.create_pick_speaker_prompt(recent_events, witnesses)
    if not witnesses or #witnesses == 0 then
        logger.warn("No witnesses in the last event.")
        return error("No witnesses in last event")
    end
    if #recent_events == 0 then
        logger.warn("No recent events passed in.")
        return error("No recent events")
    end

    logger.info("prompt_builder.create_pick_speaker_prompt with %d events", #recent_events)

    -- Log each event before sorting
    for i, evt in ipairs(recent_events) do
        logger.spam("Unsorted event #%d: %s", i, evt)
    end

    -- sort oldest to newest
    logger.debug("Sorting events by game_time_ms: %s", recent_events)
    table.sort(recent_events, function(a, b)
        return a.game_time_ms < b.game_time_ms
    end)

    -- Log each event after sorting
    for i, evt in ipairs(recent_events) do
        logger.spam("Sorted event #%d: %s", i, evt)
    end


    -- keep only the 5 most recent
    logger.spam("Selecting the 5 most recent events if available.")
    local start_index = math.max(#recent_events - 4, 1)
    local last_five_events = {}
    for i = start_index, #recent_events do
        local evt = recent_events[i]
        logger.spam("Adding event #%d to last_five_events: %s", i, evt)
        table.insert(last_five_events, evt)
    end

    local last_event = last_five_events[#last_five_events]
    logger.spam("Last event: %s", last_event)

    -- basic check for chronological order
    if #last_five_events > 1 then
        local second_last_event = last_five_events[#last_five_events - 1]
        if last_event.game_time_ms < second_last_event.game_time_ms then
            logger.warn("Events are not in chronological order: last: %d, second last: %d", 
                last_event.game_time_ms, second_last_event.game_time_ms)
        end
    end

    logger.spam("Number of witnesses in last event: %d", #witnesses)

    local messages = {
        system_message("Nearby characters are in order of distance: " .. describe_characters_with_ids(witnesses))
    }

    -- insert events from oldest to newest
    for i, evt in ipairs(last_five_events) do
        logger.spam("Inserting event #%d into user messages: %s", i, evt)
        local content = (evt == nil and "") 
        or evt.content
        or Event.describe_short(evt)
        table.insert(messages, user_message(content))
    end

    table.insert(messages, system_message("Pick the most likely next speaker and reply with only their ID nothing else."))
    logger.debug("Finished building pick_speaker_prompt with %d messages", #messages)
    return messages
end

--------------------------------------------------------------------------------
-- create_compress_memories_prompt: use all events (sorted oldest to newest)
--------------------------------------------------------------------------------
function prompt_builder.create_compress_memories_prompt(recent_events)
    -- sort oldest to newest
    table.sort(recent_events, function(a, b)
        return a.game_time_ms < b.game_time_ms
    end)

    local messages = {
        system_message("Consolidate the following memories into a shorter memory")
    }

    for _, event in ipairs(recent_events) do
        table.insert(messages, user_message(event.content or Event.describe_short(event)))
    end

    return messages
end

--------------------------------------------------------------------------------
-- create_dialogue_request_prompt: keep only the 10 most recent (oldest first)
--------------------------------------------------------------------------------
function prompt_builder.create_dialogue_request_prompt(speaker, memories)
    -- warn if more than 10 memories
    if #memories > 10 then
        logger.warn("More than 10 memories for dialogue request, number was " .. #memories)
    end
    -- sort oldest to newest
    table.sort(memories, function(a, b)
        return a.game_time_ms < b.game_time_ms
    end)

    -- keep only the 10 most recent
    local start_index = math.max(#memories - 9, 1)
    local last_ten_memories = {}
    for i = start_index, #memories do
        table.insert(last_ten_memories, memories[i])
    end

    local messages = {
        system_message(config.dialogue_prompt())
    }

    for _, memory in ipairs(last_ten_memories) do
        local content = memory.content or Event.describe_short(memory)
        table.insert(messages, user_message(content))
    end

    -- use the world_context of the newest memory
    if #last_ten_memories > 0 and last_ten_memories[#last_ten_memories].world_context then
        table.insert(messages, system_message(last_ten_memories[#last_ten_memories].world_context))
    end

    local weapon_info = ""
    if speaker.weapon then
        weapon_info = " who is carrying a " .. speaker.weapon
    end

    local inventory_info_start = " with a inventory containing "
    local inventory_info = inventory_info_start
    
    local InventoryItemAmount = {}
    local InventoryItems = {}

    local NearbyCharacterDescriptions = ""

    local speakerobject = level.object_by_id(tonumber(speaker.game_id))

    if speakerobject then
        speakerobject:iterate_inventory( function(temp, obj)
            local Item_Info = ui_item.get_sec_name(obj:section())
            if Item_Info then
                if InventoryItemAmount[Item_Info] == nil then
                    table.insert(InventoryItems, Item_Info)
                    InventoryItemAmount[Item_Info] = 1
                else
                   InventoryItemAmount[Item_Info] = InventoryItemAmount[Item_Info]+ 1
                end
                
            end
        end)

        NearbyCharacterDescriptions = "They also see :{"

        local characters = game_adapter.get_characters_near(speakerobject, 25)
        for _, character in ipairs(characters) do
            local desc = string.format(" (ID: %d) %s", Character.describe(character), character.game_id)
            NearbyCharacterDescriptions = NearbyCharacterDescriptions..desc..", "
        end
        NearbyCharacterDescriptions = NearbyCharacterDescriptions.."}"

    end
    for i,v in pairs(InventoryItems) do 
        local ItemAmount = InventoryItemAmount[v]
        local AmountText = tostring(ItemAmount)
        inventory_info = inventory_info..v..","
    end

    if inventory_info == inventory_info_start then
        inventory_info = inventory_info.."nothing"
    else
        inventory_info = inventory_info..". "
    end

    logger.info("Creating prompt for speaker: %s", speaker)

    table.insert(messages, system_message(ToolsStrings) )
    table.insert(messages, system_message("Write the next dialogue spoken by "
        .. speaker.name
        .. (weapon_info or "")
        .. (inventory_info or "")
        .. " in a "
        .. (speaker.personality or "")
        .. ", "
        .. (get_faction_speaking_style(speaker.faction) or "")
        .. " manner."
        ..NearbyCharacterDescriptions
        .. "Make use of tool actions if they fit the context, YOU MUST STILL MAKE DIALOUGE. "))
    table.insert(messages, system_message("Reply only in " .. config.language()))
    return messages
end

--------------------------------------------------------------------------------
-- create_transcription_prompt: no sorting or slicing needed
--------------------------------------------------------------------------------
function prompt_builder.create_transcription_prompt(names)
    logger.info("Creating transcription prompt")
    local prompt = "STALKER games setting, nearby characters are: "
    for i, name in ipairs(names) do
        prompt = prompt .. name
        if i < #names then
            prompt = prompt .. ", "
        end
    end
    return prompt
end

return prompt_builder