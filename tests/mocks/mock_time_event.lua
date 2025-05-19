-- Mock for CreateTimeEvent
local mock = {}
local currentTime = 0

-- Mock CreateTimeEvent function, which attempts the fun in x seconds and repeats every x seconds until the fun returns true
function mock.CreateTimeEvent(eventId, actionId, seconds, func, ...)
    local max_seconds_timeout = 5
    while true or max_seconds_timeout > 0 do
        if func(...) then
            break
        end
        max_seconds_timeout = max_seconds_timeout - 1
        os.execute("sleep " .. seconds)
    end
end

return mock