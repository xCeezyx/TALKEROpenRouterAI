---@diagnostic disable: duplicate-set-field

----------------------------------------------------------------------------------------------------
-- IMPORTS
----------------------------------------------------------------------------------------------------

local luaunit = require('tests.utils.luaunit')
local AI_request = require('infra.AI.requests')
local events = require('tests.mocks.mock_situation')
local transformations = require('infra.AI.transformations')

-- Stubbing dependencies
local model = require('infra.AI.GPT')
local memory_store = require('tests.mocks.mock_memories')
local mock_characters = require('tests.mocks.mock_characters')
----------------------------------------------------------------------------------------------------
-- CONSTANTS
----------------------------------------------------------------------------------------------------

-- Global mocks
local game_mock = {
    get_distance_to_player = function(game_id)
        return 5
    end,

    is_player = function(character_id)
        print("mocking game")
        return tostring(character_id) == "player" or tostring(character_id) == "1"
    end
}

local mock_prompt_builder = {
    create_pick_speaker_prompt = function()
        return "pick speaker"
    end,
    create_dialogue_request_prompt = function()
        return "dialogue request prompt"
    end
}

AI_request.insert_mocks(memory_store, game_mock, mock_prompt_builder)

local MODEL_UTILITY_RESPONSE = "model utility response"

----------------------------------------------------------------------------------------------------
-- Mocking utility functions in AI_request
----------------------------------------------------------------------------------------------------

function model.pick_speaker(input, callback)
    callback(MODEL_UTILITY_RESPONSE) -- Directly call the callback for simplicity
end

function model.summarize_story(input, callback)
    callback(MODEL_UTILITY_RESPONSE) -- Directly call the callback for simplicity
end

function model.generate_dialogue(input, callback)
    luaunit.assertTrue(input ~= nil)
    callback("Speaker lastname: 'Dialogue generated'")
end

function memory_store:store_compressed_memory(id, memory)
    -- do nothing for the mock
end

----------------------------------------------------------------------------------------------------
-- TESTS
----------------------------------------------------------------------------------------------------

function testSaveAndLoadNames()
    AI_request.set_witnesses(events)
    local result = AI_request.get_character_by_id("1")
    luaunit.assertEquals(result and result.name, "Anonsky")
end

-- Tests
function testPickNextSpeaker()
    AI_request.set_witnesses(events)
    AI_request.pick_speaker(events, function(
        speaker_id) luaunit.assertEquals(speaker_id, MODEL_UTILITY_RESPONSE
    ) end)
end

function testCompressMemories()
    AI_request.set_witnesses(events)
    local asserted = false
    local function after_compression()
        local old_memories = memory_store:get_memories("1")
        local new_memories = memory_store:get_new_memories("1")
        if not old_memories or not new_memories then
            luaunit.fail("No memories found")
        end
        for _, memory in ipairs(new_memories) do
            local found = false
            for _, old_memory in ipairs(old_memories) do
            if memory.id == old_memory.id then
                luaunit.assertTrue(memory.game_time_ms >= old_memory.game_time_ms)
                found = true
                break
            end
            end
            luaunit.assertTrue(found, "New memory does not match any old memory")
        end
        asserted = true
    end
    local memories = AI_request.compress_memories("1", after_compression)
    luaunit.assertTrue(asserted)
end

function testRequestDialogue()
    AI_request.set_witnesses(events)
    local callbackExecuted = false
    AI_request.insert_mocks(memory_store)
    AI_request.request_dialogue("1", function(dialogue)
        callbackExecuted = true
        luaunit.assertTrue(string.find(dialogue, "Dialogue generated") ~= nil) -- "speaker:"" should be removed
    end)
    luaunit.assertTrue(callbackExecuted)
end

function testIfIdInRecentEvents()
    local should_be_false = check_if_id_in_recent_events(events, 'bla')
    luaunit.assertFalse(should_be_false)
    local should_be_true = check_if_id_in_recent_events(events, '1')
    luaunit.assertTrue(should_be_true)
end

local function response_will_not_be_called_during_this_test()
    luaunit.fail("Response should not be called")
end


function testSkipSpeakerPickingWithSingleWitnessPlusPlayer()
    -- Arrange
    -- Mock model.pick_speaker to detect if it's called
    local modelPickSpeakerCalled = false
    local originalModelPickSpeaker = model.pick_speaker
    model.pick_speaker = function(input, callback)
        modelPickSpeakerCalled = true
    end

    local compress_memories_called = false
    AI_request.compress_memories = function(speaker_id, callback)
        compress_memories_called = true
    end

    -- Use the mock characters as witnesses
    mock_characters = require('tests.mocks.mock_characters')

    -- Create a recent_events table where the last event has only one witness
    local recent_events = {
        {
            -- Some previous event with multiple witnesses
            witnesses = {
                mock_characters[1], -- Anonsky
                mock_characters[2], -- Sarik
                mock_characters[3], -- Danila Matador
            },
            game_time_ms = 1,
            involved_objects = {}
        },
        {
            -- Last event with only one witness + player
            witnesses = {
                mock_characters[1], -- Anonsky
                mock_characters[3], -- Danila Matador
            },
            game_time_ms = 2,
            involved_objects = {mock_characters[1]}
        },
    }

    AI_request.generate_dialogue(recent_events, response_will_not_be_called_during_this_test)

    -- Assert
    luaunit.assertFalse(modelPickSpeakerCalled, "model.pick_speaker should not be called when only one witness + player is present")
    luaunit.assertTrue(compress_memories_called, "compress_memories should be called")

    -- Restore mocked functions
    model.pick_speaker = originalModelPickSpeaker
end


----------------------------------------------------------------------------------------------------
-- RUNNER
----------------------------------------------------------------------------------------------------

os.exit(luaunit.LuaUnit.run())