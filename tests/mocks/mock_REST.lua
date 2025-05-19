local http_module_mock = {}

-- Dependencies
local json = require("infra.HTTP.json")

-- Constants
http_module_mock.CHECK_INTERVAL_S = 0.1

-- Private variables
local response_handlers = {}

-- Helper functions
local function generate_random_id()
    return tostring(math.random(1000000, 9999999))
end

-- Mock function to simulate sending a request
function http_module_mock.send_request(url, method, headers, body)
    local requestId = generate_random_id()

    response_handlers[requestId] = {
        response = {
            status = 200,
            body = "Mock response for " .. method .. " " .. url,
            headers = headers
        },
        error = nil
    }

    -- Simulate a delay for the response
    response_handlers[requestId].delay = os.time() + math.random(1, 3) -- 1 to 3 seconds delay

    return requestId
end

-- Mock function to simulate checking the response
function http_module_mock.checkResponse(requestId)
    local handler = response_handlers[requestId]
    if not handler then
        return nil, "No handler for request ID: " .. requestId
    end

    if os.time() >= handler.delay then
        handler.socket = nil -- Simulate closing the socket
        return handler.response, nil
    end

    return false -- "Response not ready"
end

-- Mock function to simulate sending an async request
function http_module_mock.send_async_request(url, method, headers, body, callback)
    local requestId = http_module_mock.send_request(url, method, headers, body)
    
    local function checkAndRespond()
        local response, error = http_module_mock.checkResponse(requestId)
        if response or error then
            callback(response, error, requestId)
            return true
        end
        return false
    end

    -- Simulate repeated checks
    repeat_until_true(http_module_mock.CHECK_INTERVAL_S, checkAndRespond)

    return requestId
end

return http_module_mock