---@diagnostic disable: duplicate-set-field

----------------------------------------------------------------------------------------------------
-- IMPORTS
----------------------------------------------------------------------------------------------------

local luaunit = require('tests.utils.luaunit')
local AI_request = require('infra.AI.requests')
local events = require('tests.mocks.mock_situation')

-- Stubbing dependencies
local model = require('infra.AI.GPT')
local memory_store = require('tests.mocks.mock_memories')
local event_store = require('tests.mocks.mock_event_store')
----------------------------------------------------------------------------------------------------
-- CONSTANTS
----------------------------------------------------------------------------------------------------

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
    callback("Speaker: 'Dialogue generated'")
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
        luaunit.assertEquals(dialogue, "Dialogue generated")
    end)
    luaunit.assertTrue(callbackExecuted)
end

function testIfIdInRecentEvents()
    local should_be_false = check_if_id_in_recent_events(events, 'bla')
    luaunit.assertFalse(should_be_false)
    local should_be_true = check_if_id_in_recent_events(events, '1')
    luaunit.assertTrue(should_be_true)
end

----------------------------------------------------------------------------------------------------
-- Transformatio tests
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- RUNNER
----------------------------------------------------------------------------------------------------

os.exit(luaunit.LuaUnit.run())