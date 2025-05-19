package.path = package.path .. ';./bin/lua/?.lua;./bin/lua/*/?.lua'
local luaunit = require('tests.utils.luaunit')
local assert_or_record = require("tests.utils.assert_or_record")
package.path = package.path .. ';./gamedata/scripts/?.script'

----------------------------------------------------------------------------------------------------
-- Mocks
----------------------------------------------------------------------------------------------------

local interface = {
    register_game_event = function(unformatted_description, event_objects, witnesses)
        local event_data = {
            unformatted_description, event_objects, witnesses
        }
        assert_or_record('triggers', 'testTriggerReload', event_data)
    end
}

talker_game_queries = {}

function talker_game_queries.get_game_time_ms()
    return 0
end
function talker_game_queries.is_living_character(obj)
    return true
end
function talker_game_queries.is_in_combat(npc)
    return false
end

require('talker_trigger_callout')

----------------------------------------------------------------------------------------------------
-- Test event on player reload
----------------------------------------------------------------------------------------------------

function testTriggerCallout()
    on_enemy_eval()
end



os.exit(luaunit.LuaUnit.run())