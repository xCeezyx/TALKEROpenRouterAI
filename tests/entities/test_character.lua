-- Requires
local luaunit = require('tests.utils.luaunit')
local assert_or_record = require("tests.utils.assert_or_record")

local Character = require('domain.model.Character')

-- Test Character creation
function testCharacterCreation()
    local char = Character.new("1", "John Doe", "Veteran", "Warrior")
    luaunit.assertEquals(char.game_id, "1")
    luaunit.assertEquals(char.name, "John Doe")
    luaunit.assertEquals(char.experience, "Veteran")
    luaunit.assertEquals(char.faction, "Warrior")
end

-- Test Character description method with dynamic personality incorporation
function testCharacterDescription()
    local char = Character.new(1, "John Doe", "Veteran", "Warrior")

    -- Get the description from the character object
    local description = Character.describe(char)

    -- Pattern to validate: must contain the character's name followed by some description with keywords
    local expected_pattern = "^John Doe, a .* Veteran Warrior$"

    -- Assert description matches the expected pattern
    luaunit.assertStrMatches(description, expected_pattern)
end

-- Run tests
os.exit(luaunit.LuaUnit.run())