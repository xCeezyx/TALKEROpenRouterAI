-- Adjust the package path
package.path = package.path .. ';./bin/lua/?.lua;./bin/lua/*/?.lua'

-- Require LuaUnit, memories module, and event_store module
local luaunit = require('tests.utils.luaunit')
local event_store = require('domain.repo.event_store')
local memory_store = require('domain.repo.memory_store')

-- Helper function to create mock events with a 'was_witnessed_by' method
local function create_mock_event(game_time_ms, witnesses)
    return {
        description = "Mock Event",
        objects = {},
        game_time_ms = game_time_ms,
        world_context = "Somewhere",
        witnesses = witnesses or {},
        source_event = nil
    }
end

-- Setup function to reset the state before each test
function setup()
    -- Reset the event_store and compressed_memories
    package.loaded['event_store'] = nil
    event_store = require('domain.repo.event_store')
    package.loaded['memories'] = nil
    memory_store = require('domain.repo.memory_store')
end

-- Test adding a memory for a character and retrieving it
function testAddMemoryForCharacter()
    local character_id = 'char_1'
    local content = 'This is a memory content'
    local character_id = 'char_1'

    memory_store:store_compressed_memory(character_id, content, 0)

    local compressed = memory_store:get_compressed_memories(character_id)

    luaunit.assertNotNil(compressed)
    luaunit.assertEquals(#compressed, 1)
    luaunit.assertEquals(compressed[1].content, content)
    luaunit.assertEquals(compressed[1].game_time_ms, 0)
end

-- Test getting memories for a character based on witnessed events
function testGetMemoriesForCharacterId()
    -- Create events with witnesses
    local event1 = create_mock_event(1000, {{game_id = 'char_1'}, {game_id = 'char_2'}})
    local event2 = create_mock_event(2000, {{game_id = 'char_2'}})
    local event3 = create_mock_event(3000, {{game_id = 'char_1'}, {game_id = 'char_3'}})

    event_store:store_event(event1)
    event_store:store_event(event2)
    event_store:store_event(event3)

    local memories_char1 = memory_store:get_memories('char_1')

    luaunit.assertEquals(#memories_char1, 2)
    luaunit.assertEquals(memories_char1[1], event1)
    luaunit.assertEquals(memories_char1[2], event3)

    local memories_char2 = memory_store:get_memories('char_2')
    luaunit.assertEquals(#memories_char2, 2)
    luaunit.assertEquals(memories_char2[1], event1)
    luaunit.assertEquals(memories_char2[2], event2)

    local memories_char3 = memory_store:get_memories('char_3')
    luaunit.assertEquals(#memories_char3, 1)
    luaunit.assertEquals(memories_char3[1], event3)

    local memories_char4 = memory_store:get_memories('char_4')
    luaunit.assertEquals(#memories_char4, 0)
end

-- Test getting compressed memories for a character
function testGetCompressedMemories()
    local character_id = 'char_1'

    memory_store:store_compressed_memory(character_id, 'Memory 1', 0)
    memory_store:store_compressed_memory(character_id, 'Memory 2', 1)
    memory_store:store_compressed_memory(character_id, 'Memory 3', 2)

    local compressed = memory_store:get_compressed_memories(character_id)
    luaunit.assertEquals(#compressed, 3)
    luaunit.assertEquals(compressed[1].content, 'Memory 1')
    luaunit.assertEquals(compressed[2].content, 'Memory 2')
    luaunit.assertEquals(compressed[3].content, 'Memory 3')
end

-- Test getting uncompressed memories since the last compression
function testGetUncompressedMemoriesSinceLastCompression()
    local character_1 = {game_id = 'char_1'}

    -- Add compressed memories
    memory_store:store_compressed_memory(character_1.game_id, 'Compressed Memory 1', 500)

    -- Create events that the character witnessed, before and after the last compressed memory time
    local event1 = create_mock_event(1000, {character_1})
    local event2 = create_mock_event(1600, {character_1})
    local event3 = create_mock_event(2500, {character_1})
    local event4 = create_mock_event(3000, {character_1})

    event_store:store_event(event1)
    event_store:store_event(event2)
    memory_store:store_compressed_memory(character_1.game_id, 'Compressed Memory 2', 1600)
    event_store:store_event(event3)
    event_store:store_event(event4)

    local uncompressed_memories = memory_store:get_new_memories(character_1.game_id)

    -- Last compressed memory time is 2000 (from 'Compressed Memory 2')
    -- So events after 2000 should be included

    luaunit.assertEquals(#uncompressed_memories, 2)
    luaunit.assertNotEquals(uncompressed_memories[1], event4, 'wrong')
    luaunit.assertEquals(uncompressed_memories[1], event3, 'first event wrong')
    luaunit.assertEquals(uncompressed_memories[2], event4, 'second event wrong')
    luaunit.assertEquals(uncompressed_memories[2], event4)
end

-- Test getting new and compressed memories ready for dialogue generation
function testGetAllMemories()
    print("testing get all memories")
    local character_1 = {game_id = 'char_1'}

    -- Add compressed memories
    memory_store:store_compressed_memory(character_1.game_id, 'Compressed Memory 1', 500)

    -- Create events that the character witnessed, before and after the last compressed memory time
    local event1 = create_mock_event(1000, {character_1})
    local event2 = create_mock_event(1600, {character_1})
    local event3 = create_mock_event(2500, {character_1})
    local event4 = create_mock_event(3000, {character_1})

    event_store:store_event(event1)
    event_store:store_event(event2)
    memory_store:store_compressed_memory(character_1.game_id, 'Compressed Memory 2', 1600)
    event_store:store_event(event3)
    event_store:store_event(event4)

    local dialogue_memories = memory_store:get_all_memories(character_1.game_id)
    luaunit.assertEquals(#dialogue_memories, 4)
    luaunit.assertEquals(dialogue_memories[1].content, 'Compressed Memory 1', 'first event wrong')
    luaunit.assertEquals(dialogue_memories[2].content, 'Compressed Memory 2', 'second event wrong')
    luaunit.assertEquals(dialogue_memories[3], event3)
    luaunit.assertEquals(dialogue_memories[3], event3)
end



-- Run the tests
os.exit(luaunit.LuaUnit.run())