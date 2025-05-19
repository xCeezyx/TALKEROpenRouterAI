-- Adjust the package path to ensure LuaUnit and event_store can be required
package.path = package.path .. ';./bin/lua/?.lua'
package.path = package.path .. ';./bin/lua/*/?.lua'

local lu = require("tests.utils.luaunit")
local GPTModule = require("infra.AI.GPT")
local mock_time_event = require("tests/mocks/mock_time_event")

-- Helper function to load API key
local function loadApiKey()
    local file = io.open("api_key.txt", "r")
    if not file then
        error("Failed to load API key. Make sure api_key.txt exists in the same directory.")
    end
    local apiKey = file:read("*all")
    file:close()
    return apiKey:gsub("%s+", "") -- Remove any whitespace
end

-- Override the loadApiKey function in GPTModule
GPTModule.loadApiKey = loadApiKey

-- Test cases -- remove _ to enable, but these are real API calls

local function test_ApiConnection()
    local called = false
    local success = false

    GPTModule.send_request(
        {
            {role = "user", content = "Hello, this is a test message."}
        },
        function(content, error, reqId)
            called = true
            if error then
                print("Error occurred: " .. tostring(error))
                success = false
            else
                print("Received response: " .. tostring(content))
                success = true
            end
        end,
        GPTModule.default_config,
        GPTModule.MODEL_FAST
    )

    -- Wait for the async callback
    local waitTime = 0
    while not called and waitTime < 6 do
        os.execute("sleep 1")
        waitTime = waitTime + 1
    end

    lu.assertTrue(called, "Callback was not called within 5 seconds")
    lu.assertTrue(success, "API call was not successful")
end

local function test_ApiRateLimiting()
    local successCount = 0
    local totalCalls = 5
    local calls = 0

    for i = 1, totalCalls do
        GPTModule.send_request(
            {
                {role = "user", content = "Quick test " .. i}
            },
            function(content, error, reqId)
                calls = calls + 1
                if not error then
                    successCount = successCount + 1
                end
            end,
            GPTModule.default_config,
            GPTModule.MODEL_FAST
        )
    end

    -- Wait for all callbacks
    local waitTime = 0
    while calls < totalCalls and waitTime < 60 do
        os.execute("sleep 1")
        waitTime = waitTime + 1
    end

    lu.assertEquals(calls, totalCalls, "Not all calls completed within 60 seconds")
    lu.assertEquals(successCount, totalCalls, "Not all API calls were successful")
end

-- Run the tests
-- os.exit(lu.LuaUnit.run())