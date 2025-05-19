-- Adjust the package path to ensure LuaUnit and event_store can be required
package.path = package.path .. ';./bin/lua/?.lua'
package.path = package.path .. ';./bin/lua/*/?.lua'

-- Require LuaUnit and the Event module
local luaunit = require('tests.utils.luaunit')
local Event = require('domain.model.event')

-- Test Suite for Event

-- Test Event creation
function testEventCreation()
    local event = Event.create_event(Event.TYPE.ACTION, {"John", "picked up", "a sword"}, 1000, "Forest", {"Alice"})
    luaunit.assertNotNil(event)
    luaunit.assertEquals(event.description, Event.TYPE.ACTION)
    luaunit.assertEquals(#event.involved_objects, 3)
    luaunit.assertEquals(event.game_time_ms, 1000)
    luaunit.assertEquals(event.world_context, "Forest")
    luaunit.assertEquals(#event.witnesses, 1)
    luaunit.assertNil(event.source_event)
end

-- Test Event description function
function testEventDescription()
    local event = Event.create_event(Event.TYPE.DIALOGUE, {"Alice", "Hello, world!"}, 2000, "Town Square")
    local description = Event.describe_event(event)
    luaunit.assertEquals(description, "Alice: 'Hello, world!'")
end

-- Test Event types
function testEventTypes()
    local dialogue = Event.create_event(Event.TYPE.DIALOGUE, {"Bob", "Hi there!"}, 3000, "Tavern")
    local action = Event.create_event(Event.TYPE.ACTION, {"Charlie", "opened", "a chest"}, 4000, "Dungeon")
    local kill = Event.create_event(Event.TYPE.KILL, {"David", "Goblin"}, 5000, "Battlefield")
    local spot = Event.create_event(Event.TYPE.SPOT, {"Eve", "a hidden treasure"}, 6000, "Cave")
    local hear = Event.create_event(Event.TYPE.HEAR, {"Frank", "footsteps"}, 7000, "Dark Alley")

    luaunit.assertEquals(Event.describe_event(dialogue), "Bob: 'Hi there!'")
    luaunit.assertEquals(Event.describe_event(action), "Charlie opened a chest")
    luaunit.assertEquals(Event.describe_event(kill), "David killed Goblin")
    luaunit.assertEquals(Event.describe_event(spot), "Eve spotted a hidden treasure")
    luaunit.assertEquals(Event.describe_event(hear), "Frank heard footsteps")
end

-- Test conversation check
function testWasConversation()
    local source_event = Event.create_event(Event.TYPE.ACTION, {"John", "waved", "hello"}, 8000, "Street")
    local conversation = Event.create_event(Event.TYPE.DIALOGUE, {"John", "Hello!"}, 8001, "Street", {}, source_event)
    local non_conversation = Event.create_event(Event.TYPE.ACTION, {"John", "walked", "away"}, 8002, "Street")

    luaunit.assertTrue(Event.was_conversation(conversation))
    luaunit.assertFalse(Event.was_conversation(non_conversation))
end

-- Test was_witnessed_by function
function testWasWitnessedBy()
    local witness1 = {game_id = "1"}
    local witness2 = {game_id = "2"}
    local event = Event.create_event(Event.TYPE.ACTION, {"John", "picked up", "a sword"}, 1000, "Forest", {witness1, witness2})

    luaunit.assertTrue(Event.was_witnessed_by(event, "1"))
    luaunit.assertTrue(Event.was_witnessed_by(event, "2"))
    luaunit.assertFalse(Event.was_witnessed_by(event, "Charlie"))
end

-- Run tests
os.exit(luaunit.LuaUnit.run())