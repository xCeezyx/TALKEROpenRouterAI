-- test_pick_potential_speakers.lua
local luaunit = require('tests.utils.luaunit')
local transformations = require('infra.AI.transformations')

local function mock_event(witnesses)
    return { witnesses = witnesses }
end

-- Global mocks
mockgame = {
    get_distance_to_player = function(game_id)
        return mock_distance_map[game_id] or 0
    end,

    is_player = function(character_id)
        print("mocking game")
        return tostring(character_id) == "player"
    end
}

transformations.mockGame(mockgame)

----------------------------------------------------------------------------------------------------
-- Test Suite: pick_potential_speakers
----------------------------------------------------------------------------------------------------

TestPreprocessWitnesses = {}

function TestPreprocessWitnessessetUp()
    dummy_compress_called = false
end

function TestPreprocessWitnessestestOnlyPlayerNear()
    -- GIVEN: Only the player and one distant NPC are witnesses
    local recent_events = {
        mock_event({
            { game_id = "player" },
            { game_id = "npc1" }
        })
    }
    mock_distance_map = {
        ["player"] = 2,
        ["npc1"] = 200
    }

    -- WHEN: pick_potential_speakers is called
    local result = transformations.pick_potential_speakers(recent_events)

    -- THEN: No witnesses are returned and compress_memories is not called
    luaunit.assertEquals(result, {})
end

function TestPreprocessWitnessestestOneValidNPCNear()
    -- GIVEN: One player and one nearby NPC
    local recent_events = {
        mock_event({
            { game_id = "player" },
            { game_id = "npc1" }
        })
    }
    mock_distance_map = {
        ["player"] = 2,
        ["npc1"] = 5
    }

    -- WHEN: pick_potential_speakers is called
    local result = transformations.pick_potential_speakers(recent_events)

    -- THEN: compress_memories is called with npc1 and no list is returned
    luaunit.assertEquals(result[1], recent_events[1].witnesses[1])
end

function TestPreprocessWitnessestestMultipleNPCsNear()
    -- GIVEN: Player and two nearby NPCs
    local recent_events = {
        mock_event({
            { game_id = "player" },
            { game_id = "npc1" },
            { game_id = "npc2" }
        })
    }
    mock_distance_map = {
        ["player"] = 2,
        ["npc1"] = 5,
        ["npc2"] = 8
    }

    -- WHEN: pick_potential_speakers is called
    local result = transformations.pick_potential_speakers(recent_events)

    -- THEN: All three witnesses are returned
    luaunit.assertIsTable(result)
    luaunit.assertEquals(#result, 2)
end

----------------------------------------------------------------------------------------------------
-- Test Suite: select_old_memories_for_compression
----------------------------------------------------------------------------------------------------

function testCompressMemoriesUnderThreshold()
    -- GIVEN: Memory list smaller than compression threshold
    local memories = {
        { text = "A" }, { text = "B" }, { text = "C" }
    }

    -- WHEN: selecting old memories for compression
    local result = transformations.select_old_memories_for_compression(memories)

    -- THEN: No memories are selected
    luaunit.assertIsTable(result)
    luaunit.assertEquals(#result, 0)
end

function testCompressMemoriesExactlyThreshold()
    -- GIVEN: Memory list exactly at compression threshold
    local memories = {
        { text = "A" }, { text = "B" }, { text = "C" },
        { text = "D" }, { text = "E" }
    }

    -- WHEN: selecting old memories for compression
    local result = transformations.select_old_memories_for_compression(memories)

    -- THEN: No memories are selected
    luaunit.assertEquals(#result, 0)
end

function testCompressMemoriesAboveThreshold()
    -- GIVEN: Memory list larger than compression threshold
    local memories = {
        { id = 1 }, { id = 2 }, { id = 3 },
        { id = 4 }, { id = 5 }, { id = 6 }, { id = 7 },
        { id = 8 }, { id = 9 }, { id = 10 }, { id = 11 }
    }

    -- WHEN: selecting old memories for compression
    local result = transformations.select_old_memories_for_compression(memories)

    -- THEN: The oldest N memories are selected, leaving out the latest 3
    luaunit.assertEquals(#result, 8)
    luaunit.assertEquals(result[1].id, 1)
    luaunit.assertEquals(result[8].id, 8)
end

os.exit(luaunit.LuaUnit.run())
