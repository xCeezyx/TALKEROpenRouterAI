-- Adjust the package path to ensure LuaUnit and event_store can be required
package.path = package.path .. ';./bin/lua/?.lua'
package.path = package.path .. ';./bin/lua/*/?.lua'

local lu = require("test_s/luaunit")
local http_module = require("infra.HTTP.HTTP")

-- Mock pollnet module
local mockPollnet = {}
local mockSocket = {}

function mockSocket:poll()
    return self.pollResult
end

function mockSocket:last_message()
    return self.lastMessage
end

function mockSocket:close()
    self.closed = true
end

function mockPollnet.http_post(url, headers, body, async)
    mockPollnet.lastCall = {method = "POST", url = url, headers = headers, body = body, async = async}
    return true, mockSocket
end

function mockPollnet.http_get(url, headers, async)
    mockPollnet.lastCall = {method = "GET", url = url, headers = headers, async = async}
    return true, mockSocket
end

-- Replace the original pollnet with our mock
package.loaded["pollnet"] = mockPollnet

function setUp()
    mockPollnet.lastCall = nil
    mockSocket.pollResult = false
    mockSocket.lastMessage = nil
    mockSocket.closed = false
end

local function test_sendRequest_POST()
    local requestId, error = http_module.send_request("http://example.com", "POST", {["Content-Type"] = "application/json"}, '{"key": "value"}')
    
    lu.assertNotNil(requestId)
    lu.assertNil(error)
    lu.assertEquals(mockPollnet.lastCall.method, "POST")
    lu.assertEquals(mockPollnet.lastCall.url, "http://example.com")
    lu.assertEquals(mockPollnet.lastCall.headers["Content-Type"], "application/json")
    lu.assertEquals(mockPollnet.lastCall.body, '{"key": "value"}')
    lu.assertTrue(mockPollnet.lastCall.async)
end

local function test_sendRequest_GET()
    local requestId, error = http_module.send_request("http://example.com", "GET", {["Accept"] = "application/json"})
    
    lu.assertNotNil(requestId)
    lu.assertNil(error)
    lu.assertEquals(mockPollnet.lastCall.method, "GET")
    lu.assertEquals(mockPollnet.lastCall.url, "http://example.com")
    lu.assertEquals(mockPollnet.lastCall.headers["Accept"], "application/json")
    lu.assertTrue(mockPollnet.lastCall.async)
end

local function test_sendRequestUnsupportedMethod()
    local requestId, error = http_module.send_request("http://example.com", "PUT", {})
    
    lu.assertNil(requestId)
    lu.assertEquals(error, "Unsupported HTTP method")
end

local function test_CheckResponseNoHandler()
    local response, error = http_module.checkResponse("non_existent_id")
    
    lu.assertNil(response)
    lu.assertEquals(error, "No handler for request ID: non_existent_id")
end

local function test_CheckResponseSuccess()
    local requestId = http_module.send_request("https://dummyjson.com/posts/1", "GET", {})

    local response = nil
    local error = nil
    attempts = 0
    while response == nil and attempts < 50 do
        print("Attempt " .. attempts)
        response, error = http_module.checkResponse(requestId)
        os.execute("sleep " .. tonumber(0.1))
        attempts = attempts + 1
    end
    lu.assertNotNil(response)
    lu.assertNil(error)
end

local function test_CheckResponseNotReady()
    local requestId = http_module.send_request("http://example.com", "GET", {})
    mockSocket.pollResult = false
    
    local response, error = http_module.checkResponse(requestId)
    
    lu.assertFalse(response)
end

local function test_CheckResponseJSONDecodeError()
    local requestId = http_module.send_request("http://example.com", "GET", {})
    mockSocket.pollResult = true
    mockSocket.lastMessage = 'invalid json'
    

    local response = false
    local error = nil
    attempts = 0
    while (response == false) and attempts < 50 do
        print("Attempt " .. attempts)
        response, error = http_module.checkResponse(requestId)
        os.execute("sleep " .. tonumber(0.1))
        attempts = attempts + 1
        print("Attempt ending " .. attempts)
    end
    
    lu.assertEquals(error, "Error decoding JSON response")
end


-- Run the test_s
lu.LuaUnit.run()