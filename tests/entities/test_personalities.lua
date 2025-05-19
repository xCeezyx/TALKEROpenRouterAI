-- Import required modules
local luaunit = require('tests.utils.luaunit')

-- Import the personality module
local M = require('domain.repo.personalities')

local mock_characters = require('tests.mocks.mock_characters')
-- Helper function to create a mock characte

-- Test cases
function testGetPersonality()
    -- Setup: Assume a character with a pre-assigned personality
    local character = mock_characters[001]
    -- Test: Retrieve the personality
    local result = M.get_personality(character)
    local result2 = M.get_personality(character)
    luaunit.assertEquals(result, result2)
end

-- Run tests
os.exit(luaunit.run())