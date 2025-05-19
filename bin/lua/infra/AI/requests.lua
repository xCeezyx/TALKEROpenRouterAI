
-- AI_request module
-- This module is responsible for the AI_request's functionalities.
-- It provides functions for:
-- - picking the next speaker
-- - compressing memories
-- - requesting dialogue
-- they use a callback system to deal with the asynchronous nature of the AI requests

package.path = package.path .. ";./bin/lua/?.lua"

local transformations = require "infra.AI.transformations"
local model = require("infra.AI.GPT")
local prompt_builder = require("infra.AI.prompt_builder")
local logger = require("framework.logger")
local memory_store = require("domain.repo.memory_store")
local config = require("interface.config")
local dialogue_cleaner = require("infra.AI.dialogue_cleaner")

local AI_request = {}
AI_request.__index = AI_request

-- to be moved
local function is_player(character_id)
    return tostring(character_id) == "0"
end

------------------------------------------------------------------------------------------
-- Core functions
------------------------------------------------------------------------------------------

function check_if_id_in_recent_events(recent_events, picked_speaker_id)
    local latest_event = recent_events[#recent_events]
    local witnesses = latest_event.witnesses
    for _, witness in ipairs(witnesses) do
        if tostring(tostring(witness.game_id)) == tostring(tostring(picked_speaker_id)) then
            return true
        end
    end
    logger.warn('AI picked invalid speaker:' .. picked_speaker_id)
    return false
end

function is_valid_speaker(recent_events, picked_speaker_id)
    -- check if speaker id was in recent events
    if not check_if_id_in_recent_events(recent_events, picked_speaker_id) then
        logger.warn("AI did not pick a valid speaker: " .. picked_speaker_id)
        return false
    end
    logger.info("Picked next speaker: " .. picked_speaker_id)
    -- check if player was picked
    if is_player(picked_speaker_id) and not config.player_speaks then
        logger.info("Player picked, but does not speak automatically")
        return false
    end
    return true
end

function AI_request.pick_speaker(recent_events, compress_memories)
    logger.info("AI_request.pick_speaker")
    -- start function
    local speakers = transformations.pick_potential_speakers(recent_events)

    if not speakers then -- only player
        logger.warn("No viable speaker found close enough to player")
        return nil
    end
    
    if #speakers == 1 then -- no need to pick using AI
        logger.warn("No viable speaker found close enough to player")
        logger.debug('Compressing memories after picking speaker')
        return compress_memories(speakers[1].game_id)
    end

    local messages = prompt_builder.create_pick_speaker_prompt(recent_events, speakers)
    -- call the model to pick the next speaker
    return model.pick_speaker(messages, function(picked_speaker_id)
        -- check if AI picked a valid speaker
        if not is_valid_speaker(recent_events, picked_speaker_id) then return end
        -- move on to compress memories step
        -- this is actually a callback given to the pick_speaker function, but it's expected to be compress_memories
        logger.debug('Compressing memories after picking speaker')
        compress_memories(picked_speaker_id)
    end)
end

--- Compresses older memories when the threshold is exceeded
-- @param speaker_id The ID of the speaker whose memories are being compressed
-- @param request_dialogue Function to request dialogue after compression
function AI_request.compress_memories(speaker_id, request_dialogue)
    logger.info("AI_request.compress_memories")

    -- Fetch new memories
    local memories = memory_store:get_current_memories(speaker_id)
    logger.info("# of memories fetched: " .. #memories)

    local old_memories = transformations.select_old_memories_for_compression(memories)

    -- If there are no old memories to compress, just proceed with the dialogue
    if #old_memories == 0 then
        request_dialogue(speaker_id)
        return
    end

    -- Generate a prompt for memory compression and send a request to the model
    local game_time_of_oldest_memory = old_memories[#old_memories].game_time_ms
    local messages = prompt_builder.create_compress_memories_prompt(old_memories)
    model.summarize_story(messages, function(compressed_memory)
        -- after receiving a response...
        logger.info("Compressed memories: " .. compressed_memory)
        memory_store:store_compressed_memory(speaker_id, compressed_memory, game_time_of_oldest_memory)
        request_dialogue(speaker_id)
    end)
    return old_memories -- for testing
end


function AI_request.request_dialogue(speaker_id, callback)
    logger.info("AI_request.request_dialogue")
    local all_memories = memory_store:get_all_memories(speaker_id)
    if #all_memories == 0 then
        error("No memories found for speaker: " .. (speaker_id or ""))
    end
    local speaker_character = AI_request.get_character_by_id(speaker_id)
    local messages = prompt_builder.create_dialogue_request_prompt(speaker_character, all_memories)

    -- call the model to generate the dialogue
    return model.generate_dialogue(messages, function(generated_dialogue)
        -- when it responds...
        if generated_dialogue == nil then
            logger.error("Error generating dialogue")
            return
        end
        logger.info("Received dialogue: " .. generated_dialogue)
        generated_dialogue = dialogue_cleaner.improve_response_text(generated_dialogue) -- remove censorship and other unwanted content
        callback(generated_dialogue)
    end)
end

------------------------------------------------------------------------------------------
-- Utility functions
------------------------------------------------------------------------------------------

AI_request.witnesses = {}
-- Utility function to extract witness names using saved IDs
function AI_request.get_character_by_id(speaker_id)
    logger.info("Getting character name for ID: " .. speaker_id)
    for _, witness in ipairs(AI_request.witnesses) do
        logger.debug("Checking witness: " .. witness.game_id)
        if tostring(witness.game_id) == tostring(speaker_id) then
            return witness
        end
    end
    error("No character found for ID: " .. tostring(speaker_id))
end

function AI_request.set_witnesses(recent_events)
    AI_request.witnesses = recent_events[#recent_events].witnesses
end

-- Sequencing function
function AI_request.generate_dialogue(recent_events, function_send_dialogue_to_game)
    logger.info("AI_request.generate_dialogue")
    AI_request.set_witnesses(recent_events)
    -- first we ask the AI to pick the character that should speak next
    AI_request.pick_speaker(recent_events, function(speaker_id)
        -- then we compress the memories of the speaker
        AI_request.compress_memories(speaker_id, function()
            -- finally we request the dialogue of the speaker
            AI_request.request_dialogue(speaker_id, function(dialogue)
                -- then we call the initial callback with that dialogue
                function_send_dialogue_to_game(speaker_id, dialogue)
            end)
        end)
    end)
end



-- for mocks
function AI_request.insert_mocks(mock_memory_store, mock_game, mock_prompt_builder)
    memory_store = mock_memory_store
    transformations.mockGame(mock_game)
    if mock_prompt_builder ~= nil then
        prompt_builder = mock_prompt_builder
    end
end

return AI_request