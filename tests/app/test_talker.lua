---@diagnostic disable: duplicate-set-field
print(_VERSION)

package.path = package.path .. ';./bin/lua/?.lua'
package.path = package.path .. ';./bin/lua/*/?.lua'

-- Import required modules
local luaunit = require('tests.utils.luaunit')
local mock_situation = require("tests.mocks.mock_situation")
local assert_or_record = require("tests.utils.assert_or_record")
local talker = require('app.talker')
local mock_game_adapter = require('tests.mocks.mock_game_adapter')
talker.set_game_adapter(mock_game_adapter)

local event_store = require('domain.repo.event_store')


-- Mock the AI_request module
local AI_request = require('infra.AI.requests')
local dialogue_mock = "'Hello, world!'"

-- Mock the AI_request.generate_dialogue function
AI_request.generate_dialogue = function(speaker_id, final_callback)
    print("AI_request.generate_dialogue has been mocked!")
    final_callback(dialogue_mock)
end

-- Test Scenario: Kill Event
function Test_ScenarioKill()
    print("TestScenarioKill")
    local expected_dialogue
    talker.deliver_dialogue_to_game = function(dialogue)
        print("talker.deliver_dialogue_to_game has been mocked!")
        expected_dialogue = dialogue
    end

    -- Simulate the event where a character has been killed
    local events = mock_situation
    talker.register_event(events[1], true)

    -- Small delay to simulate asynchronous behavior
    os.execute("sleep 0.1")

    -- Retrieve events and perform assertions
    local result = event_store:get_events_since(5)
    luaunit.assertEquals(expected_dialogue, dialogue_mock)
    assert_or_record('app', 'TestScenarioKill', result)
end

-- Run the tests
os.exit(luaunit.LuaUnit.run())