-- Adjust the package path
package.path = package.path .. ';./bin/lua/?.lua;./bin/lua/*/?.lua'

-- Require LuaUnit and event_store module
local luaunit = require('tests.utils.luaunit')
local event_store = require('domain.repo.event_store')

-- Helper function to create mock events
local function create_mock_event(game_time_ms, source_event)
    return {
        description = "Mock Event",
        objects = {},
        game_time_ms = game_time_ms,
        world_context = "Somewhere",
        witnesses = {},
        source_event = source_event
    }
end

-- Helper function to store a sequence of events
local function store_mock_events(event_store, count, start_time, interval)
    for i = 1, count do
        event_store:store_event(create_mock_event(start_time + (i - 1) * interval, nil))
    end
end

-- Test storing a single event
function testStoreSingleEvent()
    local event = create_mock_event(1000, nil)
    event_store:store_event(event)
    local retrieved_event = event_store:get_event(1000)

    luaunit.assertNotNil(retrieved_event)
    luaunit.assertEquals(retrieved_event.description, "Mock Event")
    luaunit.assertEquals(retrieved_event.game_time_ms, 1000)
end

-- Test storing multiple events with the same game_time
function testStoreMultipleEventsSameTime()
    
    for i = 1, 3 do
        event_store:store_event(create_mock_event(1000, nil))
    end

    for i = 0, 2 do
        local retrieved_event = event_store:get_event(1000 + i)
        luaunit.assertNotNil(retrieved_event)
        luaunit.assertEquals(retrieved_event.game_time_ms, 1000 + i)
    end
end

-- Test retrieving an event that does not exist
function testRetrieveNonExistentEvent()
    
    luaunit.assertNil(event_store:get_event(9999))
end

-- Test that the event source_event reference is preserved correctly
function testSourceEventPreservation()
    
    local source_event = create_mock_event(500, nil)
    event_store:store_event(source_event)
    event_store:store_event(create_mock_event(1000, source_event))

    local retrieved_event = event_store:get_event(1000)
    luaunit.assertNotNil(retrieved_event)
    luaunit.assertNotNil(retrieved_event.source_event)
    luaunit.assertEquals(retrieved_event.source_event.game_time_ms, 500)
end

-- Test getting recent events
function testGetEventsSince()
    
    store_mock_events(event_store, 5, 1000, 1000)

    local recent_events = event_store:get_events_since(3000)

    luaunit.assertEquals(#recent_events, 3)
    luaunit.assertEquals(recent_events[1].game_time_ms, 3000)
    luaunit.assertEquals(recent_events[2].game_time_ms, 4000)
    luaunit.assertEquals(recent_events[3].game_time_ms, 5000)
end

-- Test counting recent events
function testGetCountEventSince()
    
    store_mock_events(event_store, 5, 1000, 1000)

    local recent_events_count = event_store:get_count_events_since(4000)

    luaunit.assertEquals(recent_events_count, 2)
end

-- Run the tests
os.exit(luaunit.LuaUnit.run())