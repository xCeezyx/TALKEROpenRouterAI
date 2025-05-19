local luaunit = require('tests.utils.luaunit')
local memory_store = require('domain.repo.memory_store')
local event_store = require('tests.mocks.mock_event_store')
package.path = package.path .. ';./gamedata/scripts/?.script'
require('talker_game_persistence')

local function save_data()
    -- Initialize with known states for predictability
    memory_store:store_compressed_memory("character_id", "Memory 1", 5)
    local saved_data = {}
    save_state(saved_data)
    return saved_data
end

function testSaveState()
    local saved_data = save_data()

    luaunit.assertNotNil(saved_data.compressed_memories)
    luaunit.assertNotNil(saved_data.events)
end

function testLoadState()
    local saved_data = save_data()
    local events = event_store:get_all_events()
    local character_memories = memory_store:get_compressed_memories("character_id")
    
    -- Empty both repos
    memory_store:clear()
    event_store:clear()

    luaunit.assertEquals(memory_store:get_compressed_memories("character_id"), {})
    luaunit.assertEquals(event_store:get_all_events(), {})

    load_state(saved_data)

    luaunit.assertEquals(memory_store:get_compressed_memories("character_id"), character_memories)
    luaunit.assertEquals(event_store:get_all_events(), events)
end

os.exit(luaunit.LuaUnit.run())