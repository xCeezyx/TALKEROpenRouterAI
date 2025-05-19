---@diagnostic disable: duplicate-set-field
-- Adjust the package path to ensure LuaUnit and event_store can be required
package.path = package.path .. ';./bin/lua/?.lua'
package.path = package.path .. ';./bin/lua/.*/?.lua'
package.path = package.path .. ';./gamedata/scripts/?.script'

local lu = require("tests.utils.luaunit")
local GPT = require('infra.AI.GPT')
local http_module = require('infra.HTTP.HTTP')

talker_game_async = {}
talker_game_async.repeat_until_true = function(seconds, func, ...)
    if func(...) then
        return func(...)
    else
        -- wait for the seconds
        os.execute("sleep " .. seconds)
        print("Waiting for " .. seconds .. " seconds")
        talker_game_async.repeat_until_true(seconds, func, ...)
    end
end

-- Mock http_module
http_module.send_async_request = function(url, method, headers, body, callback)
    local response = {
        choices = {
            {
                message = {
                    content = "Mocked response content"
                }
            }
        }
    }
    callback(response, nil)
end

-- Helper function to reset GPT before each test
local function resetGPT()
    package.loaded['GPT'] = nil
    GPT = require('infra.AI.GPT')
end

-- Test cases in global scope with camelCase names

function testSendConversationRequest()
    resetGPT()
    local called = false
    local requestId = GPT.send_request(
        {
            {role = "user", content = "Hello"}
        },
        function(content, error, reqId)
            called = true
            lu.assertNotNil(content)
            lu.assertNil(error)
        end
    )
    lu.assertTrue(called)
end

function testGenerateDialogue()
    resetGPT()
    local called = false
    GPT.generate_dialogue(
        {
            {role = "user", content = "Hello"},
            {role = "assistant", content = "Hi there!"}
        },
        function(content, error, reqId)
            called = true
            lu.assertNotNil(content)
            lu.assertNil(error)
        end
    )
    
    -- Wait for the async callback
    lu.assertTrue(called)
end

-- Run the tests
os.exit(lu.LuaUnit.run())