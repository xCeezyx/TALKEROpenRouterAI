local http_module = {}

package.path = package.path .. ";./bin/lua/?.lua;"

-- Dependencies
local json = require("infra.HTTP.json")
local pollnet = require("infra.HTTP.pollnet")
local logger = require("framework.logger")

local game_adapter = require'infra.game_adapter'

-- Constants
http_module.CHECK_INTERVAL_S = 0.1

-- Private variables
local response_handlers = {}

-- Helper functions
local function generate_random_id() -- TODO this can probably be cut
    return tostring(math.random(1000000, 9999999))
end

-- Core functionality
function http_module.send_request(url, method, headers, body)
    local requestId = generate_random_id()

    response_handlers[requestId] = {
        response = nil,
        socket = nil,
        error = nil
    }

    encoded_body = json.encode(body)

    local status, sock
    if method:upper() == "POST" then
        status, sock = pcall(pollnet.http_post, url, headers, encoded_body, true)
    elseif method:upper() == "GET" then
        status, sock = pcall(pollnet.http_get, url, headers, true)
    else
        return nil, "Unsupported HTTP method"
    end

    if not status or not sock then
        response_handlers[requestId].error = "Failed to create response socket: " .. (sock or "Unknown error")
        return requestId, response_handlers[requestId].error
    end

    response_handlers[requestId].socket = sock
    return requestId
end

function http_module.checkResponse(requestId)
    local handler = response_handlers[requestId]
    if not handler then
        return nil, "No handler for request ID: " .. requestId
    end

    if handler.error then
        return nil, handler.error
    end

    if not handler.socket then
        return nil, "No response socket for request ID: " .. requestId
    end

    if handler.socket:poll() then
        local message = handler.socket:last_message()
        if message then
            local status, decoded = pcall(json.decode, message)
            if not status then
                handler.error = "Error decoding JSON response"
                handler.socket:close()
                handler.socket = nil
                return nil, handler.error
            end

            handler.response = decoded
            handler.socket:close()
            handler.socket = nil
            return handler.response, nil
        end
    end

    return false -- "Response not ready"
end

function http_module.send_async_request(url, method, headers, body, callback)
    local requestId = http_module.send_request(url, method, headers, body)

    local function checkAndRespond()
        local response, error = http_module.checkResponse(requestId)
        if response or error then
            callback(response, error, requestId)
            return true
        end
        return false
    end

    game_adapter.repeat_until_true(http_module.CHECK_INTERVAL_S, checkAndRespond) -- TODO weird connection to game logic

    return requestId
end

return http_module