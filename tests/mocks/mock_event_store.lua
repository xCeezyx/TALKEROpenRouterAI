package.path = package.path .. ';./bin/lua/?.lua;'
local events = require('tests.mocks.mock_situation')
local event_store = require('domain.repo.event_store')

for _, event in ipairs(events) do
    event_store:store_event(event)
end

return event_store